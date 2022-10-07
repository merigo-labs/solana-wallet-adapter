/// Imports
/// ------------------------------------------------------------------------------------------------

import '../association/local_association.dart';
import '../scenarios/scenario.dart';
import '../solana_wallet_adapter_platform_interface.dart';
import '../transports/web_socket_transport.dart';


/// Local Association Scenario
/// ------------------------------------------------------------------------------------------------

class LocalAssociationScenario extends Scenario {

  /// Creates a local association between the dApp and wallet endpoints, which can be used to make 
  /// method calls within a secure session.
  LocalAssociationScenario({
    final int? port,
  }): super(
      LocalAssociation(
        port: port,
      ),
      maxAttempts: 34,
      backoffSchedule: const [150, 150, 200, 500, 500, 750, 750, 1000],
      protocols: const [WebSocketTransport.protocol],
    );

  @override
  Future<bool> openUI(final Uri uri)
    => SolanaWalletAdapterPlatform.instance.openWallet(uri);

  @override
  Future<bool> closeUI()
    => SolanaWalletAdapterPlatform.instance.closeWallet();
}