/// Web Socket Transport
/// ------------------------------------------------------------------------------------------------

class WebSocketTransport {

  /// Web socket transport constants.
  const WebSocketTransport._();

  /// The web socket sub-protocol.
  static const String protocol = 'com.solana.mobilewalletadapter.v1';

  /// The web socket reflector's sub-protocol.
  static const String reflectorProtocol = 'com.solana.mobilewalletadapter.v1.reflector';
}