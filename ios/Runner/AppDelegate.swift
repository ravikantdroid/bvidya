import UIKit
import Flutter
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        registerForPushNotifications();
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for Apple Remote Notifications:")
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        print(deviceTokenString)
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func registerForPushNotifications() {
        //        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            // 1. Check if permission granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
    }
}

//import UIKit
//import Flutter
//import PushKit
//import FirebaseMessaging
//
////import awesome_notifications
////import shared_preferences_ios
//import flutter_callkit_incoming
//
//@UIApplicationMain
//@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//      GeneratedPluginRegistrant.register(with: self)
//
//      if #available(iOS 10.0, *) {
//          UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
//         }
////      application.registerForRemoteNotifications()
//
//
//      // This function registers the desired plugins to be used within a notification background action
//      // SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
//      //     SwiftAwesomeNotificationsPlugin.register(
//      //       with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
//      //     FLTSharedPreferencesPlugin.register(
//      //       with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)
//      // }
//        //       //Setup VOIP
//         let mainQueue = DispatchQueue.main
//         let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
//         voipRegistry.delegate = self
//         voipRegistry.desiredPushTypes = [PKPushType.voIP]
//      registerForPushNotifications()
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//
//
//      override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//          print("Registered for Apple Remote Notifications:")
//          let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//
//          print(deviceTokenString)
//          Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
//      }
//
//    func registerForPushNotifications() {
//            UNUserNotificationCenter.current().delegate = self
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//                (granted, error) in
//                print("Permission granted: \(granted)")
//                // 1. Check if permission granted
//                guard granted else { return }
//                // 2. Attempt registration for remote notifications on the main thread
//                DispatchQueue.main.async {
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//            }
//
//
//        }
////
////    // Call back from Recent history
//    override func application(_ application: UIApplication,
//                              continue userActivity: NSUserActivity,
//                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//
//        guard let handleObj = userActivity.handle else {
//            return false
//        }
//
//        guard let isVideo = userActivity.isVideo else {
//            return false
//        }
//        let nameCaller = handleObj.getDecryptHandle()["nameCaller"] as? String ?? ""
//        let handle = handleObj.getDecryptHandle()["handle"] as? String ?? ""
//        let data = flutter_callkit_incoming.Data(id: UUID().uuidString, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
//        //set more data...
//        data.nameCaller = "Johnny"
//        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.startCall(data, fromPushKit: true)
//
//        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
//    }
//
//    // Handle updated push credentials
//    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
//        print(credentials.token)
//        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
//        print(deviceToken)
//        //Save deviceToken to your server
//        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
//    }
//
//    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
//        print("didInvalidatePushTokenFor")
//        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
//    }
//
//    // Handle incoming pushes
//    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
//        print("didReceiveIncomingPushWith")
//        guard type == .voIP else { return }
//
//        let id = payload.dictionaryPayload["id"] as? String ?? ""
//        let nameCaller = payload.dictionaryPayload["nameCaller"] as? String ?? ""
//        let handle = payload.dictionaryPayload["handle"] as? String ?? ""
//        let isVideo = payload.dictionaryPayload["isVideo"] as? Bool ?? false
//
//        let data = flutter_callkit_incoming.Data(id: id, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
//        //set more data
//        data.extra = ["user": "abc@123", "platform": "ios"]
//        //data.iconName = ...
//        //data.....
//        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
//    }
////
//}
