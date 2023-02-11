/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solana_common/extensions/future.dart';
import 'package:solana_common/models/serializable.dart';
import 'package:solana_common/protocol/json_rpc_request.dart';
import 'package:solana_common/protocol/json_rpc_request_config.dart';
import 'package:solana_common/protocol/json_rpc_response.dart';
import 'package:solana_common/utils/library.dart';
import 'package:solana_common/web_socket/solana_web_socket_connection.dart';
import 'package:solana_common/web_socket/web_socket_exchange_manager.dart';
import '../association/association.dart';
import '../crypto/association_token.dart';
import '../models/call_method.dart';
import '../models/hello_result.dart';
import '../models/method.dart';
import '../protocol/wallet_adapter_session.dart';
import '../../solana_wallet_adapter.dart';


/// Scenario
/// ------------------------------------------------------------------------------------------------

abstract class Scenario extends SolanaWebSocketConnection with WalletAdapterConnection {

  /// Provides [Scenario.run], which creates a secure session to execute method calls between the 
  /// dApp and wallet enpoints.
  Scenario(
    this.association, {
    super.maxAttempts,
    super.backoffSchedule,
    super.protocols, 
  }): session = WalletAdapterSession();

  /// The scenario's [Association] information.
  final Association association;

  /// The session keys.
  @protected
  final WalletAdapterSession session;

  /// The request queue.
  Iterable<WebSocketExchange> get _queue => webSocketExchangeManager.values;

  /// True if [dispose] has been called.
  bool _disposed = false;
  
  /// Disposes of all the acquired resources:
  /// * Disconnect web socket.
  /// * Discard session keys.
  /// * Close UI.
  @override
  Future<void> dispose([final Object? error, final StackTrace? stackTrace]) {
    if (!_disposed) {
      _disposed = true;
      session.dispose();
      closeUI().ignore();
      return super.dispose(error, stackTrace);
    } else {
      return Future.value();
    }
  }

  /// Opens the user interface required to establish a web socket connection (for example, a wallet 
  /// app or QR code connection link).
  /// 
  /// Returns true if the UI was launched successfully.
  @protected
  Future<bool> openUI(final Uri uri);

  /// Closes the user interface launched by calling [openUI].
  /// 
  /// Returns true if the UI was closed successfully.
  @protected
  Future<bool> closeUI();
  
  /// Called when the dApp receives an `APP_PING` message.
  /// 
  /// An `APP_PING` is an empty message. It's sent by the reflector to each endpoint when both 
  /// endpoints have connected to the reflector. On first connecting to a reflector, the endpoints 
  /// should wait to receive this message before initiating any communications. After any other 
  /// message has been received, the APP_PING message becomes a no-op, and should be ignored.
  @protected
  void onAppPing() => {};

  /// Called when the dApp and wallet endpoint establish web socket connection.
  @override
  void onWebSocketConnect() {}
  
  /// Called when the dApp and wallet endpoints disconnect.
  @override
  void onWebSocketDisconnect([final int? code, final String? reason]) 
    => dispose(const SolanaWalletAdapterException(
      'The web socket has been disconnected.', 
      code: SolanaWalletAdapterExceptionCode.sessionClosed,
    ));
  
  /// Called when the dApp receives an [error] from the wallet endpoint.
  @override
  void onWebSocketError(final Object error, [final StackTrace? stackTrace])
    => dispose(error, stackTrace);
  
  /// Called when the dApp receives [data] from the wallet endpoint.
  @override
  void onWebSocketData(final dynamic data) {
    try {
      final Uint8List message = Uint8List.fromList(data);
      return message.isEmpty ? onAppPing() : _receive(message);
    } catch (error, stackTrace) {
      dispose(error, stackTrace);
    }
  }

  /// Invokes the wallet endpoint [method] with [params].
  @override
  Future<T> send<T>(
    final Method method,
    final Serializable? params, {
    final JsonRpcRequestConfig? config,
  }) {
    check(_queue.isEmpty);
    final request = JsonRpcRequest(method.name, params: params);
    return webSocketRequest<T>(association.sessionUri(), request, config: config).unwrap();
  }

