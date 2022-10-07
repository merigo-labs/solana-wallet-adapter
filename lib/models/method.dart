/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/utils/library.dart';


/// Methods
/// ------------------------------------------------------------------------------------------------

/// JSON-RPC method call names.
enum Method {
  hello_req,                  // ignore: constant_identifier_names
  authorize,
  deauthorize,
  reauthorize,
  get_capabilities,           // ignore: constant_identifier_names
  sign_transactions,          // ignore: constant_identifier_names
  sign_and_send_transactions, // ignore: constant_identifier_names
  sign_messages,              // ignore: constant_identifier_names
  clone_authorization,        // ignore: constant_identifier_names
  ;

  /// Returns the enum variant where [EnumName.name] is equal to [name].
  /// 
  /// Returns `null` if [name] cannot be matched to an existing variant.
  /// 
  /// ```
  /// Method.tryFromName('hello_req');
  /// ```
  static Method? tryFromName(final String name) => tryCall(() => Method.values.byName(name));
}