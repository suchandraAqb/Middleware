//
//  ReceivingConfirmationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 30/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData

class ReceivingConfirmationViewController: BaseViewController,ConfirmationViewDelegate {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var step5View: UIView!
    @IBOutlet weak var step4BarViewContainer: UIView!
    
    
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var shipmentDetailsView: UIView!
    @IBOutlet weak var verificationView: UIView!
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var attemptVerView: UIView!
    @IBOutlet weak var successVerView: UIView!
    @IBOutlet weak var storeLocView: UIView!
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var tradingPartnerNameLabel: UILabel!
    @IBOutlet weak var shipDateLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var attemptVerCountLabel: UILabel!
    @IBOutlet weak var successVerCountLabel: UILabel!
    @IBOutlet weak var storageNameLabel: UILabel!
    @IBOutlet weak var shelfNameLabel: UILabel!
    
    var shipmentId:String?
    var itemsArray:Array<Any>?
    var failedSerials = Array<Dictionary<String,Any>>()
    var verifiedSerials = Array<Dictionary<String,Any>>()
    
    
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
    var isFiveStep:Bool!
    var basicQueryResultArray = Array<Dictionary<String,Any>>()

    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shipmentId = defaults.string(forKey: "shipmentId")
        isFiveStep = defaults.bool(forKey: "isFiveStep")
        if !isFiveStep{
            step4Label.text = "Confirm Receiving"
            step5View.isHidden = true
            step4BarViewContainer.isHidden = true
            backButton.tag = 3
        }else{
            backButton.tag = 4
        }
        
        
        sectionView.roundTopCorners(cornerRadious: 40)
        shipmentDetailsView.setRoundCorner(cornerRadious: 10.0)
        verificationView.setRoundCorner(cornerRadious: 10.0)
        storageView.setRoundCorner(cornerRadious: 10.0)
        attemptVerView.setRoundCorner(cornerRadious: 10.0)
        successVerView.setRoundCorner(cornerRadious: 10.0)
        storeLocView.setRoundCorner(cornerRadious: 10.0)
        shelfView.setRoundCorner(cornerRadious: 10.0)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
        
        populateStorageData()
        
