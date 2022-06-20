//
//  CustomerAddressesModel.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 13/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class CustomerAddressesModel: NSObject {
    
    static let CustomerAddShared = CustomerAddressesModel()
    var customer_addresses:Array<Any>?
    var customer_uuid:String?
    
    
    func getCustomerAddress(customer_uuid:String,ServiceCompletion:@escaping (_ isDone:Bool?) -> Void){
        let appendStr = "\(customer_uuid)/addresses"
        Utility.GETServiceCall(type: "GetTradingPartners", serviceParam: {}, parentViewC: UIViewController(), willShowLoader: false,viewController: BaseViewController(), appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let data = responseDict["data"] as? Array<Any>{
                            self.customer_addresses = data
                        }
                        
                }
                
                ServiceCompletion(true)
                  
            }
        }
        
    }
    
    class func getDefaultAddress()->NSDictionary?{
        let dataArr:NSArray?
        var address:NSDictionary?
        
        if ((CustomerAddShared.customer_addresses) != nil){
        
            dataArr =  CustomerAddShared.customer_addresses! as NSArray
            
        if dataArr != nil{
            let predicate = NSPredicate(format: "is_default_address = true")
            if let filterArray = dataArr?.filtered(using: predicate) as NSArray?{
                if filterArray.count>0{
                    address = filterArray.firstObject as? NSDictionary
                }
            }
        }
    }
                   
        return address
    }
    
    class func updateCustomerId(customerId:String,ServiceCompletion:@escaping (_ isDone:Bool?) -> Void){
        
        if CustomerAddShared.customer_uuid == nil || CustomerAddShared.customer_uuid ?? "" != customerId {
            defaults.removeObject(forKey: "shipTo")
            defaults.removeObject(forKey: "broughtBy")
            CustomerAddShared.customer_uuid = customerId
            CustomerAddShared.getCustomerAddress(customer_uuid: customerId) { (isDone:Bool?) in
                ServiceCompletion(isDone)
            }
        }else{
            ServiceCompletion(true)
        }
        
        
        
    }
    
    class func getAddresses()->Array<Any>?{
        return CustomerAddShared.customer_addresses
    }

}
