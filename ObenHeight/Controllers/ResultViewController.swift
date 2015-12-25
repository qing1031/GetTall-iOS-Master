//
//  ResultViewController.swift
//  ObenHeight
//
//  Created by Will on 9/24/15.
//  Copyright © 2015 FFORM. All rights reserved.
//

import UIKit
import Mixpanel

class ResultViewController: UIViewController {

    var recording:RecordingModel!
    
    @IBOutlet weak var heightText: UILabel!
    @IBOutlet weak var heightBtn: CheckButton!
    @IBOutlet weak var ageText: UILabel!
    @IBOutlet weak var ageBtn: CheckButton!
    @IBOutlet weak var genderText: UILabel!
    @IBOutlet weak var genderBtn: CheckButton!
    @IBOutlet weak var uncheckMsg: UILabel!
    
    @IBOutlet weak var startoverButton: BorderButton!
    @IBOutlet weak var shareItButton: BorderButton!
    
    @IBOutlet weak var meterImage: UIImageView!

    var pickerHeight:UIPickerView!
    var pickerAge:UIPickerView!
    var lastAlertText:UITextField?
    var lastSetAge:Int?
    var lastSetHeight:Int?
    var arrow:UIView?
    
    let minAge = 10
    let maxAge = 99
    let minHeight = 18
    let maxHeight = 96
    
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerHeight = UIPickerView()
        pickerHeight.dataSource = self
        pickerHeight.delegate = self
        pickerAge = UIPickerView()
        pickerAge.dataSource = self
        pickerAge.delegate = self
        
        
        

        heightBtn.onButtonTouch = { (checked:Bool) in
            if(checked == false){
                
                Utilities.alertWithMessage("You want to tell us your real height?", title: "Oops", view: self, configurationHandler: { (textField:UITextField) -> Void in
                    textField.placeholder = "Your actual height"
                    self.pickerHeight.selectRow(self.recording.estimatedHeight! - self.minHeight, inComponent: 0, animated: false)
                    textField.inputView = self.pickerHeight
                    self.lastAlertText = textField
                    }, complete: {()->Void in
                        print("finished height")
                        if(self.lastSetHeight != nil){
                            
                            ObenAPI.shared.updateHeight(self.lastSetHeight!, recording: self.recording){ (rec:RecordingModel?) in
                                if(rec != nil){
                                    self.recording = rec
                                }
                                print(rec)
                            }
                            Mixpanel.sharedInstance().track("Corrected Height")
                            Mixpanel.sharedInstance().people.increment("Correction", by: 1)
                        }
                        self.lastSetHeight = nil
                        self.lastAlertText = nil
                })
            }else{
                self.heightText.text = self.getHeightFromInches(self.recording.estimatedHeight!)
            }
        }
        ageBtn.onButtonTouch = { (checked:Bool) in
            if(checked == false){
                Utilities.alertWithMessage("You want to tell us your real age?", title: "Oops", view: self, configurationHandler: { (textField:UITextField) -> Void in
                    textField.placeholder = "Your actual age"
                    self.pickerAge.selectRow(self.recording.estimatedAge! - self.minAge, inComponent: 0, animated: false)
                    textField.inputView = self.pickerAge
                    self.lastAlertText = textField
                }, complete: {()->Void in
                    print("finished age")
                    if(self.lastSetAge != nil){
                        ObenAPI.shared.updateAge(self.lastSetAge!, recording: self.recording){ (rec:RecordingModel?) in
                            if(rec != nil){
                                self.recording = rec
                            }
                            print(rec)
                        }
                        Mixpanel.sharedInstance().track("Corrected Age")
                        Mixpanel.sharedInstance().people.increment("Correction", by: 1)
                    }
                    self.lastSetAge = nil
                    self.lastAlertText = nil
                })
            }else{
                self.ageText.text = String(self.recording.estimatedAge!)
            }
        }
        genderBtn.onButtonTouch = { (checked:Bool) in
            let startMale = self.recording.estimatedGender! >= 0.5
            let currentGender:Double = (checked ? (startMale ? 1 : 0) : (startMale ? 0 : 1))
            self.genderText.text = (currentGender >= 0.5 ? "Male" : "Female")

            ObenAPI.shared.updateGender(currentGender, recording: self.recording){ (rec:RecordingModel?) in
                if(rec != nil){
                    self.recording = rec
                }
                print(rec)
            }
            Mixpanel.sharedInstance().track("Corrected Gender")
            Mixpanel.sharedInstance().people.increment("Correction", by: 1)
        }
        Utilities.setTimeout(0.5) { () -> Void in
            self.heightBtn.setEnabledState(true)
        }
        Utilities.setTimeout(0.7) { () -> Void in
            self.ageBtn.setEnabledState(true)
        }
        Utilities.setTimeout(0.9) { () -> Void in
            self.genderBtn.setEnabledState(true)
        }
        
        
        startoverButton.onButtonTouch = { (sender:UIButton) in
            self.navigationController?.popViewControllerAnimated(true)
        }
        shareItButton.onButtonTouch = { (sender:UIButton) in
            self.performSegueWithIdentifier("shareVC", sender: self)
        }
        
       
        
