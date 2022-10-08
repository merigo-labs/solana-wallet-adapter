/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/models/serializable.dart';
import '../utils/types.dart';


/// Account
/// ------------------------------------------------------------------------------------------------

class Account extends Serializable {

  /// Wallet account.
  /// 
  /// ```
  /// final account = Account(
  ///   address: 'BQU8XcxOALDAs5yEFghOD61XYpKNty/MMsCqmSiN0QM=',
  ///   label: 'Wallet 1'
  /// );
  /// ```
  const Account({
    required this.address,
    required this.label,
  });
  
  /// The base-64 encoded address of this account.
  final Base64EncodedAddress address;

  /// A human-readable string that describes this account.
  final String? label;

  @override
  int get hashCode => address.hashCode;

  @override
  bool operator==(final dynamic other) => other is Account && other.address == address;
  
  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// ```
  /// Account.fromJson({ '<parameter>': <value> });
  /// ```
  factory Account.fromJson(final Map<String, dynamic> json) => Account(
    address: json['address'], 
    label: json['label'],
  );

  /// Creates an instance of `this` class from the constructor parameters defined in the [json] 
  /// object.
  /// 
  /// Returns `null` if [json] is omitted.
  /// 
  /// ```
  /// Account.tryFromJson({ '<parameter>': <value> });
  /// ```
  static Account? tryFromJson(final Map<String, dynamic>? json)
    => json != null ? Account.fromJson(json) : null;

  @override
  Map<String, dynamic> toJson() => {
    'address': address,
    'label': label
  };
}