
import UIKit

//MARK: - Windows
extension BuildConfiguration {
    
    func serverUrlString() -> String {
        let  string: String = RESTConstants.getBASEURL() ?? "SERVER - INVALIDATE!"

        return string
    }
    
    func baseImageUrlString() -> URL {
        return URL(string: "IMAGE_SERVER_URL")!;
    }
}
