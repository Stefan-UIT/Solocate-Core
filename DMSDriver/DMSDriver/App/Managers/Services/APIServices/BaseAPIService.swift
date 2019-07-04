//
//  BaseAPIService.swift
//  Sel2B
//
//  Created by machnguyen_uit on 6/5/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import Foundation
import Alamofire;
import ObjectMapper

fileprivate var __identifier: UInt = 0;

//MARK: - Types
enum ParamsMethod : String {
    
    case GET = "GET";
    case POST = "POST";
    case PUT = "PUT";
    case PATCH = "PATCH";
    case DELETE = "DELETE";
    case DISK_SAVING = "DISK_SAVING";
}

enum APIOutput<T:Any, E> {
    case object(T);
    case error(E);
}

enum APIInput {
    case empty;
    case dto(BaseModel); //dto: DataObject
    case json(Any); //dic: Dictionary
    case str(String, in: String?); //str: String
    case data(Data);
    case mutiFile([AttachFileModel])
}

protocol APIDataPresentable {
    var rawData: Data? {get set}
    var rawObject: Any? {get set}

}

typealias APIParams = [String: Any];
typealias GenericAPICallback<RESULT, ERROR> = (_ result: APIOutput<RESULT, ERROR>) -> Void;
typealias APICallback<RESULT> = GenericAPICallback<RESULT, APIError>;

class BaseAPIService {
    
    
    enum StatusCode: Int {
        case success = 200
        case invalidInput = 400
        case notAuthorized = 603
        case serverError = 721
        case tokenFail = 403
        case tokenExpried = 401
        
        
        var messange:String{
            get{
                switch self {
                case .tokenExpried:
                    return "session-expired".localized
                default:
                    return ""
                }
            }
        }
    }
    
    fileprivate static var sharedAPI:BaseAPIService?
    fileprivate let sessionManager: SessionManager;
    fileprivate let responsedCallbackQueue: DispatchQueue;

    
    static func shared() -> BaseAPIService {
        if BaseAPIService.sharedAPI == nil {
            let smConfig = URLSessionConfiguration.default
            smConfig.timeoutIntervalForRequest = 30;
            let sessionMgr: SessionManager = SessionManager(configuration: smConfig);
            BaseAPIService.sharedAPI = BaseAPIService(sessionMgr: sessionMgr);
        }
        return BaseAPIService.sharedAPI!;
    }
    
    
    init(sessionMgr:SessionManager) {
        sessionManager = sessionMgr;
        responsedCallbackQueue = DispatchQueue.init(label: "api_responsed_callback_queue");
    }
    
    func getHeaders() -> HTTPHeaders {
        
        let headers = ["Content-Type": "application/json",
                       "Accept": "application/json"]
        
        return headers
    }
    
    
    func requestHeader(headers:HTTPHeaders?,
                       url: String? = nil,
                       method: ParamsMethod? = .GET,
                       bodyData: Data? = nil,
                       bodyString: String? = nil) -> HTTPHeaders {
        var newHeaders = getHeaders()
        
        if let hds = headers {
            newHeaders = hds
        }
        
        let localizationCode = Locale.current.languageCode == "he" ? "hb" : "en"
        newHeaders["x-localization"] = localizationCode
        // setToken
        if let token = Caches().getTokenKeyLogin() {
            newHeaders["Authorization"] = "Bearer \(token)"
        }
    
        return newHeaders;
    }
    
