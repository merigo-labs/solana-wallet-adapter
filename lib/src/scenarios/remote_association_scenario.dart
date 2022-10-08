/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async' show Completer;
import '../association/remote_association.dart';
import '../models/hello_result.dart';
import '../scenarios/scenario.dart';
import '../transports/web_socket_transport.dart';


/// Remote Association Scenario
/// ------------------------------------------------------------------------------------------------

class RemoteAssociationScenario extends Scenario {

  /// Creates a remote association between the dApp and wallet endpoints, which can be used to make 
  /// method calls within a secure session.
  /// 
  /// [hostAuthority] is the web socket server that brokers communication between the dApp and 
  /// the remote wallet endpoint.
  RemoteAssociationScenario(
    final String hostAuthority, {
    final int? id,
  }): super(
      RemoteAssociation(
        hostAuthority: hostAuthority, 
        id: id,
      ),
      maxAttempts: 4,
      backoffSchedule: const [1000, 750, 500, 250],
      protocols: const [WebSocketTransport.protocol, WebSocketTransport.reflectorProtocol],
    );

  /// Completes when an APP_PING message is received.
  Completer<void>? _pingCompleter;

  @override
  void onAppPing() {
    final Completer<void>? completer = _pingCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  @override
  Future<HelloResult> helloRequest() async {
    await (_pingCompleter ??= Completer()).future;
    return super.helloRequest();
  }
  
  @override
  Future<bool> openUI(final Uri uri) => Future.value(true);

  @override
  Future<bool> closeUI()  => Future.value(true);
}