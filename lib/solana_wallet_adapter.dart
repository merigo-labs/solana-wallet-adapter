/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solana_common/config/cluster.dart';
import 'package:solana_common/exceptions/json_rpc_exception.dart';
import 'package:solana_common/utils/library.dart';
import 'package:solana_web3/solana_web3.dart';
import 'package:synchronized/synchronized.dart';
import 'association/association.dart';
import 'exceptions/solana_wallet_adapter_exception.dart';
import 'exceptions/solana_wallet_adapter_protocol_exception.dart';
import 'models/index.dart';
import 'protocol/wallet_adapter_connection.dart';
import 'scenarios/local_association_scenario.dart';
import 'scenarios/remote_association_scenario.dart';
import 'scenarios/scenario.dart';
import 'storage/wallet_adapter_state.dart';
import 'storage/wallet_adapter_storage.dart';
import 'utils/types.dart';


/// Exports
/// ------------------------------------------------------------------------------------------------

export 'package:solana_common/config/cluster.dart';
export 'package:solana_common/exceptions/json_rpc_exception.dart';
export 'package:solana_common/utils/types.dart';
export 'association/association.dart' show AssociationType;
export 'exceptions/solana_wallet_adapter_exception.dart';
export 'exceptions/solana_wallet_adapter_protocol_exception.dart';
export 'models/index.dart';


/// Solana Wallet Adapter
/// ------------------------------------------------------------------------------------------------

class SolanaWalletAdapter {

  /// {@template solana_wallet_adapter.SolanaWalletAdapter}
  /// Authorizes a dApp for use with a wallet endpoint that implements the 
  /// [Mobile Wallet Adapter Specification](https://solana-mobile.github.io/mobile-wallet-adapter/spec/spec.html).
   /// {@endtemplate}
  SolanaWalletAdapter(
    this.identity, {
    this.cluster,
    this.hostAuthority,
  });

  /// The plugin's package name.
  static const String packageName = 'solana_wallet_adapter';

  /// Prevent multiple connections by a dApp to a wallet endpoint (see: [_useScenario]).
  static final Lock _sessionLock = Lock();

  /// The authorization state of the dApp. A dApp can be authorized for use with a single wallet 
  /// endpoint at any one time.
  static final _storage = WalletAdapterStorage();

  /// The dApp's identity information used by the wallet to verify the dApp making the requests.
  final Identity identity;

  /// The Solana cluster the dApp endpoint intends to interact with (default: [Cluster.mainnet]).
  final Cluster? cluster;

  /// {@template solana_wallet_adapter.hostAuthority}
  /// The address of a publicly routable web socket server implementing the reflector protocol to 
  /// establish a remote connection with a wallet running on another device.
  /// {@endtemplate}
  final String? hostAuthority;

  /// The authorisation state.
  WalletAdapterState? get state => _storage.state;

  /// {@template solana_wallet_adapter.authorizeResult}
  /// The latest authorisation result of an `authorize` or `reauthorize` request.
  /// {@endtemplate}
  AuthorizeResult? get authorizeResult => _storage.authorizeResult;

  /// {@template solana_wallet_adapter.feePayerAccount}
  /// The fee payer wallet account.
  /// {@endtemplate}
  Account? get feePayerAccount => _storage.feePayerAccount;

  /// {@template solana_wallet_adapter.isAuthorized}
  /// True if the dApp has been authorized.
  /// {@endtemplate}
  bool get isAuthorized => authorizeResult != null;

  /// Reauthorize exception for an invalid auth token.
  SolanaWalletAdapterException get reauthorizeException 
    => const SolanaWalletAdapterException(
      'reauthorize() invalid auth token, request a new token with the authorize method.',
      code: SolanaWalletAdapterExceptionCode.secureContextRequired,
    );

  /// Clone authorize exception for an invalid auth token.
  SolanaWalletAdapterException get cloneAuthorizationException 
    => const SolanaWalletAdapterException(
      'cloneAuthorization() requires the current session to be in an authorized state.',
      code: SolanaWalletAdapterExceptionCode.secureContextRequired,
    );

  /// Initializes [state].
  /// 
  /// This should be called at the start of your application.
  static Future<void> initialize() => _storage.initialize();

