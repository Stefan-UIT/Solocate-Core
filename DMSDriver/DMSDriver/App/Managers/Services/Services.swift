
import Foundation
import Alamofire;

class Services {
    
    //MARK: - Services
    fileprivate(set) lazy var API: BaseAPIService = {
        return BaseAPIService.shared()
    }()
    
    fileprivate(set) lazy var firebase: FirebaseService = {
        return FirebaseService(buildConf: buildConf)
    }()
    
    fileprivate(set) lazy var socket: SocketService = {
        return SocketService.shared
    }()
    
    init(buildConf conf: BuildConfiguration) {
        buildConf = conf;
    }
    
    //MARK: - instances
    fileprivate(set) static var shared: Services?;
    let buildConf: BuildConfiguration;
    static func setupShared(buildConf: BuildConfiguration){
        shared = Services(buildConf: buildConf);
    }

}

func SERVICES() -> Services {
    return Services.shared!;
}

let SDBuildConf = SERVICES().buildConf
