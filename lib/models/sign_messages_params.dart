/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/models/serializable.dart';
import '../utils/types.dart';


/// Sign Messages Params
/// ------------------------------------------------------------------------------------------------

class SignMessagesParams extends Serializable {

  /// Sign messages request parameters.
  const SignMessagesParams({
    required this.addresses,
    required this.payloads,
  });

  /// The base-64 encoded addresses of the accounts which should be used to sign message. These 
  /// should be a subset of the addresses returned by authorize or reauthorize for the current 
  /// session’s authorization.
  final List<Base64EncodedAddress> addresses;

  /// The base-64 URL encoded messages to sign.
  final List<Base64EncodedMessage> payloads;

  @override
  Map<String, dynamic> toJson() => {
    'addresses': addresses,
    'payloads': payloads,
  };
}