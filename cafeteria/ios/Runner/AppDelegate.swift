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
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let registrar = self.registrar(forPlugin: "FirebaseInstallations") {
      let channel = FlutterMethodChannel(
        name: "firebase_installations",
        binaryMessenger: registrar.messenger())
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
    }
    return result
  }
}
