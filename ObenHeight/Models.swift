//
//  Models.swift
//  ObenHeight
//
//  Created by Will on 9/22/15.
//  Copyright © 2015 FFORM. All rights reserved.
//

import Foundation
import JSONJoy

struct UserModel: JSONJoy {
    let message: String?
    let phoneId: String?
    let userId: Int?
    
    init(_ decoder: JSONDecoder) {
        message = decoder["User"]["message"].string
        phoneId = decoder["User"]["phoneId"].string
        userId = decoder["User"]["userId"].integer
    }
}

struct RecordingModel: JSONJoy {
    let actualAge: Int?
    let actualGender: Float?
    let actualHeight: Int?
    let email: String?
    let estimatedAge: Int?
    let estimatedGender: Float?
    let estimatedHeight: Int?
    let message: String!
    let recordId: Int?
    let recordURL: String!
    let selfieURL: String!
    let userId: Int?
    let valid: Bool
    
    init(_ decoder: JSONDecoder) {
        actualAge = decoder["Record"]["actualAge"].integer
        actualGender = decoder["Record"]["actualGender"].float
        actualHeight = decoder["Record"]["actualHeight"].integer
        email = decoder["Record"]["email"].string
        estimatedAge = decoder["Record"]["estimatedAge"].integer
        estimatedGender = decoder["Record"]["estimatedGender"].float
        estimatedHeight = decoder["Record"]["estimatedHeight"].integer
        message = decoder["Record"]["message"].string ?? ""
        recordId = decoder["Record"]["recordId"].integer
        recordURL = decoder["Record"]["recordURL"].string!
        selfieURL = decoder["Record"]["selfieURL"].string!
        userId = decoder["Record"]["userId"].integer
        valid = (!decoder["Record"]["message"].string!.isEmpty && decoder["Record"]["message"].string! == "SUCCESS")
    }
}
