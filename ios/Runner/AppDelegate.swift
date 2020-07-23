import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        var screenStat = "nil"
        if UIScreen.main.brightness == 0.0 {
                             screenStat = "screen is locked"
                  }
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let CHANNEL = FlutterMethodChannel(name: "com.flutter.lockscreen", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        CHANNEL.setMethodCallHandler {
          
            
            [unowned self] (methodCall, result) in
            if (methodCall.method == "PrintBoi")
            {
                if UIScreen.main.brightness == 0.0 {
                           screenStat = "screen is locked"
                     result(screenStat)
                }
            }
        }
        
        
        
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
            

       

}
}
