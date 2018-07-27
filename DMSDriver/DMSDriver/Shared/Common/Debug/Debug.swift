
import Foundation

class Debug {
    fileprivate let buildScheme: BuildScheme;
    fileprivate let environment: [String: String];
    
    init(buildConf: BuildConfiguration) {
        buildScheme = buildConf.buildScheme;
        
        if buildScheme == .debug {
            environment = ProcessInfo.processInfo.environment;
        }else{
            environment = [:];
        }
    }
    
    lazy var useServer: String? = self.environmentString(for: "SERVER")
    lazy var disableLoggingForAPI = self.environmentBool(for: "DISABLE_API_LOG")
}

//MARK: - instances

extension Debug{
    fileprivate(set) static var shared: Debug!;
    
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

