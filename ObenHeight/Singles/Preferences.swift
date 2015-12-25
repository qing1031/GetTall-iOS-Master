//
//  Preferences.swift
//  ObenProto
//
//  Created by Will on 2/28/15.
//  Copyright (c) 2015 FFORM. All rights reserved.
//

import UIKit
import Security

class Preferences {
    
    private let manager = NSUserDefaults.standardUserDefaults()

    private let kIdentifier = "ObenProto"
    private let kPhoneId = "phoneId"
    private let kEULA = "eula"
    private let kReg = "registered"
    
    class var shared: Preferences {
        struct Static {
            static let instance: Preferences = Preferences()
        }
        return Static.instance
    }
    
    var phoneID: String{
        get{
            var val = self.manager.stringForKey(kPhoneId)
            if( val == nil ){
                val = NSUUID().UUIDString
                self.manager.setObject(val, forKey: kPhoneId)
            }
            return val!
        }
        set{
            self.manager.setObject(newValue, forKey: kPhoneId)
        }
    }
    
    var hasSeenEULA: Bool{
        get{
            return self.manager.boolForKey(kEULA)
        }
        set{
            self.manager.setBool(newValue, forKey: kEULA)
        }
    }
    
    var isRegistered: Bool{
        get{
            return self.manager.boolForKey(kReg)
        }
        set{
            self.manager.setBool(newValue, forKey: kReg)
        }
    }
}
