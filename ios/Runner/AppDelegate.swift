import UIKit
import Flutter
import GoogleMobileAds
import PushKit
import flutter_callkit_incoming
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,PKPushRegistryDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("google_map_api_key")

        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GeneratedPluginRegistrant.register(with: self)

//      ImageGallery.shared.createImagePickerChanel(window: window!)
//      Setup VOIP
        
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]

        let center  = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if error == nil{
               UIApplication.shared.registerForRemoteNotifications()
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
//    private func registerPlugins(registry: FlutterPluginRegistry) {
//        if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
//           FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
//        }
//    }
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        //Save deviceToken to your server
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }
        
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
        
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print( payload.dictionaryPayload)
        print("from notification");

        guard type == .voIP else {
            print("type != .voIP")
            return
        }
        print("type == .voIP")

        let id = Int(payload.dictionaryPayload["id"] as! String)
        let uuid = payload.dictionaryPayload["uuid"]

        let nameCaller = payload.dictionaryPayload["username"] ?? ""
        let callerImage =  payload.dictionaryPayload["userImage"] ?? ""
        let callerId =  Int(payload.dictionaryPayload["callerId"] as? String ?? "")

        let handle =  payload.dictionaryPayload["channelName"]
        let token =  payload.dictionaryPayload["token"]

        let notificationType =  payload.dictionaryPayload["notification_type"] as! String

        print(payload)

        let data = flutter_callkit_incoming.Data(id: uuid as! String, nameCaller: nameCaller as! String, handle: handle as! String, type: payload.dictionaryPayload["callType"] as! String == "1" ? 0 : 1)
        
        

        if(notificationType == "103"){
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
            //set more data
            data.extra = ["id": id!, "platform": "ios","callerId":callerId ,"callerImage":callerImage, "channelName":handle!,"token":token!]
        }
        else{
            //set more data
            data.extra = ["id": id!, "platform": "ios","callerId":callerId ,"callerImage":callerImage, "channelName":handle!]
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(data)
        }
    }
}
