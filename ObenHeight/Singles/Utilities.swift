//
//  Utilities.swift
//  ObenProto
//
//  Created by Will on 6/15/15.
//  Copyright (c) 2015 FFORM. All rights reserved.
//
import UIKit

func safeBool(value:AnyObject) -> Bool{
    
    if let valBool = value as? Bool{
        return valBool
    }
    if let valStr = value as? String{
        return valStr == "false" ? false : true
    }
    
    return false
}
func safeInt(value:AnyObject?) -> Int{
    
    if let valInt = value as? Int{
        return valInt
    }
    if let valStr = value as? String{
        return Int(valStr)!
    }
    
    return 0
}
func safeStr(value:AnyObject?) -> String{
    
    if let valStr = value as? String{
        return valStr
    }
    if let valInt = value as? Int{
        return "\(valInt)"
    }
    
    return ""
}

class Utilities{
    
    class func setupDirectories(directories:Array<String>){
        print("Setup Directories")
        
        for path in directories{
            self.makeDirectory(path, clean:false)
        }
        
    }
    
    
    
    class func makeDirectory(path:String, clean:Bool){
        let fileManager = NSFileManager.defaultManager()
        if let newPath = self.urlForPath(path){
            var exists = fileManager.fileExistsAtPath(newPath.path!)

            if(clean && exists){
                do {
                    try fileManager.removeItemAtPath(newPath.path!)
                } catch _ {
                }
                exists = false
            }
            
            if(!exists){
                do {
                    try fileManager.createDirectoryAtPath(newPath.path!, withIntermediateDirectories: true, attributes: nil)
                } catch _ {
                }
            }
        }
        
    }
    
    class func urlForPath(path:String) -> NSURL? {
        
        if let docsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            let path = "\(docsPath)/\(path)"
            return NSURL(fileURLWithPath: path)
        }
        return nil
    }
    
    class func setTimeout(delay:Double, completion:()->Void){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            completion()
        }
    }
    
    class func alertWithMessage(message:String, title:String, view:UIViewController){
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            view.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    class func alertWithMessage(message:String, title:String, view:UIViewController, configurationHandler: ((UITextField) -> Void)?, complete:()->Void){
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {(a:UIAlertAction)->Void in
                complete()
            }))
            //alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addTextFieldWithConfigurationHandler(configurationHandler)

            view.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    class func downloadFromRemoteURL(url:NSURL, toFileURL:NSURL) -> Bool{
        let manager = NSFileManager.defaultManager()
        
        
        print("checking")
        
        if(manager.fileExistsAtPath(toFileURL.path!)){
            //manager.removeItemAtPath(toFileURL.path!, error: nil)
            return true
        }
        
        
        let soundData = NSData(contentsOfURL: url)
        print("file doesn't exist, download it to \(toFileURL.path!)")
        if((soundData?.writeToFile(toFileURL.path!, atomically: true)) == true){
            return true
        }
        print("fallback")
        return false
    }
    
    class func applyShadowToView( view:UIView, shadow:NSShadow){
        if let color = shadow.shadowColor as? UIColor{
            view.layer.shadowColor = color.CGColor
            view.layer.shadowOpacity = Float(CGColorGetAlpha(color.CGColor))
        }
        
        view.layer.shadowOffset = shadow.shadowOffset
        view.layer.shadowRadius = shadow.shadowBlurRadius
        
        view.clipsToBounds = false
    }
}