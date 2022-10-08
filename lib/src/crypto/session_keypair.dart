/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:webcrypto/webcrypto.dart' show EcdhPrivateKey, EcdhPublicKey, KeyPair;


/// Session Keypair
/// ------------------------------------------------------------------------------------------------

/// An EC keypair on the P-256 curve used to begin a Diffie-Hellman-Merkle key exchange.
typedef SessionKeypair = KeyPair<EcdhPrivateKey, EcdhPublicKey>;