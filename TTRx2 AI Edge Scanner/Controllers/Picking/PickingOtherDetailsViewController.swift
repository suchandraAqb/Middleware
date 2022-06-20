//
//  PickingOtherDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 18/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PickingOtherDetailsViewController: BaseViewController,SingleSelectDropdownDelegate,DatePickerViewDelegate {
    
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
    
    var scList:Array<Any>?
    var smList:Array<Any>?
    var orderDate = Date()
    var shipmentDate = Date()
    
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        shipmentDetailsContainer.setRoundCorner(cornerRadious: 10)
        transactionDetailsContainer.setRoundCorner(cornerRadious: 10)
        scToggleButtonPressed(sctoggle1Button)
        smToggleButtonPressed(smtoggle1Button)
        createInputAccessoryView()
        
        let btn = UIButton()
        btn.tag = 1
        dateSelectedWithSender(selectedDate: orderDate, sender: btn)
        btn.tag = 2
        dateSelectedWithSender(selectedDate: shipmentDate, sender: btn)
        
        getSCList()
        populateOtherDetails()
        
        
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
    func populateOtherDetails(){
        
        if let dataDict = Utility.getDictFromdefaults(key: "picking_other_details") {
            
            if let txt =  dataDict["order_date_label"] as? String, !txt.isEmpty {
                orderDateLabel.text = txt
            }
            
            if let txt =  dataDict["order_date"] as? String, !txt.isEmpty {
                orderDateLabel.accessibilityHint = txt
            }
            
            if let txt =  dataDict["custom_order_id"] as? String, !txt.isEmpty{
                customerOrderIdTextfield.text = txt
            }
            
            if let txt =  dataDict["internal_reference_id"] as? String, !txt.isEmpty{
                interRefNbrTextfield.text = txt
            }
            
            if let txt =  dataDict["invoice_id"] as? String, !txt.isEmpty{
                invoiceTextfield.text = txt
            }
            
            if let txt =  dataDict["release_number"] as? String, !txt.isEmpty{
                releaseNoTextfield.text = txt
            }
            
            if let txt =  dataDict["po_number"] as? String, !txt.isEmpty{
                poNumberTextfield.text = txt
            }
            
            if let txt =  dataDict["order_number"] as? String, !txt.isEmpty{
                orderNoTextfield.text = txt
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
            
            if let txt =  dataDict["shipping_carrier_uuid"] as? String, !txt.isEmpty{
                shippingCarrierLabel.accessibilityHint = txt
                
                if let txt =  dataDict["custom_shipping_carrier"] as? String, !txt.isEmpty{
                    shippingCarrierLabel.text = txt
                }
                getSMList(carrierId: txt)
                scToggleButtonPressed(sctoggle1Button)
                
            }else if let txt =  dataDict["custom_shipping_carrier"] as? String, !txt.isEmpty{
                customShippingCarrierTextfield.text = txt
                scToggleButtonPressed(sctoggle2Button)
            }
            
            if let txt =  dataDict["shipping_method_uuid"] as? String, !txt.isEmpty{
                shippingMethodLabel.accessibilityHint = txt
                
                if let txt =  dataDict["custom_shipping_method"] as? String, !txt.isEmpty{
                    shippingMethodLabel.text = txt
                }
                
                smToggleButtonPressed(smtoggle1Button)
                
            }else if let txt =  dataDict["custom_shipping_method"] as? String, !txt.isEmpty{
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
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
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
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = scList as! Array<[String:Any]>
            controller.type = "Country"
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else{
            if smList == nil || smList?.count == 0 {
                Utility.showAlertWithPopAction(Title: App_Title, Message: "No Shipping method found.", InViewC: self, isPop: false, isPopToRoot: false)
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = smList as! Array<[String:Any]>
            controller.type = "State"
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
