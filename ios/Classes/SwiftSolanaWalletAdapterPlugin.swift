// Imports
// -------------------------------------------------------------------------------------------------

import Flutter
import UIKit


// Methods
// -------------------------------------------------------------------------------------------------

/// Incoming (Flutter -> Android) method channel method names.
enum IncomingMethod: String {
  case OPEN_STORE = "openStore"
  case OPEN_WALLET = "openWallet"
  case CLOSE_WALLET = "closeWallet"
}

/// Outgoing (Android -> Flutter) method channel method names.
enum OutgoingMethod: String {
  case WALLET_CLOSED = "walletClosed"
}


// Swift Solana Wallet Adapter Plugin
// -------------------------------------------------------------------------------------------------

public class SwiftSolanaWalletAdapterPlugin: NSObject, FlutterPlugin {
  
  static let METHOD_CHANNEL_NAME = "com.merigo/solana_wallet_adapter"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: SwiftSolanaWalletAdapterPlugin.METHOD_CHANNEL_NAME, 
      binaryMessenger: registrar.messenger()
    )
    let instance = SwiftSolanaWalletAdapterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case IncomingMethod.OPEN_STORE.rawValue:
      openStore(call: call, result: result)
    case IncomingMethod.OPEN_WALLET.rawValue:
      openWallet(call: call, result: result)
    case IncomingMethod.CLOSE_WALLET.rawValue:
      closeWallet(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
    
  func argumentsDictionary(_ arguments: Any?) -> [String: Any?] {
    guard let arguments = arguments as? [String: Any?] else { return [:] }
    return arguments
  }
  
  func openStore(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
    guard
      let id = argumentsDictionary(call.arguments)["id"] as? String,
      let uri = URL(string: "itms-apps://itunes.apple.com/app/\(id)"),
      UIApplication.shared.canOpenURL(uri)
    else {
      result(false)
      return
    }
    UIApplication.shared.open(uri, options: [:]) { success in result(success) }
  }
  
  func openWallet(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
    guard
      let uriString = argumentsDictionary(call.arguments)["uri"] as? String,
      let uri = URL(string: uriString),
      UIApplication.shared.canOpenURL(uri)
    else {
      result(false)
      return
    }
    UIApplication.shared.open(uri, options: [:]) { success in result(success) }
  }
  
  func closeWallet(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
    result(true)
  }
}
