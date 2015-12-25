//
//  ObenAPI.swift
//  ObenProto
//
//  Created by Will on 2/26/15.
//  Copyright (c) 2015 FFORM. All rights reserved.
//

import Foundation
import UIKit
import SwiftHTTP
import JSONJoy
import Signals


class ObenAPI {
    
    

    let basicAuthUser = "ObenUp"
    let basicAuthPass = "ObenSesame!"
    
    var basicAuthEncoded = ""
    var user:UserModel?
    
    #if RELEASE
    let baseURL = "https://www.oben.us/howtall/rest/HowTallService/"
    let streamIP = "www.oben.us:7777"
    #else
    let baseURL = "https://oben.us/howtall/rest/HowTallService/"
    let streamIP = "oben.us:7777"

    #endif
    


    //Singleton shared instance
    static let shared = ObenAPI()
    
    init(){
        print("init API \(baseURL)")
    }
    
    func isLoggedIn() -> Bool{
        if let _ = self.user?.userId{
            return true
        }
        return false
    }
    
    // MARK: Rest API
    
    func makeRequest(endpoint:String, method:String) -> NSMutableURLRequest?{

        if basicAuthEncoded.isEmpty {
            let authData = "ObenUp:ObenSesame!".dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
            let authValue = "Basic \(authData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding76CharacterLineLength))"
            self.basicAuthEncoded = authValue
        }
        
print("Requesting \(endpoint)")
        if let req = NSMutableURLRequest(urlString: "\(baseURL)\(endpoint)") {
            //print("Requesting \(req.URL)")
            req.HTTPMethod = "POST"
            req.addValue(self.basicAuthEncoded, forHTTPHeaderField: "Authorization")
            
            return req
        }
        return nil
    }
    
    
    
    func initUser(complete:(UserModel?)->()){

        

        if let req = makeRequest("initUser", method:"POST"){
            do{
                try req.appendParameters(["phoneId":Preferences.shared.phoneID])
                let opt = HTTP(req)
                opt.start { response in
                    if(response.statusCode == nil){
                        return complete(nil)
                    }
                    self.user = UserModel(JSONDecoder(response.data))
                    complete(self.user)
                }
            }catch _{
                complete(nil)
            }
            
        }
        
    }
    
    func uploadRecording(complete:(RecordingModel?)->Void){
        let file = Upload(data: AudioControl.shared.dataForSound(), fileName: "blob.wav", mimeType: "audio/wav")

        if let req = makeRequest("saveUserVoice", method:"POST"){
            do{
                try req.appendParameters([
                    "userId":self.user!.userId!,
                    "audioFile": file
                ])
                let opt = HTTP(req)
                opt.start { response in
                    if(response.statusCode == nil){
                        return complete(nil)
                    }
                    complete(RecordingModel(JSONDecoder(response.data)))
                }
            }catch _{
                complete(nil)
            }
            
        }
    }
    
    
    func updateAge(age:Int, recording:RecordingModel, complete:(RecordingModel?)->Void){
        if let req = makeRequest("saveUserAge", method:"POST"){
            do{
                try req.appendParameters([
                    "recordId":recording.recordId!,
                    "actualAge": age
                    ])
                let opt = HTTP(req)
                opt.start { response in
                    if(response.statusCode == nil){
                        return complete(nil)
                    }
                    complete(RecordingModel(JSONDecoder(response.data)))
                }
            }catch _{
                complete(nil)
            }
        }
    }
    
    func updateGender(gender:Double, recording:RecordingModel, complete:(RecordingModel?)->Void){
        if let req = makeRequest("saveUserGender", method:"POST"){
            do{
                try req.appendParameters([
                    "recordId":recording.recordId!,
                    "actualGender": (gender as NSNumber)
                    ])
                let opt = HTTP(req)
                opt.start { response in
                    if(response.statusCode == nil){
                        return complete(nil)
                    }
                    complete(RecordingModel(JSONDecoder(response.data)))
                }
            }catch _{
                complete(nil)
            }
        }
    }
    
    func updateHeight(height:Int, recording:RecordingModel, complete:(RecordingModel?)->Void){
        if let req = makeRequest("saveUserHeight", method:"POST"){
            do{
                try req.appendParameters([
                    "recordId":recording.recordId!,
                    "actualHeight": height
                    ])
                let opt = HTTP(req)
                opt.start { response in
                    if(response.statusCode == nil){
                        return complete(nil)
                    }
                    complete(RecordingModel(JSONDecoder(response.data)))
                }
            }catch _{
                complete(nil)
            }
        }
    }
    
    func updateEmail(email:String, recording:RecordingModel, complete:(RecordingModel?)->Void){
        if let req = makeRequest("saveUserEmail", method:"POST"){
            do{
                try req.appendParameters([
                    "recordId":recording.recordId!,
                    "email": (email as NSString)
                    ])
                let opt = HTTP(req)
                opt.start { response in
                    if(response.statusCode == nil){
                        return complete(nil)
                    }
                    complete(RecordingModel(JSONDecoder(response.data)))
                }
            }catch _{
                complete(nil)
            }
        }
    }
    
    func uploadSelfie(file:NSData, recording:RecordingModel, complete:(RecordingModel?)->Void){
        let file = Upload(data: file, fileName: "upload.jpg", mimeType: "image/jpg")
        
        if let req = makeRequest("saveUserSelfie", method:"POST"){
            do{
                try req.appendParameters([
                    "recordId":recording.recordId!,
                    "selfieFile": file
                    ])
                let opt = HTTP(req)
                opt.start { response in
                    if(response.statusCode == nil){
                        return complete(nil)
                    }
                    complete(RecordingModel(JSONDecoder(response.data)))
                }
            }catch _{
                complete(nil)
            }
            
        }
    }
}