  /// Handles a response [message] recevied from the wallet endpoint.
  void _receive(final Uint8List message) async {
    check(_queue.length == 1);
    final Map<String, dynamic> json = await _decrypt(message);
    final JsonRpcRequest request = webSocketExchangeManager.first.request;
    final Method? method = Method.tryFromName(request.method);
    switch (method) {
      case Method.hello_req:
        final JsonRpcResponse response = request.toResponse(result: message);
        return _complete(response.toJson(), HelloResult.fromMessage);
      case Method.authorize:
        return _complete(json, AuthorizeResult.fromJson);
      case Method.deauthorize:
        return _complete(json, DeauthorizeResult.fromJson);
      case Method.reauthorize:
        return _complete(json, ReauthorizeResult.fromJson);
      case Method.get_capabilities:
        return _complete(json, GetCapabilitiesResult.fromJson);
      case Method.sign_transactions:
        return _complete(json, SignTransactionsResult.fromJson);
      case Method.sign_and_send_transactions:
        return _complete(json, SignAndSendTransactionsResult.fromJson);
      case Method.sign_messages:
        return _complete(json, SignMessagesResult.fromJson);
      case Method.clone_authorization:
        return _complete(json, CloneAuthorizationResult.fromJson);
      case null:
        final error = JsonRpcException('No pending request found for method $method.');
        final JsonRpcResponse response = request.toResponse(error: error);
        return _complete(response.toJson(), (e) => e);
    }
  }

  /// Completes the [json] response with a `success` or `error` [JsonRpcResponse].
  void _complete<T, U>(final Map<String, dynamic> json, JsonRpcParser<T, U> parser) {
    final JsonRpcResponse<T> response = JsonRpcResponse.parse(json, parser);
    webSocketExchangeManager.complete(response, remove: true);
  }
  
  /// Encrypts [data] if a secure session has been established. A `hello_req` message is returned if 
  /// the session has not been encrypted.
  @override
  FutureOr<List<int>> encrypt(final List<int> data) {
    return session.isEncrypted 
      ? session.encrypt(data) 
      : session.generateHelloRequest();
  }

  /// Decrypts [data] if a secure session has been established. A empty object is returned if the 
  /// session has not been encrypted.
  FutureOr<Map<String, dynamic>> _decrypt(final List<int> data) {
    return session.isEncrypted 
      ? session.decrypt(data) 
      : Future.value({});
  }

  /// Adds a `hello_req` message to the request [_queue] for processing.
  @protected
  Future<HelloResult> helloRequest() => send<HelloResult>(Method.hello_req, null);

  /// Establishes an encrypted session between the dApp and wallet endpoints before calling the 
  /// [callback] function.
  /// 
  /// `This method should be called within a synchronized block and can only be called once.`
  Future<T> run<T>(
    final AssociationCallback<T> callback, {
    final Duration? timeout,
    final Uri? walletUriBase,
  }) async {
    /// Reset the method channel's callback handler.
    SolanaWalletAdapterPlatform.instance.setMethodCallHandler(null);

    // Generate a new association keypair.
    await session.generateAssociationKeypair();

    // Get the association token.
    final AssociationToken associationToken = await session.associationToken;

    /// Create the wallet uri.
    final Uri walletUri = association.walletUri(
      associationToken, 
      uriPrefix: walletUriBase,
    );

    // Add handler to process method calls by the native code (e.g. Android or iOS).
    SolanaWalletAdapterPlatform.instance.setMethodCallHandler(_methodCallHandler(walletUri));

    // Launch the UI for the current scenario.
    if (!await openUI(walletUri)) {
      throw const SolanaWalletAdapterException(
        'The mobile wallet adapter could not be opened.', 
        code: SolanaWalletAdapterExceptionCode.walletNotFound,
      );
    }

    // Connect to the wallet endpoint.
    final Duration timeLimit = timeout ?? association.type.timeout;
    await socket.connect(association.sessionUri()).timeout(timeLimit);

    // Create a new ECDH keypair.
    await session.generateSessionKeypair();

    // Send a `hello_req` message to encrypt the session.
    final HelloResult result = await helloRequest();    

    // Create the shared secret key.
    await session.generateSharedSecretKey(result.keypoint);  

    // Once encrypted, run the callback function.
    return callback(this);
  }

  /// Created a method call handler to [dispose] of the current session on receipt of a 
  /// [CallMethod.walletClosed] method call.
  Future<void> Function(MethodCall call) _methodCallHandler(
    final Uri walletUri,
  ) => (final MethodCall call) async {
      final String? uri = Map.from(call.arguments ?? {})['uri'];
      if (call.method == CallMethod.walletClosed.name && uri == walletUri.toString()) {
        dispose(const SolanaWalletAdapterException(
          'The wallet endpoint has been closed.', 
          code: SolanaWalletAdapterExceptionCode.sessionClosed,
        )).ignore();
      }
    };
}