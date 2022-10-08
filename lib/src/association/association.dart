/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:math' as math show Random;
import 'package:flutter/foundation.dart' show protected;
import 'package:solana_common/utils/library.dart';
import '../crypto/association_token.dart';
import '../exceptions/solana_wallet_adapter_exception.dart';


/// Association Types
/// ------------------------------------------------------------------------------------------------

enum AssociationType {
  local,
  remote;
}


/// Association Query Parameter
/// ------------------------------------------------------------------------------------------------

class AssociationQueryParameter<T extends Object> {
  
  /// Creates a single query parameter.
  const AssociationQueryParameter(
    this.key, {
    this.value,
  });

  /// The query parameter name.
  final String key;

  /// The query parameter value.
  final T? value;
}


/// Association
/// ------------------------------------------------------------------------------------------------

abstract class Association {

  /// Creates an [Association] for [type] to construct endpoint [Uri]s.
  const Association(this.type);

  /// The type of association.
  final AssociationType type;

  /// The default mobile wallet adapter protocol scheme.
  static const String scheme = 'solana-wallet';

  /// The base path of the URI.
  static const String pathPrefix = 'v1/associate';

  /// The association token query parameter key (`[associationParameterKey]=<association_token>`).
  static const String associationParameterKey = 'association';

  /// Generates a random non-negative integer between [minValue] and [maxValue] (inclusive).
  /// 
  /// ```
  /// final int value = Association.randomValue(minValue: 10, maxValue: 20);
  /// print(value); // 10 ≤ value ≤ 20
  /// ```
  static int randomValue({ final int minValue = 0, final int maxValue = maxInt64 - 1}) {
    assert(minValue >= 0);
    assert(maxValue < maxInt64);
    assert(minValue <= maxValue);
    final int rangeLength = maxValue - minValue + 1;
    return minValue + math.Random().nextInt(rangeLength);
  }

  /// Creates a new [Uri] that's used to connect a dApp endpoint to a wallet endpoint.
  Uri walletUri(
    final AssociationToken associationToken, { 
    final Uri? uriPrefix,
  });

  /// Creates a new [Uri] that's used to establish a secure web socket connection between a dApp and 
  /// wallet endpoint.
  Uri sessionUri();

  /// Creates a new [Uri] for [scheme] or [uriPrefix], using the provided [associationToken] and 
  /// [queryParameters].
  /// 
  /// If provided, [uriPrefix] must have a `HTTPS` scheme (for security reasons, a dApp should 
  /// reject a [uriPrefix] with schemes other than https).
  @protected
  Uri buildWalletUri(
    final AssociationToken associationToken, {
    final List<AssociationQueryParameter>? queryParameters,
    final Uri? uriPrefix, 
  }) {
    checkUriPrefix(uriPrefix);
    final String base = uriPrefix?.toString() ?? '$scheme:/';
    final String path = '$pathPrefix/${type.name}';
    final Map<String, dynamic> query = _mapQueryParameter(associationToken, queryParameters);
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  /// Creates a [Map] from the provided [associationToken] and [queryParameters].
  static Map<String, dynamic> _mapQueryParameter(
    final AssociationToken associationToken,
    final List<AssociationQueryParameter>? queryParameters,
  ) {
    final List<AssociationQueryParameter> params = queryParameters ?? [];
    params.add(AssociationQueryParameter(associationParameterKey, value: associationToken));
    return params.fold({}, (query, param) => query..addAll({ param.key: param.value.toString() }));
  }

  /// Throws a [SolanaWalletAdapterException] if the provided [uriPrefix] is invalid.
  static void checkUriPrefix(final Uri? uriPrefix) {
    if (uriPrefix != null && !uriPrefix.isScheme('HTTPS')) {
      throw const SolanaWalletAdapterException(
        'The wallet base uri prefix must start with "https://"', 
        code: SolanaWalletAdapterExceptionCode.forbiddenWalletBaseUri,
      );
    }
  }
}