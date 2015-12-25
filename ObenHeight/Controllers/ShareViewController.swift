//
//  ShareViewController.swift
//  ObenHeight
//


import UIKit
import Mixpanel

class ShareViewController: UIViewController {
    
    var recording:RecordingModel!
    
    
    @IBOutlet weak var exportView: UIView!

    @IBOutlet weak var barsLeftImage: UIImageView!
    @IBOutlet weak var barsRightImage: UIImageView!
    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var overlayImage: UIImageView!

    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    
    @IBOutlet weak var addPhotoButton: BorderButton!
    @IBOutlet weak var shareButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barsLeftImage.image = ObenStyle.imageOfBars
        barsRightImage.image = UIImage(CGImage: ObenStyle.imageOfBars.CGImage!, scale: 1.0, orientation: UIImageOrientation.UpMirrored)
        picImage.image = ObenStyle.imageOfEmptyProfile
        overlayImage.image = ObenStyle.imageOfProfileOverlay

        heightLabel.text = self.getHeightFromInches(self.recording.estimatedHeight!)
        
        ageLabel.text = "\(self.recording.estimatedAge!)"
        
        let gender = self.recording.estimatedGender >= 0.5 ? "Male" : "Female"
        genderLabel.text = gender
        
        addPhotoButton.onButtonTouch = { sender in
            dispatch_async(dispatch_get_main_queue(), {
                self.addPhoto()
                Mixpanel.sharedInstance().track("Tap Add Photo")
            })
        }
        
        shareButton.onButtonTouch = { sender in
            dispatch_async(dispatch_get_main_queue(), {
              self.actionExport()
              Mixpanel.sharedInstance().track("Tap Share")
            })
        }
        
        //let tap = UITapGestureRecognizer(target: self, action: "tap")
        //self.view.addGestureRecognizer(tap)
        Mixpanel.sharedInstance().track("Page Share")
    }
    func tap(){
        showAlert("Added to camera roll!")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("will appear share")
        super.viewWillAppear(animated)
        addPhotoButton.labelText = "Add Selfie"
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
    
    @IBAction func actionStartOver(sender:UIButton){
        if(Preferences.shared.isRegistered){
            navigateToRecordingViewController()
        }else{
            
            var refText:UITextField?
            let alert = UIAlertController(title: "Stay in the loop", message: "Would you like to register for future updates and fun new apps from Oben Inc. ?", preferredStyle: UIAlertControllerStyle.Alert)

            alert.addAction(UIAlertAction(title: "Register", style: UIAlertActionStyle.Default, handler: {action in
                if let email = refText?.text{
                    ObenAPI.shared.updateEmail(email, recording: self.recording, complete: { (rec:RecordingModel?) -> Void in
                        Preferences.shared.isRegistered = true
                        self.navigateToRecordingViewController()
                    })
                    Mixpanel.sharedInstance().track("Registered")
                }else{
                    self.navigateToRecordingViewController()
                }
                
                
            }))
            alert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.Cancel, handler: {action in
                self.navigateToRecordingViewController()
                Mixpanel.sharedInstance().track("Register No Thanks")
            }))
                alert.addTextFieldWithConfigurationHandler({ (textField:UITextField) -> Void in
                textField.placeholder = "Enter your email address"
                textField.keyboardType = UIKeyboardType.EmailAddress
                refText = textField
            })
            
            self.presentViewController(alert, animated: true, completion: nil)
        
            Mixpanel.sharedInstance().people.increment("Saw Registration", by: 1)
            
        }
        
        Mixpanel.sharedInstance().track("Tap try again")
    }
    
    func navigateToRecordingViewController(){
        dispatch_async(dispatch_get_main_queue(), {
            for vc in (self.navigationController?.viewControllers)!{
                if let recVC = vc as? RecordViewController{
                    self.navigationController?.popToViewController(recVC, animated: true)
                }
            }
        })
        
    }
    
    func addPhoto(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            self.pickPhotoWithCamera(false)
        }))
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                self.pickPhotoWithCamera(true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pickPhotoWithCamera(camera:Bool){
        let picker = UIImagePickerController()
        picker.delegate = self

        if(!camera){
            picker.sourceType = .PhotoLibrary
        }else{
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
        }
        
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true,completion:nil)
    }
    
    func generateExportImage(forCameraRoll:Bool) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.exportView.frame.size, true, 2.0)
        if(forCameraRoll){
            exportView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        }else{
            exportView.drawViewHierarchyInRect(exportView.bounds, afterScreenUpdates: false)
        }

        let snap = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snap
    }
    
    @IBAction func actionExport(){

        let snap = generateExportImage(false)
        let data = UIImageJPEGRepresentation(snap, 1.0)
        let url = Utilities.urlForPath("export.jpg")!
        data?.writeToFile(url.path!, atomically: true)

        let text = TextProvider(placeholderItem: "blah")
        text.subject = "Check out this app called HowTall"
        text.body = "HowTall.me predicted my Height, Age and Gender based on my voice! How Tall do YOU sound?"
        text.url = "https://appsto.re/us/R0nt-.i"
        
        let attachment = AttachmentProvider(placeholderItem:"placeholder attachment")
        attachment.image = UIImage(data: data!)
        
        let objectsToShare:[AnyObject] = [text, attachment]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact]

        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func showAlert(message:String){
        let height = 100.0
        let screen = UIScreen.mainScreen().bounds
        
        let destination = CGRect(x: 0, y: 0, width: Double(screen.width), height: height)
        let origin = CGRect(x:0,y:0,width:destination.width,height:0)
        
        let alert = UIView(frame: destination)
        alert.backgroundColor = ObenStyle.mediumOrange
        alert.clipsToBounds = true
        alert.frame = origin
        Utilities.applyShadowToView(alert, shadow: ObenStyle.shadow)
        
        let text = UILabel(frame: origin)
        text.text = message
        text.textAlignment = .Center
        text.textColor = UIColor.whiteColor()
        
        alert.addSubview(text)
        UIView.animateWithDuration(0.3, delay: 0.3, usingSpringWithDamping: 10, initialSpringVelocity: 20, options: [], animations: { () -> Void in
            alert.frame = destination
            text.frame = destination
        }, completion: nil)
        
        self.view.addSubview(alert)
        Utilities.setTimeout(3.0){
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 20, options: [], animations: { () -> Void in
                alert.frame = origin
                text.frame = origin
                text.alpha = 0
            }, completion: { success in
                alert.removeFromSuperview()
            })
        }
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


extension ShareViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        var img:UIImage?
        if let original = info[UIImagePickerControllerOriginalImage] as? UIImage{
            img = original
        }
        if let edited = info[UIImagePickerControllerEditedImage] as? UIImage{
            if(img == nil){
                img = edited
            }
        }
        if(img != nil){
            self.picImage.image = img!
            
            let snap = generateExportImage(true)
            let rect = CGRectMake(0, 0, snap.size.width, snap.size.height)
            UIGraphicsBeginImageContext(rect.size)
            snap.drawInRect(rect)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(result, nil, "", nil)
            if let compressed = UIImageJPEGRepresentation(img!, 0.8){
                
                print("uploading selfie photo")
                ObenAPI.shared.uploadSelfie(compressed, recording: self.recording, complete: { (rec:RecordingModel?) -> Void in
                    if let newRecording = rec{
                        print("uploaded")
                        self.recording = newRecording
                    }else{
                        print("erro")
                    }
               })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.addPhotoButton.labelText = "Change Selfie"
                self.showAlert("Saved to Camera Roll!")
            })
            
            
            Mixpanel.sharedInstance().track("Added Picture")
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