        if let shipmentData = defaults.object(forKey: ttrShipmentDetails){
            do{
                let shipmentDict:NSDictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(shipmentData as! Data) as! NSDictionary
                populateShipmentDetails(shipmentDict: shipmentDict)
            }catch{
                print("Shipment Data Not Found")
            }
        }
        fetchFromLocalLotDB()
        fetchFromLocalLineItemDB()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        
        
    }
    //MARK: - End
    //MARK: - Private Method
    func populateStorageData(){
        
        storageNameLabel.text = ""
        shelfNameLabel.text = ""
        
        
        if let storageDict = Utility.getObjectFromDefauls(key: "selected_storage") as? NSDictionary{
            
            
            if let uuid = storageDict["uuid"] as? String {
                storageNameLabel.accessibilityHint = uuid
            }
            
            if let name = storageDict["name"] as? String {
                storageNameLabel.text = name
            }
            
        }
        
        
        if let shelfDict = Utility.getObjectFromDefauls(key: "selected_shelf") as? NSDictionary{
            
            shelfView.isHidden = false
            if let uuid = shelfDict["storage_shelf_uuid"] as? String {
                shelfNameLabel.accessibilityHint = uuid
            }
            
            if let name = shelfDict["name"] as? String {
                shelfNameLabel.text = name
            }
        }else{
            shelfView.isHidden = true
        }
        
    }
    func populateShipmentDetails(shipmentDict:NSDictionary){
        
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        if let shipDate:String = shipmentDict["ship_date"] as? String{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                shipDateLabel.text = formattedDate
            }
        }
        
        if let ship_delivery_date:String = shipmentDict["ship_delivery_date"] as? String{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: ship_delivery_date){
                deliveryDateLabel.text = formattedDate
            }
        }
        
        
        if let trading_partner:NSDictionary = shipmentDict["trading_partner"] as? NSDictionary{
            
            if let name = trading_partner["name"]{
                tradingPartnerNameLabel.text = name as? String
            }
            
        }
        
        if let items:Array<Any> = shipmentDict["ship_lines_item"] as? Array<Any>{
            itemsArray = items
        }
        
        if let uuid:String = shipmentDict["uuid"] as? String{
            shipmentId = uuid
        }
        if let tempFailedArray = Utility.getObjectFromDefauls(key:  "\(self.shipmentId ?? "")_failedArray") as? [Dictionary<String, Any>]{
            self.failedSerials = tempFailedArray
        }
        if let tempVerifiedArray = Utility.getObjectFromDefauls(key:  "\(self.shipmentId ?? "")_verifiedArray") as? [Dictionary<String, Any>]{
            self.verifiedSerials = tempVerifiedArray
        }
        if let basicQuertArray = Utility.getObjectFromDefauls(key:  "\(self.shipmentId ?? "")_basicQueryResultArray") as? [Dictionary<String, Any>]{
            self.basicQueryResultArray = basicQuertArray
        }
        
        successVerCountLabel.text = "\(String(describing: self.verifiedSerials.count))"
        attemptVerCountLabel.text = "\(String(describing: self.failedSerials.count + self.verifiedSerials.count))"
    }
    func prepareDataForQuarantine(){
        if failedSerials.count>0 && basicQueryResultArray.count>0{
            if let shipmentData = defaults.object(forKey: ttrShipmentDetails){
                do{
                    let shipmentDict:NSDictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(shipmentData as! Data) as! NSDictionary
                    let requestDict = NSMutableDictionary()
                    
                    requestDict.setValue("QUARANTINE", forKey: "type")
                    if let uuid:String = shipmentDict["location_uuid"] as? String{
                        requestDict.setValue(uuid, forKey: "location_uuid")
                    }
                    requestDict.setValue("Product require QA test", forKey: "reason_text")
                    requestDict.setValue(shipmentId, forKey: "reference_num")
                    requestDict.setValue("Un-Verified Products", forKey: "notes")
                    
                    var itemsArray = [[String : Any]]()
                    for dict in failedSerials {
                        if let serial =  dict["serial"] as? String, !serial.isEmpty{
                            let filteredArray = basicQueryResultArray.filter { $0["gs1_serial"] as? String == serial }
                            if filteredArray.count > 0 {
                                let itemDict=filteredArray.first
                                let uniqueSerialArr = (filteredArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.gs1_serial") as? Array<Any>
                                var itemDict_request = [String : Any]()
                                itemDict_request["type"] = Product_Types.SerialBased.rawValue
                                itemDict_request["item_uuid"] = itemDict!["product_uuid"]
                                itemDict_request["serials"] = uniqueSerialArr
                                itemsArray.append(itemDict_request)
                            }
                        }
                    }
                    requestDict.setValue(Utility.json(from: itemsArray), forKey: "items")
                    //print("Request Data:\(requestDict)")
                    moveFailedItemsToQuarantine(requestData: requestDict)
                }catch{
//                    print("Shipment Data Not Found")
                }
            }
        }
    }
    
    func setup_stepview(){
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step3Button.isUserInteractionEnabled = true
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        
        if isFiveStep{
            
            step4Button.isUserInteractionEnabled = true
            step5Button.isUserInteractionEnabled = false
            step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        }else{
            step4Button.isUserInteractionEnabled = false
            step5Button.isUserInteractionEnabled = false
            step4Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        }
        
        
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
    
    func moveFailedItemsToQuarantine(requestData:NSMutableDictionary){
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "GetQuarantineList", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let new_adjustment_uuid = responseDict["new_adjustment_uuid"] as? String {
                        print(new_adjustment_uuid)
                    }
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let _ = responseDict["message"] as? String , let _ = responseDict["details"] as? String {
//                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else  if let _ = responseDict["message"] as? String {
//                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
//                            Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                        }
                    }else{
//                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }
    
    //MARK: - Local DB Functions
    private var jsonArray = [NSDictionary]()
    private var localTableData : Array<ReceiveLotEdit>?
    
    private func fetchFromLocalLotDB(){
        do {
            
            let fetchRequest = NSFetchRequest<ReceiveLotEdit>(entityName: "ReceiveLotEdit")
             
            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
            
            self.localTableData = serial_obj
            
            if !serial_obj.isEmpty{
                
                if let items = itemsArray{
                    
                    for item in items{
                        
                        let responseItem = item as? NSDictionary
                        
                        //TODO: - Making Array of Line Item Object
                        let jsonObject = NSMutableDictionary()
                        let shipment_line_item_uuid = responseItem?["shipment_line_item_uuid"] as? String ?? ""
                        
                        //TODO: - Making Array of Lots
                        var lotArray = [NSDictionary]()
                        
                        serial_obj.forEach { (lot) in
                            
                            let lotObject = NSMutableDictionary()
                            if lot.shipment_line_item_uuid == shipment_line_item_uuid{
                                
                                lotObject["lot_number"] = lot.lot_number
                                lotObject["quantity"] = Int(lot.quantity)
                                lotObject["expiration_date"] = lot.expiration_date
                                
                                lotArray.append(lotObject)
                            }
                        }
                        
                        //Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj.filter({$0.shipment_line_item_uuid == shipment_line_item_uuid}))
                        
                        jsonObject["shipping_line_item_uuid"] = shipment_line_item_uuid
                        
                        jsonObject["lots"] = lotArray
                        
                        jsonArray.append(jsonObject)
                        
                    }
                }
            }
            print(jsonArray)
            
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    private var jsonLineArray = [NSDictionary]()
    private var isOverRecieve = false
    private func fetchFromLocalLineItemDB(){
        do {
            
            let fetchRequest = NSFetchRequest<ReceiveLineItem>(entityName: "ReceiveLineItem")
             
            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
            
            if !serial_obj.isEmpty{
                
                //TODO: - Making obj Array
                var jsonObj = [NSDictionary]()
                
                serial_obj.forEach { item in
                    
                    let dictData = NSMutableDictionary()
                    dictData["line_item_uuid"] = item.shipment_line_item_uuid
                    dictData["quantity_receiving"] = Int(item.alloc_quantity).description
                    
                    jsonObj.append(dictData)
                }
                jsonLineArray = jsonObj
                
                if let items = itemsArray{
                    
                    let responseItem = items as? [NSDictionary]
                    
                    if let _ = responseItem?.firstIndex(where: {$0["unallocated_quantity"] as? Int ?? 0 > 0}){
                        
                        isOverRecieve = true
                    }
                }
            }
            print(jsonLineArray)
            
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    var lotCounter = 0
    func confirmShipment(){
        
        var requestDict = [String:Any]()
        requestDict["storage_area_uuid"] = storageNameLabel.accessibilityHint ?? ""
        requestDict["storage_shelf_uuid"] = shelfNameLabel.accessibilityHint ?? ""
        
        if isOverRecieve{
            
            if jsonLineArray.count == 0{
                
            }else{
                
                requestDict["is_allow_overreceiving"] = true
                requestDict["attached_line_item"] = Utility.json(from: jsonLineArray)
            }
        }
        print(requestDict)
        if let items = self.itemsArray{
            for item in items{
                if let itemm = item as? NSDictionary{
                    if let lots = itemm["lots"] as? Array<NSDictionary>{
                        if let _ = lots.first(where: {$0["lot_number"] as? String == ""}), jsonArray.count > 0{
                            requestDict["manual_lot_number_assignation"] = Utility.json(from: jsonArray)
                        }
                    }
                }
            }
        }
        let appendStr:String! =  "Inbound/" + (defaults.string(forKey: "shipmentId") ?? "") as String + "/set_shipment_verified"
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ConfirmShipment", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["uuid"] as? String {
                        defaults.removeObject(forKey: "\(self.shipmentId ?? "")_failedArray")
                        defaults.removeObject(forKey: "\(self.shipmentId ?? "")_verifiedArray")
                        defaults.removeObject(forKey: "\(self.shipmentId ?? "")_basicQueryResultArray")
                        //self.prepareDataForQuarantine()
                        if let items = self.itemsArray{
                            
                            for item in items{
                                
                                if let responseItem = item as? NSDictionary{
                                    
                                    let product_uuid = responseItem["uuid"] as? String ?? ""
                                    
                                    if let lots = responseItem["lots"] as? NSArray{
                                        
                                        for lot in lots{
                                            
                                            let responseLot = lot as? NSDictionary
                                            
                                            if let lotNo = responseLot?["lot_number"] as? String, lotNo != ""{
                                                
                                                let expDate = responseLot?["expiration_date"] as? String ?? ""
                                                if expDate == ""{
                                                    
                                                    var requestData = [String:Any]()
                                                    requestData["lot_number"] = lotNo
                                                    requestData["new_lot_number"] = lotNo
                                                    
                                                    var newAddedExpDate = String()
                                                    for item in self.jsonArray{
                                                        
                                                        if let lotArray = item["lots"] as? NSArray{
                                                            
                                                            for lotItem in lotArray{
                                                                
                                                                if let lot = lotItem as? NSDictionary{
                                                                    
                                                                    if lot["lot_number"] as? String == lotNo{
                                                                        
                                                                        newAddedExpDate = item["expiration_date"] as? String ?? ""
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    requestData["expiration_date"] = newAddedExpDate
                                                    
                                                    self.updateProductData(productUUID: product_uuid, requestData: requestData)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Shipment verified", InViewC: self, isPop: true, isPopToRoot: true)
                        return
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
    
    private func updateProductData(productUUID: String, requestData: [String:Any]){
        
        let appendStr = "\(productUUID)/lot"
        ///products/{product_uuid}/lot
        
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "UpdateProductLot", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    //                    if let _ = responseDict["uuid"] as? String {
                    //
                    //                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Lot Updated Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                    //                    }
                    
                    
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
    
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to cancel Receiving".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to confirm Receiving".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        if itemsArray != nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsView") as! ItemsViewController
            controller.itemsList = itemsArray
            controller.shipmentId = shipmentId
            controller.isfromSetLot = false
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No items found.".localized(), InViewC: self)
        }
    }
    
    @IBAction func viewMoreButtonPressed(_ sender: UIButton) {
        guard let controllers = self.navigationController?.viewControllers else { return }
        for  controller in controllers {
            if controller.isKind(of: ShipmentDetailsViewController.self){
                self.navigationController?.popToViewController(controller, animated: false)
            }
        }
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ShipmentDetailsViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentDetailsView") as! ShipmentDetailsViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2{
            
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: PurchaseOrderVC.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderVC") as! PurchaseOrderVC
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 3 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: SerialVerificationViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialVerificationView") as! SerialVerificationViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }else if sender.tag == 4 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: StorageSelectionViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "StorageSelectionView") as! StorageSelectionViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
        
        
    }
    //MARK: - End
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        confirmShipment()
    }
    func cancelConfirmation() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
}
