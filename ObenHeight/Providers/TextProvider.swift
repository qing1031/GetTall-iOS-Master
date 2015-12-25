//
//  TextProvider.swift
//  ObenHeight
//
//  Created by Will on 11/6/15.
//  Copyright © 2015 FFORM. All rights reserved.
//

import UIKit

class TextProvider: UIActivityItemProvider {

    var subject = ""
    var body = ""
    var url = ""

    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject?{
        print("Getting itemForActivityType \(activityType)")
        if(activityType == "com.google.Gmail.ShareExtension"){
            return "\(self.subject)\n\n\(self.url)"
        }
        return "\(self.body)\n\n\(self.url)"
    }
    override func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String{
        print("Getting subject \(activityType)")
        return self.subject
    }
}
