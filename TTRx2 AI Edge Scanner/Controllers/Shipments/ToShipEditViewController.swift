//
//  ToShipEditViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 24/07/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  ToShipEditDelegate: AnyObject {
    @objc optional func shipmentUpdated()
}


class ToShipEditViewController: BaseViewController,SingleSelectDropdownDelegate,DatePickerViewDelegate {

    weak var delegate: ToShipEditDelegate?
    @IBOutlet weak var shipmentDetailsContainer: UIView!
    @IBOutlet weak var transactionDetailsContainer: UIView!
    
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var shipmentDateLabel: UILabel!
    @IBOutlet weak var shippingCarrierLabel: UILabel!
    @IBOutlet weak var shippingMethodLabel: UILabel!
    
    @IBOutlet weak var customerOrderIdTextfield: UITextField!
    @IBOutlet weak var interRefNbrTextfield: UITextField!
    @IBOutlet weak var invoiceTextfield: UITextField!
    @IBOutlet weak var releaseNoTextfield: UITextField!
    @IBOutlet weak var poNumberTextfield: UITextField!
    @IBOutlet weak var orderNoTextfield: UITextField!
    @IBOutlet weak var trackingNoTextfield: UITextField!
    
    @IBOutlet weak var customShippingCarrierTextfield: UITextField!
    @IBOutlet weak var customShippingMethodTextfield: UITextField!
    
    @IBOutlet weak var shippingCarrierButton: UIButton!
    @IBOutlet weak var shippingMethodButton: UIButton!
    
    @IBOutlet weak var sctoggle1Button: UIButton!
    @IBOutlet weak var sctoggle2Button: UIButton!
    
    @IBOutlet weak var smtoggle1Button: UIButton!
    @IBOutlet weak var smtoggle2Button: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveAndShipButton: UIButton!
    
    
    var scList:Array<Any>?
    var smList:Array<Any>?
    var orderDate = Date()
    var shipmentDate = Date()
    var type = ""
    var shipmentId = ""

    
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        saveButton.setRoundCorner(cornerRadious: saveButton.frame.size.height / 2.0)
        saveAndShipButton.setRoundCorner(cornerRadious: saveAndShipButton.frame.size.height / 2.0)
        sectionView.roundTopCorners(cornerRadious: 40)
        shipmentDetailsContainer.setRoundCorner(cornerRadious: 10)
        transactionDetailsContainer.setRoundCorner(cornerRadious: 10)
        scToggleButtonPressed(sctoggle1Button)
        smToggleButtonPressed(smtoggle1Button)
        createInputAccessoryView()
        
//        let btn = UIButton()
//        btn.tag = 1
//        dateSelectedWithSender(selectedDate: orderDate, sender: btn)
//        btn.tag = 2
//        dateSelectedWithSender(selectedDate: shipmentDate, sender: btn)
        
        getShipmentDetails()
        getSCList()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    //MARK: - Private Method
    