  /// Registers [listener] to be called when the authorization state changes.
  void addListener(final VoidCallback listener) => _storage.notifier.addListener(listener);

  /// Unregisters [listener] to stop being called when the authorization state changes.
  void removeListener(final VoidCallback listener) => _storage.notifier.removeListener(listener);

  /// Set [account] to be the default fee payer.
  Future<bool> setFeePayerAccount(final Account? account) => _storage.setFeePayerAccount(account);

  /// {@macro solana_wallet_adapter.authorize}
  /// 
  /// The authorization [_storage] is set to the latest result ([AuthorizeResult]).
  /// 
  /// The operation is performed over a secure [connection].
  Future<AuthorizeResult> authorizeHandler(
    final WalletAdapterConnection connection,
  ) async { 
    final AuthorizeParams params = AuthorizeParams(identity: identity, cluster: cluster);
    final AuthorizeResult result = await connection.authorize(params);
    await _storage.setAuthorizeResult(result);
    return result;
  }

  /// {@template solana_wallet_adapter.authorize}
  /// This method allows the dApp endpoint to request authorization from the wallet endpoint for 
  /// access to `privileged methods`. On success, it returns an [AuthorizeResult.authToken] 
  /// providing access to privileged methods, along with addresses and optional labels for all 
  /// authorized accounts. It may also return a URI suitable for future use as an 
  /// `endpoint-specific URI`. After a successful call to [authorize], the current session will be 
  /// placed into an authorized state, with privileges associated with the returned 
  /// [AuthorizeResult.authToken]. On failure, the current session with be placed into the 
  /// unauthorized state.
  /// 
  /// This [AuthorizeResult.authToken] may be used to [reauthorize] future sessions between the 
  /// dApp and wallet endpoint.
  /// {@endtemplate}
  Future<AuthorizeResult> authorize({
    final AssociationType? type,
  }) => association(type, authorizeHandler);

  /// {@macro solana_wallet_adapter.deauthorize}
  /// 
  /// The authorization [_storage] is cleared for the deauthorized auth token.
  /// 
  /// The operation is performed over a secure [connection].
  Future<DeauthorizeResult> deauthorizeHandler(
    final WalletAdapterConnection connection,
    final AuthToken authToken,
  ) async { 
    final DeauthorizeParams params = DeauthorizeParams(authToken: authToken);
    final DeauthorizeResult result = await connection.deauthorize(params);
    await _storage.clearAuthorizeResult(authToken: authToken);
    return result;
  }

  /// {@template solana_wallet_adapter.deauthorize}
  /// Revokes the dApp's authroization from the wallet endpoint.
  /// {@endtemplate}
  Future<DeauthorizeResult> deauthorize({
    final AssociationType? type,
  }) async {
    final AuthorizeResult? result = authorizeResult;
    return result != null
      ? association(type, (connection) => deauthorizeHandler(connection, result.authToken))
      : Future.value(const DeauthorizeResult());   
  }

  /// {@macro solana_wallet_adapter.reauthorize}
  /// 
  /// The operation is performed over a secure [connection].
  Future<AuthorizeResult> reauthorizeHandler(
    final WalletAdapterConnection connection,
    final AuthToken authToken,
  ) async { 
    final ReauthorizeParams params = ReauthorizeParams(identity: identity, authToken: authToken);
    final ReauthorizeResult result = await connection.reauthorize(params);
    await _storage.setAuthorizeResult(result);
    return result;
  }

  /// {@template solana_wallet_adapter.reauthorize}
  /// Requests dApp reauthorization with the wallet endpoint to put the current session in an 
  /// authorized state.
  /// {@endtemplate}
  Future<AuthorizeResult> reauthorize({
    final AssociationType? type,
  }) async {
    final AuthToken? authToken = authorizeResult?.authToken;
    return authToken != null
      ? association(type, (connection) => reauthorizeHandler(connection, authToken))
      : Future.error(reauthorizeException);
  }

