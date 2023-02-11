/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'solana_wallet_adapter_method_channel.dart';


/// Solana  Wallet Adapter Platform
/// ------------------------------------------------------------------------------------------------

abstract class SolanaWalletAdapterPlatform extends PlatformInterface {
  
  /// Constructs a SolanaWalletAdapterPlatform.
  SolanaWalletAdapterPlatform(): super(token: _token);

  /// The private static token object which will be be passed to [PlatformInterface.verifyToken] 
  /// along with a platform interface object for verification.
  static final Object _token = Object();

  /// The method channel used to make native platform function calls.
  static SolanaWalletAdapterPlatform _instance = MethodChannelSolanaWalletAdapter();

  /// The default instance of [SolanaWalletAdapterPlatform] to use.
  ///
  /// Defaults to [MethodChannelSolanaWalletAdapter].
  static SolanaWalletAdapterPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own platform-specific class that 
  /// extends [SolanaWalletAdapterPlatform] when they register themselves.
  static set instance(SolanaWalletAdapterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Opens [uri].
  Future<bool> openUri(final String uri);

  /// Opens the app/play store for the application [id].
  Future<bool> openStore(final String id);

  /// Opens a mobile wallet app.
  Future<bool> openWallet(final Uri associationUri);

  /// Closes a mobile wallet app previously launched by [openWallet].
  Future<bool> closeWallet();

  /// Check if a wallet application is installed on the current device.
  Future<bool> isWalletInstalled(final String id);
  
  /// Sets a callback for receiving method calls on this channel.
  /// 
  /// The given callback will replace the currently registered callback for this channel, if any. To 
  /// remove the handler, pass null as the handler argument.
  /// 
  /// If the future returned by the handler completes with a result, that value is sent back to the 
  /// platform plugin caller wrapped in a success envelope. If the future completes with a 
  /// [PlatformException], the fields of that exception will be used to populate an error envelope 
  /// which is sent back instead. If the future completes with a [MissingPluginException], an empty 
  /// reply is sent similarly to what happens if no method call handler has been set. Any other 
  /// exception results in an error envelope being sent.
  void setMethodCallHandler(final Future Function(MethodCall)? handler);
}
