//
//  QuarantineConfirmViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 02/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class AdjustmentConfirmViewController: BaseViewController,ConfirmationViewDelegate {
    
    
    @IBOutlet weak var adjustmentTypeButton: UIButton!
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
    
    @IBOutlet weak var sourceLocationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var desLocationLabel: UILabel!
    @IBOutlet weak var storageLabel: UILabel!
    @IBOutlet weak var shelfLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var refLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var serialCountLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var desLocationView: UIView!
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var refView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var itemsVerificationView: UIView!
    var selectedLocationUuid:String?
    var adjustmentType = ""
    
    var attachmentList = [[String:Any]]()
    var counter = 0
    
    //MARK: - View Life Cysle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        locationView.setRoundCorner(cornerRadious: 10.0)
        desLocationView.setRoundCorner(cornerRadious: 10.0)
        reasonView.setRoundCorner(cornerRadious: 10.0)
        refView.setRoundCorner(cornerRadious: 10.0)
        notesView.setRoundCorner(cornerRadious: 10.0)
        itemsVerificationView.setRoundCorner(cornerRadious: 10.0)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        populateGeneralInfo()
    }
    //MARK: - End
    
    //MARK: - Private Method
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
        let itemStr = NSAttributedString(string: " " + "Serials".localized(), attributes: custTypeAttributes)
        productString.append(productStr)
        itemsString.append(itemStr)
        
        productCountLabel.attributedText = productString
        serialCountLabel.attributedText = itemsString
        //serialCountLabel.textAlignment = .right
        //        productCountLabel.attributedText = itemsString
        //        serialCountLabel.attributedText = NSAttributedString(string: "", attributes: custTypeAttributes)
        
        
    }
    func populateGeneralInfo(){
        
        if let type = defaults.value(forKey: "current_adjustment") as? String {
            adjustmentTypeButton.setTitle(type.capitalized, for: .normal)
            adjustmentType = type
            if type == "MISC_ADJUSTMENT" {
                adjustmentTypeButton.setTitle("Missing / Stolen".localized(), for: .normal)
            }
        }
        
        
        if adjustmentType == Adjustments_Types.Transfer.rawValue {
            sourceLocationLabel.text = "Source Location".localized()
            desLocationView.isHidden = false
            
        }else{
            desLocationView.isHidden = true
        }
        
        if adjustmentType == Adjustments_Types.Dispense.rawValue {
            reasonView.isHidden = true
        }else{
            reasonView.isHidden = false
        }
        
        
        var product = "0"
        var serial = "0"
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true")
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
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
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                serial = "\(arr.count)"
                
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        
        
        populateProductandItemsCount(product: product, items: serial)
        
        if let dataDict = Utility.getDictFromdefaults(key: "adjustment_general_info") {
            
            
            if let txt =  dataDict["location_uuid"] as? String, !txt.isEmpty {
                selectedLocationUuid = txt
                
                if let name =  dataDict["location_uuid_name"] as? String, !name.isEmpty {
                    locationLabel.text = name
                    locationLabel.accessibilityHint = txt
                }
            }
            
            if let txt =  dataDict["to_location_uuid"] as? String, !txt.isEmpty {
                
                
                if let name =  dataDict["to_location_uuid_name"] as? String, !name.isEmpty {
                    desLocationLabel.text = name
                    desLocationLabel.accessibilityHint = txt
                }
            }
            
            if let txt =  dataDict["to_storage_area_uuid"] as? String, !txt.isEmpty {
                
                
                if let name =  dataDict["to_storage_area_uuid_name"] as? String, !name.isEmpty {
                    storageLabel.text = name
                    storageLabel.accessibilityHint = txt
                }
            }
            
            if let txt =  dataDict["to_storage_shelf_uuid"] as? String, !txt.isEmpty {
                shelfView.isHidden = false
                
                if let name =  dataDict["to_storage_shelf_uuid_name"] as? String, !name.isEmpty {
                    shelfLabel.text = name
                    shelfLabel.accessibilityHint = txt
                }
            }else{
                shelfView.isHidden = true
            }
            
            
            
            if let txt =  dataDict["reason_uuid"] as? String, !txt.isEmpty{
                reasonLabel.accessibilityHint = txt
                
                if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                    reasonLabel.text = txt
                }
                
                
            }else if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                reasonLabel.text = txt
            }
            
            
            
            if let txt =  dataDict["reference_num"] as? String, !txt.isEmpty{
                refLabel.text = txt
            }
            
            
            if let txt =  dataDict["notes"] as? String, !txt.isEmpty{
                notesLabel.text = txt
            }
            
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
    
    func prepareDataForSave(){
        
        let requestDict = NSMutableDictionary()
        
        if let type = defaults.value(forKey: "current_adjustment") as? String {
            requestDict.setValue(type, forKey: "type")
        }
        
        
        if let dataDict = Utility.getDictFromdefaults(key: "adjustment_general_info") {
            
            
            if let txt =  dataDict["location_uuid"] as? String, !txt.isEmpty {
                requestDict.setValue(txt, forKey: "location_uuid")
            }
            
            
            if adjustmentType == Adjustments_Types.Transfer.rawValue {
                if let txt =  dataDict["to_location_uuid"] as? String, !txt.isEmpty {
                    requestDict.setValue(txt, forKey: "to_location_uuid")
                }
                
                if let txt =  dataDict["to_storage_area_uuid"] as? String, !txt.isEmpty {
                    requestDict.setValue(txt, forKey: "to_storage_area_uuid")
                }
                
                if let txt =  dataDict["to_storage_shelf_uuid"] as? String, !txt.isEmpty {
                    requestDict.setValue(txt, forKey: "to_storage_shelf_uuid")
                }
                
            }
            
            
            if adjustmentType != Adjustments_Types.Dispense.rawValue {
                if let txt =  dataDict["reason_uuid"] as? String, !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "reason_uuid")
                    
                }else if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                    requestDict.setValue(txt, forKey: "reason_text")
                }
            }
            
            
            if let txt =  dataDict["reference_num"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "reference_num")
            }
            
            
            if let txt =  dataDict["notes"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "notes")
            }
            
        }
        
        var itemsArray = [[String : Any]]()
        
        //MARK: - Prepare Lot Based Product for Save
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true")
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                if let uniqueProductArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                    
                    for product_uuid in uniqueProductArr {
                        
                        do{
                            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and product_uuid='\(product_uuid)'")
                            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
                            if !serial_obj.isEmpty{
                                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                if let uniqueLotArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_no") as? Array<Any>{
                                    
                                    
                                    for lot_no in uniqueLotArr {
                                        
                                        do{
                                            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and product_uuid='\(product_uuid)' and lot_no='\(lot_no)'")
                                            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
                                            
                                            if !serial_obj.isEmpty{
                                                //let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                                
                                                let obj = serial_obj.first
                                                var dict = [String : Any]()
                                                dict["type"] = Product_Types.LotBased.rawValue
                                                dict["item_uuid"] = obj?.product_uuid ?? ""
                                                dict["lot_number"] = lot_no
                                                dict["storage_area_uuid"] = obj?.storage_uuid ?? ""
                                                dict["storage_shelf_uuid"] = obj?.shelf_uuid ?? ""
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
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                if let uniqueProductArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                    
                    for product_uuid in uniqueProductArr {
                        
                        do{
                            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false and product_uuid='\(product_uuid)'")
                            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
                            if !serial_obj.isEmpty{
                                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                if let uniqueSerialArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.gs1_serial") as? Array<Any>{
                                    let obj = serial_obj.first
                                    var dict = [String : Any]()
                                    dict["type"] = Product_Types.SerialBased.rawValue
                                    dict["item_uuid"] = obj?.product_uuid ?? ""
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
        
        requestDict.setValue(Utility.json(from: itemsArray), forKey: "items")
        //print("Request Data:\(requestDict)")
        confirmAdjustment(requestData: requestDict)
        
        
    }
    
    func uploadAttachment(attachmentList:[[String:Any]], new_adjustment_uuid:String){
        var tempattachmentDict = [String:Any]()
            
        tempattachmentDict["reference"]     = attachmentList[counter]["reference"]
        tempattachmentDict["type"]          = attachmentList[counter]["type"]
        tempattachmentDict["type_other"]    = attachmentList[counter]["type_other"]
        tempattachmentDict["notes"]         = attachmentList[counter]["notes"]
        tempattachmentDict["is_private"]    = attachmentList[counter]["is_private"]
        
        let appendStr:String! = "\(new_adjustment_uuid)/attachments"
        
        let fileName:String!        = attachmentList[counter]["fileName"] as? String
        let fileMimeType:String!    = attachmentList[counter]["fileMimeType"] as? String
        let filePath:String!        = attachmentList[counter]["filePath"] as? String
        
        print(attachmentList[counter])
        
        
        Utility.MultiPartPOSTServiceCall(type: "GetQuarantineList", serviceParam: tempattachmentDict,fileFieldName: "file", fileName: fileName, fileMimeType: fileMimeType, filePath: filePath, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.counter += 1
                if isDone! {
                    if let responseDict: NSDictionary = responseData as? NSDictionary{
                        if (responseDict["uuid"] as? String) != nil{
                            
                            if self.counter < attachmentList.count {
                                self.uploadAttachment(attachmentList: attachmentList, new_adjustment_uuid: new_adjustment_uuid)
                            }else{
                                self.counter = 0
                                self.removeSpinner()
                                Utility.showAlertWithPopAction(Title: Success_Title, Message: "Adjustment request submitted".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                            }
                        }
                    }
                }else{
                    if self.counter < attachmentList.count {
                        self.uploadAttachment(attachmentList: attachmentList, new_adjustment_uuid: new_adjustment_uuid)
                    }else{
                        self.counter = 0
                        self.removeSpinner()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Adjustment request submitted".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                    }
                }
                
            }
        }
    }
    
    func confirmAdjustment(requestData:NSMutableDictionary){
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "GetQuarantineList", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let new_adjustment_uuid = responseDict["new_adjustment_uuid"] as? String {
                        
                        if self.attachmentList.count > 0 {
                            self.uploadAttachment(attachmentList: self.attachmentList, new_adjustment_uuid: new_adjustment_uuid)
                        }else{
                            self.removeSpinner()
                            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Adjustment request submitted".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                        }
                        defaults.removeObject(forKey: "AdjustmentVerifiedArray")
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
    //MARK: - End
    //MARK: - IBAction
    
    @IBAction func editIconPressed(_ sender: UIButton) {
        
        let btn = UIButton()
        btn.tag = 1
        stepButtonsPressed(btn)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        
        if adjustmentType == "MISC_ADJUSTMENT" {
            controller.confirmationMsg = "Are you sure you want cancel".localized() + " " + "Missing / Stolen".localized()
        }else{
            controller.confirmationMsg = "Are you sure you want cancel".localized() + " \(adjustmentType.capitalized)".firstUppercased
        }
        
        
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        if adjustmentType == "MISC_ADJUSTMENT" {
            controller.confirmationMsg = "Are you sure you want confirm".localized()+" "+"Missing / Stolen".localized()
        }else{
            controller.confirmationMsg = "Are you sure you want confirm".localized() + " \(adjustmentType.capitalized)".firstUppercased
        }
        
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AdjustmentViewItemsView") as! AdjustmentViewItemsViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: AdjustmentGeneralViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AdjustmentGeneralView") as! AdjustmentGeneralViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: AdjustmentScanViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AdjustmentScanView") as! AdjustmentScanViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }
        
        
    }
    //MARK: - End
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        prepareDataForSave()
        
    }
    func cancelConfirmation() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
    
    
    
    
}
