/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:webcrypto/webcrypto.dart' show AesGcmSecretKey;


/// Shared Secret Key
/// ------------------------------------------------------------------------------------------------

/// A shared secret key calculated by the dApp and wallet endpoints.
typedef SharedSecretKey = AesGcmSecretKey;