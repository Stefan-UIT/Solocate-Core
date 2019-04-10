
import Foundation


enum ServerEnvironment: String {
    case development = "development"
    case testing = "testing"
    case production = "production"
    case staging = "staging"
    
    init?(rawString: String) {
        self.init(rawValue: rawString.lowercased())
    }
    
    func displayString() -> String {
        return rawValue.capitalized
    }
}

//MARK: - Commons
struct BuildConfiguration {
    let serverEnvironment: ServerEnvironment

    init(serverEnvironment: ServerEnvironment) {
        self.serverEnvironment = serverEnvironment;
        //Load data in configfile (Main service)
        DMSAppConfiguration.enableConfiguration()
    }
}


//MARK: - Windows
extension BuildConfiguration {
    
    func serverUrlString() -> String {
        switch serverEnvironment {
        case .development:
            return DMSAppConfiguration.baseUrl_Dev
        case .staging:
            return DMSAppConfiguration.baseUrl_Staging
        case .testing:
            return DMSAppConfiguration.baseUrl_Staging
        case .production:
            return DMSAppConfiguration.baseUrl_Product
        }
    }
    
    func baseImageUrlString() -> URL? {
        switch serverEnvironment {
        case .development:
            return URL(string:DMSAppConfiguration.baseUrl_Dev)
        case .staging:
            return URL(string: DMSAppConfiguration.baseUrl_Staging)
        case .testing:
            return URL(string: DMSAppConfiguration.baseUrl_Staging)
        case .production:
            return URL(string: DMSAppConfiguration.baseUrl_Product)
        }
    }
}
