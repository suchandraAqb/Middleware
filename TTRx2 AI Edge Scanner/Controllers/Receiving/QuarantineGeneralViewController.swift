//
//  NewQuarantineGeneralViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 01/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class QuarantineGeneralViewController: BaseViewController,UITextViewDelegate,SingleSelectDropdownDelegate,ConfirmationViewDelegate,AddAttachmentViewDelegate {
    
    var adjustmentType = ""
    @IBOutlet weak var adjustmentTypeButton: UIButton!
    
    @IBOutlet weak var selectSourceLocationLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var referenceView: UIView!
    @IBOutlet weak var referenceSubView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesSubView: UIView!
    
    @IBOutlet weak var locationSelectionView: UIView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var refTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var quarantinePresetButton: UIButton!
    @IBOutlet weak var quarantineOtherButton: UIButton!
    @IBOutlet weak var quarantinePresetDropdownView: UIView!
    @IBOutlet weak var quarantinePresetSubDropdownView: UIView!
    @IBOutlet weak var presetNameLabel: UILabel!
    @IBOutlet weak var quarantineNotesView: UIView!
    @IBOutlet weak var quarantineNotesSubView: UIView!
    @IBOutlet weak var quarantineNotesTextView: UITextView!
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    //MARK: - End
    
    //MARK: Destination Location View For Transfer
    @IBOutlet weak var destinationLocationView: UIView!
    @IBOutlet weak var desLocationSelectionView: UIView!
    @IBOutlet weak var desLocationNameLabel: UILabel!
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var storageSelectionView: UIView!
    @IBOutlet weak var storageNameLabel: UILabel!
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var shelfSelectionView: UIView!
    @IBOutlet weak var shelfNameLabel: UILabel!
    //MARK: - End
    
    //MARK: - Attachment
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var addAttachmentButtonView: UIView!
    @IBOutlet weak var addAttachmentButton: UIButton! 
   // @IBOutlet weak var attachmentListTable: UITableView!
    @IBOutlet weak var attachmentTableHeight: NSLayoutConstraint!
    @IBOutlet weak var quantityCount:UITextField!
    @IBOutlet weak var countView:UIView!
    @IBOutlet weak var countSelectedView:UIView!
    @IBOutlet weak var confirmButton:UIButton!
    //MARK: - End
    
    var allLocations:NSDictionary?
    var selectedLocationUuid:String?
    var selectedDesLocationUuid:String?
    var quaranTineAdjustmentList:Array<Any>?
    var storageAreas:Array<Any>?
    var shelfs:Array<Any>?
    var selectedStorageArea:NSDictionary?
    var selectedShelf:NSDictionary?
    var isStorageSelected = false
    var isShelfSelected = false
    
    
    var attachmentList = [[String:Any]]()
    var isfromReceiving  = false
    var shippingDetailsDict:NSDictionary?
    var otherDetailsDict = NSMutableDictionary()
    
    //MARK: View Life Cyscle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        removeQuarantineDefaults()
        defaults.set(adjustmentType, forKey: "current_adjustment")
        
        getAdjustmentList()
        //createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        setup_initialview()
        
        
        attachmentView.isHidden = true
        print(adjustmentType)
        if adjustmentType == "QUARANTINE"{
            attachmentView.isHidden = true
        }
        let locationUdid = shippingDetailsDict!["location_uuid"] as! String
        self.locationdetailsFetch(locationUdid: locationUdid as NSString)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
    }
   
    //MARK: - End
    //MARK: - Private Method
    func setup_initialview(){
        
        if adjustmentType == Adjustments_Types.Transfer.rawValue {
            selectSourceLocationLabel.text = "Select source".localized()
            destinationLocationView.isHidden = false
            storageView.isHidden = true
            shelfView.isHidden = true
        }else{
            destinationLocationView.isHidden = true
        }
        
        if adjustmentType == Adjustments_Types.Dispense.rawValue {
            reasonView.isHidden = true
        }else{
            reasonView.isHidden = false
        }
        
        
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 17.0,color:Utility.hexStringToUIColor(hex: "719898"))
        refTextField.addLeftViewPadding(padding: 15.0)
        refTextField.inputAccessoryView = inputAccView
        notesTextView.inputAccessoryView = inputAccView
        quantityCount.addLeftViewPadding(padding: 15.0)
        sectionView.roundTopCorners(cornerRadious: 40)
        quarantineToggleButtonPressed(quarantinePresetButton)
        allLocations = UserInfosModel.getLocations()
        quarantineNotesTextView.inputAccessoryView = inputAccView
        
        locationView.setRoundCorner(cornerRadious: 10)
        destinationLocationView.setRoundCorner(cornerRadious: 10)
        reasonView.setRoundCorner(cornerRadious: 10)
        referenceView.setRoundCorner(cornerRadious: 10)
        notesView.setRoundCorner(cornerRadious: 10)
        attachmentView.setRoundCorner(cornerRadious: 10)
        addAttachmentButton.setRoundCorner(cornerRadious: addAttachmentButton.frame.height / 2.0)
        countView.setRoundCorner(cornerRadious: 10)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.height/2.0)
        storageView.setRoundCorner(cornerRadious: 10)
        shelfView.setRoundCorner(cornerRadious: 10)
        
        locationSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        desLocationSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        storageSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        shelfSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quarantinePresetSubDropdownView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quarantineNotesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        referenceSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        notesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        countSelectedView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        populateattachment()
        
        //self.attachmentListTable.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
    }
    
    func populateattachment(){
     //   attachmentListTable.reloadSections([0], with: .fade)
        addAttachmentButtonView.isHidden = true
        if attachmentList.count < 5 {
            addAttachmentButtonView.isHidden = false
        }
    }
    
    deinit {
        //self.attachmentListTable.removeObserver(self, forKeyPath: "contentSize")
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if let obj = object as? UITableView {
//            if obj == self.attachmentListTable && keyPath == "contentSize" {
//                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
//
//                    self.attachmentTableHeight.constant = newSize.height
//                    self.attachmentListTable.invalidateIntrinsicContentSize()
//                    self.attachmentListTable.layoutIfNeeded()
//
//                }
//            }
//        }
//    }
    
    
    func setup_stepview(){
        let isFirstStepCompleted = defaults.bool(forKey: "adjustment_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "adjustment_2ndStep")
        
        
        step1Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        if isFirstStepCompleted && isSecondStepCompleted{
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted {
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Button.isUserInteractionEnabled = true
        }
        step2Button.isHidden = true
        step3Button.isHidden = true
        step2Label.isHidden = true
        step3Label.isHidden = true
        step1BarView.isHidden = true
        step2BarView.isHidden = true
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        
    }
    func getAdjustmentList(){
        let appendStr = "inventory_adjustments_reasons?Type=\(adjustmentType)"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let response = responseData as? NSDictionary{
                        if let dataArr = response["data"] as? Array<Any>{
                            self.quaranTineAdjustmentList = dataArr
                        }
                    }
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        
                        Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                        
                    }else{
                        Utility.showAlertWithPopAction(Title: App_Title, Message: message ?? "", InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }
            }
        }
    }
    
    func saveData(){
        doneTyping()
        otherDetailsDict = NSMutableDictionary()
        
        if let txt = shippingDetailsDict?["uuid"] as? String, !txt.isEmpty {
           // otherDetailsDict.setValue(txt, forKey: "inbound_shipment_uuid")
        }
        
        if let txt = locationNameLabel.accessibilityHint , !txt.isEmpty {
           // otherDetailsDict.setValue(txt, forKey: "location_uuid")
        }
        
        if let txt = locationNameLabel.text , !txt.isEmpty {
          //  otherDetailsDict.setValue(txt, forKey: "location_uuid_name")
        }
        
        if let txt = selectedDesLocationUuid , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "to_location_uuid")
        }
        
        if let txt = desLocationNameLabel.text , !txt.isEmpty {
           // otherDetailsDict.setValue(txt, forKey: "to_location_uuid_name")
        }
        
        if let txt = storageNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "to_storage_area_uuid")
        }
        
        if let txt = storageNameLabel.text , !txt.isEmpty {
            //otherDetailsDict.setValue(txt, forKey: "to_storage_area_uuid_name")
        }
        
        if let txt = shelfNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "to_storage_shelf_uuid")
        }
        
        if let txt = shelfNameLabel.text , !txt.isEmpty {
            //otherDetailsDict.setValue(txt, forKey: "to_storage_shelf_uuid_name")
        }
        
        
        if quarantinePresetButton.isSelected{
            if let txt = presetNameLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "reason_uuid")
                
                if let txt = presetNameLabel.text , !txt.isEmpty {
//                    otherDetailsDict.setValue("", forKey: "reason_text")
                }
            }
        }else{
            if let txt = quarantineNotesTextView.text,!txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "reason_text")
            }
        }
        
        if let txt = refTextField.text {
            otherDetailsDict.setValue(txt, forKey: "reference_num")
        }
        
        if let txt = notesTextView.text {
            otherDetailsDict.setValue(txt, forKey: "notes")
        }
        
        Utility.saveDictTodefaults(key: "adjustment_general_info", dataDict: otherDetailsDict)
    }
    func formValidation()->Bool{
        var isValidated = true
        if let dataDict = Utility.getDictFromdefaults(key: "adjustment_general_info") {
//            let location = dataDict["location_uuid"] as? String ?? ""
            var quarantine = ""
            if ((dataDict["reason_uuid"] as? String) != nil) {
                quarantine = dataDict["reason_uuid"] as? String ?? ""
            }else if(((dataDict["reason_text"] as? String) != nil)){
                quarantine = dataDict["reason_text"] as? String ?? ""
            }
            
            
            
//            if location.isEmpty {
//                Utility.showPopup(Title: App_Title, Message: "Please select source Location.".localized(), InViewC: self)
//                isValidated = false
//            }else
            if adjustmentType == Adjustments_Types.Transfer.rawValue {
                
                let toLocation = dataDict["to_location_uuid"] as? String ?? ""
                let storage = dataDict["to_storage_area_uuid"] as? String ?? ""
                let shelf = dataDict["to_storage_shelf_uuid"] as? String ?? ""
                
                if !destinationLocationView.isHidden && toLocation.isEmpty {
                    Utility.showPopup(Title: App_Title, Message: "Please select destination Location.".localized(), InViewC: self)
                    isValidated = false
                }
//                else if location == toLocation {
//                    Utility.showPopup(Title: App_Title, Message: "Source and destination location can't be same.".localized(), InViewC: self)
//                    isValidated = false
//
//                }
                else if !storageView.isHidden && storage.isEmpty {
                    Utility.showPopup(Title: App_Title, Message: "Please select a storage area".localized(), InViewC: self)
                    isValidated = false
                }else if !shelfView.isHidden && shelf.isEmpty{
                    Utility.showPopup(Title: App_Title, Message: "Please select a Shelf.".localized(), InViewC: self)
                    isValidated = false
                }else if quarantine.isEmpty{
                    Utility.showPopup(Title: App_Title, Message: "Please select/type".localized() + " \(adjustmentType) " + "reason.".localized(), InViewC: self)
                    isValidated = false
                }
            }else if quarantine.isEmpty && adjustmentType != Adjustments_Types.Dispense.rawValue{
                Utility.showPopup(Title: App_Title, Message: "Please select/type".localized() + " \(adjustmentType) " + "reason.".localized(), InViewC: self)
                isValidated = false
            }
        }else{
            isValidated = false
        }
        
        
        return isValidated
        
    }
    
    func confirmInboundShipmentQuarantine(){
        let appendStr = shippingDetailsDict?["uuid"] as! String + "\("/quarantine")"
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "quarantine", serviceParam: otherDetailsDict, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if (responseDict["new_adjustment_uuid"] as? String) != nil {
                        self.removeSpinner()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Quarantine request submitted".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                    }
                    
                    
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else  if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                        }
                        
                        
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }
    

    func populateGeneralInfo(){
        
        if let type = defaults.value(forKey: "current_adjustment") as? String {
            adjustmentTypeButton.setTitle(type.capitalized.localized(), for: .normal)
        }
        
        
        if let dataDict = Utility.getDictFromdefaults(key: "adjustment_general_info") {
            
            
            if let txt =  dataDict["location_uuid"] as? String, !txt.isEmpty {
                selectedLocationUuid = txt
                
                if let name =  dataDict["location_uuid_name"] as? String, !name.isEmpty {
                    locationNameLabel.text = name
                    locationNameLabel.accessibilityHint = txt
                }
            }else{
                if allLocations != nil {
                    let allkeys = allLocations?.allKeys
                    let firstStorage = allLocations![allkeys?.first as? String ?? ""]
                    let button = UIButton()
                    button.tag = 1
                    selectedItem(itemStr: allkeys?.first as? String ?? "", data: firstStorage as! NSDictionary, sender: button)
                }
                
            }
            
            
            if let txt =  dataDict["to_location_uuid"] as? String, !txt.isEmpty {
                selectedDesLocationUuid = txt
                
                if let name =  dataDict["to_location_uuid_name"] as? String, !name.isEmpty {
                    desLocationNameLabel.text = name
                    desLocationNameLabel.accessibilityHint = txt
                }
                
                if allLocations != nil {
                    
                    if let locationData = allLocations![txt] as? NSDictionary{
                        let button = UIButton()
                        button.tag = 2
                        selectedItem(itemStr: txt, data: locationData, sender: button)
                    }
                    
                    
                    if let s_txt =  dataDict["to_storage_area_uuid"] as? String, !s_txt.isEmpty {
                        
                        if let name =  dataDict["to_storage_area_uuid_name"] as? String, !name.isEmpty {
                            storageNameLabel.text = name
                            storageNameLabel.accessibilityHint = s_txt
                            isStorageSelected = true
                            
                            
                            if storageAreas != nil {
                                
                                let predicate = NSPredicate(format: "uuid = '\(s_txt)'")
                                let arr = (storageAreas! as NSArray).filtered(using: predicate)
                                
                                if arr.count > 0{
                                    if let data = arr.first as?NSDictionary {
                                        let button = UIButton()
                                        button.tag = 5
                                        selecteditem(data: data, sender: button)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let sh_txt =  dataDict["to_storage_shelf_uuid"] as? String, !sh_txt.isEmpty {
                        
                        if let name =  dataDict["to_storage_shelf_uuid_name"] as? String, !name.isEmpty {
                            shelfNameLabel.text = name
                            shelfNameLabel.accessibilityHint = sh_txt
                            isShelfSelected = true
                        }
                    }
                }
            }
            
            
            if let txt =  dataDict["reason_uuid"] as? String, !txt.isEmpty{
                presetNameLabel.accessibilityHint = txt
                
                if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                    presetNameLabel.text = txt
                }
                
                quarantineToggleButtonPressed(quarantinePresetButton)
                
                
                
            }else if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                quarantineNotesTextView.text = txt
                quarantineToggleButtonPressed(quarantineOtherButton)
            }
            
            
            if let txt =  dataDict["reference_num"] as? String, !txt.isEmpty{
                refTextField.text = txt
            }
            
            
            if let txt =  dataDict["notes"] as? String, !txt.isEmpty{
                notesTextView.text = txt
            }
            
        }else{
            if allLocations != nil {
                let allkeys = allLocations?.allKeys
                let firstStorage = allLocations![allkeys?.first as? String ?? ""]
                let button = UIButton()
                button.tag = 1
                selectedItem(itemStr: allkeys?.first as? String ?? "", data: firstStorage as! NSDictionary, sender: button)
            }
        }
        
    }
    
    func removeQuarantineDefaults(){
       // defaults.removeObject(forKey: "adjustment_1stStep")
       // defaults.removeObject(forKey: "adjustment_2ndStep")
        defaults.removeObject(forKey: "adjustment_general_info")
        defaults.removeObject(forKey: "current_adjustment")
        Utility.removeAdjustmentsFromDB()
    }
    
    func locationdetailsFetch(locationUdid:NSString){
        if locationUdid != "" {
            let selctedStorage = allLocations![locationUdid as String ] as! NSDictionary?
            if selctedStorage != nil {
                self.populatedDataFromselectedStorage(detailsDict: selctedStorage!,locationuuid:locationUdid as String)
             }
        }
    }
    func populatedDataFromselectedStorage(detailsDict:NSDictionary,locationuuid:String){
        let dict = shippingDetailsDict! as NSDictionary
        if  locationuuid != ""{
            selectedDesLocationUuid = locationuuid
            
            if let name =  detailsDict["name"] as? String, !name.isEmpty {
                locationNameLabel.text = name
                locationNameLabel.accessibilityHint = locationuuid
            }
        }else{
            if allLocations != nil {
                let allkeys = allLocations?.allKeys
                let firstStorage = allLocations![allkeys?.first as? String ?? ""]
                let button = UIButton()
                button.tag = 1
                selectedItem(itemStr: allkeys?.first as? String ?? "", data: firstStorage as! NSDictionary, sender: button)
            }
            
        }
        if let s_arr =  detailsDict["sa"] as? NSArray, s_arr.count>0 {
            storageAreas = s_arr as? Array<Any>
            let dict = s_arr.firstObject as! NSDictionary
            if let name =  dict["name"] as? String, !name.isEmpty {
                self.storageView.isHidden = false
                storageNameLabel.text = name
                storageNameLabel.accessibilityHint = dict["uuid"] as? String
                isStorageSelected = true
                let haveShelf = dict["is_have_shelf"] as! Bool
                if haveShelf {
                    shelfView.isHidden = false;
                    self.getShelfList(storageAreaUUID: dict["uuid"] as! String)

                }else{
                    shelfView.isHidden = true;
                    self.shelfNameLabel.text = ""
                    self.shelfNameLabel.accessibilityHint = ""
                }
                
            }else{
                self.storageView.isHidden = true
                shelfView.isHidden = true;
                self.storageNameLabel.text = ""
                self.storageNameLabel.accessibilityHint=""
                self.shelfNameLabel.text = ""
                self.shelfNameLabel.accessibilityHint = ""
            }
        }else{
            self.storageView.isHidden = true
            shelfView.isHidden = true;
            self.storageNameLabel.text = ""
            self.storageNameLabel.accessibilityHint=""
            self.shelfNameLabel.text = ""
            self.shelfNameLabel.accessibilityHint = ""
        
        }
        if (dict["ship_lines_item"] != nil) {
            var quantity = 0
            let shipitems = dict["ship_lines_item"] as! NSArray
            if shipitems.count>0 {
                for item in shipitems{
                    let itemDict = item as! NSDictionary
                    quantity = quantity + (itemDict["quantity"] as! Int)
                }
            }
            
            let qtystr : String = "\(quantity)"
            quantityCount.text = qtystr
        }
        if (dict["transactions"] != nil){
            let transarr = dict["transactions"] as! NSArray
            let transDict = transarr.firstObject as! NSDictionary
            let poNumber = transDict["po_number"] as? String
            if !poNumber!.isEmpty {
                refTextField.text = poNumber
            }
        }
    }
    func getShelfList(storageAreaUUID:String){
        
        let appendStr:String! = (selectedDesLocationUuid ?? "") as String + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
        
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetShelfList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let list = responseDict["data"] as? Array<[String : Any]>{
                        self.shelfs = list
                        
                        let dict = self.shelfs?.first as! NSDictionary
                        if let name = dict["name"] as? String{
                            self.shelfNameLabel.text = name
                            if let uuid = dict["storage_shelf_uuid"] as? String {
                                self.shelfNameLabel.accessibilityHint = uuid
                            }
                            self.isShelfSelected = true
                            
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
    
    func checkIfProductAvailable() -> Bool{
        var product = 0
        var serial = 0
        var isProductAvailable = false
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true")
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                let uniqueArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid")
                product = (uniqueArr as? Array<Any>)?.count ?? 0
                
                
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false")
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                serial = arr.count
                
                
            }
        }catch let error{
            
            print(error.localizedDescription)
        }
        
        
        if product > 0 || serial > 0 {
            isProductAvailable = true
        }
        
        return isProductAvailable
    }
    //MARK: - End
    //MARK: - IBAction
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        saveData()
        if !formValidation(){
            return
        }
        self.confirmInboundShipmentQuarantine()
        
    }
    
    func openScanDetails(){
        
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        if sender.tag == 2 {
            nextButtonPressed(UIButton())
            
        }else if sender.tag == 3 {
            saveData()
            if !formValidation(){
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AdjustmentConfirmView") as! AdjustmentConfirmViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
        
    }
    @IBAction func quarantineToggleButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.isSelected{
            return
        }
        
        if sender == quarantinePresetButton {
            quarantinePresetButton.isSelected = true
            quarantineOtherButton.isSelected = false
            quarantinePresetDropdownView.isHidden = false
            quarantineNotesView.isHidden = true
        }else{
            quarantinePresetButton.isSelected = false
            quarantineOtherButton.isSelected = true
            quarantinePresetDropdownView.isHidden = true
            quarantineNotesView.isHidden = false
        }
        
    }
    
    @IBAction func locationSelectionButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        if allLocations == nil {
            return
        }
        
        if sender.tag == 1 {
            if checkIfProductAvailable(){
                Utility.showPopup(Title: App_Title, Message: "There are item(s) attached to this location. Please remove those item(s) first from Items section to change location.".localized(), InViewC: self)
                return
            }
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = true
        controller.nameKeyName = "name"
        controller.listItemsDict = allLocations
        controller.delegate = self
        controller.type = "Locations".localized()
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        
        self.present(controller, animated: true, completion: nil)
        
        
    }
    
    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 5{
            
            if storageAreas == nil {
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = storageAreas as! Array<[String:Any]>
            controller.delegate = self
            controller.type = "Storage Area".localized()
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
        }else if sender.tag == 6{
            
            if shelfs == nil || shelfs?.count == 0 {
                getShelfList(storageAreaUUID: storageNameLabel.accessibilityHint ?? "")
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = shelfs as! Array<[String:Any]>
            controller.type = "Storage Shelf".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func quarantineReasonButtonPressed(_ sender: UIButton) {
        if quaranTineAdjustmentList == nil {
            return
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = quaranTineAdjustmentList as! [[String : Any]]
        controller.delegate = self
        controller.type = ""
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func quarantineBackButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want cancel".localized() + " \(adjustmentType.capitalized)".firstUppercased
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func addAttachmentButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddAttachmentView") as! AddAttachmentViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    
    @IBAction func attachmentDeleteButtonPressed(_ sender: UIButton) {
        
        let msg = "You are about to delete the resource.".localized() + "\n" + "This operation can’t be undone.".localized() + "\n\n" + "Proceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            let obj = self.attachmentList[sender.tag]
            
            if (self.attachmentList as NSArray).contains(obj) {
                let index = (self.attachmentList as NSArray).index(of: obj)
                self.attachmentList.remove(at: index)
                
                self.populateattachment()
            }
            
            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    @IBAction func cancelButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - End
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
        textViewTobeField = nil
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    //MARK: - End
    //MARK: - textView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.inputAccessoryView = inputAccView
        textViewTobeField = textView
        textFieldTobeField = nil
    }
    
    //MARK: - End
    
    //MARK: - SingleSelectDropdownDelegate
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 1 {
            
            if let name = data["name"] as? String{
                locationNameLabel.text = name
                locationNameLabel.accessibilityHint = itemStr
                selectedLocationUuid = itemStr
            }
           self.locationdetailsFetch(locationUdid: itemStr as NSString)

        }else if sender != nil && sender!.tag == 2 {
            
            
            storageView.isHidden = true
            storageNameLabel.text = "Select Storage Area".localized()
            storageNameLabel.accessibilityHint = ""
            shelfView.isHidden = true
            shelfNameLabel.text = "Select Shelf".localized()
            shelfNameLabel.accessibilityHint = ""
            
            
            if let name = data["name"] as? String{
                desLocationNameLabel.text = name
                desLocationNameLabel.accessibilityHint = itemStr
                self.selectedDesLocationUuid = itemStr
                if let sa_areas = data["sa"] as? Array<Any>{
                    
                    storageAreas = sa_areas
                    storageView.isHidden = false
                }else{
                    storageView.isHidden = true
                    shelfView.isHidden = true
                    
                    if let sa_count = data["sa_count"]as? Int {
                        
                        if sa_count > 0 {
                            let userinfo = UserInfosModel.UserInfoShared
                            self.showSpinner(onView: self.view)
                            userinfo.getStorageAreasOfALocation(location_uuid: itemStr, ServiceCompletion:{ (isDone:Bool? , sa:Array<Any>?) in
                                self.removeSpinner()
                                
                                DispatchQueue.main.async{
                                    if sa != nil && !(sa?.isEmpty ?? false){
                                        self.storageAreas = sa
                                        self.storageView.isHidden = false
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 4 {
            
            if let name = data["name"] as? String{
                presetNameLabel.text = name
                
                if let uuid = data["uuid"] as? String {
                    presetNameLabel.accessibilityHint = uuid
                }
                
            }
        }else if sender != nil && sender!.tag == 5 {
            
            shelfView.isHidden = true
            shelfNameLabel.text = "Select Shelf".localized()
            shelfNameLabel.accessibilityHint = ""
            
            if let name = data["name"] as? String{
                storageNameLabel.text = name
                
                if let uuid = data["uuid"] as? String{
                    storageNameLabel.accessibilityHint = uuid
                }
                
                isStorageSelected = true
            }
            
            let isShelf = data["is_have_shelf"] as! Bool
            
            if isShelf {
                shelfView.isHidden = false
                isShelfSelected = false
                getShelfList(storageAreaUUID: storageNameLabel.accessibilityHint ?? "")
            }else{
                shelfView.isHidden = true
                shelfNameLabel.text = "Select Shelf".localized()
                shelfNameLabel.accessibilityHint = ""
                isShelfSelected = false
                
            }
        }else if sender != nil && sender!.tag == 6 {
            
            if let name = data["name"] as? String{
                shelfNameLabel.text = name
                
                if let uuid = data["storage_shelf_uuid"] as? String {
                    shelfNameLabel.accessibilityHint = uuid
                }
                
                isShelfSelected = true
                
            }
        }
    }
    //MARK: - End
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
        
    }
    func cancelConfirmation() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
    
    
    //MARK: - Search View Delegate
    func attachmentAdd(attachmentDict:[String:Any]?) {
        self.attachmentList.append(attachmentDict!)
        populateattachment()
    }
    //MARK: End
    
    
}

//MARK: - Tableview Delegate and Datasource

//extension QuarantineGeneralViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return UITableView.automaticDimension
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return attachmentList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return self.configureCell(at: indexPath)
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
//
//    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
//        let cell = attachmentListTable.dequeueReusableCell(withIdentifier: "AttachmentCell") as! AttachmentCell
//
//        let dict = self.attachmentList[indexPath.row]
//
//        var dataStr = ""
//        if let txt = dict["fileName"] as? String,!txt.isEmpty{
//            dataStr = txt
//        }
//        cell.attachmentNameLabel.text = dataStr
//
//        cell.typeButton.isHighlighted = false
//
//        if let txt = dict["fileType"] as? String,!txt.isEmpty{
//            if txt == "Picture" {
//                cell.typeButton.isHighlighted = true
//            }else if txt == "Video" {
//                cell.typeButton.isSelected = false
//            }else if txt == "Document" {
//                cell.typeButton.isSelected = true
//            }
//        }
//
//
//        cell.deleteButton.tag = indexPath.row
//
//        return cell
//    }
//}

//MARK: - End



//MARK: - Tableview Cell
//class AttachmentCell: UITableViewCell {
//
//    @IBOutlet weak var attachmentNameLabel: UILabel!
//    @IBOutlet weak var deleteButton: UIButton!
//    @IBOutlet weak var typeButton: UIButton!
//}
extension QuarantineGeneralViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        if (textFieldTobeField != nil) {
            textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
            textFieldTobeField = nil

        }else{
            textViewTobeField?.text = (codeDetails["scannedCodes"] as! String)
            textViewTobeField = nil

        }
        
    }
}
//MARK: - End

