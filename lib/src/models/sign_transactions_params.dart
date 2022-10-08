/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/models/serializable.dart';
import '../utils/types.dart';


/// Sign Transactions Params
/// ------------------------------------------------------------------------------------------------

class SignTransactionsParams extends Serializable {

  /// Sign transactions request parameters.
  const SignTransactionsParams({
    required this.payloads,
  });

  /// The base-64 encoded transactions to sign.
  final List<Base64EncodedTransaction> payloads;

  @override
  Map<String, dynamic> toJson() => {
    'payloads': payloads,
  };
}