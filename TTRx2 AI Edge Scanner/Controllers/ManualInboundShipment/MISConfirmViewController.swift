//
//  Mis1ConfirmationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 12/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISConfirmViewController:  BaseViewController,ConfirmationViewDelegate{
       
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var broughtByLabel: UILabel!
    @IBOutlet weak var shipToLabel: UILabel!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var soldByLabel: UILabel!
    @IBOutlet weak var shipFromLabel: UILabel!
    
    
    @IBOutlet weak var productCountLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var customerView: UIView!
    @IBOutlet weak var sellerView: UIView!
    @IBOutlet weak var itemsVerificationView: UIView!
    @IBOutlet weak var aggregationView: UIView!
    
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
    
    var selectedLocationUuid:String?
    var selectedCustomer:NSDictionary?
    
    var broughtByData:NSDictionary?
    var shipToData:NSDictionary?
    var soldByData:NSDictionary?
    var shipFromData:NSDictionary?
    
    var allLocations:NSDictionary?
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        customerView.setRoundCorner(cornerRadious: 10.0)
        sellerView.setRoundCorner(cornerRadious: 10.0)
        itemsVerificationView.setRoundCorner(cornerRadious: 10.0)
        aggregationView.setRoundCorner(cornerRadious: 10.0)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateProductCount()
        setup_view()
    }
    //MARK: - End
    //MARK: - Private Method
    
    func populateProductCount(){
        var tempProductCount = "0"
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let count = serial_obj.count
                tempProductCount = "\(count)"
            }
        }catch let error{
            print(error.localizedDescription)
        }
        productCountLabel.text = tempProductCount + " Product"
    }
   
    func populateSelectedCustomerView(){
        
        
        
        if selectedCustomer != nil{
            
            var custName = ""
            if let name = selectedCustomer!["name"]{
                custName = name as! String
            }else{
                custName = selectedCustomer!["trading_partner_name"] as! String
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
    
    
    
    func setup_view(){
        
        allLocations = UserInfosModel.getLocations()
        
        if let selected_location_uuid = defaults.object(forKey: "MIS_selectedLocation") as? String{
            selectedLocationUuid = selected_location_uuid
        }else{
            selectedLocationUuid = UserInfosModel.UserInfoShared.default_location_uuid
            defaults.set(selectedLocationUuid, forKey: "MIS_selectedLocation")
        }
        
        
        if let allLocations = UserInfosModel.getLocations(){
            
            if let location = allLocations[selectedLocationUuid ?? ""] as? NSDictionary{
                if let name = location["name"] as? String {
                    locationNameLabel.text = name
                }
            }
        }
  
        if let dataDict = Utility.getDictFromdefaults(key: "MIS_selectedSeller"){
            selectedCustomer = dataDict
            populateSelectedCustomerView()
        }
    
        if let dataDict = Utility.getDictFromdefaults(key: "MIS_broughtBy"){
            broughtByData = dataDict
        }else{
            if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: false){
                broughtByData = addData
                Utility.saveDictTodefaults(key: "MIS_broughtBy", dataDict: addData)
            }
        }
        populateAddressView(type: "Bought By".localized(), data: broughtByData, label: broughtByLabel)
        
        if let dataDict = Utility.getDictFromdefaults(key: "MIS_shipTo"){
            shipToData = dataDict
        }else{
            if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: false){
                shipToData = addData
                Utility.saveDictTodefaults(key: "MIS_shipTo", dataDict: addData)
            }
        }
        populateAddressView(type: "Ship To".localized(), data: shipToData, label: shipToLabel)
        
        if let dataDict = Utility.getDictFromdefaults(key: "MIS_soldBy"){
            soldByData = dataDict
        }else{
            if let addData = CustomerAddressesModel.getDefaultAddress(){
                soldByData = addData
                Utility.saveDictTodefaults(key: "MIS_soldBy", dataDict: addData)
            }
        }
        populateAddressView(type: "Sold By".localized(), data: soldByData, label: soldByLabel)

        if let dataDict = Utility.getDictFromdefaults(key: "MIS_shipFrom"){
            shipFromData = dataDict
        }else{
            if let addData = CustomerAddressesModel.getDefaultAddress(){
                shipFromData = addData
                Utility.saveDictTodefaults(key: "MIS_shipFrom", dataDict: addData)
            }
        }
        populateAddressView(type: "Ship From".localized(), data: shipFromData, label: shipFromLabel)
           
        setup_stepview()
  }
    
    func setup_stepview(){
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step3Button.isUserInteractionEnabled = true
        step4Button.isUserInteractionEnabled = true
        step5Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        
             
    }
    //MARK: - End
    
    func getLotDetails(misitem_id:Int) -> [[String : Any]] {
        var lotsTemp = [[String : Any]]()
        do{
            let predicate = NSPredicate(format:"misitem_id='\(misitem_id)'")
            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                let lots = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                for lot in lots{
                    if let lotdict = lot as? NSDictionary {
                        var sdi = ""
                        if let txt = lotdict["sdi"] as? String,!txt.isEmpty{
                            sdi = txt
                        }
                        
                        var quantity = 0
                        if let txt = lotdict["quantity"] as? Int{
                            quantity = txt
                        }
                        
                        var lot_number = ""
                        if let txt = lotdict["lot_number"] as? String,!txt.isEmpty{
                            lot_number = txt
                        }
                        
                        var production_date = ""
                        if let txt = lotdict["production_date"] as? String,!txt.isEmpty{
                            production_date = txt
                        }
                        
                        var best_by_date = ""
                        if let txt = lotdict["best_by_date"] as? String,!txt.isEmpty{
                            best_by_date = txt
                        }
                        
                        var sell_by_date = ""
                        if let txt = lotdict["sell_by_date"] as? String,!txt.isEmpty{
                            sell_by_date = txt
                        }
                        
                        var expiration_date = ""
                        if let txt = lotdict["expiration_date"] as? String,!txt.isEmpty{
                            expiration_date = txt
                        }
                        
                        var lotTemp = [String : Any]()
                        
                        lotTemp["sdi"] = Int(sdi)
                        lotTemp["quantity"] = quantity
                        lotTemp["lot_number"] = lot_number
                        lotTemp["production_date"] = production_date
                        lotTemp["best_by_date"] = best_by_date
                        lotTemp["sell_by_date"] = sell_by_date
                        lotTemp["expiration_date"] = expiration_date
                        
                        let attachments = [String]()
                        let history = [String]()
                        
                        lotTemp["attachments"] = attachments
                        lotTemp["history"] = history
                        
                        lotTemp["manufacturer_address_uuid"] = ""
                        
                        lotsTemp.append(lotTemp)
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        return lotsTemp
    }
    
    func getAggregationData(id: Int) -> [[String : Any]]{
        var aggregation_data = [[String : Any]]()
        do{
            let predicate = NSPredicate(format: "parent_id='\(id)'")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let aggregations = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                for aggregation in aggregations {
                    if let aggregationdict = aggregation as? NSDictionary {
                        var aggregationTemp = [String : Any]()
                        if let type = aggregationdict["type"] as? String,!type.isEmpty{
                            
                            var serial = ""
                            if let txt = aggregationdict["serial"] as? String,!txt.isEmpty{
                                serial = txt
                            }
                            
                            var gs1_serial = ""
                            if let txt = aggregationdict["gs1_serial"] as? String,!txt.isEmpty{
                                gs1_serial = txt
                            }
                            
                            var gs1_barcode = ""
                            if let txt = aggregationdict["gs1_barcode"] as? String,!txt.isEmpty{
                                gs1_barcode = txt
                            }
                            
                            if type == "product" || type == "PRODUCT"{
                                aggregationTemp["type"] = type
                                
                                aggregationTemp["serial"] = serial
                                aggregationTemp["gs1_serial"] = gs1_serial
                                aggregationTemp["gs1_barcode"] = gs1_barcode
                                
                                var sdi = ""
                                if let txt = aggregationdict["sdi"] as? String,!txt.isEmpty{
                                    sdi = txt
                                }
                                
                                var lot_based_quantity = 0
                                if let txt = aggregationdict["lot_based_quantity"] as? Int{
                                    lot_based_quantity = txt
                                }
                                
                                aggregationTemp["sdi"] = sdi
                                aggregationTemp["lot_based_quantity"] = lot_based_quantity
                                
                            } else if type == "container" || type == "CONTAINER"{
                                aggregationTemp["type"] = type
                                
                                aggregationTemp["serial"] = serial
                                aggregationTemp["gs1_serial"] = gs1_serial
                                aggregationTemp["gs1_barcode"] = gs1_barcode
                                
                                if let id = aggregationdict["id"] as? Int{
                                    if getAggregationData(id: id).count > 0{
                                        aggregationTemp["content"] = getAggregationData(id: id)
                                    }
                                }
                            }
                            
                            aggregation_data.append(aggregationTemp)
                        }
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        return aggregation_data
    }
    
    func prepareManualInboundShipmentSaveRequestData(){
        let requestDict = NSMutableDictionary()
        
        //TODO: is_create_transaction_from_shipment_data
        
        let createNew = defaults.bool(forKey: "MIS_create_new")
        
        requestDict.setValue(createNew, forKey: "is_create_transaction_from_shipment_data")
        //TODO: End
        
        
        //TODO: Line Item
        var shipment_line_items = [[String : Any]]()
        do{
            let productPredicate = NSPredicate(format:"TRUEPREDICATE")
            let products_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: productPredicate))
            
            
            if !products_obj.isEmpty{
                let products = Utility.convertCoreDataRequestsToJSONArray(moArray: products_obj)
                for product in products {
                    if let productdict = product as? NSDictionary {
                        
                        var lineItemTemp = [String : Any]()
                        
                        if let productid = productdict["id"] as? Int{
                            lineItemTemp["details"] = getLotDetails(misitem_id: productid)
                        }
                        
                        var quantity = 0
                        if let txt = productdict["quantity"] as? Int{
                            quantity = txt
                        }
                        
                        var product_uuid = ""
                        if let txt = productdict["product_uuid"] as? String,!txt.isEmpty{
                            product_uuid = txt
                        }
                        
                        var line_item_uuid = ""
                        if let txt = productdict["line_item_uuid"] as? String,!txt.isEmpty{
                            line_item_uuid = txt
                        }
                        
                        if !createNew {
                            lineItemTemp["line_item_uuid"] = line_item_uuid
                        }
                        
                        
                        
                        
                        lineItemTemp["quantity"] = quantity
                        lineItemTemp["product_uuid"] = product_uuid
                        
                        lineItemTemp["manufacturer_id"] = ""
                        lineItemTemp["manufacturer_name"] = ""
                        lineItemTemp["uuid"] = ""
                        
                        shipment_line_items.append(lineItemTemp)
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        requestDict.setValue(Utility.json(from: shipment_line_items), forKey: "shipment_line_items")
        
        //TODO: Line Item  End
        
        
        
        
        //TODO: Aggregation
        requestDict.setValue(Utility.json(from: getAggregationData(id: 0)), forKey: "aggregation_data")
        //TODO: Aggregation End
        
        
        
        
        
        //TODO: Purchase Order Details
        if createNew {
            if let PurchaseOrderDetails = Utility.getDictFromdefaults(key: "MIS_PurchaseOrderDetails"){
                for (ptempkey, ptempval) in PurchaseOrderDetails{
                    if let key = ptempkey as? String{
                        requestDict.setValue(ptempval, forKey: key)
                    }
                }
            }
        }
        //TODO: End
        
        
        //TODO: Shipment Details Details
        if let ShipmentsDetails = Utility.getDictFromdefaults(key: "MIS_ShipmentsDetails"){
            for (stempkey, stempval) in ShipmentsDetails{
                if let key = stempkey as? String {
                    requestDict.setValue(stempval, forKey: key)
                }
            }
        }
        //TODO: End
        
        
        //TODO: Location
        if selectedLocationUuid != nil {
            requestDict.setValue(selectedLocationUuid, forKey: "location_uuid")
        }
        //TODO: End
        
        
        //TODO: Trading Partner
        if selectedCustomer != nil , let uuid = selectedCustomer!["uuid"] as? String , !uuid.isEmpty{
            requestDict.setValue(uuid, forKey: "trading_partner_uuid")
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
        
        
        manualInboundShipmentCallApi(requestData: requestDict)
        
        
    }
    
    func manualInboundShipmentCallApi(requestData: NSMutableDictionary){
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ManualInboundShipment", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()

                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let _ = responseDict["uuid"] as? String{
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Manual Inbound Shipment Created".localized(), InViewC: self, isPop: true, isPopToRoot: true)//request submitted
                    }
                }else{
                    if responseData != nil{
                        //,,,sb12
//                        let responseDict: NSDictionary = responseData as! NSDictionary
//                        let errorMsg = responseDict["message"] as! String
//                        Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                        let createNew = defaults.bool(forKey: "MIS_create_new")
                        if createNew {
                            let responseDict: NSDictionary = responseData as! NSDictionary
                            let errorMsg = responseDict["message"] as! String
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }
                        else {
                            let responseDict: NSDictionary = responseData as! NSDictionary
                            if let details = responseDict["details"] as? String {
                                Utility.showPopup(Title: App_Title, Message: details , InViewC: self)
                            }
                            else {
                                let errorMsg = responseDict["message"] as! String
                                Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            }
                        }
                        //,,,sb12
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
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddressDetailsView") as! MISAddressDetailsViewController
            controller.isSeller = false
            controller.isSelected1stView = true
            controller.addressArr = UserInfosModel.getUserLocationAddresses()
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 3{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddressDetailsView") as! MISAddressDetailsViewController
            controller.isSeller = false
            controller.isSelected1stView = false
            controller.addressArr = UserInfosModel.getUserLocationAddresses()
            self.navigationController?.pushViewController(controller, animated: false)
        }else if sender.tag == 4{
            let btn = UIButton()
            btn.tag = 1
            stepButtonsPressed(btn)
        }else if sender.tag == 5{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddressDetailsView") as! MISAddressDetailsViewController
            controller.isSeller = true
            controller.isSelected1stView = true
            controller.addressArr = CustomerAddressesModel.getAddresses()
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 6{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddressDetailsView") as! MISAddressDetailsViewController
            controller.isSeller = true
            controller.isSelected1stView = false
            controller.addressArr = CustomerAddressesModel.getAddresses()
            self.navigationController?.pushViewController(controller, animated: false)
        }
        
    }
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want cancel Shipment".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want confirm Shipment".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let btn = UIButton()
        btn.tag = 3
        stepButtonsPressed(btn)
    }
    
    @IBAction func viewEditButtonPressed(_ sender: UIButton) {
        let btn = UIButton()
        btn.tag = 2
        stepButtonsPressed(btn)
    }
    
    
    @IBAction func viewAggregationButtonPressed(_ sender: UIButton) {
        let btn = UIButton()
        btn.tag = 4
        stepButtonsPressed(btn)
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
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: MISShipmentDetailsViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISShipmentDetailsView") as! MISShipmentDetailsViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }else if sender.tag == 3 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: MISLineItemViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISLineItemView") as! MISLineItemViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }else if sender.tag == 4 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: MISAggregationViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAggregationView") as! MISAggregationViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }
        
        
    }
    //MARK: - End
    
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        prepareManualInboundShipmentSaveRequestData()
        
    }
    func cancelConfirmation() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
    
    
    
    
    
    
}