    func populateRequestDataForSave(isSetAsShipped:Bool){
        let otherDetailsDict = NSMutableDictionary()
        if let txt = customerOrderIdTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "custom_id")
        }
        if let txt = interRefNbrTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "internal_reference_number")
        }
        if let txt = invoiceTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "invoice_nbr")
        }
        if let txt = releaseNoTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "release_nbr")
        }
        if let txt = poNumberTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "po_nbr")
        }
        if let txt = orderNoTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "order_nbr")
        }
        if let txt = shipmentDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "shipment_date")
        }
        
        if sctoggle1Button.isSelected{
            if let txt = shippingCarrierLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_carrier_uuid")
            }else{
                Utility.showPopup(Title: Warning, Message: "Choose the shipping carrier.".localized(), InViewC: self)
                return
            }
        }else{
            if let txt = customShippingCarrierTextfield.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "custom_shipping_carrier")
            }else{
                Utility.showPopup(Title: Warning, Message: "Please add the custom shipping carrier.".localized(), InViewC: self)
                return
            }
        }
        
        if smtoggle1Button.isSelected{
            if let txt = shippingMethodLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_method_uuid")
            }else{
                Utility.showPopup(Title: Warning, Message: "Choose the shipping method.".localized(), InViewC: self)
                return

            }
        }else{
            if let txt = customShippingMethodTextfield.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "custom_shipping_method")
            }else{
                Utility.showPopup(Title: Warning, Message: "Please add the custom shipping method.".localized(), InViewC: self)
                return
            }
        }
        
        if isSetAsShipped {
            otherDetailsDict.setValue(true, forKey: "is_update_shipment_metadata_only")
            otherDetailsDict.setValue(true, forKey: "is_set_as_shipped")
        }else{
            otherDetailsDict.setValue(true, forKey: "is_update_shipment_metadata_only")
        }
        updateShipmentApiCall(requestData: otherDetailsDict)

    }
    
    func updateShipmentApiCall(requestData:NSMutableDictionary){
        let appendStr = "\(type.capitalized)/\(shipmentId)"
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "UpdateShipment", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["uuid"] as? String {
                        self.delegate?.shipmentUpdated?()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Shipment Updated Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
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
    
    func getShipmentDetails(){
        self.showSpinner(onView: self.view)
        let appendStr = "\(type.capitalized)/\(shipmentId)"
          Utility.GETServiceCall(type: "ConfirmShipment", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    if let responseDict = responseData as? NSDictionary {
                       self.populateDetails(dataDict: responseDict)
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
    func populateDetails(dataDict:NSDictionary?){
        if dataDict != nil{
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let transactions:Array<Any> = dataDict!["transactions"] as? Array<Any>{
                if transactions.count>0{
                    let firstTransaction:NSDictionary = transactions.first as? NSDictionary ?? NSDictionary()
                    if let orderDate:String = firstTransaction["date"] as? String{
                        if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: orderDate){
                            orderDateLabel.text = formattedDate
                            orderDateLabel.accessibilityHint=orderDate
                        }
                    }
                    
                    if let po:String = firstTransaction["po_number"] as? String{
                        poNumberTextfield.text = po
                    }
                    
                    if let custom_order_id:String = firstTransaction["custom_order_id"] as? String{
                        customerOrderIdTextfield.text = custom_order_id
                    }
                    if let custom_order_id:String = firstTransaction["internal_reference_number"] as? String{
                        interRefNbrTextfield.text = custom_order_id
                    }
                    
                    if let invoice_number:String = firstTransaction["invoice_number"] as? String{
                        invoiceTextfield.text = invoice_number
                    }
                    
                    if let order_number:String = firstTransaction["order_number"] as? String{
                        orderNoTextfield.text = order_number
                    }
                    
                    if let release_number:String = firstTransaction["release_number"] as? String{
                        releaseNoTextfield.text = release_number
                    }
               }
                
            }
            
            if let shipDate:String = dataDict!["shipment_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                    shipmentDateLabel.text = formattedDate
                    shipmentDateLabel.accessibilityHint=shipDate
                }
            }
            if let trackingNumber:String = dataDict!["tracking_number"] as? String{
                trackingNoTextfield.text=trackingNumber
            }
            
            if let shippingCarrierDict:NSDictionary = dataDict!["shipping_carrier"] as? NSDictionary {
                if let txt =  shippingCarrierDict["uuid"] as? String, !txt.isEmpty{
                    shippingCarrierLabel.accessibilityHint = txt
                    if let txt =  shippingCarrierDict["name"] as? String, !txt.isEmpty{
                        shippingCarrierLabel.text = txt
                    }
                    getSMList(carrierId: txt)
                    scToggleButtonPressed(sctoggle1Button)
                }else if let txt =  dataDict!["custom_shipping_carrier"] as? String, !txt.isEmpty{
                    customShippingCarrierTextfield.text = txt
                    scToggleButtonPressed(sctoggle2Button)
                }
            }else if let txt =  dataDict!["custom_shipping_carrier"] as? String, !txt.isEmpty{
                customShippingCarrierTextfield.text = txt
                scToggleButtonPressed(sctoggle2Button)
            }
            
            if let shippingMethodDict:NSDictionary = dataDict!["shipping_method"] as? NSDictionary {
                if let txt =  shippingMethodDict["uuid"] as? String, !txt.isEmpty{
                    shippingMethodLabel.accessibilityHint = txt
                    if let txt =  shippingMethodDict["name"] as? String, !txt.isEmpty{
                        shippingMethodLabel.text = txt
                    }
                    smToggleButtonPressed(smtoggle1Button)
                }else if let txt =  dataDict!["custom_shipping_method"] as? String, !txt.isEmpty{
                    customShippingMethodTextfield.text = txt
                    smToggleButtonPressed(smtoggle2Button)
                }
            }else if let txt =  dataDict!["custom_shipping_method"] as? String, !txt.isEmpty{
                customShippingMethodTextfield.text = txt
                smToggleButtonPressed(smtoggle2Button)
            }
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
    //MARK: - End
    //MARK: - IBAction
    
    @IBAction func datePickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func shippingPickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1 {
            if scList == nil || scList?.count == 0 {
                return
            }
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = scList as! Array<[String:Any]>
            controller.type = "Shipment Carrier".localized()//Country
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else{
            if smList == nil || smList?.count == 0 {
                Utility.showAlertWithPopAction(Title: App_Title, Message: "No Shipping method found.", InViewC: self, isPop: false, isPopToRoot: false)
                return
            }
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = smList as! Array<[String:Any]>
            controller.type = "Shipment Method".localized()//State
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
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
            customShippingCarrierTextfield.text = ""
            customShippingMethodTextfield.text = ""
            
        }else{
            sctoggle1Button.isSelected = false
            sctoggle2Button.isSelected = true
            shippingCarrierButton.isUserInteractionEnabled = false
            customShippingCarrierTextfield.isUserInteractionEnabled = true
            smtoggle1Button.isSelected = false
            smtoggle2Button.isSelected = true
            shippingMethodButton.isUserInteractionEnabled = false
            customShippingMethodTextfield.isUserInteractionEnabled = true
            shippingCarrierLabel.text = ""
            shippingMethodLabel.text = ""
            
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
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        doneTyping()
        populateRequestDataForSave(isSetAsShipped: false)
    }
    
    @IBAction func saveAndShipButtonPressed(_ sender: UIButton) {
        doneTyping()
        populateRequestDataForSave(isSetAsShipped: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
        if let txt = orderDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "order_date")
        }
        
        if let txt = orderDateLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "order_date_label")
        }
        
        if let txt = customerOrderIdTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "custom_order_id")
        }
        
        if let txt = interRefNbrTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "internal_reference_id")
        }
        
        if let txt = invoiceTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "invoice_id")
        }
        
        if let txt = releaseNoTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "release_number")
        }
        
        if let txt = poNumberTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "po_number")
        }
        
        if let txt = orderNoTextfield.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "order_number")
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
                otherDetailsDict.setValue(txt, forKey: "shipping_carrier_uuid")
            }
            
            if let txt = shippingCarrierLabel.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "custom_shipping_carrier")
            }
        }else{
            if let txt = customShippingCarrierTextfield.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "custom_shipping_carrier")
            }
        }
        
        if smtoggle1Button.isSelected{
            if let txt = shippingMethodLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "shipping_method_uuid")
            }
            
            if let txt = shippingMethodLabel.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "custom_shipping_method")
            }
            
            
        }else{
            if let txt = customShippingMethodTextfield.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "custom_shipping_method")
            }
        }
        
        Utility.saveDictTodefaults(key: "picking_other_details", dataDict: otherDetailsDict)
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    //MARK: - End
    
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
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        
        var itemName = ""
        var itemid = ""
        
        if let name = data["name"] as? String{
            itemName =  name
            
            if let uuid = data["uuid"] as? String {
                itemid = uuid
            }
        }
        
        if sender != nil {
            if sender?.tag == 1 {
                shippingCarrierLabel.text = itemName
                shippingCarrierLabel.accessibilityHint = "\(itemid)"
                shippingMethodLabel.text = ""
                shippingMethodLabel.accessibilityHint = ""
                customShippingCarrierTextfield.text = ""
                customShippingMethodTextfield.text = ""
                getSMList(carrierId: "\(itemid)")
            }else{
                shippingMethodLabel.text = itemName
                shippingMethodLabel.accessibilityHint = "\(itemid)"
                customShippingCarrierTextfield.text = ""
                customShippingMethodTextfield.text = ""
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
            
            if sender?.tag == 1 {
                orderDate = selectedDate
                orderDateLabel.text = dateStr
                orderDateLabel.accessibilityHint = dateStrForApi
                if shipmentDate.isBeforeDate(orderDate) {
                    Utility.showPopup(Title: App_Title, Message: "Shipment date can't before Order Date " , InViewC: self)
                    shipmentDate = orderDate
                    shipmentDateLabel.text = dateStr
                    shipmentDateLabel.accessibilityHint = dateStrForApi
                }
            }else{
                
                if selectedDate.isBeforeDate(orderDate) {
                    Utility.showPopup(Title: App_Title, Message: "Shipment date can't before Order Date " , InViewC: self)
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
