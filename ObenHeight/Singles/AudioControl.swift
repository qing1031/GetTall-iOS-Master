//
//  AudioControl.swift
//  ObenProto
//
//  Created by Will on 2/26/15.
//  Copyright (c) 2015 FFORM. All rights reserved.
//

import UIKit
import AVFoundation
import Signals

struct AudioStatus{
    var play:Bool = false
    var stop:Bool = false
    var upload:Bool = false
}

protocol AudioControlDelegate{
    func playerDidStartPlaying()
    func playerDidFinishPlaying(success:Bool)
    func recorderDidStartRecording()
    func recorderDidFinishRecording(success:Bool)
}

class AudioControl: NSObject {
    
    var soundFileURL:NSURL?
    var soundFilePath:String?
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var _fileDescriptor:CInt!
    var _dispatch_source:dispatch_source_t!
    private var _meterTimer:NSTimer!
    
    let onRecordingData = Signal<NSData>()
    let onRecordingMeterUpdate = Signal<Float>()
    
    var delegate:AudioControlDelegate?
    
    class var shared: AudioControl {
        struct Static {
            static let instance: AudioControl = AudioControl()
        }
        Static.instance.initialze()
        return Static.instance
    }
    
    func initialze(){
        let currentFileName = "recording-temp.wav"
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath!)
    }
    
    func dataForSound() -> NSData{
        let soundData = NSData(contentsOfURL: soundFileURL!)!
        return soundData
    }
    
    func urlForSound() -> NSURL{
        return soundFileURL!
    }
    
    func record() -> AudioStatus{
        var status = AudioStatus()
        status.play = true
        if player != nil && player.playing {
            player.stop()
            delegate?.playerDidFinishPlaying(false)
        }

        
        if recorder == nil {
            print("recording. recorder nil")
            status.play = false
            status.stop = true
            recordWithPermission(true)
            return status
        }
        
        if recorder != nil && recorder.recording {
            print("pausing")
            recorder.pause()
            
        } else {
            print("recording")
            status.play = false
            status.stop = true
            recordWithPermission(false)
        }
        return status
    }
    
    func stop() -> NSTimeInterval{
        if recorder == nil{
            return NSTimeInterval(0)
        }
        let duration = recorder.currentTime
        print("stopped at \(recorder.currentTime)")
        
        recorder.stop()
        if(self._meterTimer != nil){
            self._meterTimer.invalidate()
        }
        

        //recordButton.setTitle("Record", forState:.Normal)
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        do {
            try session.setActive(false)
        } catch let error1 as NSError {
            error = error1
            print("could not make session inactive")
            if let e = error {
                print(e.localizedDescription)
                return 0
            }
        }
        //playButton.enabled = true
        //uploadButton.enabled = true
        //stopButton.enabled = false
        //recordButton.enabled = true
        recorder = nil
        return duration
    }
    
    func stopPlayback(){
        if(self.player != nil && self.player.playing){
            delegate?.playerDidFinishPlaying(false)
            self.player.stop()
        }
    }
    
    func play( urlToPlay:NSURL? ){
        print("playing")
        var error: NSError?
        var url = NSURL(string:"")
        if(urlToPlay != nil){
            url = urlToPlay!
        }else{
            url = soundFileURL
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("playStart", object: nil)
        
        if player != nil && player.playing{
            delegate?.playerDidFinishPlaying(false)
            NSNotificationCenter.defaultCenter().postNotificationName("playStop", object: nil)
        }
        do {
            // recorder might be nil
            // self.player = AVAudioPlayer(contentsOfURL: recorder.url, error: &error)
            self.player = try AVAudioPlayer(contentsOfURL: url!)
        } catch let error1 as NSError {
            error = error1
            self.player = nil
        }
        self.setSessionPlayback()
        if player == nil {
            if let e = error {
                print(e.localizedDescription)
            }
            //playButton.enabled = false
        }else{
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        }
    }
    
    func playRemoteUrl( url:NSURL )->Bool{
        let manager = NSFileManager.defaultManager()
        let soundData = NSData(contentsOfURL: url)
        if let filePath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first{
            let file = "\(filePath)/example.wav"
            if(manager.fileExistsAtPath(file)){
                print("Removing old file")
                do {
                    try manager.removeItemAtPath(file)
                } catch _ {
                }
            }
            if((soundData?.writeToFile(file, atomically: true)) == true){
                AudioControl.shared.play(NSURL(fileURLWithPath: file))
                return true
            }else{
                print("Couldn't write file \(soundData)")
                NSNotificationCenter.defaultCenter().postNotificationName("playStop", object: nil)
            }
            
            
        }
        return false
        
        
    }

    func setupRecorder() {

        
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath!) {
            // probably won't happen. want to do something about it?
            print("sound exists")
            do {
                try filemanager.removeItemAtURL(soundFileURL!)
            } catch _ {
            }
        }
        
        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVEncoderAudioQualityKey : AVAudioQuality.High.rawValue,
            AVEncoderBitRateKey : 16000,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey : 16000.0,
            AVLinearPCMBitDepthKey: 16
        ]

        do {
            recorder = try AVAudioRecorder(URL: soundFileURL!, settings: recordSettings as! [String : AnyObject])
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let err as NSError {
            print(err.localizedDescription)
            recorder = nil
        }

    }
    
    func getPermission(completion:(Bool)->()){
        
        
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            dispatch_async(dispatch_get_main_queue(), {
            completion(granted)    
            })
            
        })
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()

                    
                    self._meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "meterUpdate", userInfo: nil, repeats: true)
                    
                    self.delegate?.recorderDidStartRecording()
                    NSNotificationCenter.defaultCenter().postNotificationName("recordStart", object: nil)
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    func meterUpdate(){
        self.recorder.updateMeters()
        self.onRecordingMeterUpdate.fire(self.recorder.averagePowerForChannel(0))
    }

    func setSessionPlayback() {
        print("sessionPlayback")
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch _ {
        }
        var error: NSError?
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error1 as NSError {
            error = error1
            print("could not set session category")
            if let e = error {
                print(e.localizedDescription)
            }
        }
        do {
            try session.setActive(true)
        } catch let error1 as NSError {
            error = error1
            print("could not make session active")
            if let e = error {
                print(e.localizedDescription)
            }
        }
    }
    
    func setSessionPlayAndRecord() {
        print("session PlayAndRecord")
        let session:AVAudioSession = AVAudioSession.sharedInstance()

        var error: NSError?
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error1 as NSError {
            error = error1
            print("could not set session category")
            if let e = error {
                print(e.localizedDescription)
            }
        }
        do {
            try session.setActive(true)
        } catch let error1 as NSError {
            error = error1
            print("could not make session active")
            if let e = error {
                print(e.localizedDescription)
            }
        }
    }
    
    // MARK: Utilities
    
    func cleanFiles(){
        print("Cleanup Phrases Folder")
        let fileManager = NSFileManager.defaultManager()
        let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        if let phrasesDir = NSURL(string:"\(docsDir.path)/phrases"){

            do{
                let contents = try fileManager.contentsOfDirectoryAtURL(phrasesDir, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
                for file:NSURL in contents{
                    if(file.path!.hasSuffix("wav")){
                        print("Removing \(file.path!)")
                        do {
                            try fileManager.removeItemAtURL(file)
                        } catch _ {
                        }
                    }
                }
            }catch _{
                print("Couldn't clean")
            }
        }
    }
}

