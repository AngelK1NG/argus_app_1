import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        var screenStat = true
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let CHANNEL = FlutterMethodChannel(name: "com.flutter.lockscreen", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        CHANNEL.setMethodCallHandler {
          
            
            [unowned self] (methodCall, result) in
            if (methodCall.method == "printBoi")
            {
                if UIScreen.main.brightness == 0.0 {
                           screenStat = false
                    
                }
                else {
                    screenStat = true
                    if #available(iOS 10.0, *) {
                                       UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
                                   } else {
                                       // Fallback on earlier versions
                                   }
                    
                }
                result(screenStat)
            }
        }
        
        
        
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
            

       

}
}
