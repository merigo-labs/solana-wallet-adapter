/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:solana_wallet_adapter/models/call_method.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'solana_wallet_adapter_platform_interface.dart';


/// Method Channel Solana Wallet Adapter
/// ------------------------------------------------------------------------------------------------

class MethodChannelSolanaWalletAdapter extends SolanaWalletAdapterPlatform {

  /// An implementation of [SolanaWalletAdapterPlatform] that uses method channels.
  MethodChannelSolanaWalletAdapter();

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(SolanaWalletAdapter.packageName);

  /// Invokes [method] with [arguments] and returns it's [bool] result or `false` if it return null.
  Future<bool> invokeMethod(final String method, [final Map<String, dynamic>? arguments]) async
    => await methodChannel.invokeMethod(method, arguments) ?? false;

  @override
  Future<bool> openStore(final String id) => invokeMethod(
    CallMethod.openStore.name, { 
    'id': id, 
  });

  @override
  Future<bool> openWallet(final Uri associationUri) => invokeMethod(
    CallMethod.openWallet.name, { 
    'uri': associationUri.toString(), 
  });

  @override
  Future<bool> closeWallet() => invokeMethod(CallMethod.closeWallet.name);

  @override
  void setMethodCallHandler(final Future Function(MethodCall)? handler)
    => methodChannel.setMethodCallHandler(handler);
}