import Flutter
import UIKit

public class SwiftSolanaWalletAdapterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "solana_wallet_adapter", binaryMessenger: registrar.messenger())
    let instance = SwiftSolanaWalletAdapterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
