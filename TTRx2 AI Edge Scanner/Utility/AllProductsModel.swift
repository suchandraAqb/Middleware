//
//  AllProductsModel.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 06/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class AllProductsModel: NSObject {
    static let AllProductsShared = AllProductsModel()
    private var products:Array<Any>?
    
    func getAllProducts(ServiceCompletion:@escaping (_ isDone:Bool?) -> Void){
        Utility.GETServiceCall(type: "GetProductAll", serviceParam: {}, parentViewC: UIViewController(), willShowLoader: false,viewController: BaseViewController(), appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let dataArray = responseDict["data"] as? Array<Any> {
                        self.products = dataArray
                    }
                    
                }
                ServiceCompletion(true)
            }
        }
        
    }
    class func getAllProducts()->Array<Any>?{
        return AllProductsShared.products
    }
}
