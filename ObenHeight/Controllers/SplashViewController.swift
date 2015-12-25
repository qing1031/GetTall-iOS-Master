//
//  ViewController.swift
//  ObenHeight
//
//  Created by Will on 9/22/15.
//  Copyright © 2015 FFORM. All rights reserved.
//

import UIKit
import AVFoundation
import Mixpanel

class SplashViewController: UIViewController {
    
    @IBOutlet weak var startButton: BorderButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var obenImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("init user")
        
        logoImage.image = ObenStyle.imageOfLogo
        obenImage.image = ObenStyle.imageOfObenLogo
        
        ObenAPI.shared.initUser{ (user:UserModel?) in
            print("done",user)
            if(Preferences.shared.hasSeenEULA){
                let permission = AVAudioSession.sharedInstance().recordPermission()
                let targetVC = (permission == AVAudioSessionRecordPermission.Granted ? "jumpToRecordVC" : "introVC")
                dispatch_async(dispatch_get_main_queue(), {

                    self.performSegueWithIdentifier(targetVC, sender: self)
                })
                Mixpanel.sharedInstance().identify(Preferences.shared.phoneID)
            }
        }
        if(Preferences.shared.hasSeenEULA){
            startButton.hidden = true
        }
        startButton.onButtonTouch = {(sender:UIButton) in
            self.presentEULA()
        }
        
        Mixpanel.sharedInstance().track("Page Splash")
    }
    
    func presentEULA(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("eulaVC") as! EulaViewController
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        vc.onComplete = {(success:Bool) in
            if(success){
                Preferences.shared.hasSeenEULA = true
                self.performSegueWithIdentifier("introVC", sender: self)
            }
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