struct RecordingStatus{
    var dataFormatL:AudioStreamBasicDescription
    var queue:AudioQueueRef
    var buffers:AudioQueueBufferRef
    var audioFile:AudioFileID
    var currentPacket:Int64
    var recording:Bool
}

// MARK: AVAudioRecorderDelegate
extension AudioControl : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder,
        successfully flag: Bool) {
            print("finished recording \(flag)")
            AudioControl.shared.delegate?.recorderDidFinishRecording(flag)
            NSNotificationCenter.defaultCenter().postNotificationName("recordStop", object: nil)
            //stopButton.enabled = false
            //playButton.enabled = true
            //recordButton.setTitle("Record", forState:.Normal)
            
            // iOS8 and later
            /*
            var alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Keep", style: .Default, handler: {action in
                println("keep was tapped")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {action in
                println("delete was tapped")
                recorder.deleteRecording()
            }))
            let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
            rootViewController?.presentedViewController?.presentViewController(alert, animated:true, completion:nil)
            */
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder,
        error: NSError?) {
            print("\(error?.localizedDescription)")
    }
}

// MARK: AVAudioPlayerDelegate
extension AudioControl : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playerDidFinishPlaying(flag)
        NSNotificationCenter.defaultCenter().postNotificationName("playStop", object: nil)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("\(error?.localizedDescription)")
    }
}