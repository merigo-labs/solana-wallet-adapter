/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'dart:ui';
import 'package:solana_common/config/cluster.dart';
import 'package:solana_wallet_adapter_platform_interface/solana_wallet_adapter_platform_interface.dart';


/// Exports
/// ------------------------------------------------------------------------------------------------

export 'package:solana_common/config/cluster.dart';
export 'package:solana_common/exceptions/json_rpc_exception.dart';
export 'package:solana_common/utils/convert.dart';
export 'package:solana_common/utils/types.dart';
export 'package:solana_wallet_adapter_platform_interface/solana_wallet_adapter_platform_interface.dart';


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
  
  /// The dApp's identity information used by the wallet to verify the dApp making the requests.
  final AppIdentity identity;

  /// The Solana cluster the dApp endpoint intends to interact with.
  final Cluster? cluster;

  /// {@template solana_wallet_adapter.hostAuthority}
  /// The address of a publicly routable web socket server implementing the reflector protocol to 
  /// establish a remote connection with a wallet running on another device.
  /// {@endtemplate}
  final String? hostAuthority;
  
  /// {@template solana_wallet_adapter.isAuthorized}
  /// True if the dApp has been authorized.
  /// {@endtemplate}
  bool get isAuthorized => SolanaWalletAdapterPlatform.instance.authorizeResult != null;

  /// The authorisation state.
  WalletAdapterState? get state => SolanaWalletAdapterPlatform.instance.state;

  /// {@macro solana_wallet_adapter_platform_interface.authorizeResult}
  AuthorizeResult? get authorizeResult => SolanaWalletAdapterPlatform.instance.authorizeResult;

  /// {@macro solana_wallet_adapter_platform_interface.connectedAccount}
  Account? get connectedAccount => SolanaWalletAdapterPlatform.instance.connectedAccount;

  /// {@macro solana_wallet_adapter_platform_interface.initialize}
  static Future<void> initialize() 
    => SolanaWalletAdapterPlatform.instance.initialize();

  /// {@macro solana_wallet_adapter_platform_interface.disconnect}
  static Future<void> disconnect() 
    => SolanaWalletAdapterPlatform.instance.disconnect();

  /// {@macro solana_wallet_adapter_platform_interface.addListener}
  void addListener(
    final VoidCallback listener,
  ) => SolanaWalletAdapterPlatform.instance.addListener(listener);

  /// {@macro solana_wallet_adapter_platform_interface.removeListener}
  void removeListener(
    final VoidCallback listener,
  ) => SolanaWalletAdapterPlatform.instance.removeListener(listener);

  /// {@macro solana_wallet_adapter_platform_interface.setConnectedAccount}
  Future<bool> setConnectedAccount(
    final Account? account,
  ) => SolanaWalletAdapterPlatform.instance.setConnectedAccount(account);

  /// {@macro solana_wallet_adapter_platform_interface.authorizeHandler}
  Future<AuthorizeResult> authorizeHandler(
    final SolanaWalletAdapterConnection connection, {
    final AppIdentity? identity,
    final Cluster? cluster,
  }) => SolanaWalletAdapterPlatform.instance.authorizeHandler(
    connection, 
    identity ?? this.identity, 
    cluster ?? this.cluster,
  );

  /// {@macro solana_wallet_adapter_platform_interface.authorize}
  Future<AuthorizeResult> authorize({
    final AppIdentity? identity,
    final Cluster? cluster,
    final AssociationType? type,
  }) => SolanaWalletAdapterPlatform.instance.authorize(
    identity ?? this.identity,
    cluster ?? this.cluster,
    type: type,
  );
  
  /// {@macro solana_wallet_adapter_platform_interface.deauthorizeHandler}
  Future<DeauthorizeResult> deauthorizeHandler(
    final SolanaWalletAdapterConnection connection,
    final AuthToken authToken,
  ) => SolanaWalletAdapterPlatform.instance.deauthorizeHandler(
    connection, 
    authToken,
  );

  /// {@macro solana_wallet_adapter_platform_interface.deauthorize}
  Future<DeauthorizeResult> deauthorize({
    final AssociationType? type,
    final Uri? walletUriBase,
  }) => SolanaWalletAdapterPlatform.instance.deauthorize(
    type: type,
    walletUriBase: walletUriBase,
  );

  /// {@macro solana_wallet_adapter_platform_interface.reauthorizeHandler}
  Future<AuthorizeResult> reauthorizeHandler(
    final SolanaWalletAdapterConnection connection,
    final String authToken, {
    final AppIdentity? identity,
  }) => SolanaWalletAdapterPlatform.instance.reauthorizeHandler(
    connection, 
    identity ?? this.identity, 
    authToken,
  );

  /// {@macro solana_wallet_adapter_platform_interface.reauthorize}
  Future<AuthorizeResult> reauthorize({
    final AppIdentity? identity,
    final AssociationType? type,
  }) => SolanaWalletAdapterPlatform.instance.reauthorize(
    identity ?? this.identity,
    type: type,
  );

  /// {@macro solana_wallet_adapter_platform_interface.reauthorizeOrAuthorizeHandler}
  Future<AuthorizeResult> reauthorizeOrAuthorizeHandler(
    final SolanaWalletAdapterConnection connection, {
    final AppIdentity? identity,
    final Cluster? cluster,
  }) => SolanaWalletAdapterPlatform.instance.reauthorizeOrAuthorizeHandler(
    connection, 
    identity ?? this.identity, 
    cluster ?? this.cluster,
  );

  /// {@macro solana_wallet_adapter_platform_interface.reauthorizeOrAuthorize}
  Future<AuthorizeResult> reauthorizeOrAuthorize({
    final AppIdentity? identity,
    final Cluster? cluster,
    final AssociationType? type,
  }) => SolanaWalletAdapterPlatform.instance.reauthorizeOrAuthorize(
    identity ?? this.identity,
    cluster ?? this.cluster,
    type: type,
  );

  /// {@macro solana_wallet_adapter_platform_interface.getCapabilitiesHandler}
  Future<GetCapabilitiesResult> getCapabilitiesHandler(
    final SolanaWalletAdapterConnection connection,
  ) => SolanaWalletAdapterPlatform.instance.getCapabilitiesHandler(connection);

  /// {@macro solana_wallet_adapter_platform_interface.getCapabilities}
  Future<GetCapabilitiesResult> getCapabilities({
    final AssociationType? type,
  }) => SolanaWalletAdapterPlatform.instance.getCapabilities(type: type);

  /// {@macro solana_wallet_adapter_platform_interface.signTransactionsHandler}
  Future<SignTransactionsResult> signTransactionsHandler(
    final SolanaWalletAdapterConnection connection, {
    final AppIdentity? identity, 
    required final Iterable<Base64EncodedTransaction> transactions,
    final bool skipReauthorize = false,
  }) => SolanaWalletAdapterPlatform.instance.signTransactionsHandler(
    connection, 
    identity ?? this.identity, 
    transactions: transactions,
    skipReauthorize: skipReauthorize,
  );

  /// {@template solana_wallet_adapter_platform_interface.signTransactions}
  Future<SignTransactionsResult> signTransactions({
    final AppIdentity? identity,
    required final List<Base64EncodedTransaction> transactions,
    final bool skipReauthorize = false,
    final AssociationType? type,
  }) => SolanaWalletAdapterPlatform.instance.signTransactions(
    identity ?? this.identity,
    transactions: transactions,
    skipReauthorize: skipReauthorize,
    type: type,
  );

  /// {@macro solana_wallet_adapter_platform_interface.signAndSendTransactionsHandler}
  Future<SignAndSendTransactionsResult> signAndSendTransactionsHandler(
    final SolanaWalletAdapterConnection connection, {
    final AppIdentity? identity, 
    required final List<Base64EncodedTransaction> transactions,
    final SignAndSendTransactionsConfig? config,
    final bool skipReauthorize = false,
  }) => SolanaWalletAdapterPlatform.instance.signAndSendTransactionsHandler(
    connection, 
    identity ?? this.identity, 
    transactions: transactions,
    config: config,
    skipReauthorize: skipReauthorize,
  );

  /// {@template solana_wallet_adapter_platform_interface.signAndSendTransactions}
  Future<SignAndSendTransactionsResult> signAndSendTransactions({
    final AppIdentity? identity,
    required final List<Base64EncodedTransaction> transactions,
    final SignAndSendTransactionsConfig? config,
    final bool skipReauthorize = false,
    final AssociationType? type,
  }) => SolanaWalletAdapterPlatform.instance.signAndSendTransactions(
    identity ?? this.identity,
    transactions: transactions,
    config: config,
    skipReauthorize: skipReauthorize,
    type: type,
  );

  /// {@macro solana_wallet_adapter_platform_interface.signMessagesHandler}
  Future<SignMessagesResult> signMessagesHandler(
    final SolanaWalletAdapterConnection connection, {
    final AppIdentity? identity, 
    required final List<Base64EncodedMessage> messages,
    required final List<Base64EncodedAddress> addresses,
    final bool skipReauthorize = false,
  }) => SolanaWalletAdapterPlatform.instance.signMessagesHandler(
    connection, 
    identity ?? this.identity, 
    messages: messages, 
    addresses: addresses,
    skipReauthorize: skipReauthorize,
  );

  /// {@template solana_wallet_adapter_platform_interface.signMessages}
  Future<SignMessagesResult> signMessages({
    final AppIdentity? identity,
    required final List<Base64EncodedMessage> messages,
    required final List<Base64EncodedAddress> addresses,
    final bool skipReauthorize = false,
    final AssociationType? type,
  }) => SolanaWalletAdapterPlatform.instance.signMessages(
    identity ?? this.identity,
    messages: messages,
    addresses: addresses,
    skipReauthorize: skipReauthorize,
    type: type,
  );

  /// {@macro solana_wallet_adapter_platform_interface.cloneAuthorization}
  Future<CloneAuthorizationResult> cloneAuthorizationHandler(
    final SolanaWalletAdapterConnection connection, 
    final AuthToken authToken, { 
    final AppIdentity? identity,
    final bool skipReauthorize = false,
  }) => SolanaWalletAdapterPlatform.instance.cloneAuthorizationHandler(
    connection, 
    identity ?? this.identity, 
    authToken,
    skipReauthorize: skipReauthorize,
  );
  
  /// {@template solana_wallet_adapter_platform_interface.cloneAuthorization}
  Future<CloneAuthorizationResult> cloneAuthorization({
    final AppIdentity? identity,
    final bool skipReauthorize = false,
    final AssociationType? type,
  }) => SolanaWalletAdapterPlatform.instance.cloneAuthorization(
    identity ?? this.identity,
    skipReauthorize: skipReauthorize,
    type: type,
  );

  /// Creates a new association with a wallet endpoint for the provided [type] and runs [callback] 
  /// inside an encrypted session.
  /// 
  /// if [type] is omitted a local association is attempted before attempting a remote association 
  /// with [hostAuthority] if provided.
  Future<T> association<T>(
    final AssociationCallback<T> callback, {
    final AssociationType? type,
    final String? hostAuthority,
    final Duration? timeout,
    final Uri? walletUriBase,
    final String? scheme,
  }) async {
    switch (type) {
      case null:
      case AssociationType.local:
        return localAssociation(
          callback, 
          timeout: timeout, 
          walletUriBase: walletUriBase, 
          scheme: scheme,
        );
      case AssociationType.remote:
        return remoteAssociation(
          hostAuthority ?? this.hostAuthority, 
          callback, 
          timeout: timeout, 
          walletUriBase: walletUriBase, 
          scheme: scheme,
        );
    }
  }

  /// Creates a new association with a `local` wallet endpoint and runs [callback] inside an 
  /// encrypted session.
  Future<T> localAssociation<T>(
    final AssociationCallback<T> callback, {
    final Duration? timeout,
    final Uri? walletUriBase,
    final String? scheme,
  }) => SolanaWalletAdapterPlatform.instance.localAssociation(
    callback,
    timeout: timeout,
    walletUriBase: walletUriBase,
    scheme: scheme,
  );

  /// Creates a new association with a `remote` wallet endpoint and runs [callback] inside an 
  /// encrypted session.
  /// 
  /// [hostAuthority] is the web socket server that brokers communication between the dApp and 
  /// the remote wallet endpoint. 
  Future<T> remoteAssociation<T>(
    final String? hostAuthority,
    final AssociationCallback<T> callback, {
    final Duration? timeout,
    final Uri? walletUriBase,
    final String? scheme,
  }) => SolanaWalletAdapterPlatform.instance.remoteAssociation(
    hostAuthority,
    callback,
    timeout: timeout,
    walletUriBase: walletUriBase,
    scheme: scheme,
  );
}