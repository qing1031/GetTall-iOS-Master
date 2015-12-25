//
//  RecordViewController.swift
//  ObenHeight
//
//  Created by Will on 9/23/15.
//  Copyright © 2015 FFORM. All rights reserved.
//

import UIKit
import Mixpanel

class RecordViewController: UIViewController {

    @IBOutlet weak var titleImage: UIImageView!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recButton: UIButton!
    @IBOutlet weak var examplePhrase: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var phraseContainer: UIView!
    
    var lastRecording: RecordingModel?
    var originalStatus:String!
    var loadingView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recButton.setImage(ObenStyle.imageOfRecButton(active: false), forState: .Normal)
        recButton.setImage(ObenStyle.imageOfRecButton(active: true), forState: .Highlighted)
        recButton.backgroundColor = UIColor.clearColor()
        
        titleImage.image = ObenStyle.imageOfTimeToRecord
        originalStatus = statusLabel.text!
        
        if let path = Utilities.urlForPath("debug-recording.wav"){
            skipButton.hidden = !NSFileManager.defaultManager().fileExistsAtPath(path.path!)
        }
        
        loadingView = UIView(frame: self.view.frame)
        loadingView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        loadingView.alpha = 0
        let spin = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        spin.color = ObenStyle.blk
        spin.frame = CGRect(x: CGRectGetMidX(view.frame)-25, y: CGRectGetMidY(view.frame)-25, width: 50, height: 50)
        loadingView.addSubview(spin)
        spin.startAnimating()
        self.view.addSubview(loadingView)
        
        AudioControl.shared.setupRecorder()
        
        Mixpanel.sharedInstance().track("Page Record")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.alpha = 0
        if(!originalStatus.isEmpty){
            statusLabel.text = originalStatus
        }
        let phrases = [
            "When the sunlight strikes raindrops in the air, they act like a prism and form a rainbow.",
            "The rainbow is a division of white light into many beautiful colors.",
            "There is, according to legend, a boiling pot of gold at one end.",
            "People look, but no one ever finds it.",
            "She had your dark suit in greasy wash water all year.",
            "Don't ask me to carry an oily rag like that.",
            "The eastern coast is a place for pure pleasure and excitement."
        ]
        let randomIndex = Int(arc4random_uniform(UInt32(phrases.count)))
        examplePhrase.text = phrases[randomIndex]
    }

    @IBAction func tapStart(sender: AnyObject) {
        AudioControl.shared.record()
        statusLabel.text = "Recording ..."
        UIView.animateWithDuration(0.2) { () -> Void in
            self.phraseContainer.backgroundColor = ObenStyle.red
        }
        Mixpanel.sharedInstance().track("Recording Started")
        Mixpanel.sharedInstance().people.increment("Recordings", by: 1)
    }
    
    @IBAction func tapStop(sender: AnyObject) {
        AudioControl.shared.stop()
        statusLabel.text = "Processing"
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.phraseContainer.backgroundColor = ObenStyle.green
            self.loadingView.alpha = 1.0
        }
        self.uploadMorph()
    }
    
    func uploadMorph(){

        ObenAPI.shared.uploadRecording{ (recording:RecordingModel?) in
            print("done",recording)
            if let rec = recording{
                dispatch_async(dispatch_get_main_queue(), {
                    if(rec.valid){
                        self.lastRecording = rec
                        print("Delay for simulation")
                        Utilities.setTimeout(1.0){
                            self.performSegueWithIdentifier("resultVC", sender: self)
                        }
                        Mixpanel.sharedInstance().track("Recording Success")
                    }else{
                        Utilities.alertWithMessage(rec.message, title: "Error", view: self)
                        Mixpanel.sharedInstance().track("Recording Error")
                        self.statusLabel.text = self.originalStatus
                        UIView.animateWithDuration(0.2) { () -> Void in
                            self.loadingView.alpha = 0
                        }
                    }
                    
                })
                
            }
        }
    }

    @IBAction func tapSkip(){
        let fromUrl = Utilities.urlForPath("debug-recording.wav")
        let toUrl = Utilities.urlForPath("recording-temp.wav")
        do{
            try NSFileManager.defaultManager().removeItemAtURL(toUrl!)
            try NSFileManager.defaultManager().copyItemAtURL(fromUrl!, toURL: toUrl!)
            self.uploadMorph()
        }catch{}
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ResultViewController, rec = self.lastRecording{
            vc.recording = rec
        }
    }
    

}
