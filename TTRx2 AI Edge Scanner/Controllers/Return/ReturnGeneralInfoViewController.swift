//
//  ReturnGeneralInfoViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 10/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnGeneralInfoViewController: BaseViewController,SingleSelectDropdownDelegate,DatePickerViewDelegate {
    
    @IBOutlet weak var shipmentDetailsContainer: UIView!
    @IBOutlet weak var transactionDetailsContainer: UIView!
    
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var orderTimeLabel: UILabel!
    @IBOutlet weak var shipmentDateLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var shippingCarrierLabel: UILabel!
    @IBOutlet weak var shippingMethodLabel: UILabel!
    
    @IBOutlet weak var trackingNoTextfield: UITextField!
    @IBOutlet weak var notesTextfield: UITextField!
    
    @IBOutlet weak var customShippingCarrierTextfield: UITextField!
    @IBOutlet weak var customShippingMethodTextfield: UITextField!
    
    @IBOutlet weak var shippingCarrierButton: UIButton!
    @IBOutlet weak var shippingMethodButton: UIButton!
    
    @IBOutlet weak var sctoggle1Button: UIButton!
    @IBOutlet weak var sctoggle2Button: UIButton!
    
    @IBOutlet weak var smtoggle1Button: UIButton!
    @IBOutlet weak var smtoggle2Button: UIButton!
    
    //MARK: Step Items
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
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    @IBOutlet var btnVRS: UIButton!
    
    var scList:Array<Any>?
    var smList:Array<Any>?
    var orderDate = Date()
    var isOnVRS = false
    var shipmentDate = Date()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(shipment_cond_array)
        // Do any additional setup after loading the view.
        populateMandatoryFieldsMark()
        sectionView.roundTopCorners(cornerRadious: 40)
        shipmentDetailsContainer.setRoundCorner(cornerRadious: 10)
        transactionDetailsContainer.setRoundCorner(cornerRadious: 10)
        scToggleButtonPressed(sctoggle1Button)
        smToggleButtonPressed(smtoggle1Button)
        let btn = UIButton()
        btn.tag = 1
        dateSelectedWithSender(selectedDate: Date(), sender: btn)
        btn.tag = 2
        dateSelectedWithSender(selectedDate: Date(), sender: btn)
        createInputAccessoryView()
        getSCList()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        populateGeneralInfo()
    }
    
    // MARK: - END
    // MARK: - Private Method
    func setup_stepview(){
        let isFirstStepCompleted = defaults.bool(forKey: "return_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "return_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "return_3rdStep")
        
        step1Button.isUserInteractionEnabled = false
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        
        step1Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted {
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
        }else if isFirstStepCompleted && isSecondStepCompleted{
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted {
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step2Button.isUserInteractionEnabled = true
        }
        
    }
    
    func getSCList(){
        let appendStr = "shipping_carriers"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let response = responseData as? NSDictionary{
                        if let dataArr = response["data"] as? Array<Any>{
                            self.scList = dataArr
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
    
    func getSMList(carrierId:String){
        
        let appendStr = "shipping_carriers/\(carrierId)/shipping_methods"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let response = responseData as? NSDictionary{
                        
                        if let dataArr = response["data"] as? Array<Any>{
                            self.smList = dataArr
                        }else{
                            self.smList = nil
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
        let otherDetailsDict = NSMutableDictionary()
        
        if let txt = orderDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "reception_date")
        }
        
        if let txt = orderDateLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "reception_date_label")
        }
        
        if let txt = orderTimeLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "reception_time")
        }
        
        if let txt = orderTimeLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "reception_time_label")
        }
        
        
        
        if let txt = shipmentDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "shipment_date")
        }
        
        if let txt = shipmentDateLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "shipment_date_label")
        }
        
        if let txt = trackingNoTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "tracking_number")
        }
        
        if sctoggle1Button.isSelected{
            if let txt = shippingCarrierLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_carrier__preset_uuid")
            }
            
            if let txt = shippingCarrierLabel.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_carrier__custom")
            }
        }else{
            if let txt = customShippingCarrierTextfield.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_carrier__custom")
            }
        }
        
        if smtoggle1Button.isSelected{
            if let txt = shippingMethodLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_method__preset_uuid")
            }
            
            if let txt = shippingMethodLabel.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_method__custom")
            }
            
            
        }else{
            if let txt = customShippingMethodTextfield.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_method__custom")
            }
        }
        
        if let txt = conditionLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "shipment_general_condition")
        }
        
        if let txt = conditionLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "shipment_general_condition_label")
        }
        
        if let txt = notesTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "notes")
        }
        
        Utility.saveDictTodefaults(key: "return_general_info", dataDict: otherDetailsDict)
    }
    
    func populateGeneralInfo(){
        
        if let dataDict = Utility.getDictFromdefaults(key: "return_general_info") {
            
            if let txt =  dataDict["reception_date_label"] as? String, !txt.isEmpty {
                orderDateLabel.text = txt
            }
            
            if let txt =  dataDict["reception_date"] as? String, !txt.isEmpty {
                orderDateLabel.accessibilityHint = txt
            }
            
            
            if let txt =  dataDict["reception_time_label"] as? String, !txt.isEmpty {
                orderTimeLabel.text = txt
            }
            
            if let txt =  dataDict["reception_time"] as? String, !txt.isEmpty {
                orderTimeLabel.accessibilityHint = txt
            }
            
            
            if let txt =  dataDict["shipment_date_label"] as? String, !txt.isEmpty{
                shipmentDateLabel.text = txt
            }
            
            if let txt =  dataDict["shipment_date"] as? String, !txt.isEmpty{
                shipmentDateLabel.accessibilityHint = txt
            }
            
            if let txt =  dataDict["tracking_number"] as? String, !txt.isEmpty{
                trackingNoTextfield.text = txt
            }
            
            if let txt =  dataDict["shipping_carrier__preset_uuid"] as? String, !txt.isEmpty{
                shippingCarrierLabel.accessibilityHint = txt
                
                if let txt =  dataDict["shipping_carrier__custom"] as? String, !txt.isEmpty{
                    shippingCarrierLabel.text = txt
                }
                getSMList(carrierId: txt)
                scToggleButtonPressed(sctoggle1Button)
                
            }else if let txt =  dataDict["shipping_carrier__custom"] as? String, !txt.isEmpty{
                customShippingCarrierTextfield.text = txt
                scToggleButtonPressed(sctoggle2Button)
            }
            
            if let txt =  dataDict["shipping_method__preset_uuid"] as? String, !txt.isEmpty{
                shippingMethodLabel.accessibilityHint = txt
                
                if let txt =  dataDict["shipping_method__custom"] as? String, !txt.isEmpty{
                    shippingMethodLabel.text = txt
                }
                
                smToggleButtonPressed(smtoggle1Button)
                
            }else if let txt =  dataDict["shipping_method__custom"] as? String, !txt.isEmpty{
                customShippingMethodTextfield.text = txt
                smToggleButtonPressed(smtoggle2Button)
            }
            
            
            if let txt =  dataDict["shipment_general_condition_label"] as? String, !txt.isEmpty{
                conditionLabel.text = txt
            }
            
            if let txt =  dataDict["shipment_general_condition"] as? String, !txt.isEmpty{
                conditionLabel.accessibilityHint = txt
            }
            
            
            if let txt =  dataDict["notes"] as? String, !txt.isEmpty{
                notesTextfield.text = txt
            }
            
        }
        
        
    }
    func formValidation()->Bool{
        var isValidated = true
        if let dataDict = Utility.getDictFromdefaults(key: "return_general_info") {
            
            let receptionDate = dataDict["reception_date_label"] as? String ?? ""
            let goodsCondition = dataDict["shipment_general_condition"] as? String ?? ""
            /*let scUuid = dataDict["shipping_carrier__preset_uuid"] as? String ?? ""
             let scCustom = dataDict["shipping_carrier__custom"] as? String ?? ""
             let smUuid = dataDict["shipping_method__preset_uuid"] as? String ?? ""
             let smCustom = dataDict["shipping_method__custom"] as? String ?? ""
             let receptionTime = dataDict["reception_time_label"] as? String ?? ""
             let shipmentDate = dataDict["shipment_date_label"] as? String ?? ""*/
            
            
            if receptionDate.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select Reception Date.".localized(), InViewC: self)
                isValidated = false
            }else if goodsCondition.isEmpty{
                Utility.showPopup(Title: App_Title, Message: "Please select shipment condition.".localized(), InViewC: self)
                isValidated = false
            }/*else if receptionTime.isEmpty {
             Utility.showPopup(Title: App_Title, Message: "Please select Reception Time.", InViewC: self)
             isValidated = false
             }else if shipmentDate.isEmpty{
             Utility.showPopup(Title: App_Title, Message: "Please select shipment Date.", InViewC: self)
             isValidated = false
             }else if scUuid.isEmpty && scCustom.isEmpty {
             Utility.showPopup(Title: App_Title, Message: "Please select shipping courier.", InViewC: self)
             isValidated = false
             
             }else if smUuid.isEmpty && smCustom.isEmpty {
             Utility.showPopup(Title: App_Title, Message: "Please select shipping courier method.", InViewC: self)
             isValidated = false
             }*/
        }
        
        
        return isValidated
        
    }
    func populateMandatoryFieldsMark(){
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 12.0)!]
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 11.0)!]
        
        for label in mandatoryFieldLabels{
            
            let descText = NSMutableAttributedString(string: label.text ?? "", attributes: custAttributes)
            
            if label.tag == 101 || label.tag == 102 {
                
                let starText = NSAttributedString(string: "*", attributes: custTypeAttributes)
                descText.append(starText)
            }
            else{
                let starText = NSAttributedString(string: "", attributes: custTypeAttributes)
                descText.append(starText)
                
            }
            
            label.attributedText = descText
            
            
        }
    }
    // MARK: - END
    ///////////////////////////////////////////////////
    //MARK: - IBAction
    @IBAction func toggleVRS(_ sender: UIButton){
        if !sender.isSelected{
            self.btnVRS.isSelected = true
            sender.isSelected = true
            self.isOnVRS = true
        }else{
            self.btnVRS.isSelected = false
            sender.isSelected = false
            self.isOnVRS = false
        }
    }
    
    
    @IBAction func scToggleButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.isSelected{
            return
        }
        
        if sender == sctoggle1Button {
            sctoggle1Button.isSelected = true
            sctoggle2Button.isSelected = false
            shippingCarrierButton.isUserInteractionEnabled = true
            customShippingCarrierTextfield.isUserInteractionEnabled = false
            smtoggle1Button.isSelected = true
            smtoggle2Button.isSelected = false
            shippingMethodButton.isUserInteractionEnabled = true
            customShippingMethodTextfield.isUserInteractionEnabled = false
        }else{
            sctoggle1Button.isSelected = false
            sctoggle2Button.isSelected = true
            shippingCarrierButton.isUserInteractionEnabled = false
            customShippingCarrierTextfield.isUserInteractionEnabled = true
            smtoggle1Button.isSelected = false
            smtoggle2Button.isSelected = true
            shippingMethodButton.isUserInteractionEnabled = false
            customShippingMethodTextfield.isUserInteractionEnabled = true
            
        }
        
        
    }
    
    @IBAction func smToggleButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.isSelected {
            return
        }
        
        if sender == smtoggle1Button {
            smtoggle1Button.isSelected = true
            smtoggle2Button.isSelected = false
            shippingMethodButton.isUserInteractionEnabled = true
            customShippingMethodTextfield.isUserInteractionEnabled = false
            sctoggle1Button.isSelected = true
            sctoggle2Button.isSelected = false
            shippingCarrierButton.isUserInteractionEnabled = true
            customShippingCarrierTextfield.isUserInteractionEnabled = false
        }else{
            smtoggle1Button.isSelected = false
            smtoggle2Button.isSelected = true
            shippingMethodButton.isUserInteractionEnabled = false
            customShippingMethodTextfield.isUserInteractionEnabled = true
            sctoggle1Button.isSelected = false
            sctoggle2Button.isSelected = true
            shippingCarrierButton.isUserInteractionEnabled = false
            customShippingCarrierTextfield.isUserInteractionEnabled = true
            
        }
    }
    @IBAction func shippingPickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1 {
            if scList == nil || scList?.count == 0 {
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = scList as! Array<[String:Any]>
            controller.type = "Country".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else{
            if smList == nil || smList?.count == 0 {
                Utility.showAlertWithPopAction(Title: App_Title, Message: "No Shipping method found.".localized(), InViewC: self, isPop: false, isPopToRoot: false)
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = smList as! Array<[String:Any]>
            controller.type = "State".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
        }
    }
    @IBAction func conditionsButtonPressed(_ sender: UIButton) {
        doneTyping()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = shipment_cond_array as Array<[String:Any]>
        controller.type = "Shipment Condition".localized()
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        saveData()
        if !formValidation(){
            return
        }
        defaults.set(true, forKey: "return_1stStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnSerialVerificationView") as! ReturnSerialVerificationViewController
        controller.isOnVRS = self.isOnVRS
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 2 {
            nextButtonPressed(UIButton())
            
            
        }else if sender.tag == 3 {
            saveData()
            if !formValidation(){
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnSummaryView") as! ReturnSummaryViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }else if sender.tag == 4 {
            saveData()
            if !formValidation(){
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnConfirmationView") as! ReturnConfirmationViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }
        
        
    }
    @IBAction func datePickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller.delegate = self
        controller.sender = sender
        if sender.tag == 2 {
            controller.isTimePicker = true
        }
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnCancelView") as! ReturnCancelViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    // MARK: - END
    /////////////////////////////////////////////////
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    //MARK: - End
    //////////////////////////////////////////
    //MARK: - Single Select Dropdown Delegate
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        
        if sender != nil {
            
            var itemName = ""
            var itemid = ""
            
            if let name = data["name"] as? String{
                itemName =  name
                
                if let uuid = data["uuid"] as? String {
                    itemid = uuid
                }
            }
            
            if sender?.tag == 1 {
                shippingCarrierLabel.text = itemName
                shippingCarrierLabel.accessibilityHint = "\(itemid)"
                shippingMethodLabel.text = ""
                shippingMethodLabel.accessibilityHint = ""
                customShippingCarrierTextfield.text = ""
                customShippingMethodTextfield.text = ""
                getSMList(carrierId: "\(itemid)")
                
            }else if sender?.tag == 2{
                
                shippingMethodLabel.text = itemName
                shippingMethodLabel.accessibilityHint = "\(itemid)"
                customShippingCarrierTextfield.text = ""
                customShippingMethodTextfield.text = ""
                
            }else if sender?.tag == 3{
                
                conditionLabel.text = itemName
                if let value = data["value"] as? String {
                    conditionLabel.accessibilityHint = value
                }
                
            }
        }
    }
    //MARK: - End
    //////////////////////////////////
    //MARK: - DatePickerViewDelegate
    func dateSelectedWithSender(selectedDate: Date, sender: UIButton?) {
        if sender != nil{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            
            if sender?.tag == 1 {
                orderDate = selectedDate
                orderDateLabel.text = dateStr
                orderDateLabel.accessibilityHint = dateStrForApi
                if shipmentDate.isBeforeDate(orderDate) {
                    Utility.showPopup(Title: App_Title, Message: "Shipment date can't before Order Date".localized() , InViewC: self)
                    shipmentDate = orderDate
                    shipmentDateLabel.text = dateStr
                    shipmentDateLabel.accessibilityHint = dateStrForApi
                }
            }else if sender?.tag == 2{
                let timeformat = DateFormatter()
                timeformat.dateFormat = stdTimeFormat
                let timeStr = timeformat.string(from: selectedDate)
                timeformat.dateFormat = "HH:mm"
                let timeStrApi = timeformat.string(from: selectedDate)
                orderTimeLabel.text = timeStr
                orderTimeLabel.accessibilityHint = timeStrApi
            }else{
                
                if selectedDate.isBeforeDate(orderDate) {
                    Utility.showPopup(Title: App_Title, Message: "Shipment date can't before Order Date".localized() , InViewC: self)
                    return
                }
                
                shipmentDate = selectedDate
                shipmentDateLabel.text = dateStr
                shipmentDateLabel.accessibilityHint = dateStrForApi
            }
            
        }
    }
    //MARK: - End
}
