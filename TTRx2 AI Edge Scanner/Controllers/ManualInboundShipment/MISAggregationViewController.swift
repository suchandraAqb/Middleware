//
//  MISAggregationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 15/01/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISAggregationViewController: BaseViewController, MISAddAggregationScanViewControllerDelegate {
    
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
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var addAggregationButton: UIButton!
    
    @IBOutlet weak var noRecordLabel: UILabel!
    @IBOutlet weak var productAddedView : UIView!
    @IBOutlet weak var productAddedSubView : UIView!
    @IBOutlet weak var gtin14Label : UILabel!
    @IBOutlet weak var lotLabel : UILabel!
    @IBOutlet weak var serialLabel : UILabel!
    @IBOutlet weak var expirationDateLabel : UILabel!
    @IBOutlet weak var productNameTextFiled : UITextField!
    @IBOutlet weak var updateButton : UIButton!
    
    var scannedCodes: Set<String> = []

    var lineitemArr:Array<Any>?
    var itemsList:Array<Any>?
    var duplicateSerials = Array<String>()

    var oldSerials = [String]()
    var parentId:Int = 0
    var productType = ""

    var allScannedSerials = Array<String>()
    var verifiedSerials = [String]()
    var selectedProductDict:NSDictionary?
    var isOnlyLotBasedProduct :Bool = false
    var scannedCodeDetails = [String:Any]()
    var isfromLineitemNextClick : Bool = false
    var sdiArray = [String]()//,,,sb13 temp2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_initialview()
        addAggregationButton.setRoundCorner(cornerRadious: addAggregationButton.frame.height/2.0)
        updateButton.setRoundCorner(cornerRadious: updateButton.frame.height/2.0)
        productAddedSubView.setRoundCorner(cornerRadious: 20)
        createInputAccessoryView()
        productNameTextFiled.inputAccessoryView = inputAccView
        //self.getProductsTypesDetails()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        setupList()
        checkLineItemSDIExistInAggregation()//,,,sb13
    }
    
    
    //MARK: - Private Method
    func setup_initialview(){
        sectionView.roundTopCorners(cornerRadious: 40)
        productAddedView.isHidden = true
      
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        print(notification.userInfo as Any)
    }

    
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "MIS_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "MIS_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "MIS_3rdStep")
        let isFourthStepCompleted = defaults.bool(forKey: "MIS_4thStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step3Button.isUserInteractionEnabled = true
        step4Button.isUserInteractionEnabled = false
        step5Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted && isFourthStepCompleted {
            step5Button.isUserInteractionEnabled = true
        }
        
    }
    
       
    func removeaggregation(data:NSDictionary){
        if let id = data["id"] as? Int{
            var allid = [Int]()
            var complete = [Int]()
            allid.append(id)
            repeat {
                for tempId in allid {
                    if !complete.contains(tempId) {
                        complete.append(tempId)
                        do{
                            let predicate = NSPredicate(format:"parent_id='\(tempId)'")
                            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                            if !serial_obj.isEmpty{
                                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                for tempSubDetails in arr {
                                    if let dict = tempSubDetails as? NSDictionary {
                                        if let subid = dict["id"] as? Int{
                                            allid.append(subid)
                                        }
                                    }
                                }
                            }
                        }catch let error{
                            print(error.localizedDescription)
                        }
                    }
                }
            }while !allid.containsSameElements(as: complete)
            
            do{
                let predicate = NSPredicate(format:"id IN %@", allid)
                let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    for obj in serial_obj {
                        PersistenceService.context.delete(obj)
                        PersistenceService.saveContext()
                    }
                    setupList()
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
        
    func checkLineItemSDIExistInAggregation() {
        if (itemsList != nil) {
            do{
                if let aggregationSDIArr = (itemsList! as NSArray).value(forKeyPath: "@distinctUnionOfObjects.sdi") as? [String] {
                    for i in 0..<aggregationSDIArr.count {
                        let sdi = aggregationSDIArr[i]
                        let predicate = NSPredicate(format:"sdi = '\(sdi)' ")
                        let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                        if serial_obj.isEmpty{
                            //remove
                            do{
                                let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                                if !serial_obj.isEmpty{
                                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                    for dict in arr {
//                                        self.removeaggregation(data: arr[0] as! NSDictionary)
                                        self.removeaggregation(data: dict as! NSDictionary)
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
        }
    }//,,,sb13
    
    func setupList(){
        
        do{
            let predicate = NSPredicate(format:"parent_id='0'")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                itemsList = arr
                listTable.reloadData()
                self.noRecordLabel.isHidden = true
            }else{
                itemsList = nil
                listTable.reloadData()
                self.noRecordLabel.isHidden = false
            }
        }catch let error{
            print(error.localizedDescription)
            itemsList = nil
            listTable.reloadData()
            self.noRecordLabel.isHidden = false
            
        }
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                lineitemArr = arr
            }else{
                lineitemArr = nil
            }
        }catch let error{
            print(error.localizedDescription)
            lineitemArr = nil
        }
        if (defaults.object(forKey: "lineItemCheck") != nil){
        if ((defaults.object(forKey: "lineItemCheck")) as! Int == 1) && isfromLineitemNextClick {
            isfromLineitemNextClick = false
            self.AddAggregationButtonPressed(UIButton())
          }
       }
    }
    func getLotItemDetails(sdi:String) -> NSDictionary{
        //,,,sb13
//        var tempLotItemDetails:NSDictionary?
        var tempLotItemDetails:NSDictionary? = [String:Any]() as NSDictionary
        //,,,sb13
        do{
            let predicate = NSPredicate(format:"sdi='\(sdi)'")
            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                if let dict = arr.first as? NSDictionary {
                    tempLotItemDetails = dict
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        return tempLotItemDetails!//,,,defect
    }
    
    func getProductName(misitem_id: Int) -> String {
        var tempProductName = ""
        do{
            let predicate = NSPredicate(format:"id='\(misitem_id)'")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                if let dict = arr.first as? NSDictionary {
                    if let txt = dict["product_name"] as? String,!txt.isEmpty{
                        tempProductName = txt
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        return tempProductName
    }
    
    func lineItemAggregationMatch(sdi: String, linelotType:String, linequantity:Int)-> Bool{
        var ismatch = true
        var count = 0
        var type = ""
        do{
            let predicate = NSPredicate(format:"sdi = '\(sdi)' ")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                for aggregation in arr {
                    if let aggregationdict = aggregation as? NSDictionary {
                        
                        var lot_based_quantity = 0
                        if let txt = aggregationdict["lot_based_quantity"] as? Int{
                            lot_based_quantity = txt
                        }
                        
                        if lot_based_quantity > 0 {
                            type = "LOT_BASED"
                            count = count + lot_based_quantity
                        }else{
                            type = "SERIAL_BASED"
                            count = arr.count
                            break
                        }
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
            
        }
        
        if linelotType != type {
            ismatch = false
        }
        
        if count != linequantity {
            ismatch = false
        }
        
        
        return ismatch
    }
    
    func getSubAggregationCount(parent_id:String) -> Int {
        var count = 0
        do{
            let predicate = NSPredicate(format:"parent_id='\(parent_id)'")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                count = serial_obj.count
            }
        }catch let error{
            print(error.localizedDescription)
        }
        return count
    }
    
    func checkLineItemLotType() -> NSMutableArray {
        let lotTypeArray = [] as NSMutableArray
        
        //Check Lot Types of Line Item
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty {
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
//                print("arr....>>>>",arr)
                
                for tempSubDetails in arr {
                    if let lineItemDict = tempSubDetails as? NSDictionary {
                        let lot_type = lineItemDict["lot_type"] as? String
                        if lot_type == "SERIAL_BASED" || lot_type == "FOUND" {
                            lotTypeArray.add("SERIAL_BASED")
                        }
                        else if lot_type == "LOT_BASED" || lot_type == "LOT_FOUND" {
                            lotTypeArray.add("LOT_BASED")
                        }
                        else {
                            lotTypeArray.add("")
                        }
                    }
                }
            }
            else {
//                print("serial_obj empty....>>>>")
            }
            
        }catch let error {
            print(error.localizedDescription)
        }
        
        return lotTypeArray
    }//,,,sb12
    
    
    func getLineItemSerialBasedDataOnly() -> Array<Any> {
        var serialBasedArray = [] as Array<Any>
        
        //Get Serial Based Data from Line Item
        do{
//            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let predicate = NSPredicate(format:"lot_type='SERIAL_BASED' || lot_type='FOUND'")

            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty {
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                serialBasedArray = arr
            }
            else {
//                print("serial_obj empty....>>>>")
            }
            
        }catch let error {
            print(error.localizedDescription)
        }
        
        return serialBasedArray
    }//,,,sb12
    
    func containerValidation() -> Bool {
        var isValidated = true
        //Check Empty Container
        do {
            let predicate = NSPredicate(format:"type = 'container'")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                for tempSubDetails in arr {
                    if let dict = tempSubDetails as? NSDictionary {
                        if let subid = dict["id"] as? Int{
                            if getSubAggregationCount(parent_id: "\(subid)") == 0 {
                                Utility.showPopup(Title: App_Title, Message: "Please Fill all Container.".localized(), InViewC: self)
                                isValidated = false
                                break
                            }
                        }
                    }
                }
            }
        }catch let error {
            print(error.localizedDescription)
        }
       
        return isValidated
        
    }//,,,sb12
    
    func aggregationValidation() -> Bool{
        var isValidated = true
        //Check Empty Container
        do{
            let predicate = NSPredicate(format:"type = 'container'")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                for tempSubDetails in arr {
                    if let dict = tempSubDetails as? NSDictionary {
                        if let subid = dict["id"] as? Int{
                            if getSubAggregationCount(parent_id: "\(subid)") == 0 {
                                Utility.showPopup(Title: App_Title, Message: "Please Fill all Container.".localized(), InViewC: self)
                                isValidated = false
                                break
                            }
                        }
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
       
        //Line Item Aggregation Match
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                for tempSubDetails in arr {
                    if let lineItemDict = tempSubDetails as? NSDictionary {
                        if let sdi = lineItemDict["sdi"] as? String, !sdi.isEmpty, let lot_type = lineItemDict["lot_type"] as? String, !lot_type.isEmpty, let quantity = lineItemDict["quantity"] as?Int {
                            if (defaults.object(forKey: "lineItemCheck") != nil) {
//                              if((defaults.object(forKey: "lineItemCheck")) as! Int == 0){
                                var lot_type_details = lot_type
                                if lot_type == "FOUND" ||  lot_type == "SERIAL_BASED"{
                                    lot_type_details = "SERIAL_BASED"
                                }else{
                                    lot_type_details = "LOT_BASED"
                                }
                                if !lineItemAggregationMatch(sdi: sdi, linelotType: lot_type_details, linequantity: quantity) {
                                    Utility.showPopup(Title: App_Title, Message: "Mismatch between the Line Items and the Aggregation Data.".localized(), InViewC: self)
                                        isValidated = false
                                        break
                                        }
                                    }
//                                }
                            }
                        }
                    }
                }
            
        }catch let error{
            print(error.localizedDescription)
        }
        return isValidated
        
    }
    
    func checkingAggregation(container_content:[String:Any],productName:String,productGtint14:String){
        var isexistonLineitem :Bool = false
        print(container_content as Any)
        
            if let scanProductudid = container_content["product_uuid"]as? String,!scanProductudid.isEmpty {
                do{
                     let predicate = NSPredicate(format:"product_uuid='\(scanProductudid)'")
                     let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
                     if !serial_obj.isEmpty{
                        if let scanProductlotid = container_content["lot_number"]as? String,!scanProductlotid.isEmpty {
                        do{
                            let predicate = NSPredicate(format:"lot_number='\(scanProductlotid)'")
                            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                            if !serial_obj.isEmpty{
                                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                isexistonLineitem = true
                                self.addAggregation(selectedProductLotDict: (container_content as NSDictionary),selectLineitem: (arr[0] as! NSDictionary))
                            }else{
                                if (defaults.object(forKey: "lineItemCheck") != nil) {
                                    if((defaults.object(forKey: "lineItemCheck")) as! Int == 0){
                                        if lineitemArr?.count == nil {
                                            Utility.showAlertWithPopAction(Title: Warning, Message: "Data not present in line items".localized(), InViewC: self, isPop: true, isPopToRoot: false)

                                        }else{
                                            Utility.showAlertWithPopAction(Title: Warning, Message: "Mismatch between the Line Items and the Aggregation Data".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                                         }
                                      }
                                  }
                               }
                           }
                        }else{
                            Utility.showAlertWithPopAction(Title: Warning, Message: "Product Lot number not found".localized(), InViewC: self, isPop: true, isPopToRoot: false)

                        }
                     }else{
                        if (defaults.object(forKey: "lineItemCheck") != nil) {
                            if ((defaults.object(forKey: "lineItemCheck")) as! Int == 0) {
                                if lineitemArr?.count == nil {
                                    Utility.showAlertWithPopAction(Title: Warning, Message: "Data not present in line items".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                                }else{
                                    Utility.showAlertWithPopAction(Title: Warning, Message: "Mismatch between the Line Items and the Aggregation Data".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                                    }
                                }
                            }else{
                                if lineitemArr?.count == nil {
                                    Utility.showAlertWithPopAction(Title: Warning, Message: "Data not present in line items".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                            }
                        }
                     }
                }catch let error{
                    print(error.localizedDescription)
                }
            }else{
                Utility.showAlertWithPopAction(Title: Warning, Message: "Product UUID not found".localized(), InViewC: self, isPop: true, isPopToRoot: false)
            }
        
        let scanProductlotid = container_content["lot_number"]as? String
        let scanProductudid = container_content["product_uuid"]as? String
        
        if scanProductudid!.isEmpty || scanProductlotid!.isEmpty{
            Utility.showAlertWithPopAction(Title: Warning, Message: "Product details or lot number not found".localized(), InViewC: self, isPop: true, isPopToRoot: false)
        }else{
            if (defaults.object(forKey: "lineItemCheck") != nil) {
                if !isexistonLineitem && (defaults.object(forKey: "lineItemCheck") ?? 1) as! Bool{
                    let quantity = 1
                    let udid = container_content["product_uuid"] as! String
                    let productname = productName
                    let gtin14 = productGtint14

                    self.addProductforLine(product_uuid: udid, product_name: productname, gtin14: gtin14 , quantity: Int16(quantity),container_content: container_content)
                }
            }
        }
    }
    func addProductforLine(product_uuid:String, product_name:String, gtin14:String, quantity:Int16,container_content:[String:Any]){
        let obj = MISItem(context: PersistenceService.context)
        obj.product_uuid = product_uuid
        obj.product_name = product_name
        obj.gtin14 = gtin14
        obj.quantity = quantity
        obj.id = getAutoIncrementId()
        PersistenceService.saveContext()
        self.addProductforLineLot(container_content:container_content)

    }
    func addProductforLineLot(container_content:[String:Any]){
        //        if let misitem_id = container_content["id"] as? Int16 {
                    
                    let obj = MISLotItem(context: PersistenceService.context)
                    
                    obj.id = getAutoIncrementId()
                    obj.misitem_id = obj.id
                    obj.lot_number = container_content["lot_number"] as? String
                    obj.best_by_date = ""
                    obj.expiration_date = container_content["expiration_date"] as? String
                    obj.production_date =  ""
                    obj.sell_by_date = ""
                    obj.quantity = 1
                    obj.lot_type = container_content["product_type"] as? String
                    obj.sdi = String(obj.id)
                    PersistenceService.saveContext()
                    self.checkingLineItemAggregation(container_content: container_content)

        //            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Lot Added".localized(), InViewC: self, isPop: false, isPopToRoot: false)
                    }
    func checkingLineItemAggregation(container_content:[String:Any]){
        print(container_content as Any)
        
        if let scanProductudid = container_content["product_uuid"]as? String,!scanProductudid.isEmpty {
        do{
             let predicate = NSPredicate(format:"product_uuid='\(scanProductudid)'")
             let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
             if !serial_obj.isEmpty{
                if let scanProductlotid = container_content["lot_number"]as? String,!scanProductlotid.isEmpty {
                do{
                    let predicate = NSPredicate(format:"lot_number='\(scanProductlotid)'")
                    let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                    if !serial_obj.isEmpty{
                        let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                        self.addAggregation(selectedProductLotDict: (container_content as NSDictionary),selectLineitem: (arr[0] as! NSDictionary))
                    }else{
                        if (defaults.object(forKey: "lineItemCheck") != nil) {
                            if((defaults.object(forKey: "lineItemCheck")) as! Int == 0){
                                Utility.showAlertWithPopAction(Title: Warning, Message: "Mismatch between the Line Items and the Aggregation lot Data".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                            }
                        }
                     }
                   }
                }
             }else{
                if (defaults.object(forKey: "lineItemCheck") != nil) {
                    if ((defaults.object(forKey: "lineItemCheck")) as! Int == 0) {
                        Utility.showAlertWithPopAction(Title: Warning, Message: "Mismatch between the Line Items and the Aggregation Data".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }
             }
        }catch let error{
            print(error.localizedDescription)
            }
        }
    }
    func checkingLineItemAggregationAndRemove(container_content:[String:Any]){
        if let id = container_content["id"] {
            do{
                let predicate = NSPredicate(format:"id='\(id)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
                if  serial_obj.isEmpty{
                    do{
                        let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                        if !serial_obj.isEmpty{
                            for obj in serial_obj {
                                PersistenceService.context.delete(obj)
                                PersistenceService.saveContext()
                            }
                            setupList()
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                    
                }
        }catch let error{
            print(error.localizedDescription)
            }
        }
    }

//    }
//        print(lineitemArr as Any)
//        var isvalid = false
//
//        if lineitemArr!.count>0 {
//            if let scanProductudid = container_content["uuid"]as? String,!scanProductudid.isEmpty {
//            for lineDict in lineitemArr! {
//                if let lineDetailsDict = lineDict as? NSDictionary {
//                    if let lineudid = lineDetailsDict["product_uuid"] as? String,!lineudid.isEmpty {
//                        if lineudid == scanProductudid{
//                            isvalid = true
//                            self.getlotDetails(productDict: lineDict as! NSDictionary)
//                         }
//                       }
//                    }
//                }
//                if !isvalid {
//                    Utility.showAlertWithPopAction(Title: Warning, Message: "Not match to the line items".localized(), InViewC: self, isPop: true, isPopToRoot: false)
//                }
//            }
//        }
//    }
//    func getlotDetails(productDict:NSDictionary){
//        var isvalid = false
//
//        if let misitem_id = productDict["id"] as? Int16 {
//            do{
//                let predicate = NSPredicate(format:"misitem_id='\(misitem_id)'")
//                let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
//
//
//                if !serial_obj.isEmpty{
//                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
//                    itemsList = arr
//                    if itemsList!.count>0 {
//                        if let scanProductlotid = productDict["lot_id"]as? String,!scanProductlotid.isEmpty {
//                        for lineDict in itemsList! {
//                            if let lineDetailsDict = lineDict as? NSDictionary {
//                                if let linelotid = lineDetailsDict["lot_id"] as? String,!linelotid.isEmpty {
//                                    if linelotid == scanProductlotid{
//                                        isvalid = true
//                                        self.addAggregation(selectedProductDict: productDict, selectedProductLotDict: lineDetailsDict)
//                                        listTable.reloadData()
//                                        }
//                                    }
//                                }
//                            }
//                            if !isvalid {
//                                Utility.showAlertWithPopAction(Title: Warning, Message: "Not match to the lot number ".localized(), InViewC: self, isPop: true, isPopToRoot: false)
//                            }
//                        }
//                    }
//                }else{
//                    itemsList = nil
//                    listTable.reloadData()
//                }
//            }catch let error{
//                print(error.localizedDescription)
//                itemsList = nil
//                listTable.reloadData()
//
//            }
//        }
//
//    }
    func addAggregation (selectedProductLotDict:NSDictionary?,selectLineitem:NSDictionary?){
        var isvalidate = true
        var quantity = 0

        if let lot_type = selectLineitem?["lot_type"] as? String,!lot_type.isEmpty, let sdi = selectLineitem?["sdi"] as? String,!lot_type.isEmpty, let tmp_quantity = selectLineitem?["quantity"] as? Int{
                
                let oldCount = getaggregationCount(sdi: sdi)
                
                //,,,sb12
                /*
                if oldCount == tmp_quantity {
                    Utility.showPopup(Title: App_Title, Message: "This Product Lot already in Aggregation".localized(), InViewC: self)
                    isvalidate = false
                }
                */
                let createNew = defaults.bool(forKey: "MIS_create_new")
                if createNew {
                    //Create a Purchase Order based from the Shipment
                    if oldCount == tmp_quantity {
                        Utility.showPopup(Title: App_Title, Message: "This Product Lot already in Aggregation".localized(), InViewC: self)
                        isvalidate = false
                    }
                }
                //,,,sb12
                
                
                if lot_type == "SERIAL_BASED" || lot_type == "FOUND" {
                    
                    if verifiedSerials.count == 0 {
                        Utility.showPopup(Title: App_Title, Message: "Please scan Product serial".localized(), InViewC: self)
                        isvalidate = false
                    }
                    
                    //,,,sb12
                    /*
                    if verifiedSerials.count > (tmp_quantity - oldCount) {
                        Utility.showPopup(Title: App_Title, Message: "Serial count must not be greater than bought quantity".localized(), InViewC: self)
                        isvalidate = false
                    }*/
                    
                    let createNew = defaults.bool(forKey: "MIS_create_new")
                    if createNew {
                        //Create a Purchase Order based from the Shipment
                        if verifiedSerials.count > (tmp_quantity - oldCount) {
                            Utility.showPopup(Title: App_Title, Message: "Serial count must not be greater than bought quantity".localized(), InViewC: self)
                            isvalidate = false
                        }
                    }
                    //,,,sb12
                    
                    if isvalidate {
                        for serial in verifiedSerials {
                            
                            let serialProductobj = MISAggregation(context: PersistenceService.context)
                           // serialProductobj.gs1_barcode = (selectedProductLotDict!["gs1_barcode"] as! String)
                            if (selectedProductLotDict!["gs1_urn"] != nil){
                                serialProductobj.gs1_serial = (selectedProductLotDict!["gs1_urn"] as! String)
                            }
                            serialProductobj.parent_id = Int16(parentId)
                            serialProductobj.id = getAutoIncrementId()
                            serialProductobj.type = "product"
                            serialProductobj.sdi = sdi
                            serialProductobj.serial = serial
                            PersistenceService.saveContext()
                        }
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        self.setupList()

                    }
                }else if lot_type == "LOT_BASED" || lot_type == "LOT_FOUND" {
                    quantity = tmp_quantity
                    
                    //,,,sb12
            //        if quantity == 0 {
                    if quantity <= 0 {
                    //,,,sb12
                        
                        Utility.showPopup(Title: App_Title, Message: "Please enter quantity.".localized(), InViewC: self)
                        isvalidate = false
                    }
                    
                    //,,,sb12
                    /*
                    if quantity > (tmp_quantity - oldCount){
                        Utility.showPopup(Title: App_Title, Message: "Required quantity must not be greater than bought quantity.".localized(), InViewC: self)
                        isvalidate = false
                    }
                    */
                    let createNew = defaults.bool(forKey: "MIS_create_new")
                    if createNew {
                        //Create a Purchase Order based from the Shipment
                        if quantity > (tmp_quantity - oldCount){
                            Utility.showPopup(Title: App_Title, Message: "Required quantity must not be greater than bought quantity.".localized(), InViewC: self)
                            isvalidate = false
                        }
                    }
                    //,,,sb12
                    
                    if isvalidate {
                        let lotProductobj = MISAggregation(context: PersistenceService.context)
                        
                      //  lotProductobj.gs1_barcode = (selectedProductLotDict!["gs1_barcode"] as! String)
                        lotProductobj.gs1_serial = (selectedProductLotDict!["gs1_urn"] as! String)
                        lotProductobj.parent_id = Int16(parentId)
                        lotProductobj.id = getAutoIncrementId()
                        lotProductobj.type = "product"
                        lotProductobj.sdi = sdi
                        lotProductobj.lot_based_quantity = Int16(quantity)
                        PersistenceService.saveContext()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        self.setupList()
                    }
                }
            }
    }
    func addAggregationWithContainer(containerDict:NSDictionary?){
        //,,,sb13
        /*
        let gs1Serial = containerDict!["gs1_urn"] as! String
        let simpleSerial = ""
        */
        print ("containerDict...MISAggregationViewController",containerDict!)
        
        var gs1Serial = ""
        var simpleSerial = ""
        
        if let gs1_urn = containerDict!["gs1_urn"]as? String,!gs1_urn.isEmpty {
            gs1Serial = gs1_urn
        }
        else {
            if let serial_number = containerDict!["serial_number"]as? String,!serial_number.isEmpty {
                simpleSerial = serial_number
            }
        }
        //,,,sb13
        
        
//    if let txt = simpleSerialTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
//        simpleSerial = txt
//    }
//        var quantity = 0
//        if let txt = quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
//            quantity = Int(txt) ?? 0
//        }
    
    var isvalidate = true
    productType = containerDict!["type"] as! String
    
    if productType == "container" || productType == "CONTAINER"  {
    
        var tempserialkey = ""
        
        if (gs1Serial == "" && simpleSerial == "") || (gs1Serial != "" && simpleSerial != ""){
            Utility.showPopup(Title: App_Title, Message: "Please select either GS1 Serial or Simple Serial".localized(), InViewC: self)
            isvalidate = false
        }else if gs1Serial != "" {
            tempserialkey = "gs1Serial"
        }else if simpleSerial != "" {
            tempserialkey = "simpleSerial"
        }
        
        if isvalidate {
            
            let containerobj = MISAggregation(context: PersistenceService.context)
            
            if tempserialkey == "gs1Serial" {
                containerobj.gs1_serial = gs1Serial
            }else if tempserialkey == "simpleSerial"{
                containerobj.serial = simpleSerial
            }
                        
            containerobj.parent_id = Int16(parentId)
            containerobj.id = getAutoIncrementId()
            containerobj.type = "container"
            PersistenceService.saveContext()
            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: false, isPopToRoot: false)
            }
            self.setupList()
        }
    }
    func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchAutoIncrementId())
            if !serial_obj.isEmpty{
                if let obj = serial_obj.first {
                    autoId = obj.id + Int16(1)
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        return autoId
    }
    func getaggregationCount(sdi: String) -> Int{
        var count = 0
        do{
            let predicate = NSPredicate(format:"sdi = '\(sdi)' ")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                for aggregation in arr {
                    if let aggregationdict = aggregation as? NSDictionary {
                        
                        var lot_based_quantity = 0
                        if let txt = aggregationdict["lot_based_quantity"] as? Int{
                            lot_based_quantity = txt
                        }
                        
                        if lot_based_quantity > 0 {
                            count = count + lot_based_quantity
                        }else{
                            count = arr.count
                            break
                        }
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
            
        }
        return count
    }

    func clickOnCamera(){
//        if(defaults.bool(forKey: "IsMultiScan")){
////            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
////            controller.delegate = self
////            controller.isForReceivingSerialVerificationScan = true
////            self.navigationController?.pushViewController(controller, animated: true)
//    }else{
        DispatchQueue.main.async {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller.delegate = self
        controller.isFromAggregation = true
        self.navigationController?.pushViewController(controller, animated: true)
        }
//        }
    }
    func didClickOnSearchByManually(parentId parent_Id:Int){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddAggregationView") as! MISAddAggregationViewController
        controller.parentId = 0
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func callApiForGS1BarcodeLookupDetails(scannedCode: [String],productname:String,productGtIn14:String){

        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        if first.count > 0 {
            self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedCode: scannedCode,productname: productname,productgtIn14: productGtIn14)
            self.showSpinner(onView: self.view)
        }else if duplicateSerials.count>0{
            duplicateSerials = []
            Utility.showPopup(Title: App_Title, Message: "Serial(s) already scanned.".localized(), InViewC: self)
            return
        }else{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self)
            return
        }
    }
    func addUpdateSerialsToDB(scannedCode: [String]){
        for data in scannedCode {
            let details = UtilityScanning(with:data).decoded_info
            if details.count > 0 {
            do{
                let predicate = NSPredicate(format:"gs1_barcode='\(data)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                if serial_obj.isEmpty{
                    
                    //,,,sb13 temp1
//                    self.allScannedSerials.append(data)
                    
                    self.allScannedSerials = []
                    if !self.allScannedSerials.contains(data) {
                        self.allScannedSerials.append(data)
                    }
                    //,,,sb13 temp1
                    
                }else{
                    duplicateSerials.append(data)
                    print("Existing Serial Fetched")
                    continue
                }
            }catch let error{
                print(error.localizedDescription)
                
             }
            }
        }
        
    }
    func getProductsTypesDetails(){
        
            let appendStr = ""
            
            Utility.GETServiceCall(type: "ProductsTypes", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    if isDone! {
                    }
                }
            }
        
    }
    func getGS1BarcodeLookupDetails(serials : String,scannedCode:[String],productname:String,productgtIn14:String){
        
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?barcode=\(str ?? "")&check_inventory=true"
            
            Utility.GETServiceCall(type: "barcodedecoder", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{ [self] in
                    if isDone! {
                        let responsedict: NSDictionary = responseData as! NSDictionary //as? NSArray ?? NSArray()
                        print(responsedict as NSDictionary)
                        selectedProductDict = responsedict
                        
                        if let inventoryData:NSDictionary = selectedProductDict!["inventory_data"] as? NSDictionary {
                            if(inventoryData["is_serial_known"] != nil){
                               let serialKnown = inventoryData["is_serial_known"] as! Bool
                                  if (serialKnown == true) {
                                    self.removeSpinner()
                                    Utility.showPopup(Title: App_Title, Message: "Product already exist in inventory", InViewC: self)
                                    return
                                }
                            }
                        }//,,,sb13 add extra closing bracket
                            
                        if let scanProductType = selectedProductDict!["type"]as? String,!scanProductType.isEmpty {
                            if scanProductType == "PRODUCT" || scanProductType == "product"{
                                self.serialVerify(scannedCode: scannedCode)
                                var productName = ""
                                if let allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                                    if !allproducts.isEmpty  {
                                        let filteredArray = allproducts.filter { $0["gtin14"] as? String == (selectedProductDict!["gtin14"] as! String) }
                                                print(filteredArray as Any)
                                                if filteredArray.count > 0 {
                                                    productName = (filteredArray.first?["name"] as? String)!
                                                }
                                        
                                    }
                                }
                                self.checkingAggregation(container_content: selectedProductDict as! [String : Any],productName:productName,productGtint14: productgtIn14)
                            }else if scanProductType == "CONTAINER" || scanProductType == "container"{
                                    self.addAggregationWithContainer(containerDict: selectedProductDict)
                            }
                        }else {
                                Utility.showPopup(Title: App_Title, Message: "Something went wrong.Barcode not specify either it is container or product.".localized() , InViewC: self)
                        }
    //                        }//,,,sb13 comment extra closing bracket
                    }else {
                        if responseData != nil{
                            let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                            let errorMsg = responseDict["message"] as? String ?? ""
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                    }
                    
                    self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
                    
                    let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
                    
                    if first.count > 0 {
                        self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedCode: scannedCode,productname: productname,productgtIn14: productgtIn14)
                    }else{
                        self.removeSpinner()
                    }
                }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
        
    }
    func serialVerify(scannedCode: [String]){
        
        var tempGTIN = ""
        var tempLot = ""
        var tempProductName = ""
        if selectedProductDict != nil{
            if let gtin = selectedProductDict?["gtin14"] as? String,!gtin.isEmpty, let productName = selectedProductDict?["product_name"] as? String,!productName.isEmpty{
                
                tempGTIN = gtin
                tempProductName = productName
            }
        }
        
        if selectedProductDict != nil{
            if let lot_number = selectedProductDict?["lot_number"] as? String,!lot_number.isEmpty {
                
                tempLot = lot_number
            }
        }
        for data in scannedCode {
            
            let details = UtilityScanning(with:data).decoded_info
            if details.count > 0 {
                if(details.keys.contains("01")) && (details.keys.contains("10")) && (details.keys.contains("21")){
                    if let _ = details["01"]?["value"] as? String, let _ = details["10"]?["value"] as? String, let serial = details["21"]?["value"] as? String{
//                        if gtin14 != tempGTIN {
//                            Utility.showPopup(Title: App_Title, Message: "Please scan \(tempProductName) serial".localized(), InViewC: self)
//                            break
//                        }
//
//                        if lot != tempLot {
//                            Utility.showPopup(Title: App_Title, Message: "Please scan \(tempProductName) and \(tempLot) serial".localized(), InViewC: self)
//                            break
//                        }
                        verifiedSerials = [String]()
                        verifiedSerials.append(serial)
                        }
                    }else{
                        if(details.keys.contains("01")) && (details.keys.contains("21")){
                            if let _ = details["01"]?["value"] as? String, let serial = details["21"]?["value"] as? String{
                                verifiedSerials = [String]()
                                verifiedSerials.append(serial)
                            }
                        }
                    }
                }
            }
        
    }
    func checkLotBased(){
            do{
                let predicate = NSPredicate(format:"lot_type='LOT_BASED' || lot_type='LOT_FOUND'")
                let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                    if arr.count == itemsList?.count {
                        isOnlyLotBasedProduct = true
                    }else{
                        isOnlyLotBasedProduct = false
                    }
                }else{
                    isOnlyLotBasedProduct = false
                }
            }catch let error{
                print(error.localizedDescription)
                isOnlyLotBasedProduct = false
            }
        
    }
    func setUpforProduct(){
        
        let requestDict = NSMutableDictionary()
        requestDict.setValue("Pharmaceutical", forKey: "type")
        requestDict.setValue("AVAILABLE", forKey: "status")
        requestDict.setValue(true, forKey: "is_active")
        requestDict.setValue(false, forKey: "is_send_copy_outbound_shipments_to_2nd_party")
        requestDict.setValue(false, forKey: "is_override_products_packaging_type_validation")
        requestDict.setValue(gtin14Label.text, forKey: "gtin14")
        
        
        let dict = NSMutableDictionary()
        let arr = [] as NSMutableArray
        dict.setValue("en", forKey: "language_code")
        dict.setValue(productNameTextFiled.text, forKey: "name")
        dict.setValue("", forKey: "description")
        dict.setValue("", forKey: "composition")
        dict.setValue("", forKey: "product_long_name")
        arr.add(dict)
        requestDict.setValue(Utility.json(from: arr) ,forKey: "product_descriptions")
        self.productApiCall(requestDict: requestDict)
    }
    func productApiCall(requestDict : NSDictionary){
        DispatchQueue.main.async { [self] in
            productAddedView.isHidden = true
            self.showSpinner(onView: self.view)
        }
        Utility.POSTServiceCall(type: "AddNewProduct", serviceParam: requestDict, parentViewC: self, willShowLoader: false, viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async { [self] in
                self.removeSpinner()
                if isDone! {
                scannedCodes = []
                scannedCodes.insert(scannedCodeDetails["scannedCode"] as! String)
                self.addUpdateSerialsToDB(scannedCode: Array(scannedCodes))
                DispatchQueue.main.async{
                    self.callApiForGS1BarcodeLookupDetails(scannedCode: Array(self.scannedCodes),productname: productNameTextFiled.text! as String ,productGtIn14: gtin14Label.text! as String)
                }
            
            }else{
                let dict = responseData as! NSDictionary
                let error = dict["message"] as! String
                    Utility.showPopup(Title: App_Title, Message:error , InViewC: self)
                }
            }
        }
    }

    //MARK: - End

    //MARK: - IBAction
    @IBAction func arrowButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISViewAggregationView") as! MISViewAggregationViewController
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            controller.selectDict = dict
        }
        controller.lineitemArr = lineitemArr
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let msg = "You are about to delete the resource.".localized() + "\n" + "This operation can’t be undone.".localized() + "\n\n" + "Proceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            if let dict = self.itemsList![sender.tag] as? NSDictionary {
                self.removeaggregation(data: dict)
            }
            
            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func AddAggregationButtonPressed(_ sender: UIButton) {
       
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddAggregationScanView") as! MISAddAggregationScanViewController
        controller.delegate = self
        controller.lineItemArr = lineitemArr
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
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
                                    
                                    if (!sdiArray.contains(sdi)) {
                                        sdiArray.append(sdi)
                                    }//,,,sb13 temp2
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
    }//,,,sb13 temp2
        
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        //,,,sb12
        /*
        self.checkLotBased()
        
        if isOnlyLotBasedProduct{
            defaults.set(true, forKey: "MIS_4thStep")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }else{
            if !aggregationValidation(){
                return
            }
            if ((lineitemArr?.count) == nil) {
                Utility.showPopup(Title: App_Title, Message: "Line item must be filled up.".localized() , InViewC: self)
                return
            }
            if ((itemsList?.count) == nil) {
                Utility.showPopup(Title: App_Title, Message: "Aggregation data must be filied up".localized() ,InViewC: self)
            }
//        if lineitemArr?.count != itemsList?.count {
//            Utility.showPopup(Title: App_Title, Message: "Mismatch between the line items and data aggregation".localized(), InViewC: self)
//        }
            defaults.set(true, forKey: "MIS_4thStep")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }
        */
        
        let createNew = defaults.bool(forKey: "MIS_create_new")
        if createNew {
            //Create a Purchase Order based from the Shipment

            self.checkLotBased()
            
            if isOnlyLotBasedProduct{
                defaults.set(true, forKey: "MIS_4thStep")
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
                self.navigationController?.pushViewController(controller, animated: false)
            }else{
                if !aggregationValidation(){
                    return
                }
                if ((lineitemArr?.count) == nil) {
                    Utility.showPopup(Title: App_Title, Message: "Line item must be filled up.".localized() , InViewC: self)
                    return
                }
                if ((itemsList?.count) == nil) {
                    Utility.showPopup(Title: App_Title, Message: "Aggregation data must be filied up".localized() ,InViewC: self)
                }
    //        if lineitemArr?.count != itemsList?.count {
    //            Utility.showPopup(Title: App_Title, Message: "Mismatch between the line items and data aggregation".localized(), InViewC: self)
    //        }
                defaults.set(true, forKey: "MIS_4thStep")
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
                self.navigationController?.pushViewController(controller, animated: false)
            }
        }
        else {
            //Select an existing Purchase Order

            //Check Previous line item array
            if !containerValidation() {
                return
            }//,,,sb12
            if ((lineitemArr?.count) == nil) {
                Utility.showPopup(Title: App_Title, Message: "Line item must be filled up.".localized() , InViewC: self)
                return
            }
            else {
                //Check lot type
                let arr = self.checkLineItemLotType()
                let filterArray = arr.filter { ($0 as! String).contains("LOT_BASED") }
//                print("arr....",arr,arr.count)

                if (arr.count > 0 && filterArray.count ==  arr.count) {
                    //Lot based Data Only
                    //Pass Confirmation
                    defaults.set(true, forKey: "MIS_4thStep")
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
                    self.navigationController?.pushViewController(controller, animated: false)
                }
                else {
                    if arr.contains("") {
                        Utility.showPopup(Title: App_Title, Message: "Something went wrong.".localized() ,InViewC: self)
                    }
                    else {
                        //Serial Based Or Mixed (Serial Based and Lot Based)
                        if ((itemsList?.count) == nil) {
                            Utility.showPopup(Title: App_Title, Message: "Aggregation data must be filied up for serial based data.".localized() ,InViewC: self)
                        }
                        else {
                            
//                            //,,,sb13 temp2
//                            let filteredArray = (itemsList! as? [[String: Any]])!.filter { $0["type"] as? String == "container" }
//                            if filteredArray.count > 0 {

                            sdiArray = []
                                let agg:[[String : Any]] = getAggregationData(id: 0) //required
//                                print("agg...",agg)
                                print("sdiArray..>>>.",sdiArray)
                                if sdiArray.count > 0 {
                                    let lineItemSerialBasedArray = self.getLineItemSerialBasedDataOnly()
                                    if let lineItemSerialBasedSDIArr = (lineItemSerialBasedArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.sdi") as? [String] {
                                        
                                        let statusArray = [] as NSMutableArray

                                        for i in 0..<lineItemSerialBasedSDIArr.count {
                                            let sdi = lineItemSerialBasedSDIArr[i]
                                            if sdiArray.contains(sdi) {
                                                statusArray.add("true")
                                            }else {
                                                statusArray.add("false")
                                            }
                                        }
                                        
                                        if statusArray.count == 0 || statusArray.contains("false") {
                                            Utility.showPopup(Title: App_Title, Message: "Aggregation data is required for serial based lot.".localized() ,InViewC: self)
                                        }
                                        else {
    //                                        print("Pass")
                                            //Pass Confirmation
                                            defaults.set(true, forKey: "MIS_4thStep")
                                            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
                                            self.navigationController?.pushViewController(controller, animated: false)
                                        }
                                    }
                                    else {
                                        Utility.showPopup(Title: App_Title, Message: "Line item must be filled up.".localized() , InViewC: self)//Extra
                                    }
                                }
                                else {
                                    Utility.showPopup(Title: App_Title, Message: "Aggregation data must be filied up for serial based data".localized() ,InViewC: self)//Extra
                                }
                                
//                            }//,,,sb13 temp2
//                            else {
//                                //product only
//                                //,,,sb12
//                                if let aggregationMixedSDIArr = (itemsList! as NSArray).value(forKeyPath: "@distinctUnionOfObjects.sdi") as? [String] {
//
//                                    let lineItemSerialBasedArray = self.getLineItemSerialBasedDataOnly()
//                                    if let lineItemSerialBasedSDIArr = (lineItemSerialBasedArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.sdi") as? [String] {
//
//                                        let statusArray = [] as NSMutableArray
//
//                                        for i in 0..<lineItemSerialBasedSDIArr.count {
//                                            let sdi = lineItemSerialBasedSDIArr[i]
//                                            if aggregationMixedSDIArr.contains(sdi) {
//                                                statusArray.add("true")
//                                            }else {
//                                                statusArray.add("false")
//                                            }
//                                        }
//
//                                        if statusArray.count == 0 || statusArray.contains("false") {
//                                            Utility.showPopup(Title: App_Title, Message: "Aggregation data is required for serial based lot.".localized() ,InViewC: self)
//                                        }
//                                        else {
//    //                                        print("Pass")
//                                            //Pass Confirmation
//                                            defaults.set(true, forKey: "MIS_4thStep")
//                                            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
//                                            self.navigationController?.pushViewController(controller, animated: false)
//                                        }
//                                    }
//                                    else {
//                                        Utility.showPopup(Title: App_Title, Message: "Line item must be filled up.".localized() , InViewC: self)//Extra
//                                    }
//                                }
//                                else {
//                                    Utility.showPopup(Title: App_Title, Message: "Aggregation data must be filied up for serial based data".localized() ,InViewC: self)//Extra
//                                }
//                                //,,,sb12
//                            }
//                            //,,,sb13 temp2
                            
                            /*
                            //Pass Confirmation
                            defaults.set(true, forKey: "MIS_4thStep")
                            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
                            self.navigationController?.pushViewController(controller, animated: false)
                            */
                        }
                    }
                }
            }
        }
        //,,,sb12
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
        }else if sender.tag == 5 {
            nextButtonPressed(UIButton())
        }
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender:UIButton){
        productAddedView.isHidden = true
    }
    @IBAction func updateButtonPressed(_ sender:UIButton){
        if let str = productNameTextFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines),str.isEmpty{
            Utility.showPopup(Title: "", Message: "Enter the product name", InViewC: self)
        }else{
            self.setUpforProduct()
        }
    }
}
    //MARK: - End
//MARK: - Tableview Delegate and Datasource
extension MISAggregationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "MISAggregationRootCell") as! MISAggregationRootCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        cell.typeView.isHidden = true
        cell.arrowButton.isHidden = true
        cell.serialView.isHidden = true
        
        if let dict = self.itemsList![indexPath.row] as? NSDictionary {
            
            var dataStr = ""
            if let txt = dict["serial"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            if let txt = dict["gs1_serial"] as? String,!txt.isEmpty, dataStr == "" {
                dataStr = txt
            }
            cell.serialLabel.text = dataStr
            
            if let type = dict["type"] as? String,!type.isEmpty{
                if type == "product" || type == "PRODUCT" {
                    cell.typeView.isHidden = false
                    cell.titleButton.isSelected = false
                    if let txt = dict["sdi"] as? String,!txt.isEmpty{
                        cell.referenceLabel.text = txt
                        
                        let tempLotDetails = getLotItemDetails(sdi: txt)
                        
                        if let lot_type = tempLotDetails["lot_type"] as? String,!txt.isEmpty{
                            
                            if lot_type == "SERIAL_BASED" || lot_type == "FOUND"{
                                cell.typeLabel.text = "Serial Based"
                                cell.serialView.isHidden = false
                            }else if lot_type == "LOT_BASED" || lot_type == "LOT_FOUND"{
                                cell.typeLabel.text = "Lot Based"
                            }
                            
                            dataStr = ""
                            if let txt = tempLotDetails["lot_number"] as? String,!txt.isEmpty{
                                dataStr = txt
                            }
                            cell.lotLabel.text = dataStr
                            
                            dataStr = ""
                            if let misitem_id = tempLotDetails["misitem_id"] as? Int{
                                dataStr = getProductName(misitem_id: misitem_id)
                            }
                            cell.titleLabel.text = dataStr
                        }
                        else {
                            cell.typeLabel.text = ""
                            cell.lotLabel.text = ""
                            cell.titleLabel.text = ""
                            cell.referenceLabel.text = ""
                        }//,,,sb13
                    }
                    
                    
                } else if type == "container" || type == "CONTAINER"{
                    cell.serialView.isHidden = false
                    cell.titleButton.isSelected = true
                    cell.arrowButton.isHidden = false
                    cell.titleLabel.text = "Container".localized()
                }
            }
        }
        
        
        cell.arrowButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        
        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class MISAggregationRootCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
  
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var serialLabel: UILabel!
    
    @IBOutlet weak var serialView: UIView!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//extension MISAggregationViewController : ScanViewControllerDelegate{
//    func didScanCodeForReceive(codeDetails: [String : Any]) {
//        print(codeDetails["scannedCode"] as Any)
//        self.getIndividualProduct(code: codeDetails["scannedCode"] as! String)
//    }
//}
extension MISAggregationViewController : SingleScanViewControllerDelegate{
    internal func didSingleScanCodeForScanAggreation(codeDetails: [String : Any],productName:String,productGtIn14:String,lotnumber:String,serialnumber:String,expirationdate:String){
        
        
        //,,,sb13
        var scanProductType = ""
        if let scannedCode = codeDetails["scannedCode"] as? String, !scannedCode.isEmpty {
            let productTypeNumber = scannedCode.prefix(2)
            if (productTypeNumber == "00") {
                scanProductType =  "CONTAINER"
            }
            else if (productTypeNumber == "01") {
                scanProductType =  "PRODUCT"
            }
        }
        //,,,sb13
        
        
        //,,,sb13
//        if productName.isEmpty {
         if scanProductType == "PRODUCT" && productName.isEmpty {
        //,,,sb13
            
            productAddedView.isHidden = false

            if !productGtIn14.isEmpty{
                gtin14Label.text = productGtIn14
            }
            if !lotnumber.isEmpty {
                lotLabel.text = lotnumber
            }
            if !serialnumber.isEmpty {
                serialLabel.text = serialnumber
            }
            if !expirationdate.isEmpty{
                let arr =  expirationdate.split(separator: "T")
                if arr.count>0{
                    expirationDateLabel.text = String(arr[0])
                }
            }
            scannedCodeDetails = codeDetails
            productNameTextFiled.text = ""

        }
        else{
            productAddedView.isHidden = true

            scannedCodes = []
            scannedCodes.insert(codeDetails["scannedCode"] as! String)
            self.addUpdateSerialsToDB(scannedCode: Array(scannedCodes))
            DispatchQueue.main.async{
                self.callApiForGS1BarcodeLookupDetails(scannedCode: Array(self.scannedCodes),productname: productName ,productGtIn14: productGtIn14)
            }
        }
        
    }
}



//MARK: - End

