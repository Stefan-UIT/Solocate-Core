
import Foundation

class Debug {
    //fileprivate let buildScheme: BuildScheme;
    fileprivate let environment: [String: String];
    
    var serverEnvironment:ServerEnvironment?
    var useServer: String?
    lazy var disableLoggingForAPI = self.environmentBool(for: "DISABLE_API_LOG")
    
    init(useServer:String? = nil) {
        if SDBuildConf.tagetBuild == .Production {
            environment = [:]
        }else {
            environment = ProcessInfo.processInfo.environment
            self.useServer = useServer
            if  useServer == nil {
                self.useServer = self.environmentString(for: "SERVER")
            }
        }
    }
}

//MARK: - instances

extension Debug{
    fileprivate(set) static var shared: Debug?
    
    static func setup(shared: Debug) {
        self.shared = shared;
    }
}


//MARK: - Utils

fileprivate extension Debug {
    
    func environmentStringArray(for key: String) -> [String]? {
        guard let value = environment[key] else {
            return nil;
        }

        return value.components(separatedBy: ",")
    }
    
    func environmentIntArray(for key: String) -> [Int]? {
        guard let values = environmentStringArray(for: key) else {
            return nil;
        }
        
        return values.flatMap({ (string) -> Int? in
            return Int(string);
        })
    }
    
    func environmentString(for key: String) -> String? {
        return environment[key];
    }
    
    func environmentBool(for key: String) -> Bool {
        guard let value = environment[key] else {
            return false;
        }
        
        guard let boolValue = Bool(value) else{
            return false;
        }
        
        return boolValue;
    }
}

