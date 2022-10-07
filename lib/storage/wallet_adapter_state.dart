/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:solana_common/models/serializable.dart';
import 'package:solana_wallet_adapter/models/account.dart';
import 'package:solana_wallet_adapter/models/authorize_result.dart';


/// Wallet Adapter State
/// ------------------------------------------------------------------------------------------------

class WalletAdapterState extends Serializable {

  /// The wallet adapter state.
  const WalletAdapterState({
    this.authorizeResult,
    this.feePayerAccount,
  });

  /// The latest result of a successful `authorize` request.
  final AuthorizeResult? authorizeResult;

  /// The account selected to be the default fee payer.
  final Account? feePayerAccount;
  
  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// ```
  /// WalletAdapterState.fromJson({ '<parameter>': <value> });
  /// ```
  factory WalletAdapterState.fromJson(final Map<String, dynamic> json) => WalletAdapterState(
    authorizeResult: AuthorizeResult.tryFromJson(json['authorizeResult']),
    feePayerAccount: Account.tryFromJson(json['feePayerAccount']),
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
    'authorizeResult': authorizeResult,
    'feePayerAccount': feePayerAccount,
  };

  /// Serializes this class into a JSON string.
  String toJsonString() => jsonEncode(toJson());
}