/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:solana_common/models/serializable.dart';
import '../models/account.dart';
import '../models/authorize_result.dart';


/// Wallet Adapter State
/// ------------------------------------------------------------------------------------------------

class WalletAdapterState extends Serializable {

  /// The wallet adapter state.
  const WalletAdapterState({
    this.authorizeResult,
    this.connectedAccount,
  });

  /// The latest result of a successful `authorize` request.
  final AuthorizeResult? authorizeResult;

  /// The connected account and default fee payer.
  final Account? connectedAccount;
  
  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// ```
  /// WalletAdapterState.fromJson({ '<parameter>': <value> });
  /// ```
  factory WalletAdapterState.fromJson(final Map<String, dynamic> json) => WalletAdapterState(
    authorizeResult: AuthorizeResult.tryFromJson(json['authorizeResult']),
    connectedAccount: Account.tryFromJson(json['connectedAccount']),
  );

  /// Creates an instance of `this` class from the constructor parameters encoded in the provided
  /// [jsonString].
  /// 
  /// ```
  /// WalletAdapterState.fromJsonString('{ <parameter>: <value> }');
  /// ```
  factory WalletAdapterState.fromJsonString(final String jsonString) 
    => WalletAdapterState.fromJson(jsonDecode(jsonString));

  @override
  Map<String, dynamic> toJson() => {
    'authorizeResult': authorizeResult,   // jsonEncode calls .toJson()
    'connectedAccount': connectedAccount, // jsonEncode calls .toJson()
  };

  /// Serializes this class into a JSON string.
  String toJsonString() => jsonEncode(toJson());
}