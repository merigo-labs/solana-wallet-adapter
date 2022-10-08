// Imports
// -------------------------------------------------------------------------------------------------

import UIKit
import Flutter


// App Delegate
// -------------------------------------------------------------------------------------------------

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
//    channel = FlutterMethodChannel(
//      name: AppDelegate.METHOD_CHANNEL_NAME,
//      binaryMessenger: controller.binaryMessenger
//    )
//    channel?.setMethodCallHandler(self.methodChannelHandler)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