    func request<RESULT:BaseModel, ERROR: APIError>(method: ParamsMethod,
                 serverURL: String  = E(SDBuildConf.serverUrlString()),
                 headers:HTTPHeaders? = nil,
                 path: String,
                 input: APIInput,
                 callback:@escaping GenericAPICallback<RESULT, ERROR>) -> APIRequest{
        
        __identifier += 1;
        
        let identifier = __identifier;
        
        let url = serverURL.appending(path);
        
        var alarmofireMethod: HTTPMethod;
        switch method {
        case .POST:
            alarmofireMethod = .post;
            break;
        case .PUT:
            alarmofireMethod = .put;
            break;
        case .PATCH:
            alarmofireMethod = .patch;
            break;
        case .DELETE:
            alarmofireMethod = .delete;
            break;
        default:
            alarmofireMethod = .get;
            break;
        }
        
        func APILog(_ STATUS: String, _ MSG: String?) {
            print(">>> [API]  [\( String(format: "%04u", identifier) )] [\( method )] [\( url)] \( STATUS )");
            if let msg = MSG { print("\( msg )\n\n"); }
        }
        
        let encoding = APIEncoding(input, method: method);
        
        let headers = requestHeader(headers: headers,
                                    url: url,
                                    method: method,
                                    bodyData: encoding.bodyDataValue,
                                    bodyString: encoding.bodyStringValue)
        
        if (Debug.shared.disableLoggingForAPI == false) {
            DispatchQueue.global().async {
                APILog("REQUEST", encoding.bodyStringValue);
            }
        }
        
        var request: DataRequest;

        request = sessionManager.request(url,
                                         method: alarmofireMethod,
                                         parameters: [:],
                                         encoding: encoding,
                                         headers: headers);
        
        request.responseJSON(queue: responsedCallbackQueue,
                             options: .allowFragments) {[weak self] (dataResponse) in
                                
                                self?.handleResponseJSON(dataResponse: dataResponse, callback: callback)

                                if Debug.shared.disableLoggingForAPI == false {
                                    DispatchQueue.global().async {
                                        let logResult = dataResponse.data != nil ? String(data: dataResponse.data!, encoding: .utf8) : "<empty>";
                                        var logStatus : String;
                                        if let statusCode = dataResponse.response?.statusCode {
                                            logStatus = String(statusCode);
                                        }else if let anError = dataResponse.error {
                                            logStatus = "\(anError)";
                                        }else{
                                            logStatus = "Unexpected Error!";
                                        }
                                        
                                        APILog("RESPONSE-\(logStatus)", logResult);
                                    }
                                }
                        
        };
        
        return APIRequest(alarmofireDataRequest: request);
    }
    
    
    func requestWithFormDataType<RESULT:BaseModel, ERROR: APIError>(url: String,
                     method:HTTPMethod,
                     files: [AttachFileModel]?,
                     parameters: [String : Any],
                     callback:@escaping GenericAPICallback<RESULT, ERROR>){
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "Authorization": "Bearer \(E(Caches().getTokenKeyLogin()))"
        ]
        
        func APILog(_ STATUS: String, _ MSG: String?) {
            print(">>> [API]  [] [\( method )] [\( url)] \( STATUS )");
            if let msg = MSG { print("\( msg )\n\n"); }
        }
        
        func parseJson(_ rawObject: Any) -> (data: Data, string: String)? {
            
            guard let jsonData = (try? JSONSerialization.data(withJSONObject: rawObject, options: .init(rawValue: 0))) else {
                print("Couldn't parse [\(rawObject)] to JSON");
                return nil;
            }
            
            let jsonString = String(data: jsonData, encoding: .utf8)!;
            return (data: jsonData, string: jsonString);
        }
        
        if Debug.shared.disableLoggingForAPI == false {
            DispatchQueue.global().async {
                APILog("REQUEST", parseJson(parameters)?.string);
            }
        }
        
        Alamofire.upload(multipartFormData: {(multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            for i in 0..<(files?.count ?? 0) {
                if let file = files?[i]{
                    multipartFormData.append(file.contentFile ?? Data(),
                                             withName: E(file.param),
                                             fileName: E(file.name), mimeType: "\(E(file.mimeType))")
                }
            }
            
            print("Uploading file ...")
            
        }, usingThreshold: UInt64.init(), to: url, method: method, headers: headers) {[weak self] (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    self?.handleResponseJSON(dataResponse: response, callback: callback)

                    if Debug.shared.disableLoggingForAPI == false {
                        let logResult = response.data != nil ? String(data: response.data!, encoding: .utf8) : "<empty>";
                        var logStatus : String;
                        if let statusCode = response.response?.statusCode {
                            logStatus = String(statusCode);
                        }else if let anError = response.error {
                            logStatus = "\(anError)";
                        }else{
                            logStatus = "Unexpected Error!";
                        }
                        
                        APILog("RESPONSE-\(logStatus)", logResult);
                    }
                }
                
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                let err = APIError()
                err.message = error.localizedDescription;
                
                DispatchQueue.main.async {
                    callback(.error(err as! ERROR))
                }
            }
        }
    }
 }


