import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        var screenStat = true
        if UIScreen.main.brightness == 0.0 {
                             screenStat = false
                  }
        
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
                }
                result(screenStat)
            }
        }
        
        
        
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
            

       

}
}
