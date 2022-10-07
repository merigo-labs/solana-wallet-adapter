/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/models/serializable.dart';
import '../utils/types.dart';


/// Clone Authorization Result
/// ------------------------------------------------------------------------------------------------

class CloneAuthorizationResult extends Serializable {

  /// The result of a successful `clone_authorization` request.
  const CloneAuthorizationResult({
    required this.authToken,
  });
  
  /// An opaque string representing a unique identifying token issued by the wallet endpoint for 
  /// sharing with another instance of the dapp endpoint, possibly running on a different system.
  final AuthToken authToken;

  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// ```
  /// CloneAuthorizationResult.fromJson({ '<parameter>': <value> });
  /// ```
  factory CloneAuthorizationResult.fromJson(final Map<String, dynamic> json) 
    => CloneAuthorizationResult(
      authToken: json['auth_token'],
    );

  @override 
  Map<String, dynamic> toJson() => {
    'auth_token': authToken,
  };
}