/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/models/serializable.dart';


/// Deauthorize Result
/// ------------------------------------------------------------------------------------------------

class DeauthorizeResult extends Serializable {

  /// The result of a successful `deauthorize` request.
  const DeauthorizeResult();

  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// ```
  /// DeauthorizeResult.fromJson({ '<parameter>': <value> });
  /// ```
  factory DeauthorizeResult.fromJson(final Map<String, dynamic> json) => const DeauthorizeResult();

  @override 
  Map<String, dynamic> toJson() => {};
}