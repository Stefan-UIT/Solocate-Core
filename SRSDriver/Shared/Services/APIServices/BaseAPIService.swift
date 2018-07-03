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
        case notAuthorized = 401
        case serverError = 721
        case tokenFail = 603
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
        // setToken
        if let token = Caches().getTokenKeyLogin() {
            newHeaders["Authorization"] = "Bearer \(token)"
        }
    
        return newHeaders;
    }
    
    func request<RESULT:BaseModel, ERROR: APIError>(method: ParamsMethod,
                 serverURL: String  = E(RESTConstants.getBASEURL()),
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
        
        APILog("REQUEST", encoding.bodyStringValue);

        let request: DataRequest;
        
        request = sessionManager.request(url,
                                         method: alarmofireMethod,
                                         parameters: [:],
                                         encoding: encoding,
                                         headers: headers);

        request.responseJSON(queue: responsedCallbackQueue, options: .allowFragments) { (dataResponse) in
            
            let result: APIOutput<RESULT, ERROR>;
            
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
     
            switch dataResponse.result {
            case .success(let object):
                result = self.handleResponse(dataResponse: dataResponse, object: object)
                
            case .failure(let error):
                result = self.handleFailure(dataResponse: dataResponse, error: error)
            }
            
            DispatchQueue.main.async {
                callback(result);
            }
        };
        
        return APIRequest(alarmofireDataRequest: request);
    }
    
    
    
    func uploadMultipartFormData<RESULT:BaseModel, ERROR: APIError>(method: ParamsMethod,
                                serverURL:String  = E(RESTConstants.getBASEURL()),
                                headers:HTTPHeaders? = nil,
                                path: String,
                                input: [AttachFileModel],
                                callback:@escaping GenericAPICallback<RESULT, ERROR>) {
        
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
        
        func APILog(_ STATUS: String, _ MSG: String? = nil) {
            print(">>> [API]  [\( String(format: "%04u", identifier) )] [\( method )] [\( path )] \( STATUS )");
            if let msg = MSG { print("\( msg )\n\n"); }
        }
        
        APILog("REQUEST");

//        let headers = requestHeader(headers: headers) // Curently can't test with Sel2B server File

        //test
        let tempHeader = ["Authorization":"Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiIiLCJpYXQiOjE1MjgzNjY4MDUsImV4cCI6MTUyODQ1MzIwNSwibmFtZSI6IkRyaXZlciAxIDEiLCJqdGkiOjU1NH0.2rdhguvZ4K3bJZvO_AZKVQ9Vu4FfHQO5F3jrwDLfhHQ"]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for file  in input {
                multipartFormData.append(file.contentFile ?? Data(),
                                         withName: "file[]",
                                         fileName: E(file.name),
                                         mimeType: E(file.mimeType))
            }
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
           to: url, method: .post, headers: tempHeader) { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    print(response)
                    
                    var result: APIOutput<RESULT, ERROR>;

                    switch response.result {
                        case .success(let results):
                            
                            if let dic = results as? ResponseDictionary {
                                let data: ResponseDictionary = dic["data"] as! ResponseDictionary
                                let obj  = RESULT(JSON: data)!
                    
                                result = .object(obj)
                                
                            }else {
                                
                                print("Data response  invalid.")
                                
                                let obj = RESULT(JSON: [:])!
                                result  = .object(obj)
                            }
                            
                            break;
                        
                        case .failure(let error):
                            
                            let err = APIError() as! ERROR
                            err.message = error.localizedDescription
                        
                            result = .error(err)
                            
                            break;
                        
                    }
                    
                    DispatchQueue.main.async {
                        callback(result);
                    }
                    
                })
            case .failure(let error) :
                
                print(error)
                let err = APIError() as! ERROR
                err.message = error.localizedDescription
                
                var result: APIOutput<RESULT, ERROR>;
                result = .error(err)
                
                DispatchQueue.main.async {
                    callback(result);
                }
            }
        }
    }
}


fileprivate extension BaseAPIService{
    
    func handleResponse<RESULT:BaseModel, ERROR: APIError>(dataResponse: DataResponse<Any>, object: Any) -> APIOutput<RESULT, ERROR> {
        
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
                
                return .object(resultObject)
            }
            
        case .tokenFail,
             .notAuthorized:
            
        App().reLogin()
            
        default:
            break;
        }
        
        let err = ERROR(dataResponse: dataResponse)
        return .error(err)
    }
    
    
    func handleFailure<RESULT, ERROR: APIError>(dataResponse: DataResponse<Any>, error: Error) -> APIOutput<RESULT, ERROR>  {
        let err = ERROR(dataResponse: dataResponse)
        err.message = error.localizedDescription;

        return .error(err)
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
            
            for file in files {
                let data = file.getJsonObject(method: .POST)
                if let data = data as? Data {
                    mutiData.append(data);
                }else {
                    print("Data Invalid.")
                }
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
