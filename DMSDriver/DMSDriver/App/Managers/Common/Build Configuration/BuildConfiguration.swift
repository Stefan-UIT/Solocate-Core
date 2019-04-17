
import Foundation


enum ServerEnvironment: String {
    case development = "development"
    case staging = "staging"
    case production = "production"

    init?(rawString: String) {
        self.init(rawValue: rawString.lowercased())
    }
    
    func serverUrlString() -> String {
        switch self {
        case .development:
            return DMSAppConfiguration.baseUrl_Dev
        case .staging:
            return DMSAppConfiguration.baseUrl_Staging
        case .production:
            return DMSAppConfiguration.baseUrl_Product
        }
    }
}

//MARK: - Commons
struct BuildConfiguration {
    let serverEnvironment: ServerEnvironment

    init(environment:ServerEnvironment) {
        #if DEVELOPMENT  // check taget
            self.serverEnvironment = environment
        #else
            self.serverEnvironment = .production
        #endif
        //Load data in configfile (Main service)
        DMSAppConfiguration.enableConfiguration()
    }
}


//MARK: - Windows
extension BuildConfiguration {
    
    func serverUrlString() -> String {
        if let server = Debug.shared.useServer {
            return server
        }
        
        return serverEnvironment.serverUrlString()
    }
    
    func baseImageUrlString() -> URL? {
        switch serverEnvironment {
        case .development:
            return URL(string:DMSAppConfiguration.baseUrl_Dev)
        case .staging:
            return URL(string: DMSAppConfiguration.baseUrl_Staging)
        case .production:
            return URL(string: DMSAppConfiguration.baseUrl_Product)
        }
    }
}
