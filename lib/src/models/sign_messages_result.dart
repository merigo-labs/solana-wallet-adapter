/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/models/serializable.dart';
import '../models/sign_messages_params.dart';
import '../utils/types.dart';


/// Sign Messages Result
/// ------------------------------------------------------------------------------------------------

class SignMessagesResult extends Serializable {

  /// The result of a successful `sign_messages` request.
  const SignMessagesResult({
    required this.signedPayloads,
  });
  
  /// The base-64 encoded signed messages. 
  /// [SignMessagesParams.payloads].
  final List<Base64EncodedSignedMessage> signedPayloads;

  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// ```
  /// SignMessagesResult.fromJson({ '<parameter>': <value> });
  /// ```
  factory SignMessagesResult.fromJson(final Map<String, dynamic> json) 
    => SignMessagesResult(
      signedPayloads: List<Base64EncodedSignedMessage>.from(json['signed_payloads']),
    );
    
  @override
  Map<String, dynamic> toJson() => {
    'signed_payloads': signedPayloads,
  };
}