//
//  ContainerEditConfirmViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 10/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ContainerEditConfirmViewController: BaseViewController,ConfirmationViewDelegate {

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
    
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var uniqueSerialLabel: UILabel!
    @IBOutlet weak var gsiidLabel: UILabel!
    @IBOutlet weak var containerTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var storageAreaLabel: UILabel!
    @IBOutlet weak var storageShelfLabel: UILabel!
    @IBOutlet weak var dispositionLabel: UILabel!
    @IBOutlet weak var businessStepLabel: UILabel!
        
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var serialCountLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var itemsVerificationView: UIView!
    var selectedLocationUuid:String?
    var adjustmentType = ""
    
       
    //MARK: - View Life Cysle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        itemsVerificationView.setRoundCorner(cornerRadious: 10.0)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
        
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
        populateContainerDetails()
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
        let productStr = NSAttributedString(string: "\(Int(product!)!>1 ?" " + "Lot Products".localized() : " " + "Lot Product".localized())", attributes: custTypeAttributes)
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
    
    func populateContainerDetails() {
        if let containerData = Utility.getObjectFromDefauls(key: "container_edit_details") as? [String:Any]{
            var dataStr = ""
            if let txt = containerData["serial"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            uniqueSerialLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerData["gs1_unique_id"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            gsiidLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerData["packaging_type_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            containerTypeLabel.text = dataStr
                        
            dataStr = ""
            if let txt = containerData["location_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            locationLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerData["storage_area_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            storageAreaLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerData["storage_shelf_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            storageShelfLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerData["disposition_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            dispositionLabel.text = dataStr.capitalized
            
            dataStr = ""
            if let txt = containerData["business_step_name"] as? String,!txt.isEmpty{
                dataStr = txt.capitalized
            }
            businessStepLabel.text = dataStr
            
        }
    }
    
    func prepareDataForSave(){
        
        let requestDict = NSMutableDictionary()
        
        var uuid = ""
        
        if let dataDict = Utility.getDictFromdefaults(key: "container_edit_details") {
                   
           if let txt = dataDict["uuid"] as? String,!txt.isEmpty{
               uuid = txt
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
                                                        dict["type"] = "PRODUCT_LOT"
                                                        dict["product_uuid"] = obj?.product_uuid ?? ""
                                                        dict["lot"] = lot_no
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
                                        for serial in uniqueSerialArr{
                                            var dict = [String : Any]()
                                            dict["type"] = "GS1_UNIQUE_ID"
                                            dict["product_uuid"] = obj?.product_uuid ?? ""
                                            dict["serial"] = serial
                                            
                                            itemsArray.append(dict)
                                            
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
        
        requestDict.setValue(Utility.json(from: itemsArray), forKey: "items")
        //print("Request Data:\(requestDict)")
        
        
        if itemsArray.count>0{
            saveContainerItems(uuid: uuid, requestData: requestDict)
        }else{
            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Container will be updated.".localized() + "\n" + "The system will process the request in the background.".localized(), InViewC: self, isPop: true, isPopToRoot: true)
        }
       
    }
    
    func prepareDataForContainerUpdate(){
    
        let requestDict = NSMutableDictionary()
        
        var uuid = ""
        
        if let dataDict = Utility.getDictFromdefaults(key: "container_edit_details") {
                   
           if let txt = dataDict["uuid"] as? String,!txt.isEmpty{
               uuid = txt
           }
            
            if let txt =  dataDict["container_type_id"] as? String, !txt.isEmpty {
                 requestDict.setValue(txt, forKey: "container_type_id")
            }
            
            if let txt =  dataDict["gs1_id_unique_serial"] as? String, !txt.isEmpty {
                 requestDict.setValue(txt, forKey: "gs1_id_unique_serial")
            }
            
            if let txt =  dataDict["unique_serial"] as? String, !txt.isEmpty {
                 requestDict.setValue(txt, forKey: "unique_serial")
            }
            
            if let txt =  dataDict["disposition_id"] as? String, !txt.isEmpty {
                 requestDict.setValue(txt, forKey: "disposition_id")
            }
            
            if let txt =  dataDict["business_step_id"] as? String, !txt.isEmpty {
                 requestDict.setValue(txt, forKey: "business_step_id")
            }
        }
        updateContainer(uuid: uuid, requestData: requestDict)
    }
    
    func saveContainerItems(uuid:String,requestData:NSMutableDictionary) {
        let appendStr = "UUID/\(uuid)/content"
        self.showSpinner(onView: self.view)
        
        Utility.POSTServiceCall(type: "ContainersDetails", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        
                        if let txt = responseDict["task_queue_uuid"] as? String,!txt.isEmpty{
                            defaults.removeObject(forKey: "InventoryVerifiedArray")
                            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Container will be updated.".localized() + "\n" + "The system will process the request in the background.".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                        }
                        
                    }
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        var err = ""
                        if let errorMsg = responseDict["message"] as? String{
                            err = errorMsg
                        }
                        Utility.showPopup(Title: App_Title, Message: err , InViewC: self)
                        
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }
    
    func updateContainer(uuid:String,requestData:NSMutableDictionary) {
        let appendStr = "UUID/\(uuid)"
        self.showSpinner(onView: self.view)
        
        Utility.PUTServiceCall(type: "ContainersDetails", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        
                        if let txt = responseDict["task_queue_uuid"] as? String,!txt.isEmpty{
                            self.prepareDataForSave()
                        }
                    }
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        var err = ""
                        if let errorMsg = responseDict["message"] as? String{
                            err = errorMsg
                        }
                        Utility.showPopup(Title: App_Title, Message: err , InViewC: self)
                        
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
        controller.confirmationMsg = "Are you sure you want to cancel".localized() + " \(adjustmentType.capitalized)".firstUppercased
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to confirm".localized() + " \(adjustmentType.capitalized)".firstUppercased
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentViewItemsView") as! AdjustmentViewItemsViewController
        controller.isFromContainer = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ContainerEditViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerEditView") as! ContainerEditViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ContainerEditItemViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerEditItemView") as! ContainerEditItemViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }
        
        
    }
    //MARK: - End
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        prepareDataForContainerUpdate()
        
    }
    func cancelConfirmation() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
}
