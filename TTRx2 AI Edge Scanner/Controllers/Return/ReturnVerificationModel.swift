//
//  ReturnVerificationModel.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 13/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit


class ReturnVerificationModel: NSObject {
    static let ReturnVerificationObj = ReturnVerificationModel()
    var isCheckingInprogress = false
    
    func checkForUpdate(){
        if self.checkActiveReturn(){
            isCheckingInprogress = true
            self.checkVerification()
        }else{
            isCheckingInprogress = false
        }
    }
    
    
    func checkActiveReturn()->Bool{
        var status = false
        do{
            let return_obj = try PersistenceService.context.fetch(Return.activeFetchRequest)
            if !return_obj.isEmpty{
                status =  true
            }
        }catch{
            return status
            
        }
        return status
    }
    
    
    func checkVerification(){
        
        guard let _ = defaults.value(forKey: "client_udid") as? String , let _ = defaults.value(forKey: "userName") as? String , let _ = defaults.value(forKey: "password") as? String else {
            return
        }
        
        let appendStr = "\(defaults.object(forKey: "current_returnuuid") ?? "")/verification_status_updates?do_long_polling=true&_=\(Date().currentTimeMillis())"
        
        Utility.GETServiceCall(type: "ReturnSerialsStatusCheck", serviceParam:{}, parentViewC: BaseViewController(), willShowLoader: false,viewController: BaseViewController(), appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                if isDone! {
                    if let responseDict = responseData as? [String:Any] {
                        
                        if let messages = responseDict["messages"] as? [[String:Any]]{
                            self.updateDB(items: messages)
                        }
                        
                    }
                    
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        //Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        print("Return Serial Updates Stattus Error:\(errorMsg)")
                        
                    }else{
                        // Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        print("Return Serial Updates Stattus Error:\(message ?? "")")
                    }
                }
                
                self.checkForUpdate()
                
            }
        }
    }
    
    func updateDB(items:[[String:Any]]){
        
        for data in items {
            
            do{
                let barcode = data["return_id"] ?? ""
                let predicate = NSPredicate(format:"event_id='\(barcode)'")
                let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchRequestWithPredicate(predicate: predicate))
                
                
                if !serial_obj.isEmpty{
                    
                    let obj = serial_obj.first!
                    //VRS Response = [ U, S, EF, ES, EL, EE, EEL, EMP, ENR ]
                    //Local Response = [ U, OK, OK_DIFF, EWTP ]
                    
                    //if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "S", let is_vrs_check_enabled = data["is_vrs_check_enabled"] as? String, let local_resp = data["local_resp"] as? String,local_resp == "OK"{
                    
                    if data["local_resp"] as? String == "OK" && (data["vrs_resp"] as? String == "S" || data["vrs_resp"] as? String == "SR" || data["is_vrs_check_enabled"] as? Bool == false){
                        
                        obj.status = Return_Serials.Status.Verified.rawValue
                        
                    }else if (data["is_lotbased"] as? Bool == true && data["local_resp"] as? String == "OK"){
                        
                        for item in serial_obj{
                            
                            item.status = Return_Serials.Status.Verified.rawValue
                        }
                        
                    }else if (data["is_lotbased"] as? Bool == true && data["local_resp"] as? String == "OK_DIFF"){
                        
                        for item in serial_obj{
                            
                            item.status = Return_Serials.Status.Failed.rawValue
                            var error = ""
                            if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "U"{
                                error = "Processing"
                            }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EF"{
                                error = "Error Failure to communicate with VRS"
                            }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "ES"{
                                error = "Error Serial Not Found"
                            }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EL"{
                                error = "Error Lot"
                            }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EE"{
                                error = "Error Expiration Date"
                            }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EEL"{
                                error = "Error Expiration Date and Lot"
                            }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EMP"{
                                error = "Error, Manufacturer Policy"
                            }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "ENR"{
                                error = "Error, Not for Redistribution"
                            }
                            
                            item.failed_reason = error
                        }
                        
                    }else{
                        
                        obj.status = Return_Serials.Status.Failed.rawValue
                        
                        var error = ""
                        if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "U"{
                            error = "Processing"
                        }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EF"{
                            error = "Error Failure to communicate with VRS"
                        }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "ES"{
                            error = "Error Serial Not Found"
                        }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EL"{
                            error = "Error Lot"
                        }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EE"{
                            error = "Error Expiration Date"
                        }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EEL"{
                            error = "Error Expiration Date and Lot"
                        }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "EMP"{
                            error = "Error, Manufacturer Policy"
                        }else if let vrs_resp = data["vrs_resp"] as? String,vrs_resp == "ENR"{
                            error = "Error, Not for Redistribution"
                        }
                        
                        obj.failed_reason = error
                    }
                    PersistenceService.saveContext()
                }
                
            }catch let error{
                print(error.localizedDescription)
                
            }
            
        }
        NotificationCenter.default.post(name: Notification.Name("Return_RefreshProducts"), object: nil)
    }
}
