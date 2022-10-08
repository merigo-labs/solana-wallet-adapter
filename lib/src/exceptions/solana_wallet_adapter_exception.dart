/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_common/exceptions/solana_exception.dart';


/// Solana Wallet Adapter Exception Codes
/// ------------------------------------------------------------------------------------------------

enum SolanaWalletAdapterExceptionCode {
  forbiddenWalletBaseUri,
  secureContextRequired,
  sessionClosed,
  sessionKeypair,
  walletNotFound,
  remoteConnectCancelled,
  ;
}


/// Solana Wallet Adapter Exception
/// ------------------------------------------------------------------------------------------------

typedef SolanaWalletAdapterException = SolanaException<SolanaWalletAdapterExceptionCode>;