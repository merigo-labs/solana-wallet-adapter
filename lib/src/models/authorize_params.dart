/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/config/cluster.dart';
import 'package:solana_common/models/serializable.dart';
import '../models/identity.dart';


/// Authorize Params
/// ------------------------------------------------------------------------------------------------

class AuthorizeParams extends Serializable {

  /// Request parameters for `authorize` method calls.
  const AuthorizeParams({
    required this.identity,
    required this.cluster,
  });

  /// The dApp's identity information used by the wallet to verify the dApp making the authorization 
  /// request.
  final Identity identity;

  /// The Solana cluster the dApp endpoint intends to interact with (default: [Cluster.mainnet]).
  final Cluster? cluster;

  @override
  Map<String, dynamic> toJson() => {
    'identity': identity.toJson(),
    'cluster': cluster?.name,
  };
}