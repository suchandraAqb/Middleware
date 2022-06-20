//
//  ReturnCancelViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 19/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnCancelViewController: BaseViewController {
    
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueButtonView: UIView!
    @IBOutlet weak var voidView: UIView!
    @IBOutlet weak var voidButtonView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var cancelButtonView: UIView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        continueView.setRoundCorner(cornerRadious: 20)
        continueButtonView.setRoundCorner(cornerRadious: continueButtonView.frame.size.height/2.0)
        voidView.setRoundCorner(cornerRadious: 20)
        voidButtonView.setRoundCorner(cornerRadious: voidButtonView.frame.size.height/2.0)
        cancelView.setRoundCorner(cornerRadious: 20)
        cancelButtonView.setRoundCorner(cornerRadious: cancelButtonView.frame.size.height/2.0)
        
        
    }
    //MARK: - End
    
    //MARK: - Private Method
    func voidReturn(){
        let requestDict = NSMutableDictionary()
        requestDict.setValue("VOID", forKey: "status")
        if let dataDict = Utility.getObjectFromDefauls(key: "selected_outbound_shipment") as? NSDictionary {
            
            if let uuid:String = dataDict["shipment_uuid"] as? String{
               requestDict.setValue(uuid, forKey: "shipment_uuid")
            }
            
            if let uuid:String = dataDict["trading_partner_uuid"] as? String{
                requestDict.setValue(uuid, forKey: "customer_uuid")
            }
            
        }
        
        var appendStr =  ""
        if let txt = defaults.object(forKey: "current_returnuuid") as? String{
            appendStr = "/\(txt)"
        }
        
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "InitiateReturn", serviceParam: requestDict, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    print("Void Response:\(responseDict)")
                    if let _ = responseDict["uuid"] as? String {
                        Utility.removeReturnFromDB()
                        Utility.removeReturnLotDB()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Your shipment has been Voided".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                        
                    }
                    
                    
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else if let errorMsg = responseDict["message"] as? String{
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }
                        else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                        }
                        
                        
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                    
                    
                }
                
            }
        }
    }
    
    
    //MARK: - End
    
    
    
    //MARK: - IBAction
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        backActionPopToRoot(sender: UIButton())
    }
    
    @IBAction func voidButtonPressed(_ sender: UIButton) {
        voidReturn()
        
        //backActionPopToRoot(sender: UIButton())
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    //MARK: - End
    
    

}
