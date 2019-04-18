
import Foundation

enum TagetBuild:String {
    case Development = "Development"
    case Production = "Production"
}


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
    let tagetBuild:TagetBuild

    init() {
        #if DEVELOPMENT  // check taget
            tagetBuild = .Development
            self.serverEnvironment = .development

        #else
            tagetBuild = .Production
            self.serverEnvironment = .production
        
        #endif
        //Load data in configfile (Main service)
        DMSAppConfiguration.enableConfiguration()
    }
}


//MARK: - Windows
extension BuildConfiguration {
    
    func serverUrlString() -> String {
        if let server = Debug.shared?.useServer {
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
