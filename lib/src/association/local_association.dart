/// Imports
/// ------------------------------------------------------------------------------------------------

import 'association.dart';
import '../crypto/association_token.dart';


/// Local Association
/// ------------------------------------------------------------------------------------------------

class LocalAssociation extends Association {

  /// Creates an [Association] to construct `local` endpoint [Uri]s.
  LocalAssociation({
    final int? port,
  }): port = port ?? Association.randomValue(minValue: minPort, maxValue: maxPort),
      super(AssociationType.local);

  /// The local port number.
  final int port;

  /// The minimum port number for local association URIs.
  static const int minPort = 49152;

  /// The maximum port number for local association URIs.
  static const int maxPort = 65535;

  /// The [port] number query parameter key (`[portParameterKey]=[port]`).
  static const String portParameterKey = 'port';

  @override
  Uri walletUri(
    final AssociationToken associationToken, { 
    final Uri? uriPrefix,
  }) => buildWalletUri(
      associationToken,
      uriPrefix: uriPrefix,
      queryParameters: [
        AssociationQueryParameter(
          portParameterKey, 
          value: port,
        ),
      ],
    );
  
  @override
  Uri sessionUri() => Uri.parse('ws://localhost:$port/solana-wallet');
}