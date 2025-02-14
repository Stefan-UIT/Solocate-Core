
import FirebaseCore
import FirebaseMessaging

/// Service for Firebase details based on the BuildConfiguration

class FirebaseService:NSObject {

    let tokenType:  MessagingAPNSTokenType;
    let options: FirebaseOptions;

    init(buildConf conf: BuildConfiguration? = nil) {
        
        var plistPath: String;
        
        if let confBuild = conf  {
            switch confBuild.serverEnvironment {
            case .development:
                tokenType = .sandbox
                plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
                
//            case .staging:
//                tokenType = .prod
//                plistPath = Bundle.main.path(forResource: "GoogleService-Info-staging", ofType: "plist")!
                
            case .production:
                tokenType = .prod
                plistPath = Bundle.main.path(forResource: "GoogleService-Info-prod", ofType: "plist")!
                
            default:
                tokenType = .sandbox
                plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
            }
            
        }else {
             tokenType = .unknown
             plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        }
        
        options = FirebaseOptions(contentsOfFile: plistPath)!;
    }
    
    func setupFirebase() {
        FirebaseApp.configure(options: options);
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    func setPUSHToken(_ token: Data)  {
        Messaging.messaging().setAPNSToken(token, type: tokenType)
    }
}

//MARK: - MessagingDelegate
extension FirebaseService: MessagingDelegate{
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("==>Did receive FCM token: \(fcmToken)")
        if Caches().hasLogin {
            SERVICES().API.updateNotificationFCMToken(fcmToken) { (result) in }
        }
        
        Cache.shared.setObject(obj: fcmToken, forKey: Defaultkey.fcmToken)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("==>didReceive remote message: \(remoteMessage.appData)")
    }
}