        Mixpanel.sharedInstance().track("Page Result")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let height = recording.estimatedHeight!
        heightText.text = getHeightFromInches(height)
        ageText.text = String(recording.estimatedAge!)
        genderText.text = recording.estimatedGender! >= 0.5 ? "Male" : "Female"
        meterImage.animationImages = nil
        var images = [UIImage]()
        for i in 1...48{
            var t = CGFloat(i)
            let b:CGFloat = 1.0, c:CGFloat = CGFloat(i)/48*CGFloat(height), d:CGFloat = 48.0
            t /= d
            let result = c * t * t + b
            images.append(ObenStyle.imageOfMeter(inches: result))
        }

        meterImage.image = ObenStyle.imageOfMeter(inches: CGFloat(height))
        meterImage.animationImages = images
        meterImage.animationRepeatCount = 1
        meterImage.animationDuration = 1.0
        meterImage.startAnimating()
        

        self.addArrow()
    }
    
    func addArrow(){
        if(UIScreen.mainScreen().bounds.height > 500){
            Utilities.setTimeout(0.5){
                if(self.arrow == nil){
                    let point = self.uncheckMsg.frame.origin
                    self.arrow = UIImageView(image: ObenStyle.imageOfArrow)
                    self.arrow!.frame = CGRect(x: point.x, y: point.y - self.arrow!.bounds.height + 15, width: self.arrow!.bounds.width, height: self.arrow!.bounds.height)
                    self.view.addSubview(self.arrow!)
                }
                
                self.arrow!.alpha = 0
                UIView.animateWithDuration(1.0) { () -> Void in
                    self.arrow!.alpha = 1
                }
            }
        }
    }
    
    func animateHeight(){
        self.timer?.timeInterval

        meterImage.image = ObenStyle.imageOfMeter(inches: CGFloat(recording.estimatedHeight!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getHeightFromInches(heightInInches:Int) -> String{
        if (NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue == true){
            let cm = Int(Double(heightInInches) * 2.54)
            return "\(cm)cm"
        }else{
            let ht = Float(heightInInches)
            let htFT = Int(floor( ht / 12 ))
            let htIN = Int(ht % 12)
            return "\(htFT)'" + (htIN != 0 ? "\(htIN)\"" : "")
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ShareViewController{
            vc.recording = self.recording
        }
    }

}

extension ResultViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if(pickerView == self.pickerAge){
            return maxAge - minAge
        }
        // Then Height
        return maxHeight - minHeight // Max 7', or 80" tall
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{

        if(pickerView == self.pickerAge){
            return "\(row+minAge)"
        }
        
        return getHeightFromInches(row + minHeight)
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
//        print("\(pickerView) selected \(row) in comp \(component)")
        if(pickerView == self.pickerAge){
            let age = row + minAge
            self.lastAlertText?.text = "\(age)"
            self.ageText.text = "\(age)"
            self.lastSetAge = age
        }else{
            //Heihgt
            let height = row + minHeight
            self.lastSetHeight = height
            self.lastAlertText?.text = "\(self.getHeightFromInches(height))"
            self.heightText.text = "\(self.getHeightFromInches(height))"
            
        }
        
    }
}
