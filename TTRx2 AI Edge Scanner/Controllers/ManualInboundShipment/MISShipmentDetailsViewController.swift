//
//  MISShipmentDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 30/12/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISShipmentDetailsViewController:  BaseViewController,UITextViewDelegate,SingleSelectDropdownDelegate,DatePickerViewDelegate {
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step4Button: UIButton!
    @IBOutlet weak var step5Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step3BarView: UIView!
    @IBOutlet weak var step4BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    @IBOutlet weak var step5Label: UILabel!
    //MARK: - End
       
    
    @IBOutlet weak var shipmentView: UIView!
    @IBOutlet weak var locationView: UIView!
    
    @IBOutlet weak var statementView: UIView!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    @IBOutlet weak var storageShelfMainView: UIView!
    
    @IBOutlet weak var storageSelectionView: UIView!
    @IBOutlet weak var shelfSelectionView: UIView!
    
    @IBOutlet weak var shelfView: UIView!
    
    @IBOutlet var typeButtons: [UIButton]!
    
    @IBOutlet var shippingButtons: [UIButton]!
    
    
    @IBOutlet weak var shipmentDateLabel: UILabel!
    @IBOutlet weak var shippingCarrierLabel: UILabel!
    @IBOutlet weak var shippingCarrierTextField: UITextField!
    @IBOutlet weak var shippingMethodLabel: UILabel!
    @IBOutlet weak var shippingMethodTextField: UITextField!
    @IBOutlet weak var trackingNumberTextField: UITextField!
    
    @IBOutlet weak var storageLabel: UILabel!
    @IBOutlet weak var shelfLabel: UILabel!
    
    @IBOutlet weak var statementTextField: UITextField!
    @IBOutlet weak var directPurchaseButton: UIButton!
    
    
    var locationUuid = ""
    
    var allLocations:NSDictionary?
    
    var isStorageSelected:Bool!
    var isShelfSelected:Bool!
    var storageAreas:Array<Any>?
    var shelfsArray:Array<Any>?
    
        
    var isShippingTypeCustom = false
    var shippingCarrierArray:Array<Any>?
    var shippingMethodArray:Array<Any>?
    
    var isDirectPurchaseSelected = false
    
    var shipmentStatus = ""
    
    var disPatchGroup = DispatchGroup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selected_location_uuid = defaults.object(forKey: "MIS_selectedLocation") as? String{
            locationUuid = selected_location_uuid
        }
        
        createInputAccessoryViewAddedScan()
        
        setup_initialview()
        populateStorageArea()
        getShippingCarrierList()
        
        let currentDate = Date()
        let apiformatter = DateFormatter()
        apiformatter.dateFormat = "yyyy-MM-dd"
        let uiformatter = DateFormatter()
        uiformatter.dateFormat = "MM-dd-yyyy"
        let dateStrForApi = apiformatter.string(from: currentDate)
        let dateStr = uiformatter.string(from: currentDate)
        shipmentDateLabel.text = dateStr
        shipmentDateLabel.accessibilityHint = dateStrForApi
        
        self.disPatchGroup.notify(queue: .main) {
            self.populateShipmentsDetails()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
    }
    
    
    //MARK: - Private Method
    func populateShipmentsDetails(){
        if let shipmentsDetailsDict = Utility.getDictFromdefaults(key: "MIS_ShipmentsDetails"){
            if let txt = shipmentsDetailsDict["shipment_date"] as? String,!txt.isEmpty{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: "MM-dd-yyyy", dateStr: txt) {
                    shipmentDateLabel.text = formattedDate
                    shipmentDateLabel.accessibilityHint = txt
                }
            }
            
            if let txt = shipmentsDetailsDict["tracking_number"] as? String,!txt.isEmpty{
                trackingNumberTextField.text = txt
            }
            
            if let txt = shipmentsDetailsDict["trx_statement"] as? String,!txt.isEmpty{
                statementTextField.text = txt
            }
            
            if let is_direct_purchase = shipmentsDetailsDict["is_direct_purchase"] as? Bool{
                if is_direct_purchase {
                    directPurchaseButton.isSelected = true
                    isDirectPurchaseSelected = true
                }else{
                    directPurchaseButton.isSelected = false
                    isDirectPurchaseSelected = false
                }
            }
            
            
            let isShippingTypeCustom = defaults.bool(forKey: "isShippingTypeCustom")
            if isShippingTypeCustom {
                let btn = UIButton()
                btn.tag = 2
                shippingButtonPressed(btn)
                if let txt = shipmentsDetailsDict["custom_shipping_carrier"] as? String,!txt.isEmpty{
                    shippingCarrierTextField.text = txt
                }
                
                if let txt = shipmentsDetailsDict["custom_shipping_method"] as? String,!txt.isEmpty{
                    shippingMethodTextField.text = txt
                }
            }else{
                let btn = UIButton()
                btn.tag = 1
                shippingButtonPressed(btn)
                if let shipping_carrier_uuid = shipmentsDetailsDict["shipping_carrier_uuid"] as? String,!shipping_carrier_uuid.isEmpty, shippingCarrierArray?.count ?? 0 > 0{
                    for shippingCarrier in shippingCarrierArray! {
                        if let shippingCarrierDict = shippingCarrier as? NSDictionary {
                            if let txt = shippingCarrierDict["uuid"] as? String,!txt.isEmpty, txt == shipping_carrier_uuid{
                                let shippingCarrierbtn = UIButton()
                                shippingCarrierbtn.tag = 3
                                selecteditem(data: shippingCarrierDict,sender:shippingCarrierbtn)
                                break
                            }
                        }
                    }
                }
            }
            
            if let new_shipment_status = shipmentsDetailsDict["new_shipment_status"] as? String,!new_shipment_status.isEmpty{
                let btn = UIButton()
                if new_shipment_status == "RECEIVED_AND_VALIDATED" {
                    btn.tag = 1
                    if let storage_area_uuid = shipmentsDetailsDict["new_shipment_received_and_validated_storage_area_uuid"] as? String,!storage_area_uuid.isEmpty, storageAreas?.count ?? 0 > 0 {
                        for storageArea in storageAreas!{
                            if let storageAreaDict = storageArea as? NSDictionary {
                                if let txt = storageAreaDict["uuid"] as? String,!txt.isEmpty, txt == storage_area_uuid{
                                    let storageAreabtn = UIButton()
                                    storageAreabtn.tag = 1
                                    self.selecteditem(data: storageAreaDict, sender:storageAreabtn)
                                    break
                                }
                            }
                        }
                    }
                    
                }else if new_shipment_status == "RECEIVED" {
                    btn.tag = 2
                }else if new_shipment_status == "NOT_RECEIVED" {
                    btn.tag = 3
                }
                typeButtonPressed(btn)
            }
        }
    }
    
    func setup_initialview(){
        sectionView.roundTopCorners(cornerRadious: 40)
        
        shipmentView.setRoundCorner(cornerRadious: 10)
        locationView.setRoundCorner(cornerRadious: 10)
        statementView.setRoundCorner(cornerRadious: 10)
        
        allLocations = UserInfosModel.getLocations()
        
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 17.0,color:Utility.hexStringToUIColor(hex: "719898"))
        
        storageSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        shelfSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        let btn = UIButton()
        btn.tag = 1
        typeButtonPressed(btn)
        shippingButtonPressed(btn)
        
    }
    
    
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "MIS_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "MIS_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "MIS_3rdStep")
        let isFourthStepCompleted = defaults.bool(forKey: "MIS_4thStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        step5Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted && isFourthStepCompleted {
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            step5Button.isUserInteractionEnabled = true
            
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
           
        }else if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted {
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
                        
        }else if isFirstStepCompleted && isSecondStepCompleted {
            step3Button.isUserInteractionEnabled = true
        }
        
    }
    
    func populateStorageArea(){
        if locationUuid != "" {
            let allLocations = UserInfosModel.getLocations()
            if allLocations != nil{
                if let locationData = allLocations![locationUuid] as? NSDictionary{
                    if let sa = locationData["sa"] as? Array<Any>, !sa.isEmpty{
                        storageAreas = sa
                        if storageAreas?.count == 1 {
                            let data = storageAreas![0] as! NSDictionary
                            if let name = data["name"] as? String{
                                storageLabel.text = name
                            }
                            if let uuid = data["uuid"] as? String {
                                storageLabel.accessibilityHint = uuid
                            }
                            storageLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                            let isShelf = data["is_have_shelf"] as! Bool

                            if isShelf {
                                shelfView.isHidden = false
                                isShelfSelected = false
                                getShelfList(storageAreaUUID: storageLabel.accessibilityHint ?? "")
                            }
                        }
                    }else{
                        if let sa_count = locationData["sa_count"]as? Int {
                            if sa_count > 0 {
                                let userinfo = UserInfosModel.UserInfoShared
                                self.showSpinner(onView: self.view)
                                userinfo.getStorageAreasOfALocation(location_uuid: locationUuid, ServiceCompletion:{ (isDone:Bool? , sa:Array<Any>?) in
                                    self.removeSpinner()
                                    if sa != nil && !(sa?.isEmpty ?? false){
                                        self.storageAreas = sa
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }else{
            print("No Location UUID")
        }
        
    }
    
   
    
    func getShelfList(storageAreaUUID:String){
        
        let appendStr:String! = locationUuid + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
        
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetShelfList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{ [self] in
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                    
                        if let list = responseDict["data"] as? Array<[String : Any]>{
                            self.shelfsArray = list
                                if shelfsArray?.count == 1 {
                                    let data = shelfsArray![0] as! NSDictionary
                                        if let name = data["name"] as? String{
                                            shelfLabel.text = name
                                            shelfLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                                        if let uuid = data["storage_shelf_uuid"] as? String {
                                            shelfLabel.accessibilityHint = uuid
                                            Utility.saveObjectTodefaults(key: "selected_shelf", dataObject: data)
                                    }
                                    isShelfSelected = true
                                }
                            }
                            
                            if let shipmentsDetailsDict = Utility.getDictFromdefaults(key: "MIS_ShipmentsDetails"){
                                if let storage_shelf_uuid = shipmentsDetailsDict["new_shipment_received_and_validated_storage_shelf_uuid"] as? String,!storage_shelf_uuid.isEmpty, list.count > 0{
                                    for shelfDict in list {
                                        if let txt = shelfDict["uuid"] as? String,!txt.isEmpty, txt == storage_shelf_uuid{
                                            let shelfDictbtn = UIButton()
                                            shelfDictbtn.tag = 2
                                            self.selecteditem(data: shelfDict as NSDictionary,sender:shelfDictbtn)
                                            break
                                        }
                                    }
                                }
                            }
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
    
    func getShippingCarrierList(){
        
        let appendStr:String! = "shipping_carriers/"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
          Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.disPatchGroup.leave()
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                    
                        if let list = responseDict["data"] as? Array<[String : Any]>{
                            let sortedResults = (list as NSArray).sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as! [[String:AnyObject]]
                            self.shippingCarrierArray = sortedResults
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
    
    func getShippingMethodList(shipping_carrier_uuid:String){
        
        let appendStr:String! = "shipping_carriers/" + shipping_carrier_uuid + "/shipping_methods"
        
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                    
                        if let list = responseDict["data"] as? Array<[String : Any]>{
                            self.shippingMethodArray = list
                            
                            if let shipmentsDetailsDict = Utility.getDictFromdefaults(key: "MIS_ShipmentsDetails"){
                                if let shipping_method_uuid = shipmentsDetailsDict["shipping_method_uuid"] as? String,!shipping_method_uuid.isEmpty, list.count > 0{
                                    for shippingMethodDict in list {
                                        if let txt = shippingMethodDict["uuid"] as? String,!txt.isEmpty, txt == shipping_method_uuid{
                                            let shippingMethodbtn = UIButton()
                                            shippingMethodbtn.tag = 4
                                            self.selecteditem(data: shippingMethodDict as NSDictionary,sender:shippingMethodbtn)
                                            break
                                        }
                                    }
                                }
                            }
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
    
    func saveData()->NSMutableDictionary{
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()

        if let txt = shipmentDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "shipment_date")
        }
        
        if isShippingTypeCustom {
            defaults.set(true, forKey: "isShippingTypeCustom")

            if let txt = shippingCarrierTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "custom_shipping_carrier")
            }

            if let txt = shippingMethodTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "custom_shipping_method")
            }
        }else {
            defaults.set(false, forKey: "isShippingTypeCustom")
            if let txt = shippingCarrierLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_carrier_uuid")
            }

            if let txt = shippingMethodLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_method_uuid")
            }
            
        }

        if let txt = trackingNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "tracking_number")
        }
        
        
        otherDetailsDict.setValue(shipmentStatus, forKey: "new_shipment_status")
        
        if shipmentStatus == "RECEIVED_AND_VALIDATED" {
            if let txt = storageLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "new_shipment_received_and_validated_storage_area_uuid")
            }

            if let txt = shelfLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "new_shipment_received_and_validated_storage_shelf_uuid")
            }
        }
        
        if let txt = statementTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "trx_statement")
        }
        
        otherDetailsDict.setValue(isDirectPurchaseSelected, forKey: "is_direct_purchase")


        return otherDetailsDict


    }

    func formValidation()->Bool{
        var isValidated = true
        
        var shipment_date = ""
        if let txt = shipmentDateLabel.accessibilityHint , !txt.isEmpty {
            shipment_date = txt
        }
        
        var storage = ""
        if let txt = storageLabel.accessibilityHint , !txt.isEmpty {
            storage = txt
        }
        
        var shelf = ""
        if let txt = shelfLabel.accessibilityHint , !txt.isEmpty {
            shelf = txt
        }
        
        
        if shipment_date.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter Shipment Date".localized(), InViewC: self)
            isValidated = false
        }else if storage.isEmpty && shipmentStatus == "RECEIVED_AND_VALIDATED" {
            Utility.showPopup(Title: App_Title, Message: "Please select a Storage Area".localized(), InViewC: self)
            isValidated = false
        }else if !shelfView.isHidden && shelf.isEmpty && shipmentStatus == "RECEIVED_AND_VALIDATED"{
            Utility.showPopup(Title: App_Title, Message: "Please select a Shelf".localized(), InViewC: self)
            isValidated = false
        }


        return isValidated

    }
    
    //MARK: - End

    //MARK: - IBAction
    @IBAction func shippingButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        for btn in shippingButtons {
            
            if btn.tag == sender.tag {
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
            
            if btn.isSelected && btn.tag == 1 {
                isShippingTypeCustom = false
            }else if btn.isSelected {
                isShippingTypeCustom = true
            }
            
        }
    }
    
    
    @IBAction func typeButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        
        for btn in typeButtons {
            if btn.tag == sender.tag {
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
            
            
            if btn.isSelected && btn.tag == 1 {
                storageShelfMainView.isHidden = false
                shipmentStatus = "RECEIVED_AND_VALIDATED"
            }else if btn.isSelected && btn.tag == 2 {
                storageShelfMainView.isHidden = true
                shipmentStatus = "RECEIVED"
            }else if btn.isSelected && btn.tag == 3 {
                storageShelfMainView.isHidden = true
                shipmentStatus = "NOT_RECEIVED"
            }
        }
    }
    
    
    @IBAction func directPurchaseButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            isDirectPurchaseSelected = false
        }else{
            sender.isSelected = true
            isDirectPurchaseSelected = true
        }
    }
    
    
    @IBAction func shippingCarrierButtonPressed(_ sender: UIButton) {
        if shippingCarrierArray == nil || isShippingTypeCustom == true {
           return
        }
        sender.tag = 3
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = shippingCarrierArray as! Array<[String:Any]>
        controller.delegate = self
        controller.type = "Shipping Carrier".localized()
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func shippingMethodButtonPressed(_ sender: UIButton) {
        if shippingMethodArray == nil || isShippingTypeCustom == true {
           return
        }
        sender.tag = 4
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = shippingMethodArray as! Array<[String:Any]>
        controller.delegate = self
        controller.type = "Shipping Method".localized()
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func storageLocationButtonPressed(_ sender: UIButton) {
        if storageAreas == nil {
           return
        }
        sender.tag = 1
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = storageAreas as! Array<[String:Any]>
        controller.delegate = self
        controller.type = "Storage Area".localized()
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
          
    }
    
    @IBAction func shelfButtonPressed(_ sender: UIButton) {
        if shelfsArray == nil || shelfsArray?.count == 0 {
            getShelfList(storageAreaUUID: storageLabel.accessibilityHint ?? "")
            return
        }
        sender.tag = 2
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = shelfsArray as! Array<[String:Any]>
        controller.type = "Storage Shelf".localized()
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
          
    }
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        
        if !formValidation(){
            return
        }
        
        let dict = saveData()
        
        Utility.saveDictTodefaults(key: "MIS_ShipmentsDetails", dataDict: dict)
        
        defaults.set(true, forKey: "MIS_2ndStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISLineItemView") as! MISLineItemViewController
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: MISPurchaseOrderViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISPurchaseOrderView") as! MISPurchaseOrderViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 3 {
            nextButtonPressed(UIButton())
        }else if sender.tag == 4 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAggregationView") as! MISAggregationViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }else if sender.tag == 5 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }
        
        
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
        
        if sender != nil && sender?.tag ?? 0 == 1 {
            
            shelfView.isHidden = true
            shelfLabel.text = "Select Shelf".localized()
            shelfLabel.accessibilityHint = ""
            isShelfSelected = false
            defaults.removeObject(forKey: "selected_shelf")
            
            
            
            if let name = data["name"] as? String{
                storageLabel.text = name
                storageLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                if let uuid = data["uuid"] as? String{
                    storageLabel.accessibilityHint = uuid
                }
                
               Utility.saveObjectTodefaults(key: "selected_storage", dataObject: data)
               isStorageSelected = true
            }
            
            let isShelf = data["is_have_shelf"] as! Bool

            if isShelf {
                shelfView.isHidden = false
                isShelfSelected = false
                getShelfList(storageAreaUUID: storageLabel.accessibilityHint ?? "")
            }
            
        }else if sender != nil && sender?.tag ?? 0 == 2 {
            
            if let name = data["name"] as? String{
                shelfLabel.text = name
                shelfLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                if let uuid = data["storage_shelf_uuid"] as? String {
                    shelfLabel.accessibilityHint = uuid
                    
                    Utility.saveObjectTodefaults(key: "selected_shelf", dataObject: data)
                   
                }
                
                isShelfSelected = true
                
            }
        }else if sender != nil && sender?.tag ?? 0 == 3 {
            if let name = data["name"] as? String{
                shippingCarrierLabel.text = name
            }
            if let uuid = data["uuid"] as? String {
                shippingCarrierLabel.accessibilityHint = uuid
            }
            getShippingMethodList(shipping_carrier_uuid: shippingCarrierLabel.accessibilityHint ?? "")
        }else if sender != nil && sender?.tag ?? 0 == 4 {
            if let name = data["name"] as? String{
                shippingMethodLabel.text = name
            }
            if let uuid = data["uuid"] as? String {
                shippingMethodLabel.accessibilityHint = uuid
            }
        }
        
    }
    //MARK: - End
    
    //MARK: - DatePickerViewDelegate
    func dateSelectedWithSender(selectedDate: Date, sender: UIButton?) {
        if sender != nil{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            
            shipmentDateLabel.text = dateStr
            shipmentDateLabel.accessibilityHint = dateStrForApi
        }
    }
    //MARK: - End
    

}
extension MISShipmentDetailsViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        if (textFieldTobeField != nil) {
            textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
            textFieldTobeField = nil

        }
    }
}
