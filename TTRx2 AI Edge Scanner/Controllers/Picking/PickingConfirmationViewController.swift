//
//  PickingConfirmationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 12/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PickingConfirmationViewController: BaseViewController,ConfirmationViewDelegate,SingleSelectDropdownDelegate {
    var verifiedSerials = Array<Dictionary<String,Any>>()
    var failedSerials = Array<Dictionary<String,Any>>()
    
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var broughtByLabel: UILabel!
    @IBOutlet weak var shipToLabel: UILabel!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var soldByLabel: UILabel!
    @IBOutlet weak var shipFromLabel: UILabel!
    
    
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var serialCountLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var customerView: UIView!
    @IBOutlet weak var sellerView: UIView!
    @IBOutlet weak var itemsVerificationView: UIView!
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var shipmentStatusview:UIView!
    @IBOutlet weak var notShipButton:UIButton!
    @IBOutlet weak var shipButton : UIButton!
    @IBOutlet weak var storageStack:UIStackView!
    @IBOutlet weak var storageNameLabel:UILabel!
    @IBOutlet weak var shelfLabel:UILabel!
    @IBOutlet weak var storageAreaButton:UIButton!
    @IBOutlet weak var storageShelfButton:UIButton!
    @IBOutlet weak var shelfView:UIView!
    //MARK: - End
    
    var selectedLocationUuid:String?
    var selectedCustomer:NSDictionary?
    var broughtByData:NSDictionary?
    var shipToData:NSDictionary?
    var soldByData:NSDictionary?
    var shipFromData:NSDictionary?
    
    var allLocations:NSDictionary?
    var storageAreas:Array<Any>?
    var shelfs:Array<Any>?
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        storageStack.isHidden = true

        customerView.setRoundCorner(cornerRadious: 10.0)
        sellerView.setRoundCorner(cornerRadious: 10.0)
        itemsVerificationView.setRoundCorner(cornerRadious: 10.0)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
        shipmentStatusview.setRoundCorner(cornerRadious: 10.0)
        storageAreaButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        storageShelfButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tempVerifiedSerials = Utility.getObjectFromDefauls(key: "VerifiedSalesOrderByPickingArray") as? [[String : Any]]{
            self.verifiedSerials = tempVerifiedSerials
            print(self.verifiedSerials as NSArray)
        }else{
            self.verifiedSerials = Array<Dictionary<String,Any>>()
        }
        if let tempFailedSerials = Utility.getObjectFromDefauls(key: "FailedSalesOrderByPickingArray") as? [[String : Any]]{
            self.failedSerials = tempFailedSerials
            print(self.failedSerials as NSArray)
        }else{
            self.failedSerials = Array<Dictionary<String,Any>>()
        }
        
        if let selected_location_uuid = defaults.object(forKey: "selectedLocation") as? String{
            selectedLocationUuid = selected_location_uuid
        }else{
            selectedLocationUuid = UserInfosModel.UserInfoShared.default_location_uuid
            defaults.set(selectedLocationUuid, forKey: "selectedLocation")
        }

        self.showSpinner(onView: self.view)
        UserInfosModel.UserInfoShared.getLocationAddress(isDefault: false, location_uuid: selectedLocationUuid ?? "") { (isDone:Bool?) in
            if isDone ?? false{
                self.removeSpinner()
                self.setup_stepview()
            }
        }
        self.locationdetailsFetch(locationUdid: selectedLocationUuid! as NSString)
        setShipmentStatus()
    }
    //MARK: - End
    //MARK: - Private Method
    func setShipmentStatus(){
        // Auto populated pre selected storage and shipment status
        if let selectedShipmentStatus = defaults.value(forKey: "SelectedShipmentStatus") as? Bool {
            if selectedShipmentStatus {
                checkUncheckPressed(shipButton)
            }else{
                checkUncheckPressed(notShipButton)
                if let data = defaults.object(forKey:"SelectedStorageArea") as? NSDictionary{
                    let btn = UIButton()
                    btn.tag=1;
                    selecteditem(data: data, sender: btn)
                }
                if let data = defaults.object(forKey: "SelectedStorageShelf") as? NSDictionary{
                    let btn = UIButton()
                    btn.tag=2;
                    selecteditem(data: data, sender: btn)
                }
            }
        }
        //---------
    }
    
    func refreshProductView(){
        if let distinctArray =  (self.verifiedSerials as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
            productCountLabel.text = "\(String(describing: distinctArray.count)) Products"
        }else{
            productCountLabel.text = "0"
        }
        serialCountLabel.text = "\(String(describing: self.verifiedSerials.count)) Serials"
    }
    func locationdetailsFetch(locationUdid:NSString){
        storageNameLabel.text = "Select Storage"
        storageNameLabel.accessibilityHint = ""
        shelfLabel.text = "Select Shelf"
        shelfLabel.accessibilityHint = ""
        storageAreas=[]
        if locationUdid != "" {
            allLocations = UserInfosModel.getLocations()
            let selctedStorage = allLocations![locationUdid as String ] as! NSDictionary?
            if selctedStorage != nil {
                if let s_arr =  selctedStorage?["sa"] as? NSArray {
                    storageAreas = s_arr as? Array<Any>
                    
                }
            }
        }
        
    }
    func populateSelectedCustomerView(){
        
        if selectedCustomer != nil{
            
            var custName = ""
            if let name = selectedCustomer!["name"]{
                custName = name as! String
            }
            
            var custType = ""
            if let type = selectedCustomer!["type"]{
                custType = "\n(\(type as! String))"
            }
            
            
            let custAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "00AFEF"),
                NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!]
            let attString = NSMutableAttributedString(string: custName, attributes: custAttributes)
            
            let custTypeAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
                NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
            
            let typeStr = NSAttributedString(string: custType.capitalized, attributes: custTypeAttributes)
            attString.append(typeStr)
            
            customerNameLabel.attributedText = attString
            
        }
        
    }
    func populateProductandItemsCount(product:String?,items:String?){
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "00AFEF"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 17.0)!]
        let productString = NSMutableAttributedString(string: product ?? "0", attributes: custAttributes)
        let itemsString = NSMutableAttributedString(string: items ?? "0", attributes: custAttributes)
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 12.0)!]
        
        //let productStr = NSAttributedString(string: " Lot Product(s)", attributes: custTypeAttributes)
        let productStr = NSAttributedString(string: "\(Int(product!)!>1 ?" Lot Products".localized() : " Lot Product".localized())", attributes: custTypeAttributes)
        let itemStr = NSAttributedString(string: "\(Int(items!)!>1 ?" Serials".localized() : " Serial".localized())", attributes: custTypeAttributes)
        productString.append(productStr)
        itemsString.append(itemStr)
        
        productCountLabel.attributedText = productString
        serialCountLabel.attributedText = itemsString
        //serialCountLabel.textAlignment = .right
        //        productCountLabel.attributedText = itemsString
        //        serialCountLabel.attributedText = NSAttributedString(string: "", attributes: custTypeAttributes)
        
        
    }
    
    func populateAddressView(type:String,data:NSDictionary?,label:UILabel){
        
        let firstAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let typeStr = NSMutableAttributedString(string: type, attributes: firstAttributes)
        
        let secondAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "00AFEF"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let thirdAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        if data != nil {
            var nick_name = ""
            if let recipient_name:String = data!["recipient_name"] as? String{
                nick_name = "\n\(recipient_name)"
            }
            
            //            if let address_nickname:String = data!["address_nickname"] as? String{
            //                nick_name = "\(nick_name)\n\(address_nickname)"
            //            }
            
            let nameStr = NSAttributedString(string: nick_name, attributes: secondAttributes)
            
            var addressStr:String = "\n"
            
            if let line1:String = data!["line1"] as? String{
                if line1.count > 0 {
                    addressStr = addressStr + line1 + ", "
                }
                
            }
            
            if let line2:String = data!["line2"] as? String{
                if line2.count > 0 {
                    addressStr = addressStr + line2 + ", "
                }
            }
            
            if let line3:String = data!["line3"] as? String{
                if line3.count > 0 {
                    addressStr = addressStr + line3 + ", "
                }
            }
            
            if let city:String = data!["city"] as? String{
                
                if city.count > 0 {
                    addressStr = addressStr + city + ", "
                }
            }
            
            if let state_name:String = data!["state_name"] as? String{
                
                if state_name.count > 0 {
                    addressStr = addressStr + state_name + ", "
                }
            }
            
            if let country_name:String = data!["country_name"] as? String{
                if country_name.count > 0 {
                    addressStr = addressStr + country_name
                }
            }
            
            
            let addStr = NSAttributedString(string: addressStr, attributes: thirdAttributes)
            
            typeStr.append(nameStr)
            typeStr.append(addStr)
            label.attributedText = typeStr
            
        }
        
    }
    
    
    
    func setup_stepview(){
        
        allLocations = UserInfosModel.getLocations()
        
        if let selected_location_uuid = defaults.object(forKey: "selectedLocation") as? String{
            selectedLocationUuid = selected_location_uuid
        }else{
            selectedLocationUuid = UserInfosModel.UserInfoShared.default_location_uuid
            defaults.set(selectedLocationUuid, forKey: "selectedLocation")
        }
        
        
        if let allLocations = UserInfosModel.getLocations(){
            
            if let location = allLocations[selectedLocationUuid ?? ""] as? NSDictionary{
                if let name = location["name"] as? String {
                    locationNameLabel.text = name
                }
            }
        }
        
        if let dataDict = Utility.getDictFromdefaults(key: "selectedCustomer"){
            selectedCustomer = dataDict
            populateSelectedCustomerView()
        }
        
        
        if let dataDict = Utility.getDictFromdefaults(key: "broughtBy"){
            broughtByData = dataDict
        }else{
            if let addData = CustomerAddressesModel.getDefaultAddress(){
                broughtByData = addData
                Utility.saveDictTodefaults(key: "broughtBy", dataDict: addData)
                
            }
        }
        
        populateAddressView(type: "Sold To".localized(), data: broughtByData, label: broughtByLabel)
        
        if let dataDict = Utility.getDictFromdefaults(key: "shipTo"){
            shipToData = dataDict
        }else{
            if let addData = CustomerAddressesModel.getDefaultAddress(){
                shipToData = addData
                Utility.saveDictTodefaults(key: "shipTo", dataDict: addData)
                
            }
        }
        
        populateAddressView(type: "Ship To".localized(), data: shipToData, label: shipToLabel)
        
        
        if let dataDict = Utility.getDictFromdefaults(key: "soldBy"){
            soldByData = dataDict
            self.populateAddressView(type: "Sold By".localized(), data: self.soldByData, label: self.soldByLabel)
        }else{
            if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: false){
                self.soldByData = addData
                Utility.saveDictTodefaults(key: "soldBy", dataDict: addData)
                self.populateAddressView(type: "Sold By".localized(), data: self.soldByData, label: self.soldByLabel)
            }
        }
        
        
        if let dataDict = Utility.getDictFromdefaults(key: "shipFrom"){
            shipFromData = dataDict
            self.populateAddressView(type: "Ship From".localized(), data: self.shipFromData, label: self.shipFromLabel)
        }else{
            if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: false){
                self.shipFromData = addData
                Utility.saveDictTodefaults(key: "shipFrom", dataDict: addData)
                self.populateAddressView(type: "Ship From".localized(), data: self.shipFromData, label: self.shipFromLabel)
            }
        }
        
        
        
        var product = "0"
        var serial = "0"
        if let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any> {
            let arr = exProducts as NSArray?
            if let uniqueArr = arr?.value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                product = "\(uniqueArr.count)"
            }
            
        }
        serial = "\(String(describing: self.verifiedSerials.count))"
        
        populateProductandItemsCount(product: product, items: serial)
        
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        
        step3Button.isUserInteractionEnabled = false
        step3Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        
        
        
    }
    
    func delete_picking_session(){
        
        guard let session_id = defaults.object(forKey: "picking_session_id") as? String, !session_id.isEmpty else{
            return
        }
        
        
        let appendStr:String! = "session/\(session_id)"
        //self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "Picking_Transactions", serviceParam: "" as Any, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                //self.removeSpinner()
                if isDone! {
                    let _: NSDictionary = responseData as! NSDictionary
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let _ = responseDict["message"] as! String
                        //Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                    }else{
                        //Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
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
    func preparePickingSaveRequestData(){
        let requestDict = NSMutableDictionary()
        
        //TODO: Basic Info
        if selectedLocationUuid != nil {
            requestDict.setValue(selectedLocationUuid, forKey: "location_uuid")
        }else{
            Utility.showPopup(Title: App_Title, Message: "Please select location..", InViewC: self)
            return
        }
        if notShipButton.isSelected {        
            if storageNameLabel.accessibilityHint == nil || storageNameLabel.accessibilityHint == "" {
                Utility.showAlertDefault(Title: App_Title, Message: "Please select storage area", InViewC: self)
                return
            }
            if !shelfView.isHidden && (shelfLabel.accessibilityHint == "" || shelfLabel.accessibilityHint == nil) {
                Utility.showAlertDefault(Title: App_Title, Message: "Please select the storage shelf", InViewC: self)
                return
            }
        }
        if selectedCustomer != nil , let uuid = selectedCustomer!["uuid"] as? String , !uuid.isEmpty{
            requestDict.setValue(uuid, forKey: "trading_partner_uuid")
        }else{
            Utility.showPopup(Title: App_Title, Message: "Please select Trading Partner first.", InViewC: self)
            return
        }
        if shipButton.isSelected {
            requestDict.setValue(true, forKey: "is_shipment_approved")
        }else if(notShipButton.isSelected){
            requestDict.setValue(false, forKey: "is_shipment_approved")
            requestDict.setValue(storageNameLabel.accessibilityHint, forKey: "unapproved_shipment_storage_area_uuid")
            requestDict.setValue(shelfLabel.accessibilityHint, forKey: "unapproved_shipment_storage_shelf_uuid")
        }
        requestDict.setValue(false, forKey: "is_direct_purchase")
        requestDict.setValue(false, forKey: "is_received_as_direct_purchase")
        
        
        //TODO: End
        //TODO: Other Details
        
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStrForApi = formatter.string(from: currentDate)
        
        if let other_details = Utility.getDictFromdefaults(key: "picking_other_details"){
            
            if let txt = other_details["order_date"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "order_date")
            }else{
                requestDict.setValue(dateStrForApi, forKey: "order_date")
            }
            
            if let txt = other_details["shipment_date"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipment_date")
            }
            
            if let txt = other_details["custom_order_id"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "custom_order_id")
            }
            
            if let txt = other_details["internal_reference_id"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "internal_reference_id")
            }
            
            if let txt = other_details["invoice_id"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "invoice_id")
            }
            
            if let txt = other_details["release_number"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "release_number")
            }
            
            if let txt = other_details["po_number"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "po_number")
            }
            
            if let txt = other_details["order_number"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "order_number")
            }
            
            if let txt = other_details["tracking_number"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "tracking_number")
            }
            
            if let txt = other_details["shipping_carrier_uuid"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipping_carrier_uuid")
                
            }else if let txt = other_details["custom_shipping_carrier"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "custom_shipping_carrier")
            }
            
            if let txt = other_details["shipping_method_uuid"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipping_method_uuid")
                
            }else if let txt = other_details["custom_shipping_method"] as? String , !txt.isEmpty{
                requestDict.setValue(txt, forKey: "custom_shipping_method")
            }
            
        }else{
            requestDict.setValue(dateStrForApi, forKey: "order_date")
        }
        
        //TODO: End
        
        
        //TODO: Billing Address
        if broughtByData != nil {
            
            if let uuid = broughtByData!["uuid"] as? String , !uuid.isEmpty {
                requestDict.setValue(uuid, forKey: "billing_address_uuid")
            }else{
                
                if let txt = broughtByData!["recipient_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_recipient_name")
                }
                
                if let txt = broughtByData!["line1"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_line1")
                }
                
                if let txt = broughtByData!["country_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_country_name")
                }
                
                if let txt = broughtByData!["state_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_state_name")
                }
                
                if let txt = broughtByData!["state_id"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_state_id")
                }
                
                if let txt = broughtByData!["city"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_city")
                }
                
                if let txt = broughtByData!["zip"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_zip")
                }
                
                if let txt = broughtByData!["phone"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_phone")
                }
                
                if let txt = broughtByData!["email"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "billing_address_custom_email")
                }
            }
            
        }
        //TODO: End
        //TODO: Ship To
        
        if shipToData != nil {
            
            if let uuid = shipToData!["uuid"] as? String , !uuid.isEmpty {
                requestDict.setValue(uuid, forKey: "ship_to_address_uuid")
            }else{
                
                if let txt = shipToData!["recipient_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_recipient_name")
                }
                
                if let txt = shipToData!["line1"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_line1")
                }
                
                if let txt = shipToData!["country_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_country_name")
                }
                
                if let txt = shipToData!["state_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_state_name")
                }
                
                if let txt = shipToData!["state_id"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_state_id")
                }
                
                if let txt = shipToData!["city"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_city")
                }
                
                if let txt = shipToData!["zip"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_zip")
                }
                
                if let txt = shipToData!["phone"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_phone")
                }
                
                if let txt = shipToData!["email"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_to_address_custom_email")
                }
            }
            
        }
        
        //TODO: End
        
        //TODO: Sold By
        
        if soldByData != nil {
            
            if let uuid = soldByData!["uuid"] as? String , !uuid.isEmpty {
                requestDict.setValue(uuid, forKey: "sold_by_address_uuid")
            }else{
                
                if let txt = soldByData!["recipient_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_recipient_name")
                }
                
                if let txt = soldByData!["line1"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_line1")
                }
                
                if let txt = soldByData!["country_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_country_name")
                }
                
                if let txt = soldByData!["state_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_state_name")
                }
                
                if let txt = soldByData!["state_id"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_state_id")
                }
                
                if let txt = soldByData!["city"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_city")
                }
                
                if let txt = soldByData!["zip"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_zip")
                }
                
                if let txt = soldByData!["phone"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_phone")
                }
                
                if let txt = soldByData!["email"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "sold_by_address_custom_email")
                }
            }
        }
        
        //TODO: End
        //TODO: Ship From
        
        if shipFromData != nil {
            
            if let uuid = shipFromData!["uuid"] as? String , !uuid.isEmpty {
                requestDict.setValue(uuid, forKey: "ship_from_address_uuid")
            }else{
                
                if let txt = shipFromData!["recipient_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_recipient_name")
                }
                
                if let txt = shipFromData!["line1"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_line1")
                }
                
                if let txt = shipFromData!["country_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_country_name")
                }
                
                if let txt = shipFromData!["state_name"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_state_name")
                }
                
                if let txt = shipFromData!["state_id"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_state_id")
                }
                
                if let txt = shipFromData!["city"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_city")
                }
                
                if let txt = shipFromData!["zip"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_zip")
                }
                
                if let txt = shipFromData!["phone"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_phone")
                }
                
                if let txt = shipFromData!["email"] as? String , !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "ship_from_address_custom_email")
                }
            }
            
        }
        
        //TODO: End
        confirmPicking(requestData: requestDict)
    }
    
    func confirmPicking(requestData:NSMutableDictionary){
        
        var appendStr =  "session/"
        if let session_id = defaults.value(forKey: "picking_session_id") as? String , !session_id.isEmpty {
            appendStr = appendStr + session_id
        }else{
            Utility.showPopup(Title: App_Title, Message: "No Picking session found..", InViewC: self)
            return
        }
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "Picking_Transactions", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["transaction_uuid"] as? String {
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Picking request submitted", InViewC: self, isPop: true, isPopToRoot: true)
                    }
                    
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if responseDict["message"] as? String != nil || responseDict["details"] as? String != nil{
                            Utility.showPopup(Title: responseDict["message"] as? String ?? "", Message: responseDict["details"] as? String ?? "" , InViewC: self)
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong." , InViewC: self)
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
    
    @IBAction func editIconPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            stepButtonsPressed(sender)
            
        }else if sender.tag == 2{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddressDetailsView") as! AddressDetailsViewController
            controller.isSeller = false
            controller.isSelected1stView = true
            controller.addressArr = CustomerAddressesModel.getAddresses()
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 3{
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddressDetailsView") as! AddressDetailsViewController
            controller.isSeller = false
            controller.isSelected1stView = false
            controller.addressArr = CustomerAddressesModel.getAddresses()
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 4 {
            
            if allLocations == nil {
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = true
            controller.nameKeyName = "name"
            controller.listItemsDict = allLocations
            controller.delegate = self
            controller.type = "Locations"
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
        }else if sender.tag == 5{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddressDetailsView") as! AddressDetailsViewController
            controller.isSeller = true
            controller.isSelected1stView = true
            controller.addressArr = UserInfosModel.getUserLocationAddresses()
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 6{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddressDetailsView") as! AddressDetailsViewController
            controller.isSeller = true
            controller.isSelected1stView = false
            controller.addressArr = UserInfosModel.getUserLocationAddresses()
            self.navigationController?.pushViewController(controller, animated: false)
        }
        
    }
    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1{
            
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
            
        }else if sender.tag == 2{
            
            if (storageNameLabel.accessibilityHint == nil || storageNameLabel.accessibilityHint == "") {
                Utility.showPopup(Title: App_Title, Message: "Please fill the storage before choosing shelf", InViewC: self)
                return
            }
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
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want cancel Picking".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        if  shipButton.isSelected || notShipButton.isSelected {
            if notShipButton.isSelected {
                if storageNameLabel.accessibilityHint == nil || storageNameLabel.accessibilityHint == "" {
                    Utility.showAlertDefault(Title: App_Title, Message: "Please select storage area", InViewC: self)
                    return
                }
                if !shelfView.isHidden && (shelfLabel.accessibilityHint == "" || shelfLabel.accessibilityHint == nil) {
                    Utility.showAlertDefault(Title: App_Title, Message: "Please select the storage shelf", InViewC: self)
                    return
                }
            }
        }else{
            Utility.showAlertWithPopAction(Title: Warning, Message: "Please select the shipment status".localized(), InViewC: self, isPop: false, isPopToRoot: false)
            return
        }
       
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want confirm Picking".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingItemsView") as! PickingItemsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewEditButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingOtherDetailsView") as! PickingOtherDetailsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: SelectCustomerViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SelectCustomerView") as! SelectCustomerViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: PickingScanItemsViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingScanItemsView") as! PickingScanItemsViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
    }
   
    @IBAction func checkUncheckPressed(_ sender:UIButton){
       
            if sender == notShipButton && !notShipButton.isSelected{
                notShipButton.isSelected = true
                shipButton.isSelected = false
                storageStack.isHidden = false
                defaults.setValue(false, forKey: "SelectedShipmentStatus")
            }else if(sender == shipButton && !shipButton.isSelected){
                notShipButton.isSelected = false
                shipButton.isSelected = true
                storageStack.isHidden = true
                defaults.setValue(true, forKey: "SelectedShipmentStatus")
            }
    }
    //MARK: - End
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        if shipButton.isSelected || notShipButton.isSelected {
            preparePickingSaveRequestData()
        }else{
            Utility.showAlertWithPopAction(Title: Warning, Message: "Please select the shipment status".localized(), InViewC: self, isPop: false, isPopToRoot: false)

        }
        
    }
    func cancelConfirmation() {
        delete_picking_session()
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
    
    //MARK: - SingleSelectDropdownDelegate
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if let name = data["name"] as? String{
            locationNameLabel.text = name
            locationNameLabel.accessibilityHint = itemStr
            defaults.removeObject(forKey: "shipFrom")
            defaults.removeObject(forKey: "soldBy")
            if UserInfosModel.UserInfoShared.default_location_uuid != itemStr{
                self.showSpinner(onView: self.view)
                UserInfosModel.UserInfoShared.getLocationAddress(isDefault: false, location_uuid: itemStr) { (isDone:Bool?) in
                    self.selectedLocationUuid = itemStr
                    defaults.set(self.selectedLocationUuid, forKey: "selectedLocation")
                    self.removeSpinner()
                    self.setup_stepview()
                }
            }else{
                self.selectedLocationUuid = itemStr
                defaults.set(self.selectedLocationUuid, forKey: "selectedLocation")
                if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: true){
                    soldByData = addData
                    Utility.saveDictTodefaults(key: "soldBy", dataDict: addData)
                    
                }
                
                if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: true){
                    shipFromData = addData
                    Utility.saveDictTodefaults(key: "shipFrom", dataDict: addData)
                }
                self.setup_stepview()
            }
            self.locationdetailsFetch(locationUdid: itemStr as NSString)

        }
    }

    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender?.tag == 1 {
            defaults.setValue(data, forKey: "SelectedStorageArea")
            if let txt = data["name"] as? String,!txt.isEmpty {
                storageNameLabel.text = data["name"] as? String

            }
            if let txt = data["uuid"] as? String,!txt.isEmpty {
                storageNameLabel.accessibilityHint = data["uuid"] as? String
            }
            
            let haveShelf = data["is_have_shelf"] as! Bool
            if haveShelf {
                shelfView.isHidden = false
                self.getShelfList(storageAreaUUID: storageNameLabel.accessibilityHint!)
            }else{
                shelfView.isHidden = true
            }
        }
        if sender?.tag == 2 {
            defaults.setValue(data, forKey: "SelectedStorageShelf")
            if let txt = data["name"] as? String,!txt.isEmpty {
                shelfLabel.text = data["name"] as? String

            }
            if let txt = data["storage_shelf_uuid"] as? String,!txt.isEmpty {
                shelfLabel.accessibilityHint = data["storage_shelf_uuid"] as? String

            }
        }
    }
}
