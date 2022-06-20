//
//  PickingSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 22/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PickingSearchViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var tradingPartnerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var poTextField: UITextField!
    @IBOutlet weak var shipmentUuidTextField: UITextField!
    @IBOutlet weak var oNTextField: UITextField!
    
    
    
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var searchButton: UIButton!
    var tradingPartners:Array<Any>?
    var locationsArr = [[String:Any]]()
    
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        
        let global = ["uuid":"","name":"Global"]
        locationsArr.append(global)
        
        
        if let locations = UserInfosModel.getLocations(){
            for (_, data) in locations.enumerated() {
                var dict = [String : Any]()
                dict["uuid"] = data.key
                if let value = data.value as? NSDictionary{
                    dict["name"] = value["name"] ?? ""
                }
                
                locationsArr.append(dict)
               
            }
            
            let btn = UIButton()
            btn.tag = 1
            selecteditem(data: global as NSDictionary, sender: btn)
            
        }
        
        //getTradingPartnersList()
       // createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (defaults.object(forKey: "SalesByPickingVerifiedArray") != nil){
            defaults.removeObject(forKey: "SalesByPickingVerifiedArray")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    
    
    
    //MARK: - Private Method
    
    func getPickingListWithQueryParam(appendStr:String){
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "ShipmentPickings", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        
                        if let dataArray = responseDict["data"] as? Array<Any> {
                            
//                                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentsListView") as! ShipmentsListViewController
//                                controller.itemsList = dataArray
//                                self.navigationController?.pushViewController(controller, animated: true)
                            
                        }else{
                           Utility.showPopup(Title: App_Title, Message: "No Shipments found" , InViewC: self)
                        }
                    
                   
                        
                }else{
                   
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                       
                   }else{
                      Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                   }
                       
                       
                }
                  
            }
        }
        
    }
    func getTradingPartnersList(){
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetTradingPartners", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        
                        if let dataArray = responseDict["data"] as? Array<Any> {
                            self.tradingPartners = dataArray
                        }
                    
                   
                        
                }else{
                   
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                       
                   }else{
                      Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                   }
                       
                       
                }
                  
            }
        }
        
    }
    //MARK: - End
    //MARK: - IBAction
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1{
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = locationsArr
            controller.type = "Locations"
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
        }else if sender.tag == 2{
            if tradingPartners == nil {
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = tradingPartners as! Array<[String:Any]>
            controller.type = "Trading Partners"
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func locationScanButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller.delegate = self
        controller.isForLocationSelection=true
        self.navigationController?.pushViewController(controller, animated: true)
        
//                self.didReceiveBarcodeLocationScan(codeDetails: ["scannedCodes":"b592af47-4319-4739-824b-9ca8d93d34cc"])
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var locationUUID = ""
        if let str = locationLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            locationUUID = str
        }
        
        var tpName = ""
        if let str = tradingPartnerLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            tpName = str
        }
        
        var poStr = ""
        if let str = poTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            poStr = str
        }
        
       
        
       var order = ""
       if let str = oNTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
           order = str
       }
        
       var sUuid = ""
       if let str = shipmentUuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
           sUuid = str
       }
        
       
        
        var appendStr = "to_pick?"
        
        if !locationUUID.isEmpty{
            appendStr = appendStr + "location_uuid=\(locationUUID)&"
        }
        
        if !tpName.isEmpty{
            appendStr = appendStr + "trading_partner_name=\(tpName)&"
        }
        
        if !order.isEmpty{
            appendStr = appendStr + "order_nbr=\(order)&"
        }
        
        if !sUuid.isEmpty{
            appendStr = appendStr + "shipment_uuid=\(sUuid)&"
        }
        
       
        
        if !poStr.isEmpty{
            appendStr = appendStr + "po_nbr=\(poStr)&"
        }
        
        
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingListView") as! PickingListViewController
        controller.appendStr = escapedString
        self.navigationController?.pushViewController(controller, animated: true)
    }
    //MARK: - End
    //MARK: - textField Delegate
       func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.inputAccessoryView = inputAccView
            textFieldTobeField = textField

          
       }
       func textFieldDidEndEditing(_ textField: UITextField) {
          
       }
       func textFieldShouldReturn(_ textField: UITextField) -> Bool
       {
           textField.resignFirstResponder()
           return true
       }
    //MARK: - End
    //MARK: - SingleSelectDropdownDelegate
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil{
            
            if sender?.tag == 1{
                if let name = data["name"] as? String{
                    locationLabel.text = name
                    locationLabel.accessibilityHint = (data["uuid"] as? String) ?? ""
                }
            }else if sender?.tag == 2{
                if let name = data["name"] as? String{
                    tradingPartnerLabel.text = name
                    tradingPartnerLabel.accessibilityHint = name
                }
            }
            
        }
    }
    //MARK: - End
}


extension PickingSearchViewController:SingleScanViewControllerDelegate{
    func didReceiveBarcodeLocationScan(codeDetails:[String:Any]){
        let locationCode = codeDetails["scannedCodes"] as! String
        print(locationCode)
        let predicate = NSPredicate(format:"uuid='\(locationCode)'")
        let filterArray = (locationsArr as NSArray).filtered(using: predicate)
        if filterArray.count>0 {
            let dict=filterArray[0]
            let btn=UIButton()
            btn.tag=1
            self.selecteditem(data: dict as! NSDictionary,sender:btn)
        }else{
            Utility.showPopup(Title: "Error!", Message: "Selected location is not available.".localized() , InViewC: self)
        }
    }
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}


