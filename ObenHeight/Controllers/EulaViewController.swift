//
//  EulaViewController.swift
//  desi
//
//  Created by Will on 9/4/15.
//  Copyright (c) 2015 FFORM. All rights reserved.
//

import UIKit
import SwiftHTTP
import Mixpanel

class EulaViewController: UIViewController {

    var onComplete:((success:Bool)->Void)?
    
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var noButton: BorderButton!
    @IBOutlet weak var yesButton: BorderButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clearColor()
        
        noButton.onButtonTouch = { (sender:UIButton) in
            self.closeModal(false)
        }
        yesButton.onButtonTouch = { (sender:UIButton) in
            self.closeModal(true)
        }
        let tap = UITapGestureRecognizer(target: self, action: "tapClose")
        darkView.addGestureRecognizer(tap)
        
        drawerView.layer.cornerRadius = 5.0
        buttonsView.layer.cornerRadius = 5.0
        
        if let url = NSBundle.mainBundle().URLForResource("assets/eula", withExtension: "rtf"){
            textView.text = "Loading"
            textView.scrollEnabled = false
            let data = NSData(contentsOfFile: url.path!)!
            textView.attributedText = try! NSAttributedString(data: data, options: [:], documentAttributes: nil)
            textView.scrollEnabled = true
        }else{
            textView.text = "Couldn't load EULA"
        }
        // Do any additional setup after loading the view.
        Mixpanel.sharedInstance().track("Page Eula")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.darkView.alpha = 0
        UIView.animateWithDuration(0.5, delay: 0.3, options: .CurveEaseInOut, animations: { () -> Void in
            self.darkView.alpha = 1
        }, completion: nil)
       
        Utilities.setTimeout(0.1){
            self.textView.scrollRectToVisible(CGRectMake(0,0,1,1), animated: false)
        }
    }
    
    func tapClose(){
        closeModal(false)
    }
    
    func closeModal(action:Bool){
        
        self.dismissViewControllerAnimated(true){
            self.onComplete?(success:action)
        }
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
