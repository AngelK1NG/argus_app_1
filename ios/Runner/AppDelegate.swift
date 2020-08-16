import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var screenOn = true
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let CHANNEL = FlutterMethodChannel(name: "plugins.flutter.io/screen", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        CHANNEL.setMethodCallHandler {
            [unowned self] (methodCall, result) in
            if (methodCall.method == "isScreenOn") {
                if UIScreen.main.brightness == 0.0 {
                    screenOn = false
                } else {
                    screenOn = true
                    if #available(iOS 10.0, *) {
                        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
                    } else {
                        // Fallback on earlier versions
                    }
                }
                result(screenOn)
            }
        }
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)      
    }
}