fileprivate extension BaseAPIService{
    
    func handleResponseJSON<RESULT:BaseModel,ERROR:APIError>(dataResponse: DataResponse<Any>,callback:@escaping GenericAPICallback<RESULT, ERROR>)  {
        switch dataResponse.result {
        case .success(let object):
            self.handleResponse(dataResponse: dataResponse, object: object, callback: callback)
            
        case .failure(let error):
            self.handleFailure(dataResponse: dataResponse, error: error, callback: callback)
        }
    }
    
    func handleResponse<RESULT:BaseModel, ERROR: APIError>(dataResponse: DataResponse<Any>,
                                                           object: Any,
                                                           callback:@escaping GenericAPICallback<RESULT, ERROR>){
        
        let status: StatusCode = StatusCode(rawValue: (dataResponse.response?.statusCode)!) ?? .serverError
        switch status {
        case .success:
            
            var newResults:ResponseDictionary = [:]
            
            if let dic = object as? ResponseDictionary {
                newResults = dic
            }else if let rs =  object as? ResponseArray {
               newResults = ["data": rs]
            }else {
                print("Invalid Response Data.");
            }

            if var resultObject = RESULT(JSON: newResults) {
                	
                if var responseData = resultObject as? APIDataPresentable{
                    responseData.rawData = dataResponse.data ?? Data()
                    responseData.rawObject = object
                    
                    resultObject = responseData as! RESULT
                }
                
                DispatchQueue.main.async {
                    callback(.object(resultObject));
                }
            }
            
        case .tokenFail,
             .tokenExpried,
             .notAuthorized:
            let err = ERROR(dataResponse: dataResponse)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                App().reLogin()
                App().showAlert(err.getMessage())
                callback(.error(err));
            }

        default:
            let err = ERROR(dataResponse: dataResponse)
            DispatchQueue.main.async {
                callback(.error(err));
            }
        }
    }
    
    
    func handleFailure<RESULT, ERROR: APIError>(dataResponse: DataResponse<Any>,
                                                error: Error,
                                                callback:@escaping GenericAPICallback<RESULT, ERROR>){
        let err = ERROR(dataResponse: dataResponse)
        err.message = error.localizedDescription;
        DispatchQueue.main.async {
            callback(.error(err));
        }
    }
}

//MARK: - Encoding
extension BaseAPIService {
    
    struct APIEncoding: ParameterEncoding {
        
        var bodyStringValue: String? = nil
        var bodyDataValue: Data? = nil
        
        init(_ theInput: APIInput, method: ParamsMethod) {
            
            func parseJson(_ rawObject: Any) -> (data: Data, string: String)? {
                
                guard let jsonData = (try? JSONSerialization.data(withJSONObject: rawObject, options: .init(rawValue: 0))) else {
                    print("Couldn't parse [\(rawObject)] to JSON");
                    return nil;
                }
                
                let jsonString = String(data: jsonData, encoding: .utf8)!;
                return (data: jsonData, string: jsonString);
            }
            
            switch theInput {
            case .empty:
                bodyStringValue = nil;
                bodyDataValue = nil;
                
            case .dto(let info):
                let params = info.getJsonObject(method: method)
                if (((params as? ResponseDictionary) != nil) ||
                    ((params as? ResponseArray) != nil))  {
                    
                    let jsonValues = parseJson(params);
                    bodyStringValue = jsonValues?.string;
                    bodyDataValue = jsonValues?.data;
                    
                }else if let prs = params as? Data {
                    bodyStringValue = String.init(data: prs, encoding: .utf8);
                    bodyDataValue = prs;
                }
                
            case .json(let jsonObject):
                let jsonValues = parseJson(jsonObject);
                bodyStringValue = jsonValues?.string;
                bodyDataValue = jsonValues?.data;
                
            case .str(let string, let inString):
                let sideString = inString ?? "";
                bodyStringValue = "\(sideString)\(string)\(sideString)";
                bodyDataValue = bodyStringValue?.data(using: .utf8, allowLossyConversion: true);
                
            case .data(let data):
                bodyStringValue = String.init(data: data, encoding: .utf8);
                bodyDataValue = data;
                
            case .mutiFile(let files):
                bodyDataValue = getMutiDataFromFile(files: files);
                bodyStringValue = String.init(data: bodyDataValue!, encoding: .utf8);
            }
            
        }
        
        func getMutiDataFromFile(files:[AttachFileModel]) -> Data {
            let mutiData:NSMutableData = NSMutableData()
            
            for i in 0..<files.count {
                let file = files[i]
                let data = file.getDataObject()
                
                mutiData.append(data as Data);
            }
            
            return mutiData as Data;
        }
        
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try urlRequest.asURLRequest();
            request.httpBody = bodyDataValue;
            return request;
        }
    }
}

//MARK: - API Request

public class APIRequest {
    
    private var alarmofireDataRequest: DataRequest? = nil;
    
    required public init(alarmofireDataRequest request: DataRequest){
        alarmofireDataRequest = request;
    }
    
    public func cancel() {
        if let request = alarmofireDataRequest {
            request.cancel();
        }
    }
    
}