  /// {@macro solana_wallet_adapter.reauthorizeOrAuthorize}
  /// 
  /// A `reauthorize` request is made if [_storage] contains an auth token. An `authorize` request 
  /// is made if the [_storage] does not contain an auth token or a `reauthorize request fails with 
  /// a [SolanaWalletAdapterProtocolExceptionCode.authorizationFailed] code.
  /// 
  /// The operation is performed over a secure [connection].
  Future<AuthorizeResult> reauthorizeOrAuthorizeHandler(
    final WalletAdapterConnection connection,
  ) async {
    final AuthorizeResult? result = authorizeResult;
    if (result != null) {
      try {
        return await reauthorizeHandler(connection, result.authToken);
      } on JsonRpcException catch(error) {
        if (error.code != SolanaWalletAdapterProtocolExceptionCode.authorizationFailed) {
          rethrow;
        }
      }
    }
    return authorizeHandler(connection);
  }

  /// {@template solana_wallet_adapter.reauthorizeOrAuthorize}
  /// Requests dApp `reauthorization/authorization` based on the current state.
  /// {@endtemplate}
  Future<AuthorizeResult> reauthorizeOrAuthorize({
    final AssociationType? type,
  }) => association(type, (connection) => reauthorizeOrAuthorizeHandler(connection));

  /// {@template solana_wallet_adapter.getCapabilities}
  /// Gets the limits of a wallet endpoint’s implementation of the specification. It returns whether 
  /// optional specification features are supported, as well as any implementation-specific limits.
  /// {@endtemplate}
  Future<GetCapabilitiesResult> getCapabilities({
    final AssociationType? type,
  }) => association(type, (connection) => connection.getCapabilities());

  /// {@macro solana_wallet_adapter.signTransactions}
  /// 
  /// The operation is performed over a secure [connection].
  Future<SignTransactionsResult> signTransactionsHandler(
    final WalletAdapterConnection connection, {
    required final List<Base64EncodedTransaction> transactions,
    final AssociationType? type,
  }) async {
    return connection.signTransactions(
      SignTransactionsParams(
        payloads: transactions,
      ),
    );
  }

  /// {@template solana_wallet_adapter.signTransactions}
  /// Invokes the wallet endpoint to simulate the [transactions] and present them to the user for 
  /// approval (if applicable). If approved (or if it does not require approval), the wallet 
  /// endpoint should sign the transactions with the private keys for the requested authorized 
  /// account addresses, and return the signed transactions to the dapp endpoint.
  /// {@endtemplate}
  Future<SignTransactionsResult> signTransactions({
    required final List<Base64EncodedTransaction> transactions,
    final AssociationType? type,
  }) => association(type, (connection) => signTransactionsHandler(
      connection, 
      transactions: transactions,
    ));

  /// {@macro solana_wallet_adapter.signAndSendTransactions}
  /// 
  /// The operation is performed over a secure [connection].
  Future<SignAndSendTransactionsResult> signAndSendTransactionsHandler(
    final WalletAdapterConnection connection, {
    required final List<Base64EncodedTransaction> transactions,
    final SignAndSendTransactionsConfig? config,
  }) async {
    return connection.signAndSendTransactions(
      SignAndSendTransactionsParams(
        payloads: transactions,
        options: config ?? const SignAndSendTransactionsConfig(),
      ),
    );
  }

  /// {@template solana_wallet_adapter.signAndSendTransactions}
  /// `Implementation of this method by a wallet endpoint is optional.`
  /// 
  /// Invokes the wallet endpoint to simulate the transactions provided by [transactions] and 
  /// present them to the user for approval (if applicable). If approved (or if it does not require 
  /// approval), the wallet endpoint should verify the transactions, sign them with the private keys 
  /// for the authorized addresses, submit them to the network, and return the transaction 
  /// signatures to the dapp endpoint. A `null` transaction signature indicates failure.
  /// 
  /// The [config] object allows customization of how the wallet endpoint processes the transactions 
  /// it sends to the Solana network. If specified, [SignAndSendTransactionsConfig.minContextSlot] 
  /// specifies the minimum slot number that the transactions should be evaluated at. This allows 
  /// the wallet endpoint to wait for its network RPC node to reach the same point in time as the 
  /// node used by the dApp endpoint, ensuring that, e.g., the recent blockhash encoded in the 
  /// transactions will be available.
  /// {@endtemplate}
  Future<SignAndSendTransactionsResult> signAndSendTransactions({
    required final List<Base64EncodedTransaction> transactions,
    final SignAndSendTransactionsConfig? config,
    final AssociationType? type,
  }) => association(type, (connection) => signAndSendTransactionsHandler(
      connection, 
      transactions: transactions,
    ));

