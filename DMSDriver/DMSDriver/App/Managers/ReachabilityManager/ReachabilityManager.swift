

import Foundation
import ReachabilitySwift
import Alamofire
import SVProgressHUD

let ReachabilityManager = _ReachabilityManager.shared

class _ReachabilityManager: NSObject {
    
    static let shared = _ReachabilityManager()  // 2. Shared instance
    
    private var backgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 1)
    var isCalling:Bool = false
    @objc dynamic var temp:[CoreRequest]!

    
    // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .notReachable
    }
    
    var isReachableViaWiFi : Bool {
        return reachabilityStatus == .reachableViaWiFi
    }
    
    var isReachableViaWWAN : Bool {
        return reachabilityStatus == .reachableViaWWAN
    }
    
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.NetworkStatus = .notReachable
    var curentReachabilityStatus: Reachability.NetworkStatus = .notReachable

    
    // 5. Reachibility instance for Network status monitoring
    let reachability = Reachability()!
    
    
    /// Called whenever there is a change in NetworkReachibility Status
    ///
    /// — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            debugPrint("Network became unreachable")
        case .reachableViaWiFi:
            debugPrint("Network reachable through WiFi")
        case .reachableViaWWAN:
            debugPrint("Network reachable through Cellular Data")
        }
        reachabilityStatus = reachability.currentReachabilityStatus
        
        if isNetworkAvailable &&
            reachabilityStatus != curentReachabilityStatus {
            DMSLocationManager.startUpdatingDriverLocationIfNeeded()
            //updateAllRequestToServer()
        }else{
            DMSLocationManager.invalidTimer()
        }
        curentReachabilityStatus = reachabilityStatus
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        self.stopMonitoring()
        self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
            self.endBackgroundTask()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            debugPrint("Could not start reachability notifier")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification,
                                                  object: reachability)
        endBackgroundTask()
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
    }
}

// MARK: - API
extension _ReachabilityManager{
    func updateAllRequestToServer()  {
        if isNetworkAvailable {
            CoreDataManager.getAllRequest(Caches().user?.userInfo?.id ?? 0) { (success,requests) in
                if requests.count > 0 {
                    if !self.isCalling{
                        SVProgressHUD.show(withStatus: "Async..")
                    }
                    self.isCalling = true
                    //let mySerialQueue = DispatchQueue(label: "seldat.com.dms.directmail.request")
                    let queue = OperationQueue()
                    queue.maxConcurrentOperationCount = 1
                    
                    let operation = BlockOperation(block: {
                        self.updateRequest(requests.first!)
                    })
                    operation.completionBlock = {
                        print("completion")
                    }
                    queue.addOperation(operation)
                    
                }else{
                    self.isCalling = false
                    SVProgressHUD.dismiss()
                    App().mainVC?.refetchDataRouteOrTaskListOrHistoryNotify()
                }
            }
        }
    }
    
    func callAPi() {
    
        
    }

    func updateRequest(_ request: RequestModel) {
        SERVICES().API.updateRequestFromLocalDB(request) { (result) in
            switch result{
            case .object(_):
                CoreDataManager.deleteRequestModel(request, { (success) in
                    if success{
                        print("Deleted request:\(E(request.path))")
                        self.updateAllRequestToServer()
                    }
                })
                                
            case .error(let error):
                if let statusCode = error.code {
                    switch statusCode{
                    case .tokenFail:
                        App().reLogin()
                        break
                    default:
                        break
                    }
                }
                
                if request.count <= 3{
                    App().showAlertView(error.getMessage(),
                                        positiveTitle: "Retry".localized,
                                        positiveAction: { (ok) in
                                            self.updateRequest(request)

                    }, negativeTitle: "cancel".localized,
                       negativeAction: { (cancel) in
                        //
                    })
                }else{
                    CoreDataManager.deleteRequestModel(request, { (success) in
                        if success{
                            print("Deleted request:\(E(request.path))")
                            self.updateAllRequestToServer()
                        }
                    })
                }
                request.count =  request.count + 1
            }
        }
    }
}
