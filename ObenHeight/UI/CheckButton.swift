//
//  CheckButton.swift
//  ObenHeight
//
//  Created by Will on 9/24/15.
//  Copyright © 2015 FFORM. All rights reserved.
//

import UIKit

@IBDesignable class CheckButton: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var onButtonTouch: ((Bool)->Void)?
    var img:UIImageView?
    var enabled = false
    
    required init?(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
        self.setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup(){
        
        
        
        self.userInteractionEnabled = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: "tap")
        self.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor.clearColor()
        img = UIImageView(image: ObenStyle.imageOfCheck(active: self.enabled))
        img!.frame = bounds
        img!.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(img!)
    }

    func setEnabledState(newValue:Bool, propagate:Bool = false){
        self.img?.image = ObenStyle.imageOfCheck(active: newValue)
        if(propagate){
            self.onButtonTouch?(newValue)
        }
        
        self.enabled = newValue
    }
    
    func tap(){
        print("tap")
        enabled = !enabled
        self.setEnabledState(enabled, propagate:true)
    }
}
