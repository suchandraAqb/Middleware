//
//  DPConfirmationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 28/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class DPConfirmationViewController: BaseViewController,DPStorageSelectionDelegate,SingleSelectDropdownDelegate {
    
    
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var shipToLabel: UILabel!
    
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var serialCountLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var customerView: UIView!
    
    @IBOutlet weak var itemsVerificationView: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var pickerNameLabel: UILabel!
    @IBOutlet weak var pickingStartDateLabel: UILabel!
    @IBOutlet weak var poLabel: UILabel!
    @IBOutlet weak var orderNoLabel: UILabel!
    
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
    
    //MARK: Confirmation View
    @IBOutlet weak var confirmationView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var subtextView: UIView!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet var roundButtons: [UIButton]!
    //MARK: - End
    
    @IBOutlet weak var shipmentStatusview:UIView!
    @IBOutlet weak var notShipButton:UIButton!
    @IBOutlet weak var shipButton : UIButton!
    @IBOutlet weak var storageStack:UIStackView!
    @IBOutlet weak var storageNameLabel:UILabel!
    @IBOutlet weak var shelfLabel:UILabel!
    @IBOutlet weak var storageAreaButton:UIButton!
    @IBOutlet weak var storageShelfButton:UIButton!
    @IBOutlet weak var shelfView:UIView!
    @IBOutlet weak var cancelPickingView:UIView!
    @IBOutlet weak var voidPickingButton:UIButton!
    @IBOutlet weak var postponeButton:UIButton!
    @IBOutlet var buttonViews:[UIView]!
    var selectedLocationUuid:String?
    var serialList = Array<DirectPicking>()
    
    var allLocations:NSDictionary?
    var storageAreas:Array<Any>?
    var shelfs:Array<Any>?
    var storage_location_uuid:String?
    var pickedArr = NSArray()

    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshProductView()
        self.locationdetailsFetch()
        getShipmentItemDetails()
        setup_stepview()

    }
    //MARK: - End
    
    //MARK: - Private Method
   
    func initialSetup(){
        sectionView.roundTopCorners(cornerRadious: 40)
        containerView.roundTopCorners(cornerRadious: 40)
        customerView.setRoundCorner(cornerRadious: 10.0)
        subtextView.setRoundCorner(cornerRadious: 10.0)
        itemsVerificationView.setRoundCorner(cornerRadious: 10.0)
        cancelPickingView.roundTopCorners(cornerRadious: 40)
        voidPickingButton.setRoundCorner(cornerRadious: voidPickingButton.frame.size.height/2)
        postponeButton.setRoundCorner(cornerRadious: postponeButton.frame.size.height/2)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
        for button in buttonViews{
            button.setRoundCorner(cornerRadious: 20)
        }
        for btn in roundButtons{
            btn.setRoundCorner(cornerRadious: btn.frame.size.height/2.0)
        }
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 13.0)!]
        let attString = NSMutableAttributedString(string: "Note: ".localized(), attributes: custAttributes)
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let typeStr = NSAttributedString(string: "If the item to pick is not present, you must update the shipment and reduce the quantity to ship in order to ship the shipment.".localized(), attributes: custTypeAttributes)
        attString.append(typeStr)
        
        subTextLabel.attributedText = attString
        
        storageStack.isHidden = true
        cancelPickingView.isHidden = true

        shipmentStatusview.setRoundCorner(cornerRadious: 10.0)
        storageAreaButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        storageShelfButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
    }
    
    func checkItemsPicked(){
        self.showSpinner(onView: self.view)
        UserInfosModel.UserInfoShared.serialBasedOrLotBasedItemsGetApiCall(ServiceCompletion:{ isDone, itemArr in
            self.removeSpinner()
            if itemArr != nil && !(itemArr?.isEmpty ?? false) {
                self.pickedArr = itemArr! as NSArray
                let predicate = NSPredicate(format:"picking_type = '\("GS1_SERIAL_BASED")'|| picking_type = '\("SIMPLE_SERIAL_BASED")'")
                let serial = self.pickedArr.filtered(using: predicate)

                let predicate1 = NSPredicate(format:"picking_type = '\("LOT_BASED")'")
                let lot = self.pickedArr.filtered(using: predicate1)
                
                self.populateProductandItemsCount(product: "\(lot.count)", items: "\(serial.count)")
            }else{
                self.pickedArr = []
                self.populateProductandItemsCount(product: "0", items: "0")

            }
            Utility.saveObjectTodefaults(key: "PickedItemCount", dataObject: self.pickedArr)

        })
    }
    func refreshProductView(){
        var product = "0"
        var serial = "0"
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                let uniqueArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid")
                product = "\((uniqueArr as? Array<Any>)?.count ?? 0)"
                
                
            }
        }catch let error{
            
            print(error.localizedDescription)
        }
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                serial = "\(arr.count)"
                
                
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        
        self.checkItemsPicked()
       // populateProductandItemsCount(product: product, items: serial)
        
    }
    func getShipmentItemDetails(){
                
        let shipmentId = defaults.object(forKey: "outboundShipemntuuid")
        let appendStr = "to_pick/\(shipmentId ?? "")?is_open_picking_session=false"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ShipmentPickings", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  if isDone! {
                    
                    if let responseDict = responseData as? NSDictionary {
                        if let picking_data = responseDict["picking_data"] as? [String:Any]{
                            Utility.saveObjectTodefaults(key: "DirectPickingData", dataObject: picking_data)
                            self.populateDetailsView()

                        }
                        
                    }
                }else{
                     self.removeSpinner()
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       
                    Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                       
                   }else{
                      
                    Utility.showAlertWithPopAction(Title: App_Title, Message: message, InViewC: self, isPop: true, isPopToRoot: false)
                   }
                }
            }
        }
    }
    func populateDetailsView(){
        if let data = Utility.getObjectFromDefauls(key: "DirectPickingData") as? NSDictionary{
            var dataStr = ""
            if let txt = data["status"] as? String{
                dataStr = txt
                if txt == "TO_PICK" {
                    dataStr = "To Do"
                }else if txt == "PICKING_IN_PROGRESS"{
                    dataStr = "In Progress"
                }
            }
            statusLabel.text = dataStr
            pickerNameLabel.text = UserInfosModel.UserInfoShared.userName ?? ""
            
            dataStr = ""
            if let txt = data["created_on"] as? String{
                dataStr = txt
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.sZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: dataStr){
                    dataStr = formattedDate
                }
            }
            createdDateLabel.text = dataStr
            pickingStartDateLabel.text = dataStr
            
            var custName = ""
            if let name = data["trading_partner_name"] as? String{
                custName = name
            }
            
            let custType = ""
            
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
            
            if let shipping_data = data["shipping_address"] as? NSDictionary {
                populateAddressView(type: "Ship To".localized(), data: shipping_data, label: shipToLabel)
            }
            
            
            // Auto populated pre selected storage and shipment status
            if let selectedShipmentStatus = defaults.value(forKey: "DPSelectedShipmentStatus") as? Bool {
                if selectedShipmentStatus {
                    checkUncheckPressed(shipButton)
                }else{
                    checkUncheckPressed(notShipButton)
                    if let data = defaults.object(forKey:"DPSelectedStorageArea") as? NSDictionary{
                        let btn = UIButton()
                        btn.tag=1;
                        selecteditem(data: data, sender: btn)
                    }
                    if let data = defaults.object(forKey: "DPSelectedStorageShelf") as? NSDictionary{
                        let btn = UIButton()
                        btn.tag=2;
                        selecteditem(data: data, sender: btn)
                    }
                }
            }
            if ischeck(){
                shipmentStatusview.isHidden = true
            }else{
                shipmentStatusview.isHidden = false
            }
            //---------
            
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
        let productStr = NSAttributedString(string: "\(Int(product!)!>1 ?" Lot Products" : " Lot Product")", attributes: custTypeAttributes)
        let itemStr = NSAttributedString(string: " Serials", attributes: custTypeAttributes)
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
  
    func ischeck() -> Bool {
        var ispartial = false
        if let dataDict = Utility.getDictFromdefaults(key: "DirectPickingData") {
            let arr = dataDict["items"] as! Array<Any>
            for item in arr {
                let itemDict = item as! NSDictionary
                let total_quantity = itemDict["total_quantity"] as! Int
                let qty_picked = itemDict["qty_picked"] as! Int
                if total_quantity != qty_picked {
                    ispartial = true
                }
                
            }
        }
        return ispartial
    }
    func fetchScannedSerials(){
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                serialList = serial_obj
            }
        }catch let error{
            print(error.localizedDescription)
            
        }
        
    }
    
    func setup_stepview(){
        
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
    
    
    
    func preparePickingSaveRequestData(isComplete:Bool ,storage_uuid:String = "",shelf_uuid:String = ""){
        
        if isComplete {
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
        }
        
        
        let requestDict = NSMutableDictionary()
        if let dataDict = Utility.getDictFromdefaults(key: "DirectPickingData") {
            if let txt = dataDict["uuid"] as? String{
                requestDict.setValue(txt, forKey: "picking_uuid")
            }
            
//            requestDict.setValue("SHIPPED", forKey: "complete_ready_status")
            
            requestDict.setValue(isComplete, forKey: "is_complete")
            requestDict.setValue(false, forKey: "is_update_shipping_carrier")
            requestDict.setValue(false, forKey: "is_update_tracking_number")
            requestDict.setValue(false, forKey: "is_update_shipment_date")
            requestDict.setValue(true, forKey: "is_remove_from_parent_container")
            requestDict.setValue(false, forKey: "is_void_on_failure")
            
            if !isComplete{
                requestDict.setValue(storage_uuid, forKey: "storage_location_uuid")
                requestDict.setValue(shelf_uuid, forKey: "storage_shelf_uuid")
                requestDict.setValue("", forKey: "complete_ready_status")
            }else{
                if shipButton.isSelected {
                    requestDict.setValue("SHIPPED", forKey: "complete_ready_status")
                }else if(notShipButton.isSelected){
                    requestDict.setValue("READY_TO_SHIP", forKey: "complete_ready_status")
                    requestDict.setValue(storageNameLabel.accessibilityHint, forKey: "storage_location_uuid")
                    requestDict.setValue(shelfLabel.accessibilityHint, forKey: "storage_shelf_uuid")
                }
            }
        }
        
        var itemsArray = [[String : Any]]()
        
        //MARK: - Prepare Lot Based Product for Save
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and is_container = false")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                if let uniqueProductArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                    
                    for product_uuid in uniqueProductArr {
                        
                        do{
                            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and product_uuid='\(product_uuid)' and is_container = false")
                            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                            if !serial_obj.isEmpty{
                                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                if let uniqueLotArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_no") as? Array<Any>{
                                    
                                    
                                    for lot_no in uniqueLotArr {
                                        
                                        do{
                                            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and product_uuid='\(product_uuid)' and lot_no='\(lot_no)' and is_container = false")
                                            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                                            
                                            if !serial_obj.isEmpty{
                                                //let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                                
                                                let obj = serial_obj.first
                                                var dict = [String : Any]()
                                                dict["type"] = Product_Types.LotBased.rawValue
                                                dict["product_uuid"] = obj?.product_uuid ?? ""
                                                dict["lot_number"] = lot_no
                                                dict["storage_area_uuid"] = obj?.storage_uuid ?? ""
                                                dict["storage_area_shelf_uuid"] = obj?.shelf_uuid ?? ""
                                                dict["quantity"] = serial_obj.reduce(0) { $0 + ($1.value(forKey: "quantity") as? Int64 ?? 0) }
                                                
                                                itemsArray.append(dict)
                                                
                                                
                                            }
                                        }catch let error{
                                            print(error.localizedDescription)
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                                
                            }
                        }catch let error{
                            print(error.localizedDescription)
                        }
                        
                        
                    }
                    
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        //MARK: - End
        
        //MARK: - Prepare Serial Based Product for Save
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                if let uniqueProductArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                    
                    for product_uuid in uniqueProductArr {
                        
                        do{
                            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false and product_uuid='\(product_uuid)'")
                            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                            if !serial_obj.isEmpty{
                                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                if let uniqueSerialArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.gs1_serial") as? Array<Any>{
                                    let obj = serial_obj.first
                                    var dict = [String : Any]()
                                    dict["type"] = Product_Types.SerialBased.rawValue
                                    dict["product_uuid"] = obj?.product_uuid ?? ""
                                    dict["serials"] = uniqueSerialArr
                                    
                                    itemsArray.append(dict)
                                }
                            }
                        }catch let error{
                            print(error.localizedDescription)
                        }
                        
                        
                    }
                    
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        //MARK: - End
        //MARK: - Prepare Containe for Save
      /*
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false and is_container = true")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                if let uniqueProductArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                    
                    for product_uuid in uniqueProductArr {
                        
                        do{
                            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false and product_uuid='\(product_uuid)' and is_container = true")
                            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                            if !serial_obj.isEmpty{
                                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                if let uniqueSerialArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.serial") as? Array<Any>{
//                                    for unique in uniqueSerialArr{
//                                        var dict = [String : Any]()
//                                        dict["type"] = Product_Types.Container.rawValue
//                                        dict["container_gs1_serial_number"] = unique
//                                        dict["container_create_if_not_exist"] = true
//
//                                        itemsArray.append(dict)
//                                    }
                                    
                                    var dict = [String : Any]()
                                    dict["type"] = Product_Types.AggregaionBased.rawValue
                                    dict["serials"] = uniqueSerialArr
                                    
                                    itemsArray.append(dict)
                                }
                            }
                        }catch let error{
                            print(error.localizedDescription)
                        }
                        
                        
                    }
                    
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }*/
        
        //MARK: - End
        
        requestDict.setValue(Utility.json(from: itemsArray), forKey: "items")
        //print("Request Data:\(requestDict)")
        confirmPicking(requestData: requestDict)
    }
    
    
    func confirmPicking(requestData:NSMutableDictionary){
        var appendStr =  ""
        if let pickingId = defaults.value(forKey: "SOPickingUUID") as? String , !pickingId.isEmpty {
            appendStr = appendStr + pickingId + "/close" ///pick_and_close
        }
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ShipmentPickings", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["uuid"] as? String {
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Picking request submitted", InViewC: self, isPop: true, isPopToRoot: true)
                    }
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else  if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong.." , InViewC: self)
                        }
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }
    func preparePickingSaveRequestDataUpdated(isComplete:Bool ,storage_uuid:String = "",shelf_uuid:String = ""){
        
        if isComplete {
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
        }
        let requestDict = NSMutableDictionary()
        if Utility.getDictFromdefaults(key: "DirectPickingData") != nil {

            requestDict.setValue(isComplete, forKey: "is_complete")

            if !isComplete{
                requestDict.setValue(storage_uuid, forKey: "storage_location_uuid")
                requestDict.setValue(shelf_uuid, forKey: "storage_shelf_uuid")
                requestDict.setValue("", forKey: "complete_ready_status")
            }else{
                if shipButton.isSelected {
                    requestDict.setValue("SHIPPED", forKey: "complete_ready_status")
                }else if(notShipButton.isSelected){
                    requestDict.setValue("READY_TO_SHIP", forKey: "complete_ready_status")
                    requestDict.setValue(storageNameLabel.accessibilityHint, forKey: "storage_location_uuid")
                    requestDict.setValue(shelfLabel.accessibilityHint, forKey: "storage_shelf_uuid")
                }
            }
        }
        confirmPicking(requestData: requestDict)
    }

    
    func locationdetailsFetch(){
        storageNameLabel.text = "Select Storage"
        storageNameLabel.accessibilityHint = ""
        shelfLabel.text = "Select Shelf"
        shelfLabel.accessibilityHint = ""
        storageAreas=[]
        
        //---------
        if let location_uuid = defaults.object(forKey: "SOPickingLocationUUID") as? String{
            storage_location_uuid = location_uuid
            let allLocations = UserInfosModel.getLocations()
            if allLocations != nil{
                if let locationData = allLocations![location_uuid] as? NSDictionary{
                    if let sa = locationData["sa"] as? Array<Any>, !sa.isEmpty{
                        storageAreas = sa
                    }else{
                        if let sa_count = locationData["sa_count"]as? Int {
                            if sa_count > 0 {
                                let userinfo = UserInfosModel.UserInfoShared
                                self.showSpinner(onView: self.view)
                                userinfo.getStorageAreasOfALocation(location_uuid: location_uuid, ServiceCompletion:{ (isDone:Bool? , sa:Array<Any>?) in
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
        }
        //------
    }
    
    func getShelfList(storageAreaUUID:String){
        let appendStr:String! = (storage_location_uuid ?? "") as String + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
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
    //MARK: - End
    //MARK: - IBAction
    
    @IBAction func checkUncheckPressed(_ sender:UIButton){
       
            if sender == notShipButton && !notShipButton.isSelected{
                notShipButton.isSelected = true
                shipButton.isSelected = false
                storageStack.isHidden = false
                defaults.setValue(false, forKey: "DPSelectedShipmentStatus")
            }else if(sender == shipButton && !shipButton.isSelected){
                notShipButton.isSelected = false
                shipButton.isSelected = true
                storageStack.isHidden = true
                defaults.setValue(true, forKey: "DPSelectedShipmentStatus")
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
        if cancelPickingView.isHidden{
            cancelPickingView.isHidden = false
        }else{
            cancelPickingView.isHidden = true
        }
        
//        let msg = "Your picking will be voided and picked items will be put back to the original location in the inventory. Continue?"
//
//        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
//        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: { (UIAlertAction) in
//
//            self.navigationController?.popToRootViewController(animated: true)
//
//
//        })
//        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
//
//            Utility.void_SOpicking_session(controller: self)
//            self.navigationController?.popToRootViewController(animated: true)
//
//
//        })
//
//        confirmAlert.addAction(action)
//        confirmAlert.addAction(okAction)
//        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    @IBAction func voidPickingButtonPressed(_ sender:UIButton){
        cancelPickingView.isHidden = true
        Utility.void_SOpicking_session(controller: self)
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func postponePickingButtonPressed(_ sender:UIButton){
        cancelPickingView.isHidden = true
        self.navigationController?.popToRootViewController(animated: true)

    }
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        if !(self.pickedArr.count>0){
            Utility.showPopup(Title: App_Title, Message: "Please scan serials or pick items manually before proceed.".localized(), InViewC: self)
            return
        }
      
        if  self.ischeck() {
            confirmationView.isHidden = false
            shipmentStatusview.isHidden = true
        }else{
            confirmationView.isHidden = true
            shipmentStatusview.isHidden = false
            self.completePickingButtonPressed(sender)
        }
    }
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPViewPickedItems") as! DPViewPickedItemsViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
//        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPViewItemsView") as! DPViewItemsViewController
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: PickingDetailsViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingDetailsView") as! PickingDetailsViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: DirectPickingScanViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "DirectPickingScanView") as! DirectPickingScanViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    
    @IBAction func completePickingButtonPressed(_ sender: UIButton) {
        confirmationView.isHidden = true
        if shipButton.isSelected || notShipButton.isSelected {
            preparePickingSaveRequestDataUpdated(isComplete: true)
        }else{
            Utility.showAlertWithPopAction(Title: Warning, Message: "Please select the shipment status".localized(), InViewC: self, isPop: false, isPopToRoot: false)
        }
    }
    
    @IBAction func partialPickingButtonPressed(_ sender: UIButton) {
        confirmationView.isHidden = true
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPStorageSelectionView") as! DPStorageSelectionViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    
    @IBAction func confirmationCloseButtonPressed(_ sender: UIButton) {
        confirmationView.isHidden = true
    }
    
    
    //MARK: - End
    
    //MARK: - DPStorageSelectionDelegate
    func didSelectStorageForDP(storage_uuid: String, shelf_uuid: String) {
        preparePickingSaveRequestDataUpdated(isComplete: false,storage_uuid: storage_uuid,shelf_uuid: shelf_uuid)
    }
    //MARK: - End
    
    //MARK: - SingleSelectDropdownDelegate
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender?.tag == 1 {
            defaults.setValue(data, forKey: "DPSelectedStorageArea")
            if let txt = data["name"] as? String,!txt.isEmpty {
                storageNameLabel.text = data["name"] as? String
            }
            if let txt = data["uuid"] as? String,!txt.isEmpty {
                storageNameLabel.accessibilityHint = data["uuid"] as? String
            }
            
            let haveShelf = data["is_have_shelf"] as! Bool
            if haveShelf {
                shelfView.isHidden = false
                shelfLabel.accessibilityHint=""
                shelfLabel.text = "Select Shelf"
                self.getShelfList(storageAreaUUID: storageNameLabel.accessibilityHint!)
            }else{
                shelfLabel.accessibilityHint=""
                shelfLabel.text = "Select Shelf"
                shelfView.isHidden = true
            }
        }
        if sender?.tag == 2 {
            defaults.setValue(data, forKey: "DPSelectedStorageShelf")
            if let txt = data["name"] as? String,!txt.isEmpty {
                shelfLabel.text = data["name"] as? String
            }
            if let txt = data["storage_shelf_uuid"] as? String,!txt.isEmpty {
                shelfLabel.accessibilityHint = data["storage_shelf_uuid"] as? String
            }
        }
    }
    
    
    
    
    
    
}
