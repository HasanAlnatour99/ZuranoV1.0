import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let mapsKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsKey.isEmpty,
       !mapsKey.contains("$(") {
      #if DEBUG
      print("✅ Google Maps iOS key loaded")
      #endif
      GMSServices.provideAPIKey(mapsKey)
    } else {
      #if DEBUG
      print("❌ Google Maps iOS key missing or unresolved")
      #endif
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
