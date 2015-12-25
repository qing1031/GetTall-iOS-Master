
//  Created by Will on 1/20/15.
//  Copyright (c) 2015 FFORM. All rights reserved.
//

import UIKit

extension ObenStyle{
    class func dynamicImage(named:String) -> UIImage?{
        switch(named){
            
            default:
                return nil
        }
    }
}

@IBDesignable class BorderButton: UIButton {
    
    typealias buttonTouchInsideEvent = (sender: UIButton) -> ()
    // MARK: Internals views
    var button : UIButton = UIButton(frame: CGRectZero)
    var isAnimated = true
    let animationDuration = 0.15
    // MARK: Callback
    var onButtonTouch: buttonTouchInsideEvent?
    var lastLabelColor:UIColor = UIColor.whiteColor()
    private var originalBackground:UIColor = UIColor.clearColor()
    private var icon:UIImage?
    private var iv:UIImageView?
    private var pressDownState:Bool = false
    
    // MARK: IBSpec
    @IBInspectable var borderColor: UIColor = UIColor.blackColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.5 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderCornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = borderCornerRadius
        }
    }
    
    @IBInspectable var labelColor: UIColor = UIColor.blackColor() {
        didSet {
            self.button.setTitleColor(labelColor, forState: .Normal)
        }
    }
    
    @IBInspectable var labelText: String = "" {
        didSet {
            self.button.setTitle(labelText, forState: .Normal)
        }
    }
    
    @IBInspectable var labelFontSize: CGFloat = 11.0 {
        didSet {
            self.button.titleLabel?.font = UIFont(name: FONT_HEAVY, size: labelFontSize)
        }
    }
    
    @IBInspectable var bgColor: UIColor = UIColor.clearColor() {
        didSet {
            self.originalBackground = bgColor
            self.layer.backgroundColor = bgColor.CGColor
        }
    }
    @IBInspectable var highlightColor:UIColor?
    @IBInspectable var iconName: String = ""{
        didSet {
            if let img = ObenStyle.dynamicImage(iconName){
                icon = img
                
            }else{
                icon = nil
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
        self.setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        self.userInteractionEnabled = true
        
        self.button.addTarget(self, action: "onPress:", forControlEvents: .TouchDown)
        self.button.addTarget(self, action: "onPress:", forControlEvents: .TouchDragEnter)
        
        self.button.addTarget(self, action: "onRealPress:", forControlEvents: .TouchUpInside)
        self.button.addTarget(self, action: "onReset:", forControlEvents: .TouchUpInside)
        self.button.addTarget(self, action: "onReset:", forControlEvents: .TouchUpOutside)
        self.button.addTarget(self, action: "onReset:", forControlEvents: .TouchDragExit)
        self.button.addTarget(self, action: "onReset:", forControlEvents: .TouchCancel)

        //self.originalBackground = self.bgColor
    }
    
    // MARK: views setup
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.button.frame = self.bounds
        self.button.titleLabel?.textAlignment = .Center
        self.button.backgroundColor = UIColor.clearColor()
        
        if let icn = icon{
            if(self.iv == nil){
                self.iv = UIImageView(image: icn.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
                let pad = CGFloat(10.0)
                let dim = CGRectGetHeight(self.bounds) - CGFloat(pad*2)
                let centerPoint = CGPoint(x: CGRectGetWidth(self.bounds)/2 - (dim/2), y: ((CGRectGetHeight(self.bounds)/2)-(dim/2)))
                let leftPoint = CGPoint(x: CGRectGetMinX(self.button.titleRectForContentRect(self.bounds)) - dim - pad, y: pad)
                
                let textSize:CGPoint = self.labelText.isEmpty ? centerPoint : leftPoint
                //println("bounds: \(self.bounds)   left \(leftPoint)   center:\(centerPoint)  chosen:\(textSize)   icon: \(self.iconName)")
                self.iv!.frame = CGRect(x: textSize.x , y: textSize.y, width: dim, height: dim)
                self.iv!.contentMode = UIViewContentMode.ScaleAspectFit
                self.iv!.tintColor = self.labelColor
                self.addSubview(self.iv!)
            }
            
        }
        self.addSubview(self.button)
    }
    
    // MARK: Actions
    func onPress(sender: AnyObject) {
        pressDownState = true
        UIView.animateWithDuration(self.isAnimated ? self.animationDuration : 0, animations: {
            self.lastLabelColor = self.labelColor
            self.labelColor = UIColor.whiteColor()
            self.backgroundColor = self.highlightColor != nil ? self.highlightColor! : self.borderColor
        })
    }
    
    func onReset(sender: AnyObject) {
        if(pressDownState == false){
            return
        }
        pressDownState = false
        UIView.animateWithDuration(self.isAnimated ? self.animationDuration : 0, animations: {
            self.labelColor = self.lastLabelColor
            self.backgroundColor = self.originalBackground
        })
    }
    
    func onRealPress(sender: AnyObject) {
        pressDownState = true
        self.onReset(self)
        if let btn = sender as? UIButton{
            self.onButtonTouch?(sender: btn)
        }
        
    }
    
    func toggleEnabled(enValue:Bool?){
        if let v = enValue{
            self.enabled = v
        }else{
            self.enabled = !self.enabled
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = self.enabled ? 1.0 : 0.2
        })
    }
    
}

