//
//  RecordViewController.swift
//  ObenHeight
//
//  Created by Will on 9/23/15.
//  Copyright © 2015 FFORM. All rights reserved.
//

import UIKit
import Mixpanel

class IntroViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var check1: UIImageView!
    @IBOutlet weak var check2: UIImageView!
    @IBOutlet weak var check3: UIImageView!
    @IBOutlet weak var recordButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImage.image = ObenStyle.imageOfLogo
        check1.image = ObenStyle.imageOfCheckImage
        check2.image = ObenStyle.imageOfCheckImage
        check3.image = ObenStyle.imageOfCheckImage
        recordButton.onButtonTouch = { (sender:UIButton) in
            dispatch_async(dispatch_get_main_queue(), {
                
            
                AudioControl.shared.getPermission { (success:Bool) in
                    if(success){
                        self.performSegueWithIdentifier("recordVC", sender: self)
                    }else{
                        let alert = UIAlertController(title: "Uh oh", message: "You need to let us use your microphone to record your voice.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Open Preferences", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                            print("done")
                            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                            alert.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: { () -> Void in
                            print("alert closed")
                        })
                    }
                }
            })
        }
        
        Mixpanel.sharedInstance().track("Page Intro")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
