//
//  AttachmentProvider.swift
//  ObenHeight
//
//  Created by Will on 11/6/15.
//  Copyright © 2015 FFORM. All rights reserved.
//

import UIKit

class AttachmentProvider: UIActivityItemProvider {
    
    var image:UIImage?
    
    override func item() -> AnyObject{
        return self.image ?? ""
    }
}