  /// {@macro solana_wallet_adapter.signMessages}
  /// 
  /// The operation is performed over a secure [connection].
  Future<SignMessagesResult> signMessagesHandler(
    final WalletAdapterConnection connection, {
    required final List<Base64EncodedMessage> messages,
    required final List<Base64EncodedAddress> addresses,
  }) async {
    return connection.signMessages(
      SignMessagesParams(
        addresses: addresses,
        payloads: messages,
      ),
    );
  }

  /// {@template solana_wallet_adapter.signMessages}
  /// Invokes the wallet endpoint to present the provided messages to the user for approval. If 
  /// approved, the wallet endpoint should sign the messages with the private key for the authorized 
  /// account address, and return the signed messages to the dApp endpoint. 
  /// 
  /// The signatures should be appended to the message, in the same order as addresses.
  /// {@endtemplate}
  Future<SignMessagesResult> signMessages({
    required final List<Base64EncodedMessage> messages,
    required final List<Base64EncodedAddress> addresses,
    final AssociationType? type,
  }) => association(type, (connection) => signMessagesHandler(
      connection,
      messages: messages, 
      addresses: addresses,
    ));

  /// {@macro solana_wallet_adapter.cloneAuthorization}
  /// 
  /// The operation is performed over a secure [connection].
  Future<CloneAuthorizationResult> cloneAuthorizationHandler(
    final WalletAdapterConnection connection,
    final AuthToken authToken,
  ) async {
    await reauthorizeHandler(connection, authToken);
    return connection.cloneAuthorization();
  }

  /// {@template solana_wallet_adapter.cloneAuthorization}
  /// `Implementation of this method by a wallet endpoint is optional.`
  /// 
  /// Attempts to clone the session’s currently active authorization in a form suitable for sharing 
  /// with another instance of the dApp endpoint, possibly running on a different system. Whether or 
  /// not the wallet endpoint supports cloning an auth_token is an implementation detail. If this 
  /// method succeeds, it will return an auth token appropriate for sharing with another instance of 
  /// the same dApp endpoint.
  /// {@endtemplate}
  Future<CloneAuthorizationResult> cloneAuthorization({
    final AssociationType? type,
  }) async {
    final AuthToken? authToken = authorizeResult?.authToken;
    return authToken != null
      ? association(type, (connection) => cloneAuthorizationHandler(connection, authToken))
      : Future.error(cloneAuthorizationException);
  }

  /// Runs [callback] for the provided [scenario], then disposes of it. A [scenario] can only be 
  /// used once.
  Future<T> _useScenario<T>(
    final Scenario scenario,
    final Future<T> Function(WalletAdapterConnection connection) callback, 
  ) async {
    try {
      final Uri? walletUriBase = authorizeResult?.walletUriBase;
      return await _sessionLock.synchronized(
        timeout: Duration.zero,
        () => scenario.run<T>(
          callback, 
          walletUriBase: walletUriBase,
        ),
      );
    } finally {
      scenario.dispose();
    }
  }

  /// Creates a new association with a wallet endpoint for the provided [type] and runs [callback] 
  /// inside an encrypted session.
  Future<T> association<T>(
    final AssociationType? type,
    final Future<T> Function(WalletAdapterConnection connection) callback, 
  ) => type != AssociationType.remote
      ? localAssociation(callback)
      : remoteAssociation(hostAuthority, callback);

  /// Creates a new association with a `local` wallet endpoint and runs [callback] inside an 
  /// encrypted session.
  Future<T> localAssociation<T>(
    final Future<T> Function(WalletAdapterConnection connection) callback,
  ) => _useScenario(LocalAssociationScenario(), callback);

  /// Creates a new association with a `remote` wallet endpoint and runs [callback] inside an 
  /// encrypted session.
  /// 
  /// [hostAuthority] is the web socket server that brokers communication between the dApp and 
  /// the remote wallet endpoint. 
  Future<T> remoteAssociation<T>(
    final String? hostAuthority,
    final Future<T> Function(WalletAdapterConnection connection) callback,
  ) {
    check(hostAuthority != null, '[hostAuthority] cannot be null for [AssociationType.remote].');
    return _useScenario(RemoteAssociationScenario(hostAuthority!), callback);
  }
}