/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';


/// App Store Wallet
/// ------------------------------------------------------------------------------------------------

class AppStoreWallet {

  AppStoreWallet({
    required this.name,
    required final String favicon,
    required this.androidId,
    required this.iosId,
  }): favicon = AssetImage(
      'icons/$favicon.ico', 
      package: SolanaWalletAdapter.packageName,
    );

  final String name;

  /// The favicon image name (located in /icons).
  final AssetImage favicon;
  final String androidId;
  final String iosId;

  String get id => Platform.isAndroid ? androidId : iosId;

  factory AppStoreWallet.phantom() => AppStoreWallet(
    name: 'Phantom', 
    favicon: 'phantom', 
    androidId: 'app.phantom', 
    iosId: '1598432977',
  );

  factory AppStoreWallet.solflare() => AppStoreWallet(
    name: 'Solflare', 
    favicon: 'solflare', 
    androidId: 'com.solflare.mobile', 
    iosId: '1580902717',
  );
}