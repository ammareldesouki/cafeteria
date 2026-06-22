import Flutter
import UIKit
import FirebaseCore
import FirebaseInstallations

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "firebase_installations",
                                       binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { (call, result) in
      if call.method == "deleteInstallationId" {
        Installations.installations().delete { error in
          if let error = error {
            result(FlutterError(code: "DELETE_FAILED",
                                message: error.localizedDescription,
                                details: nil))
          } else {
            result(true)
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
