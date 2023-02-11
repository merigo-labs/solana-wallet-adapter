/// Call Methods
/// ------------------------------------------------------------------------------------------------

/// Method channel call names invoked by the native platform (e.g. Android, iOS).
enum CallMethod {
  openUri,
  openStore,
  openWallet,
  closeWallet,
  walletClosed,
  isWalletInstalled,
  ;
}