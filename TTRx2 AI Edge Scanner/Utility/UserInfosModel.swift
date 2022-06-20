//
//  UserInfosModel.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 08/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class UserInfosModel: NSObject {
    
    static let UserInfoShared = UserInfosModel()
    var products:NSDictionary?
    var locations:NSDictionary?
    var userName:String?
    var lastUpdate:Date?
    var default_location_uuid:String?
    var default_location_addresses:Array<Any>?
    var user_location_addresses:Array<Any>?
    
    
    func getAllUserInfos(ServiceCompletion:@escaping (_ isDone:Bool?) -> Void){
        let appendStr = "?is_include_locations=true&is_include_products=true&is_include_settings=true"
        Utility.GETServiceCall(type: "UserInfo", serviceParam: {}, parentViewC: UIViewController(), willShowLoader: false,viewController: BaseViewController(), appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                
                if isDone! {
                    self.lastUpdate = Date()
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let location_uuid = responseDict["default_location_uuid"] as? String{
                        if self.default_location_uuid == nil || self.default_location_uuid ?? "" != location_uuid{
                            self.default_location_uuid = location_uuid
                            self.getLocationAddress(isDefault: true, location_uuid: location_uuid) { (isDone:Bool?) in}
                        }else if self.default_location_addresses == nil{
                            self.getLocationAddress(isDefault: true, location_uuid: self.default_location_uuid ?? "") { (isDone:Bool?) in}
                            
                        }
                    }else{
                        
                        if let locations = responseDict["locations"] as? NSDictionary{
                            let allKeys = locations.allKeys
                            if let firstLocationUuid = allKeys.first as? String{
                                self.default_location_uuid = firstLocationUuid
                                self.getLocationAddress(isDefault: true, location_uuid: firstLocationUuid) { (isDone:Bool?) in}
                            }
                        }
                    }
                    
                    
                    if let name = responseDict["name"] as? String{
                        self.userName = name
                    }
                    
                    if let locationsArray = responseDict["locations"] as? NSDictionary{
                        self.locations = locationsArray
                    }
                    
                    if let productArray = responseDict["products"] as? NSDictionary{
                        self.products = productArray
                    }
                    
                    if let settings = responseDict["settings"] as? NSDictionary{
                        
                        if let user_timezone = settings["core__time_zone"] as? String,!user_timezone.isEmpty{
                            defaults.set(user_timezone, forKey: "user_timezone")
                        }
                        
                    }
                    
                }
                ServiceCompletion(true)
            }
        }
    }
    
    func getLocationAddress(isDefault:Bool,location_uuid:String,ServiceCompletion:@escaping (_ isDone:Bool?) -> Void){
        let appendStr = "\(location_uuid)/addresses"
        Utility.GETServiceCall(type: "GetLocationDetails", serviceParam: {}, parentViewC: UIViewController(), willShowLoader: false,viewController: BaseViewController(), appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let data = responseDict["data"] as? Array<Any>{
                        if isDefault{
                            self.default_location_addresses = data
                        }
                        self.user_location_addresses = data
                    }
                }
                ServiceCompletion(true)
            }
        }
    }
    
    func getStorageAreasOfALocation(location_uuid:String,ServiceCompletion:@escaping (_ isDone:Bool?,_ sa:Array<Any>?) -> Void){
        let appendStr = "\(location_uuid)/storage_areas"
        Utility.GETServiceCall(type: "GetLocationDetails", serviceParam: {}, parentViewC: UIViewController(), willShowLoader: false,viewController: BaseViewController(), appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                
                var storage_areas:Array<Any>?
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let data = responseDict["data"] as? Array<Any>{
                        storage_areas = data
                    }
                }
                
                ServiceCompletion(true,storage_areas)
                
            }
        }
        
    }
    func serialBasedOrLotBasedItemsGetApiCall(ServiceCompletion:@escaping (_ isDone:Bool?,_ itemArr:Array<Any>?) -> Void){
        
        let appendStr:String! = "/\(defaults.object(forKey: "SOPickingUUID") ?? "")/items"
       
        Utility.GETServiceCall(type: "PickNewItem", serviceParam: {}, parentViewC: UIViewController(), willShowLoader: true,viewController: BaseViewController(), appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                
                var itemarr : Array<[String:Any]>?

                if isDone! {
                     let responseDict: NSDictionary = responseData as! NSDictionary
                        if let list = responseDict["data"] as? Array<[String:Any]>{
                            itemarr = list
                            Utility.saveDictTodefaults(key: "PickedData", dataDict: responseDict)
                        }
                    }
                    ServiceCompletion(true, itemarr)
              }
        }
    }
    
    func staffMgtGetApiCall(ServiceCompletion:@escaping (_ isDone:Bool?,_ itemArr:Array<Any>?) -> Void){
        
        let appendStr:String! = ""
        Utility.GETServiceCall(type: "staffMgtGetApiCall", serviceParam: {}, parentViewC: UIViewController(), willShowLoader: false,viewController: BaseViewController(), appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                if isDone! {
                    if let responseDict = responseData as? NSDictionary{
                        if let staffarr = responseDict["data"] as? NSArray{
                            Utility.saveObjectTodefaults(key: "staffMgtList", dataObject: staffarr)
                        }
                    }
                }
            }
        }
    }
    class func getAllProducts()->NSDictionary?{
        return UserInfoShared.products
    }
    
    class func getLocations()->NSDictionary?{
        return UserInfoShared.locations
    }
    
    class func getUserDefaultlocationAddresses()->Array<Any>?{
        return UserInfoShared.default_location_addresses
    }
    
    class func getUserLocationAddresses()->Array<Any>?{
        return UserInfoShared.user_location_addresses
    }
    
    class func getDefaultAddress(is_Default_Location:Bool)->NSDictionary?{
        var dataArr = [Any]()
        var address:NSDictionary?
        
        
        
        if is_Default_Location {
            if let arr =  UserInfoShared.default_location_addresses{
                dataArr = arr
            }
            
        }else{
            if let arr =  UserInfoShared.user_location_addresses{
                dataArr = arr
            }
            
        } 
        
        
        if !dataArr.isEmpty{
            let predicate = NSPredicate(format: "is_default_address = true")
            if let filterArray = (dataArr as NSArray).filtered(using: predicate) as NSArray?{
                if filterArray.count>0{
                    address = filterArray.firstObject as? NSDictionary
                }
            }else{
                address = dataArr.first as? NSDictionary
            }
        }
        return address
    }
}
