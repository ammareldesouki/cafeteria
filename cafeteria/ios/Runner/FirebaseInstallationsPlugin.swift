import Flutter
import UIKit
import FirebaseInstallations

public class FirebaseInstallationsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "firebase_installations",
      binaryMessenger: registrar.messenger())
    let instance = FirebaseInstallationsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
