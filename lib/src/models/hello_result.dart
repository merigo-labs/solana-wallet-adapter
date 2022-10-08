/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:typed_data' show Uint8List;
import 'package:solana_common/models/serializable.dart';


/// Hello Result
/// ------------------------------------------------------------------------------------------------

class HelloResult extends Serializable {

  /// The result of a successful `hello_req` request.
  const HelloResult(this.keypoint);

  /// The X9.62 encoded wallet endpoint ephemeral ECDH public keypoint.
  final List<int> keypoint;

  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// ```
  /// HelloResult.fromMessage([4, 12, 36, ...]);
  /// ```
  factory HelloResult.fromMessage(final List<int> message) 
    => HelloResult(Uint8List.fromList(message));

  @override
  Map<String, dynamic> toJson() => {};
}