//
//  MISPurchaseOrderViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 17/12/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISPurchaseOrderViewController: BaseViewController,UITextViewDelegate,SingleSelectDropdownDelegate,DatePickerViewDelegate,MISSelectSellerViewDelegate,ConfirmationViewDelegate {
    
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
    
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var sellerView: UIView!
    @IBOutlet weak var orderDateView: UIView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var noteView: UIView!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    @IBOutlet weak var locationSelectionView: UIView!
    @IBOutlet weak var sellerSelectionView: UIView!
    
    @IBOutlet weak var locationSelectButton: UIButton!
    @IBOutlet weak var sellerSelectButton: UIButton!
    @IBOutlet weak var orderDateSelectButton: UIButton!
    
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    
    @IBOutlet weak var customerOrderIdTextField: UITextField!
    @IBOutlet weak var invoiceTextField: UITextField!
    @IBOutlet weak var poNumberTextField: UITextField!
    @IBOutlet weak var internalReferenceNbrTextField: UITextField!
    @IBOutlet weak var releaseNumberTextField: UITextField!
    @IBOutlet weak var orderNumberTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    var allLocations:NSDictionary?
    var purchaseOrderDetailsDict = [String:Any]()
    var tradingPartners:Array<Any>?
    
    var disPatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        setup_initialview()

        allLocations = UserInfosModel.getLocations()
        print(allLocations)
       // createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        notesTextView.inputAccessoryView = inputAccView

        let currentDate = Date()
        let apiformatter = DateFormatter()
        apiformatter.dateFormat = "yyyy-MM-dd"
        let uiformatter = DateFormatter()
        uiformatter.dateFormat = "MM-dd-yyyy"
        let dateStrForApi = apiformatter.string(from: currentDate)
        let dateStr = uiformatter.string(from: currentDate)
        orderDateLabel.text = dateStr
        orderDateLabel.accessibilityHint = dateStrForApi
                
        self.disPatchGroup.notify(queue: .main) {
            let createNew = defaults.bool(forKey: "MIS_create_new")
            if  createNew {
                self.getTradingPartnersDetails()
            }else{
                self.populatepurchaseOrderDetails()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
    }
    
    
    //MARK: - Private Method
    func populatepurchaseOrderDetails(){
        print(purchaseOrderDetailsDict)
        let createNew = defaults.bool(forKey: "MIS_create_new")
        
        if !createNew && purchaseOrderDetailsDict.count > 0{
            
            if let trading_partner_uuid = purchaseOrderDetailsDict["trading_partner_uuid"] as? String,!trading_partner_uuid.isEmpty, let trading_partner_name = purchaseOrderDetailsDict["trading_partner_name"] as? String,!trading_partner_name.isEmpty{
                
                var selectedCustomerDict:NSDictionary?
                
//                let createNew = defaults.bool(forKey: "MIS_create_new")
//                if  createNew {
//                    for tradingPartner in tradingPartners!{
//                        if let tradingPartnerDict = tradingPartner as? NSDictionary {
//                            if let tmptradingPartneruuid = tradingPartnerDict["uuid"] as? String,!tmptradingPartneruuid.isEmpty, tmptradingPartneruuid == trading_partner_uuid {
//                                selectedCustomerDict = tradingPartnerDict
//                                break
//                            }
//                        }
//                      }
//                }else{
                    selectedCustomerDict = purchaseOrderDetailsDict as NSDictionary
//                }
                if selectedCustomerDict != nil{

                    Utility.saveDictTodefaults(key: "MIS_selectedSeller", dataDict: selectedCustomerDict ?? NSDictionary())

//                    let createNew = defaults.bool(forKey: "MIS_create_new")
//                        if  createNew {
//                            let _ = CustomerAddressesModel.CustomerAddShared
//
//                            self.showSpinner(onView: self.view)
//                            defaults.removeObject(forKey: "MIS_soldBy")
//                            defaults.removeObject(forKey: "MIS_shipFrom")
//                            CustomerAddressesModel.updateCustomerId(customerId: trading_partner_uuid) { (isDone:Bool?) in
//                               self.removeSpinner()
//                        }
//                    }
                    self.sellerNameLabel.text = trading_partner_name
                    self.sellerNameLabel.accessibilityHint = trading_partner_uuid
                    self.sellerNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                
                }
            }
            
            if let location_uuid = purchaseOrderDetailsDict["location_uuid"] as? String,!location_uuid.isEmpty{
                let btn = UIButton()
                btn.tag = 1
                if let txt = allLocations?[location_uuid] as? Dictionary<String,Any>,!txt.isEmpty{
                let dict = self.allLocations?[location_uuid] as! Dictionary<String,Any>
                selectedItem(itemStr: location_uuid, data: dict as NSDictionary,sender: btn)
              }
            }
            if let txt = purchaseOrderDetailsDict["transaction_date"] as? String,!txt.isEmpty{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: "MM-dd-yyyy", dateStr: txt){
                    orderDateLabel.text = formattedDate
                    orderDateLabel.accessibilityHint = txt
                }
            }else{
                orderDateLabel.text = "---"
                orderDateLabel.accessibilityHint = ""
            }
            
            var dataStr = ""
            if let txt = purchaseOrderDetailsDict["custom_id"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            customerOrderIdTextField.text = dataStr
            
            dataStr = ""
            if let txt = purchaseOrderDetailsDict["invoice_nbr"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            invoiceTextField.text = dataStr
            
            dataStr = ""
            if let txt = purchaseOrderDetailsDict["po_nbr"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            poNumberTextField.text = dataStr
            
            dataStr = ""
            if let txt = purchaseOrderDetailsDict["internal_reference_number"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            internalReferenceNbrTextField.text = dataStr
            
            dataStr = ""
            if let txt = purchaseOrderDetailsDict["release_nbr"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            releaseNumberTextField.text = dataStr
            
            dataStr = ""
            if let txt = purchaseOrderDetailsDict["order_nbr"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            orderNumberTextField.text = dataStr
            
            dataStr = ""
            if let txt = purchaseOrderDetailsDict["notes"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            notesTextView.text = dataStr
            
            locationSelectButton.isUserInteractionEnabled = false
            sellerSelectButton.isUserInteractionEnabled = false
            orderDateSelectButton.isUserInteractionEnabled = false
            customerOrderIdTextField.isUserInteractionEnabled = false
            invoiceTextField.isUserInteractionEnabled = false
            poNumberTextField.isUserInteractionEnabled = false
            internalReferenceNbrTextField.isUserInteractionEnabled = false
            releaseNumberTextField.isUserInteractionEnabled = false
            orderNumberTextField.isUserInteractionEnabled = false
            notesTextView.isUserInteractionEnabled = false
            
            
         
        }
    }
    
    
    
    func setup_initialview(){
        sectionView.roundTopCorners(cornerRadious: 40)
        locationView.setRoundCorner(cornerRadious: 10)
        sellerView.setRoundCorner(cornerRadious: 10)
        orderDateView.setRoundCorner(cornerRadious: 10)
        productView.setRoundCorner(cornerRadious: 10)
        noteView.setRoundCorner(cornerRadious: 10)
        
        customerOrderIdTextField.keyboardType = .numbersAndPunctuation
        invoiceTextField.keyboardType = .numbersAndPunctuation
        poNumberTextField.keyboardType = .numbersAndPunctuation
        internalReferenceNbrTextField.keyboardType = .numbersAndPunctuation
        releaseNumberTextField.keyboardType = .numbersAndPunctuation
        orderNumberTextField.keyboardType = .numbersAndPunctuation
        
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 17.0,color:Utility.hexStringToUIColor(hex: "719898"))
        locationSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        sellerSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
    }
    
    
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "MIS_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "MIS_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "MIS_3rdStep")
        let isFourthStepCompleted = defaults.bool(forKey: "MIS_4thStep")
        
        step1Button.isUserInteractionEnabled = false
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        step5Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
               
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted && isFourthStepCompleted {
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            step5Button.isUserInteractionEnabled = true
            
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
        }else if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted {
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
        }else if isFirstStepCompleted && isSecondStepCompleted {
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
        }else if isFirstStepCompleted {
            step2Button.isUserInteractionEnabled = true
        }
        
    }
    
    func saveData()->NSMutableDictionary{
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
              
        if let txt = orderDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "transaction_date")
        }
        
        if let txt = customerOrderIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "trx_customer_order_id")
        }
        
        if let txt = invoiceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "trx_invoice_nbr")
        }
        
        if let txt = poNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "trx_po_nbr")
        }
        
        if let txt = internalReferenceNbrTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "trx_internal_ref_nbr")
        }
        
        if let txt = releaseNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "trx_release_nbr")
        }
        
        if let txt = orderNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "trx_order_nbr")
        }
        
        if let txt = notesTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "trx_notes")
        }
        
        return otherDetailsDict
        
        
    }
    
    func formValidation()->Bool{
        var isValidated = true
        
        var location_uuid = ""
        if let txt = locationNameLabel.accessibilityHint , !txt.isEmpty {
            location_uuid = txt
        }
        
        var trading_partner_uuid = ""
        if let txt = sellerNameLabel.accessibilityHint , !txt.isEmpty {
            trading_partner_uuid = txt
        }
        
        var transaction_date = ""
        if let txt = orderDateLabel.accessibilityHint , !txt.isEmpty {
            transaction_date = txt
        }
               
              
    
        if location_uuid.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please select Location.".localized(), InViewC: self)
           isValidated = false
        }else if trading_partner_uuid.isEmpty {
           Utility.showPopup(Title: App_Title, Message: "Please select Seller.".localized(), InViewC: self)
            isValidated = false
               
        }else if transaction_date.isEmpty {
           Utility.showPopup(Title: App_Title, Message: "Please select order date.".localized(), InViewC: self)
            isValidated = false
        }
        
        
        return isValidated
        
    }
    
    
    //MARK: - Call Api
    func getTradingPartnersDetails(){
        self.disPatchGroup.enter()
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetTradingPartners", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  self.disPatchGroup.leave()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        
                        if let dataArray = responseDict["data"] as? Array<Any> {
                            self.tradingPartners = dataArray
                            self.populatepurchaseOrderDetails()
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
    @IBAction func manualInboundShipmentBackButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to cancel".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func locationSelectionButtonPressed(_ sender: UIButton) {
        doneTyping()
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
    }
    @IBAction func locationScanButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller.delegate = self
        controller.isForLocationSelection=true
        self.navigationController?.pushViewController(controller, animated: true)
//
//             "b592af47-4319-4739-824b-9ca8d93d34cc"
//             "6d72602d-6843-4adc-aedb-5d147d84ffa5"
//             "c02d4563-1a29-4df9-b7f9-311eca2a9868"
//             "166411fc-9cc4-42e3-836e-56a11c87a5f7"
//             "823d8e69-5842-4ec8-b281-a6ab4838a298"
//        self.didReceiveBarcodeLocationScan(codeDetails: ["scannedCodes":"b592af47-4319-4739-824b-9ca8d93d34cc"])
    }
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func sellerButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISSelectSellerView") as! MISSelectSellerViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        if !formValidation(){
            return
        }
        
        let dict = saveData()
        
        Utility.saveDictTodefaults(key: "MIS_PurchaseOrderDetails", dataDict: dict)
        
          

        defaults.set(true, forKey: "MIS_1stStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISShipmentDetailsView") as! MISShipmentDetailsViewController
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 2 {
            nextButtonPressed(UIButton())
        }else if sender.tag == 3 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISLineItemView") as! MISLineItemViewController
            self.navigationController?.pushViewController(controller, animated: false)
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
    //MARK: - SingleSelectDropdownDelegate
    
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 1 {
            if let name = data["name"] as? String{
                locationNameLabel.text = name
                locationNameLabel.accessibilityHint = itemStr
                locationNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                defaults.removeObject(forKey: "MIS_shipTo")
                defaults.removeObject(forKey: "MIS_broughtBy")
                if UserInfosModel.UserInfoShared.default_location_uuid != itemStr{
//                    self.showSpinner(onView: self.view)
                    UserInfosModel.UserInfoShared.getLocationAddress(isDefault: false, location_uuid: itemStr) { (isDone:Bool?) in
                        defaults.set(itemStr, forKey: "MIS_selectedLocation")
//                        self.removeSpinner()
                        self.setup_stepview()
                    }
                }else{
                    defaults.set(itemStr, forKey: "MIS_selectedLocation")
                    if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: true){
                        Utility.saveDictTodefaults(key: "MIS_shipTo", dataDict: addData)
                        
                    }
                    
                    if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: true){                        Utility.saveDictTodefaults(key: "MIS_broughtBy", dataDict: addData)
                    }
                }
                 if (purchaseOrderDetailsDict["ship_from_address_custom"] != nil) {
                     Utility.saveDictTodefaults(key: "MIS_shipFrom", dataDict: purchaseOrderDetailsDict["ship_from_address_custom"] as! NSDictionary)
                   
                }
                if (purchaseOrderDetailsDict["sold_by_address_custom"] != nil) {
                    Utility.saveDictTodefaults(key: "MIS_soldBy", dataDict: purchaseOrderDetailsDict["sold_by_address_custom"] as! NSDictionary)
                  
               }
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
            
            orderDateLabel.text = dateStr
            orderDateLabel.accessibilityHint = dateStrForApi
            
        }
    }
    //MARK: - End
    
    
    //MARK: - Search View Delegate
    func doneButtonPressed(tradingPartnerName: String,tradingPartnerUuid: String) {
        self.sellerNameLabel.text = tradingPartnerName
        self.sellerNameLabel.accessibilityHint = tradingPartnerUuid
        self.sellerNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
    }
    //MARK: End
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
        
    }
    func cancelConfirmation() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
        

}
extension MISPurchaseOrderViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        if (textFieldTobeField != nil) {
            textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
            textFieldTobeField = nil

        }else{
            textViewTobeField?.text = (codeDetails["scannedCodes"] as! String)
            textViewTobeField = nil

        }
        
    }
    func didReceiveBarcodeLocationScan(codeDetails:[String:Any]){
        let locationCode = codeDetails["scannedCodes"] as! String
        print(locationCode)
        if let dict = allLocations![locationCode] as? Dictionary<String,Any> {
            self.selectedItem(itemStr: locationCode, data: dict as NSDictionary,sender: locationSelectButton)
        }else{
            Utility.showPopup(Title: "Error!", Message: "Selected location is not available.".localized() , InViewC: self)
        }
    }
}
