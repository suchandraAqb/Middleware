//
//  ReturnSummaryViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 15/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnSummaryViewController: BaseViewController,UITextViewDelegate,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var shipmentSerialsSummaryView: UIView!
    @IBOutlet weak var toReturnedView: UIView!
    @IBOutlet weak var toReturnedLabel: UILabel!
    @IBOutlet weak var resaleableCountLabel: UILabel!
    @IBOutlet weak var quarantineCountLabel: UILabel!
    @IBOutlet weak var notResaleableCountLabel: UILabel!
    
    @IBOutlet weak var resalableView: UIView!
    @IBOutlet weak var resalableCountStrLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationSubView: UIView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var storageSubView: UIView!
    @IBOutlet weak var storageNameLabel: UILabel!
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var shelfSubView: UIView!
    @IBOutlet weak var shelfNameLabel: UILabel!
    
    @IBOutlet weak var quarantineView: UIView!
    @IBOutlet weak var quarantineCountStrLabel: UILabel!
    @IBOutlet weak var quarantinePresetButton: UIButton!
    @IBOutlet weak var quarantineOtherButton: UIButton!
    @IBOutlet weak var quarantinePresetDropdownView: UIView!
    @IBOutlet weak var quarantinePresetSubDropdownView: UIView!
    @IBOutlet weak var presetNameLabel: UILabel!
    @IBOutlet weak var quarantineNotesView: UIView!
    @IBOutlet weak var quarantineNotesSubView: UIView!
    @IBOutlet weak var quarantineNotesTextView: UITextView!
    
    @IBOutlet weak var notResalableView: UIView!
    @IBOutlet weak var notResalableCountStrLabel: UILabel!
    @IBOutlet weak var notResalablePresetButton: UIButton!
    @IBOutlet weak var notResalableOtherButton: UIButton!
    @IBOutlet weak var notResalablePresetDropdownView: UIView!
    @IBOutlet weak var notResalablePresetDropdownSubView: UIView!
    @IBOutlet weak var notResalablePresetNameLabel: UILabel!
    @IBOutlet weak var notResalableNotesView: UIView!
    @IBOutlet weak var notResalableNotesSubView: UIView!
    @IBOutlet weak var notResalableNotesTextView: UITextView!
    
    
    
    //MARK: Step Items
    @IBOutlet weak var step4View: UIView!
    @IBOutlet weak var step3BarViewContainer: UIView!
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step4Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step3BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    
    @IBOutlet weak var pendingItemsLabel: UILabel!
    
    
    var quaranTineAdjustmentList:Array<Any>?
    var notResalableAdjustmentList:Array<Any>?
    var allLocations:NSDictionary?
    var storageAreas:Array<Any>?
    var shelfs:Array<Any>?
    var selectedLocationUuid:String?
    var selectedStorageArea:NSDictionary?
    var selectedShelf:NSDictionary?
    var isStorageSelected = false
    var isShelfSelected = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotificationForRefreshVerificationSTatus), name: Notification.Name("Return_RefreshProducts"), object: nil)
        
        sectionView.roundTopCorners(cornerRadious: 40)
        shipmentSerialsSummaryView.setRoundCorner(cornerRadious: 10)
        createInputAccessoryView()
        setup_overallview()
        getAdjustmentList(type: "QUARANTINE")
        getAdjustmentList(type: "DESTRUCTION")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        populateReturnSummary()
        populatePendingCount()
    }
    //MARK: - End
    ///////////////////////////////////////////////////////
    //MARK: - Remove Observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - End
    ////////////////////////////////////////////////////
    //MARK: - Private Method
    func populatePendingCount(){
        
        guard let return_uuid = defaults.object(forKey: "current_returnuuid") as? String , !return_uuid.isEmpty else {
            return
        }
        
        do{
            
            let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialWithStatusRequest(uuid: return_uuid, status: Return_Serials.Status.Pending.rawValue))
            
            
            if !serial_obj.isEmpty{
                pendingItemsLabel.isHidden = false
                pendingItemsLabel.text = "\(serial_obj.count) " + "Item(s) is pending for verifications.".localized()
            }else{
                pendingItemsLabel.isHidden = true
                pendingItemsLabel.text = "0 " + "Item(s) is pending for verifications.".localized()
                
            }
            
            
        }catch let error{
            print(error.localizedDescription)
            
        }
        
    }
    
    func populateReturnedLabel(product:String?){
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 13.0)!]
        let productString = NSMutableAttributedString(string: "To be returned".localized() + " ", attributes: custAttributes)
        
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "00AFEF"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 30.0)!]
        
        let productStr = NSAttributedString(string: product ?? "0", attributes: custTypeAttributes)
        
        
        productString.append(productStr)
        
        toReturnedLabel.attributedText = productString
        
        
    }
    
    func setup_overallview(){
        storageView.isHidden = true
        shelfView.isHidden = true
        quarantineToggleButtonPressed(quarantinePresetButton)
        notResalableToggleButtonPressed(notResalablePresetButton)
        allLocations = UserInfosModel.getLocations()
        quarantineNotesTextView.inputAccessoryView = inputAccView
        notResalableNotesTextView.inputAccessoryView = inputAccView
        resalableView.setRoundCorner(cornerRadious: 10)
        quarantineView.setRoundCorner(cornerRadious: 10)
        notResalableView.setRoundCorner(cornerRadious: 10)
        toReturnedView.setRoundCorner(cornerRadious: 5)
        locationSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        storageSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        shelfSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quarantinePresetSubDropdownView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        notResalablePresetDropdownSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quarantineNotesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        notResalableNotesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
    }
    
    
    
    func setup_stepview(){
        let isFirstStepCompleted = defaults.bool(forKey: "return_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "return_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "return_3rdStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted {
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step4Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted{
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
        }else if isFirstStepCompleted {
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        }
    }
    
    func getAdjustmentList(type:String){
        let appendStr = "inventory_adjustments_reasons?Type=\(type)"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let response = responseData as? NSDictionary{
                        
                        if let dataArr = response["data"] as? Array<Any>{
                            if type == "QUARANTINE"{
                                self.quaranTineAdjustmentList = dataArr
                            }else if type == "DESTRUCTION"{
                                self.notResalableAdjustmentList = dataArr
                            }
                            
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
    
    func getShelfList(storageAreaUUID:String){
        
        let appendStr:String! = (selectedLocationUuid ?? "") as String + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
        
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetShelfList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let list = responseDict["data"] as? Array<[String : Any]>{
                        self.shelfs = list
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
    
    func saveData(){
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
        if let txt = locationNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "resalable_items__location_uuid")
        }
        
        if let txt = locationNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "resalable_items__location_name")
        }
        
        if let txt = storageNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "resalable_items__storage_area_uuid")
        }
        
        if let txt = storageNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "resalable_items__storage_area_name")
        }
        
        
        
        if let txt = shelfNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "resalable_items__storage_shelf_uuid")
        }
        
        if let txt = shelfNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "resalable_items__storage_shelf_name")
        }
        
        
        
        if quarantinePresetButton.isSelected{
            if let txt = presetNameLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "quarantine_reason__preset_uuid")
                
                if let txt = presetNameLabel.text , !txt.isEmpty {
                    otherDetailsDict.setValue(txt, forKey: "quarantine_reason__custom")
                }
            }
            
            
        }else{
            if let txt = quarantineNotesTextView.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "quarantine_reason__custom")
            }
        }
        
        if notResalablePresetButton.isSelected{
            if let txt = notResalablePresetNameLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "destruction_reason__preset_uuid")
                
                if let txt = notResalablePresetNameLabel.text , !txt.isEmpty {
                    otherDetailsDict.setValue(txt, forKey: "destruction_reason__custom")
                }
                
            }
            
        }else{
            if let txt = notResalableNotesTextView.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "destruction_reason__custom")
            }
        }
        
        
        
        Utility.saveDictTodefaults(key: "return_summary_info", dataDict: otherDetailsDict)
    }
    func populateReturnSummary(){
        
        if let dataDict = Utility.getDictFromdefaults(key: "return_summary_info") {
            
            if let txt =  dataDict["resalable_items__location_uuid"] as? String, !txt.isEmpty {
                selectedLocationUuid = txt
                
                if let name =  dataDict["resalable_items__location_name"] as? String, !name.isEmpty {
                    locationNameLabel.text = name
                    locationNameLabel.accessibilityHint = txt
                }
                
                if allLocations != nil {
                    
                    if let locationData = allLocations![txt] as? NSDictionary{
                        let button = UIButton()
                        button.tag = 1
                        selectedItem(itemStr: txt, data: locationData, sender: button)
                    }
                    
                    
                    if let s_txt =  dataDict["resalable_items__storage_area_uuid"] as? String, !s_txt.isEmpty {
                        
                        if let name =  dataDict["resalable_items__storage_area_name"] as? String, !name.isEmpty {
                            storageNameLabel.text = name
                            storageNameLabel.accessibilityHint = s_txt
                            isStorageSelected = true
                            
                            
                            if storageAreas != nil {
                                
                                let predicate = NSPredicate(format: "uuid = '\(s_txt)'")
                                let arr = (storageAreas! as NSArray).filtered(using: predicate)
                                
                                if arr.count > 0{
                                    if let data = arr.first as?NSDictionary {
                                        let button = UIButton()
                                        button.tag = 2
                                        selecteditem(data: data, sender: button)
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    
                    
                    if let sh_txt =  dataDict["resalable_items__storage_shelf_uuid"] as? String, !sh_txt.isEmpty {
                        
                        if let name =  dataDict["resalable_items__storage_shelf_name"] as? String, !name.isEmpty {
                            shelfNameLabel.text = name
                            shelfNameLabel.accessibilityHint = sh_txt
                            isShelfSelected = true
                        }
                    }
                }
            }
            
            
            if let txt =  dataDict["quarantine_reason__preset_uuid"] as? String, !txt.isEmpty{
                presetNameLabel.accessibilityHint = txt
                
                if let txt =  dataDict["quarantine_reason__custom"] as? String, !txt.isEmpty{
                    presetNameLabel.text = txt
                }
                
                quarantineToggleButtonPressed(quarantinePresetButton)
                
                
                
            }else if let txt =  dataDict["quarantine_reason__custom"] as? String, !txt.isEmpty{
                quarantineNotesTextView.text = txt
                quarantineToggleButtonPressed(quarantineOtherButton)
            }
            
            if let txt =  dataDict["destruction_reason__preset_uuid"] as? String, !txt.isEmpty{
                notResalablePresetNameLabel.accessibilityHint = txt
                
                if let txt =  dataDict["destruction_reason__custom"] as? String, !txt.isEmpty{
                    notResalablePresetNameLabel.text = txt
                }
                
                notResalableToggleButtonPressed(notResalablePresetButton)
                
            }else if let txt =  dataDict["destruction_reason__custom"] as? String, !txt.isEmpty{
                notResalableNotesTextView.text = txt
                notResalableToggleButtonPressed(notResalableOtherButton)
            }
            
            
        }
        
        let resalable = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Resalable.rawValue)
        resaleableCountLabel.text = "\(resalable)"
        
        if resalable > 0 {
            resalableView.isHidden = false
            
        }else{
            resalableView.isHidden = true
            selectedLocationUuid = ""
            locationNameLabel.text = ""
            locationNameLabel.accessibilityHint = ""
            isShelfSelected = false
        }
        
        let quarantine = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Quarantine.rawValue)
        quarantineCountLabel.text = "\(quarantine)"
        
        if quarantine > 0 {
            quarantineView.isHidden = false
            
            
        }else{
            quarantineView.isHidden = true
            presetNameLabel.accessibilityHint = ""
            presetNameLabel.text = ""
            quarantineNotesTextView.text = ""
            quarantineToggleButtonPressed(quarantinePresetButton)
        }
        
        let destruct = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Destruct.rawValue)
        notResaleableCountLabel.text = "\(destruct)"
        
        if destruct > 0 {
            notResalableView.isHidden = false
            
            
        }else{
            notResalableView.isHidden = true
            notResalablePresetNameLabel.accessibilityHint = ""
            notResalablePresetNameLabel.text = ""
            notResalableNotesTextView.text = ""
            notResalableToggleButtonPressed(notResalablePresetButton)
        }
        
        populateReturnedLabel(product: "\(resalable+quarantine+destruct)")
        
        
    }
    
    func formValidation()->Bool{
        var isValidated = true
        if let dataDict = Utility.getDictFromdefaults(key: "return_summary_info") {
            
            let location = dataDict["resalable_items__location_uuid"] as? String ?? ""
            let storage = dataDict["resalable_items__storage_area_uuid"] as? String ?? ""
            let shelf = dataDict["resalable_items__storage_shelf_uuid"] as? String ?? ""
            let quarantine = dataDict["quarantine_reason__custom"] as? String ?? ""
            let destruction = dataDict["destruction_reason__custom"] as? String ?? ""
            
            
            if !resalableView.isHidden && location.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select a Location.".localized(), InViewC: self)
                isValidated = false
            }else if !storageView.isHidden && storage.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select a storage area".localized(), InViewC: self)
                isValidated = false
            }else if !shelfView.isHidden && shelf.isEmpty{
                Utility.showPopup(Title: App_Title, Message: "Please select a Shelf.".localized(), InViewC: self)
                isValidated = false
            }else if !quarantineView.isHidden && quarantine.isEmpty{
                Utility.showPopup(Title: App_Title, Message: "Please select/type quarantine reason.".localized(), InViewC: self)
                isValidated = false
            }else if !notResalableView.isHidden && destruction.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select/type destruction reason.".localized(), InViewC: self)
                isValidated = false
                
            }
        }
        
        
        return isValidated
        
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ReturnGeneralInfoViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnGeneralInfoView") as! ReturnGeneralInfoViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ReturnSerialVerificationViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnSerialVerificationView") as! ReturnSerialVerificationViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }else if sender.tag == 4 {
            nextButtonPressed(UIButton())
        }
        
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        saveData()
        if !formValidation(){
            return
        }
        
        defaults.set(true, forKey: "return_3rdStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnConfirmationView") as! ReturnConfirmationViewController
        self.navigationController?.pushViewController(controller, animated: false)
        
        
    }
    
    @IBAction func viewAllProductSummaryViewButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnProductSummaryView") as! ReturnProductSummaryViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    
    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1 {
            if allLocations == nil {
                return
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
            
        }else if sender.tag == 2{
            
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
            
        }else if sender.tag == 3{
            
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
            
        }else if sender.tag == 4{
            
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
            
        }else if sender.tag == 5{
            
            if notResalableAdjustmentList == nil {
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = notResalableAdjustmentList as! [[String : Any]]
            controller.delegate = self
            controller.type = ""
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
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
    
    @IBAction func notResalableToggleButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.isSelected{
            return
        }
        
        if sender == notResalablePresetButton {
            notResalablePresetButton.isSelected = true
            notResalableOtherButton.isSelected = false
            notResalablePresetDropdownView.isHidden = false
            notResalableNotesView.isHidden = true
        }else{
            notResalablePresetButton.isSelected = false
            notResalableOtherButton.isSelected = true
            notResalablePresetDropdownView.isHidden = true
            notResalableNotesView.isHidden = false
        }
    }
    //MARK: - End
    /////////////////////////////////////////////////
    //MARK: - textView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.inputAccessoryView = inputAccView
    }
    //MARK: - End
    //////////////////////////////////////////////////
    //MARK: - SingleSelectDropdownDelegate
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 1 {
            
            
            storageView.isHidden = true
            storageNameLabel.text = "Select Storage Area".localized()
            storageNameLabel.accessibilityHint = ""
            shelfView.isHidden = true
            shelfNameLabel.text = "Select Shelf".localized()
            shelfNameLabel.accessibilityHint = ""
            
            
            if let name = data["name"] as? String{
                locationNameLabel.text = name
                locationNameLabel.accessibilityHint = itemStr
                self.selectedLocationUuid = itemStr
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
        if sender != nil && sender!.tag == 3 {
            
            if let name = data["name"] as? String{
                shelfNameLabel.text = name
                
                if let uuid = data["storage_shelf_uuid"] as? String {
                    shelfNameLabel.accessibilityHint = uuid
                }
                
                isShelfSelected = true
                
            }
        }else if sender != nil && sender!.tag == 2 {
            
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
        }
        
        else if sender != nil && sender!.tag == 4 {
            
            if let name = data["name"] as? String{
                presetNameLabel.text = name
                
                if let uuid = data["uuid"] as? String {
                    presetNameLabel.accessibilityHint = uuid
                }
                
            }
        }else if sender != nil && sender!.tag == 5 {
            
            if let name = data["name"] as? String{
                notResalablePresetNameLabel.text = name
                
                if let uuid = data["uuid"] as? String {
                    notResalablePresetNameLabel.accessibilityHint = uuid
                }
            }
        }
    }
    
    //MARK: - Local Notification Receiver Method
    @objc func receiveNotificationForRefreshVerificationSTatus(_ notification: NSNotification) {
        // Take Action on Notification
        populatePendingCount()
    }
    
    //MARK: - End
}
