/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:convert' show base64Url;
import 'dart:typed_data' show Uint8List;
import 'package:webcrypto/webcrypto.dart' show EcdsaPublicKey, EcdsaPrivateKey, EllipticCurve, Hash;
import '../crypto/association_token.dart';


/// Association Keypair
/// ------------------------------------------------------------------------------------------------

class AssociationKeypair {

  /// An ECDSA keypair on the P-256 curve.
  const AssociationKeypair({
    required this.publicKey,
    required this.privateKey,
  });

  /// The ECDSA public key.
  final EcdsaPublicKey publicKey;

  /// The ECDSA secret key.
  final EcdsaPrivateKey privateKey;

  /// Creates an ECDSA keypair on the P-256 curve.
  static Future<AssociationKeypair> generate() async {
    final keypair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
    return AssociationKeypair(publicKey: keypair.publicKey, privateKey: keypair.privateKey);
  }

  /// Returns the raw public key (`X9.62` format).
  Future<Uint8List> rawKey() => publicKey.exportRawKey();

  /// Returns a `base-64 URL encoding` of the X9.62 public key format.
  Future<AssociationToken> token() async => base64Url.encode(await rawKey());

  /// Signs [data] using the [privateKey] and returns the raw `signature`.
  Future<Uint8List> sign(final List<int> data) => privateKey.signBytes(data, Hash.sha256);
}