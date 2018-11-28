//
//  API+User.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 11/27/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation


extension BaseAPIService{
    @discardableResult
    func getUserProfile(callback: @escaping APICallback<ResponseDataModel<UserModel>>) -> APIRequest {
        return request(method: .GET,
                       path: PATH_REQUEST_URL.GET_USER_PROFILE.URL,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func updateUserProfile(_ user:UserModel, callback: @escaping APICallback<ResponseDataModel<UserModel>>) -> APIRequest {
        return request(method: .PUT,
                       path: PATH_REQUEST_URL.UPDATE_USER_PROFILE.URL,
                       input: .dto(user),
                       callback: callback);
    }
    
    @discardableResult
    func login(_ userLogin:UserLoginModel, callback: @escaping APICallback<ResponseDataModel<UserModel>>) -> APIRequest {
        return request(method: .POST,
                       path: PATH_REQUEST_URL.LOGIN.URL,
                       input: .dto(userLogin),
                       callback: callback);
    }
    
    @discardableResult
    func logout(callback: @escaping APICallback<UserModel>) -> APIRequest {
        return request(method: .GET,
                       path:PATH_REQUEST_URL.LOGOUT.URL,
                       input: .empty,
                       callback: callback);
    }
    
    @discardableResult
    func forgotPassword(_ email: String, callback: @escaping APICallback<ResponseDataModel<EmptyModel>>) -> APIRequest {
        let params = ["email": email]
        return request(method: .POST,
                       path: PATH_REQUEST_URL.FORGET_PASSWORD.URL ,
                       input: .json(params),
                       callback: callback);
    }
    
    @discardableResult
    func changePassword(_ para: [String: Any], callback: @escaping APICallback<ChangePasswordModel>) -> APIRequest {
        return request(method: .POST,
                       path: PATH_REQUEST_URL.CHANGE_PASSWORD.URL,
                       input: .json(para),
                       callback: callback);
    }
    
    @discardableResult
    func getDrivingRule(callback: @escaping APICallback<DrivingRule>) -> APIRequest {
        return request(method: .GET,
                       path: PATH_REQUEST_URL.GET_DRIVING_RULE.URL,
                       input: .empty,
                       callback: callback);
    }
}
