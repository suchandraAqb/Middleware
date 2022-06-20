//
//  OutboundShipmentSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 23/07/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol  OutboundShipmentSearchViewDelegate: AnyObject {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class OutboundShipmentSearchViewController: BaseViewController,SingleSelectDropdownDelegate,DatePickerViewDelegate {
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var tradingPartnerLabel: UILabel!
    @IBOutlet weak var deliveryStatusLabel: UILabel!
    @IBOutlet weak var shipDateLabel: UILabel!
    @IBOutlet weak var poNumberTextField: UITextField!
    @IBOutlet weak var invoiceNumberTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var releaseNumberTextField: UITextField!
    @IBOutlet weak var internalRefNumberTextField: UITextField!
    @IBOutlet weak var orderNumberTextField: UITextField!
    @IBOutlet weak var customOrderIdTextField: UITextField!
    @IBOutlet weak var deliveryDateLabel: UILabel!

    
    @IBOutlet weak var releaseNumberView: UIView!
    @IBOutlet weak var internalRefNumberView: UIView!
    @IBOutlet weak var orderNumberView: UIView!
    @IBOutlet weak var customOrderIdView: UIView!
    @IBOutlet weak var deliveryDateView: UIView!
    
    @IBOutlet weak var advanceSearchButton: UIButton!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    weak var delegate: OutboundShipmentSearchViewDelegate?
    var searchDict = [String:Any]()
    var tradingPartners:Array<Any>?
    var allLocationList = [[String : Any]]()
    var allLocations:NSDictionary?
    
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        setupUI()
        //createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        advanceSearchButton.isSelected = true
        advanceSearchButtonPressed(advanceSearchButton)
        getAllLocation()
        getTradingPartnersList()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateSearchData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    
    //MARK: - Privete Method
    func setupUI(){
        uuidTextField.delegate = self
        poNumberTextField.delegate = self
        orderNumberTextField.delegate = self
        invoiceNumberTextField.delegate = self
        releaseNumberTextField.delegate = self
        internalRefNumberTextField.delegate = self
        customOrderIdTextField.delegate = self
    }
    
    func getAllLocation (){
        allLocations = UserInfosModel.getLocations()
        let globDict = ["name" : "Global".localized(), "value" : ""]
        allLocationList.append(globDict)
        for (key, val) in allLocations! {
            if let valDict = val as? [String: Any] {
                if let txt = valDict["name"] as? String,!txt.isEmpty{
                    let globDict = ["name" : txt, "value" : key as! String]
                    allLocationList.append(globDict)
                }
            }
        }
    }
    
    
    func populateSearchData(){
        if !searchDict.isEmpty {
            
            if let txt = searchDict["Uuid"] as? String,!txt.isEmpty{
                uuidTextField.text = txt
            }
            
            if let txt = searchDict["TradingPartner"] as? String,!txt.isEmpty{
                tradingPartnerLabel.text = txt
                tradingPartnerLabel.accessibilityHint = txt
                tradingPartnerLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
            if let txt = searchDict["DeliveryStatus"] as? String,!txt.isEmpty{
                deliveryStatusLabel.text = txt
                deliveryStatusLabel.accessibilityHint = searchDict["DeliveryStatusForApi"] as? String
                deliveryStatusLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
            if let txt = searchDict["ShipDate"] as? String,!txt.isEmpty{
                shipDateLabel.text = txt
                shipDateLabel.accessibilityHint = searchDict["ShipDateForApi"] as? String
                shipDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
            if let txt = searchDict["PoNumber"] as? String,!txt.isEmpty{
                poNumberTextField.text = txt
            }
            
            if let txt = searchDict["DeliveryDate"] as? String,!txt.isEmpty{
                deliveryDateLabel.text = txt
                deliveryDateLabel.accessibilityHint = searchDict["DeliveryDateForApi"] as? String
                deliveryDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["Location"] as? String,!txt.isEmpty{
                locationLabel.text = txt
                locationLabel.accessibilityHint = searchDict["LocationForApi"] as? String
                locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
                        
            if let txt = searchDict["OrderNumber"] as? String,!txt.isEmpty{
                orderNumberTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["InvoiceNumber"] as? String,!txt.isEmpty{
                invoiceNumberTextField.text = txt
//                if !advanceSearchButton.isSelected{
//                   advanceSearchButtonPressed(advanceSearchButton)
//                }
            }
            
            if let txt = searchDict["ReleaseNumber"] as? String,!txt.isEmpty{
                releaseNumberTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["InternalRefNumber"] as? String,!txt.isEmpty{
                internalRefNumberTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["CustomOrderId"] as? String,!txt.isEmpty{
                customOrderIdTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag==0 {
            if tradingPartners == nil {
                return
            }
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = tradingPartners as! Array<[String:Any]>
            controller.type = "Trading Partners"
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag==1{
            let deliveryStatusList = [["name" : "All" , "value" : "all"],["name" : "Received" , "value" : "received"]]
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = deliveryStatusList
            controller.type = "Delivery Status"
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag==2{
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag==3{
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag==4{
            doneTyping()
             if allLocationList.count == 0 {
                 return
             }
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
             let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
             controller.isDataWithDict = false
             controller.nameKeyName = "name"
             controller.listItems = allLocationList
             controller.type = "Locations".localized()
             controller.delegate = self
             controller.sender = sender
             controller.modalPresentationStyle = .custom
             self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func advanceSearchButtonPressed(_ sender: UIButton) {
        advanceSearchButton.isSelected.toggle()
        if advanceSearchButton.isSelected {
            orderNumberView.isHidden = false
            releaseNumberView.isHidden = false
            internalRefNumberView.isHidden=false
            customOrderIdView.isHidden=false
            deliveryDateView.isHidden=false
            mainScroll.scrollToBottom(animated: true)
         }else{
            orderNumberView.isHidden = true
            releaseNumberView.isHidden = true
            internalRefNumberView.isHidden=true
            customOrderIdView.isHidden=true
            deliveryDateView.isHidden=true
            UIView.animate(withDuration: 0.3) {
                self.mainScroll.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var uuidstr = ""
        if let str = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            uuidstr = str
        }
        
        var tradingPartnerStr = ""
        if let str = tradingPartnerLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            tradingPartnerStr = str
        }
        
        var deliveryStatusStr = ""
        if let str = deliveryStatusLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            deliveryStatusStr = str
        }
        
        var shipDateStr = ""
        if let str = shipDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            shipDateStr = str
        }
        
        var poNumberStr = ""
        if let str = poNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            poNumberStr = str
        }
        
        var deliveryDateStr = ""
        if let str = deliveryDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            deliveryDateStr = str
        }
        
        var locationStr = ""
        if let str = locationLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            locationStr = str
        }
        
        var orderNumberStr = ""
        if let str = orderNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            orderNumberStr = str
        }
        var invoiceNumberStr = ""
        if let str = invoiceNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            invoiceNumberStr = str
        }
        var releaseNumberStr = ""
        if let str = releaseNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            releaseNumberStr = str
        }
        
        var internalRefNumber = ""
        if let str = internalRefNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            internalRefNumber = str
        }
        var customOrderId = ""
        if let str = customOrderIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            customOrderId = str
        }
        
              
       
        
        var appendStr = ""
        
        if !uuidstr.isEmpty{
            appendStr = appendStr + "uuid=\(uuidstr)&"
            searchDict["Uuid"] = uuidstr
        }else{
            searchDict["Uuid"] = ""
        }
        
        
        if !tradingPartnerStr.isEmpty{
            appendStr = appendStr + "trading_partner_name=\(tradingPartnerStr)&"
            searchDict["TradingPartner"] = tradingPartnerStr
        }else{
            searchDict["TradingPartner"] = ""
        }
        
        if !deliveryStatusStr.isEmpty{
//            appendStr = appendStr + "delivery_status=\(deliveryStatusStr)&"
            searchDict["DeliveryStatusForApi"] = deliveryStatusStr
            searchDict["DeliveryStatus"] = deliveryStatusLabel.text
        }else{
            searchDict["DeliveryStatusForApi"] = ""
            searchDict["DeliveryStatus"] = ""
        }
        
        if !shipDateStr.isEmpty{
            appendStr = appendStr + "shipment_date=\(shipDateStr)&"
            searchDict["ShipDateForApi"] = shipDateStr
            searchDict["ShipDate"] = shipDateLabel.text
        }else{
            searchDict["ShipDateForApi"] = ""
            searchDict["ShipDate"] = ""
        }
        
        if !poNumberStr.isEmpty{
            appendStr = appendStr + "transaction_po_number=\(poNumberStr)&"
            searchDict["PoNumber"] = poNumberStr
        }else{
            searchDict["PoNumber"] = ""
        }
        
        if !deliveryDateStr.isEmpty{
            appendStr = appendStr + "delivery_date=\(deliveryDateStr)&"
            searchDict["DeliveryDateForApi"] = deliveryDateStr
            searchDict["DeliveryDate"] = deliveryDateLabel.text
        }else{
            searchDict["DeliveryDateForApi"] = ""
            searchDict["DeliveryDate"] = ""
        }
        
        if !locationStr.isEmpty{
            appendStr = appendStr + "location_uuid=\(locationStr)&"
            searchDict["LocationForApi"] = locationStr
            searchDict["Location"] = locationLabel.text
        }else{
            searchDict["LocationForApi"] = ""
            searchDict["LocationForApi"] = ""
        }
        
        if !orderNumberStr.isEmpty{
            appendStr = appendStr + "transaction_order_number=\(orderNumberStr)&"
            searchDict["OrderNumber"] = orderNumberStr
        }else{
            searchDict["OrderNumber"] = ""
        }
        
        if !invoiceNumberStr.isEmpty{
            appendStr = appendStr + "transaction_invoice_number=\(invoiceNumberStr)&"
            searchDict["InvoiceNumber"] = invoiceNumberStr
        }else{
            searchDict["InvoiceNumber"] = ""
        }
        
        if !releaseNumberStr.isEmpty{
            appendStr = appendStr + "transaction_release_number=\(releaseNumberStr)&"
            searchDict["ReleaseNumber"] = releaseNumberStr
        }else{
            searchDict["ReleaseNumber"] = ""
        }
        
        
        if !internalRefNumber.isEmpty{
            appendStr = appendStr + "transaction_internal_reference_number=\(internalRefNumber)&"
            searchDict["InternalRefNumber"] = internalRefNumber
        }else{
            searchDict["InternalRefNumber"] = ""
        }
        
        if !customOrderId.isEmpty{
            appendStr = appendStr + "transaction_custom_order_id=\(customOrderId)&"
            searchDict["CustomOrderId"] = customOrderId
        }else{
            searchDict["CustomOrderId"] = ""
        }
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        doneTyping()
        searchDict = [String:Any]()
        
        uuidTextField.text = ""
         
        tradingPartnerLabel.text = "Trading Partner"
        tradingPartnerLabel.accessibilityHint = ""
        tradingPartnerLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        
         
        deliveryStatusLabel.text = "Delivery Status"
        deliveryStatusLabel.accessibilityHint = ""
        deliveryStatusLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
         
        shipDateLabel.text = "Ship Date"
        shipDateLabel.accessibilityHint = ""
        shipDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        
        poNumberTextField.text = ""
        
         
        deliveryDateLabel.text = "Delivery Date"
        deliveryDateLabel.accessibilityHint = ""
        deliveryDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        
        locationLabel.text = "Location"
        locationLabel.accessibilityHint = ""
        locationLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        
       orderNumberTextField.text = ""
        invoiceNumberTextField.text = ""
        releaseNumberTextField.text = ""
        internalRefNumberTextField.text = ""
        customOrderIdTextField.text = ""
        
        
        self.delegate?.clearSearch()
        self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
        advanceSearchButton.isSelected = true
        advanceSearchButtonPressed(advanceSearchButton)
    }
    //MARK: - End
    
    //MARK: Api Call
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
            if sender?.tag==0 {
                if let name = data["name"] as? String{
                    tradingPartnerLabel.text = name
                    tradingPartnerLabel.accessibilityHint = name
                    tradingPartnerLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
            }
            if sender?.tag==1 {
                if let name = data["name"] as? String{
                    deliveryStatusLabel.text = name
                    deliveryStatusLabel.accessibilityHint = data["value"] as? String
                    deliveryStatusLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
            }
            if sender?.tag==4 {
                if let name = data["name"] as? String{
                    locationLabel.text = name
                    locationLabel.accessibilityHint = data["value"] as? String
                    locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
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
            if sender?.tag == 2 {
                shipDateLabel.text = dateStr
                shipDateLabel.accessibilityHint = dateStrForApi
                shipDateLabel.textColor=Utility.hexStringToUIColor(hex: "072144")
            }else if sender?.tag == 3 {
                deliveryDateLabel.text = dateStr
                deliveryDateLabel.accessibilityHint = dateStrForApi
                deliveryDateLabel.textColor=Utility.hexStringToUIColor(hex: "072144")
            }
        }
    }
    //MARK: - End
}
extension OutboundShipmentSearchViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}
