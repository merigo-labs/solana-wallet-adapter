/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/models/serializable.dart';
import 'sign_and_send_transactions_config.dart';
import '../utils/types.dart';


/// Sign And Send Transactions Params
/// ------------------------------------------------------------------------------------------------

class SignAndSendTransactionsParams extends Serializable {

  /// Request parameters for `sign_and_send_transactions` method calls.
  const SignAndSendTransactionsParams({
    required this.payloads,
    this.options,
  });

  /// The base-64 encoded transactions to sign.
  final List<Base64EncodedTransaction> payloads;

  /// The configuration options.
  final SignAndSendTransactionsConfig? options;

  @override
  Map<String, dynamic> toJson() => {
    'payloads': payloads,
    'options': options?.toJson(),
  };
}