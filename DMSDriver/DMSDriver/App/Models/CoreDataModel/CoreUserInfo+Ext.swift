//
//  CoreUserInfo+Ext.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 11/18/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation

extension CoreUserInfo{
    func setAttributeFrom(_ userInfo: UserModel.UserInfo? = nil)  {
        id = Int32(userInfo?.id ?? 0)
        userName = userInfo?.userName
        lastName = userInfo?.lastName
        firstName = userInfo?.firstName
        phone = userInfo?.phone
        email = userInfo?.email
        companyId = Int16(userInfo?.companyID ?? 0)
    }
    
    func convertToUserInfoModel() -> UserModel.UserInfo? {
        let userInfoJSON = [KEY_USER_ID:id,
                            KEY_EMAIL:(email ?? ""),
                            KEY_FIRST_NAME:(firstName ?? ""),
                            KEY_LAST_NAME:(lastName ?? ""),
                            KEY_PHONE:(phone ?? ""),
                            "username":(userName ?? ""),
                            "company_id":companyId] as [String:Any]
        let userInfo = UserModel.UserInfo(JSON: userInfoJSON)
        return userInfo
    }
}
