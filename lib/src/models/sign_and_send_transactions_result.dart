/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/models/serializable.dart';
import '../utils/types.dart';


/// Sign And Send Transactions Result
/// ------------------------------------------------------------------------------------------------

class SignAndSendTransactionsResult extends Serializable {

  /// The result of a successful `sign_and_send_transactions` request.
  const SignAndSendTransactionsResult({
    required this.signatures,
  });

  /// The base-64 encoded `transaction signatures` for transactions which were successfully sent to 
  /// the network and `null` for transactions which were unable to be submitted to the network for 
  /// any reason.
  final List<Base64EncodedSignature?> signatures;

  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// ```
  /// SignAndSendTransactionsResult.fromJson({ '<parameter>': <value> });
  /// ```
  factory SignAndSendTransactionsResult.fromJson(final Map<String, dynamic> json) 
    => SignAndSendTransactionsResult(
      signatures: List<Base64EncodedSignature?>.from(json['signatures']),
    );

  @override
  Map<String, dynamic> toJson() => {
    'signatures': signatures,
  };
}