
import Foundation

enum TagetBuild:String {
    case Development = "Development"
    case Production = "Production"
}


enum ServerEnvironment: String {
    case development = "development"
    case qc = "qc"
    case demo = "demo"
    case production = "production"

    init?(rawString: String) {
        self.init(rawValue: rawString.lowercased())
    }
    
    func serverUrlString() -> String {
        switch self {
        case .development:
            return DMSAppConfiguration.baseUrl_Dev
        case .qc:
            return DMSAppConfiguration.baseUrl_QC
        case .demo:
            return DMSAppConfiguration.baseUrl_Demo
        case .production:
            return DMSAppConfiguration.baseUrl_Product
        }
    }
}

//MARK: - Commons
struct BuildConfiguration {
    let serverEnvironment: ServerEnvironment
    let tagetBuild:TagetBuild
    var currentEnvironment: ChooseEvironment {
        get {
            let number = UserDefaults.standard.integer(forKey: "ENVIRONMENT")
            guard let environment = ChooseEvironment(rawValue: number)  else {
                return .Development
            }
            return environment
        }
    }
    init() {
        #if DEVELOPMENT  // check taget
        let number = UserDefaults.standard.integer(forKey: "ENVIRONMENT")
        guard let environment = ChooseEvironment(rawValue: number)  else {
            tagetBuild = .Development
            self.serverEnvironment = .development
            return
        }
        tagetBuild = .Development
        switch environment {
        case .QC:
            self.serverEnvironment = .qc
            break
        case .Demo:
            self.serverEnvironment = .demo
            break
        default:
            self.serverEnvironment = .development
            break
        }

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
        if let server = Debug.shared.useServer {
            return server
        }
        
        return serverEnvironment.serverUrlString()
    }
    
    func baseImageUrlString() -> URL? {
        switch serverEnvironment {
        case .development:
            return URL(string:DMSAppConfiguration.baseUrl_Dev)
        case .qc:
            return URL(string:DMSAppConfiguration.baseUrl_QC)
        case .demo:
            return URL(string:DMSAppConfiguration.baseUrl_Demo)
        case .production:
            return URL(string: DMSAppConfiguration.baseUrl_Product)
        }
    }
}
