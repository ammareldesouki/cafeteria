import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FirebaseInstallationsPlugin.register(
      with: self.registrar(forPlugin: "FirebaseInstallationsPlugin")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
