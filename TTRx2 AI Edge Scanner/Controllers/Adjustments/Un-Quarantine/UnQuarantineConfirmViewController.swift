//
//  UnQuarantineConfirmViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by rupshikha anand on 02/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class UnQuarantineConfirmViewController: BaseViewController,ConfirmationViewDelegate,SingleSelectDropdownDelegate {
    var verifiedSerials = Array<Dictionary<String,Any>>()
    var failedSerials = Array<Dictionary<String,Any>>()
    
    
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var serialCountLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var customerView: UIView!
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var referenceView: UIView!
    @IBOutlet weak var noteView: UIView!
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    
    //MARK: Edit
    @IBOutlet weak var reasonButton: UIButton!
    @IBOutlet weak var referenceButton: UIButton!
    @IBOutlet weak var notesButton: UIButton!
    //MARK: - End
    
    var adjustment_uuid = ""
    var attachmentList = [[String:Any]]()
    var counter = 0

    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        customerView.setRoundCorner(cornerRadious: 10.0)
        reasonView.setRoundCorner(cornerRadious: 10.0)
        referenceView.setRoundCorner(cornerRadious: 10.0)
        noteView.setRoundCorner(cornerRadious: 10.0)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        populateGeneralInfo()
        
    }
    //MARK: - End
    //MARK: - Private Method
    
    func populateGeneralInfo(){
        
        if let uuid = defaults.value(forKey: "adjustment_uuid") as? String{
            adjustment_uuid = uuid
        }
        
        self.uuidLabel.text = adjustment_uuid
        
        if let dataDict = Utility.getDictFromdefaults(key: "unquaratine_general_info") {
            
            
            if let txt =  dataDict["reason_uuid"] as? String, !txt.isEmpty{
                reasonLabel.accessibilityHint = txt
                
                if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                    reasonLabel.text = txt
                }
                
                
                
            }else if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                reasonLabel.text = txt
            }
            
            
            
            if let txt =  dataDict["reference_num"] as? String, !txt.isEmpty{
                referenceLabel.text = txt
            }
            
            
            if let txt =  dataDict["notes"] as? String, !txt.isEmpty{
                noteLabel.text = txt
            }
            
        }
        
        
    }
    
    
    func refreshProductView(){
        if let distinctArray =  (self.verifiedSerials as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
            productCountLabel.text = "\(String(describing: distinctArray.count)) " + "Products".localized()
        }else{
            productCountLabel.text = "0"
        }
        serialCountLabel.text = "\(String(describing: self.verifiedSerials.count)) " + "Serials".localized()
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
        requestDict.setValue("UN-QUARANTINE", forKey: "type")
        requestDict.setValue(adjustment_uuid, forKey: "previous_adjustment_uuid")
        
        if let location_uuid = defaults.value(forKey: "unquarantineLocation") as? String {
            requestDict.setValue(location_uuid, forKey: "location_uuid")
        }
        
        
        
        if let dataDict = Utility.getDictFromdefaults(key: "unquaratine_general_info") {
            
            
            if let txt =  dataDict["location_uuid"] as? String, !txt.isEmpty {
                requestDict.setValue(txt, forKey: "location_uuid")
            }
            
            if let txt =  dataDict["reason_uuid"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "reason_uuid")
                
            }else if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "reason_text")
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
        if let selectItems = Utility.getObjectFromDefauls(key: "selectedItems") as? [[String:Any]]{
            
            
            for item in selectItems {
                if let products = item["product"] as? [[String: Any]], let firstPro = products.first {
                    let item_uuid = (firstPro["uuid"] as? String) ?? ""
                    
                    //MARK: - For Lot Based Product
                    if let lots = firstPro["lots"] as? [[String: Any]] {
                        
                        for lot in lots{
                            
                            var dict = [String : Any]()
                            dict["type"] = Product_Types.LotBased.rawValue
                            dict["item_uuid"] = item_uuid
                            dict["lot_number"] = lot["lot_number"] ?? ""
                            dict["storage_area_uuid"] = lot["storage_area_uuid"] ?? ""
                            dict["storage_shelf_uuid"] = lot["storage_shelf_uuid"] ?? ""
                            dict["quantity"] = (lot["quantity"] as? Int) ?? 0
                            
                            itemsArray.append(dict)
                        }
                        
                    }
                    //MARK: - End
                    
                    //MARK: - For Serial Based Product
                    if let structure = item["structure"] as? [[String: Any]] {
                        
                        if let serials = (structure as NSArray).value(forKeyPath: "@distinctUnionOfObjects.gs1_serial") as? Array<Any>{
                            
                            var dict = [String : Any]()
                            dict["type"] = Product_Types.SerialBased.rawValue
                            dict["item_uuid"] = item_uuid
                            dict["serials"] = serials
                            
                            itemsArray.append(dict)
                            
                        }
                        
                        
                    }
                    //MARK: - End
                    
                    
                    
                }
                
                
            }
            
            
        }
        
        
        //MARK: - End
        
        requestDict.setValue(Utility.json(from: itemsArray), forKey: "items")
        print("Request Data:\(requestDict)")
        confirmUnquarantine(requestData: requestDict)
        
        
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
                                Utility.showAlertWithPopAction(Title: Success_Title, Message: "Un-Quarantine request submitted".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                            }
                        }
                    }
                }else{
                    if self.counter < attachmentList.count {
                        self.uploadAttachment(attachmentList: attachmentList, new_adjustment_uuid: new_adjustment_uuid)
                    }else{
                        self.counter = 0
                        self.removeSpinner()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Un-Quarantine request submitted".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                    }
                }
                
            }
        }
    }
    func confirmUnquarantine(requestData:NSMutableDictionary){
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "GetQuarantineList", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let new_adjustment_uuid = responseDict["new_adjustment_uuid"] as? String {
                            
                            if self.attachmentList.count > 0 {
                                self.uploadAttachment(attachmentList: self.attachmentList, new_adjustment_uuid: new_adjustment_uuid)
                            }else{
                                self.removeSpinner()
                                Utility.showAlertWithPopAction(Title: Success_Title, Message: "Un-Quarantine request submitted".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                            }
                       
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
    
    
    //MARK: - IBAction
    @IBAction func reasonButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineSearchView") as! UnQuarantineSearchViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func referenceButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineSearchView") as! UnQuarantineSearchViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func noteButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineSearchView") as! UnQuarantineSearchViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func editIconPressed(_ sender: UIButton) {
        
        let btn = UIButton()
        btn.tag = 1
        stepButtonsPressed(btn)
        
    }
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want cancel Un-Quarantine?".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want confirm Un-Quarantine?".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: UnQuarantineGeneralViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineGeneralView") as! UnQuarantineGeneralViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: UnQuarantineItemViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineItemView") as! UnQuarantineItemViewController
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
//class x {
//    
//    fileprivate var x = String()
//    
//}
//class y {
//    
//    fileprivate var y = String()
//    let c = x()
//    c.x = ""
//}
