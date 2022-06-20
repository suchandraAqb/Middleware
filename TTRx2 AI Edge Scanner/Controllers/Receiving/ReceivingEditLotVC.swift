//
//  ReceivingEditLotVC.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 24/03/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData

class ReceivingEditLotVC: BaseViewController , DatePickerViewDelegate {
    
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var lotView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var ownershipButton: UIButton!
    @IBOutlet weak var attachmentButton: UIButton!
    
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnExpiry: UIButton!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    @IBOutlet weak var lotTextField: UITextField!
    @IBOutlet var lotButtons: [UIButton]!
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var expirationDateLabel: UILabel!
    
    
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var gtinLabel: UILabel!
    
    var lotType = ""
    var isAdd = true
    
    var remainingquantity:Int = 0
    var id = Int16()
    
    public var editLocalDBData : ReceiveLotEdit?{
        didSet{
//            self.populateDetails()
        }
    }
    public var shippingLineItemData : SippingLineItemDataModel?{
        didSet{
            
        }
    }
    
    public var editData : LotDataModel?{
        didSet{
            //self.populateDetails()
        }
    }
    
    public var isLotBased = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createInputAccessoryViewAddedScan()
        setup_initialview()
        self.populateDetails()
        //self.fetchFromLocalDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //editLocalData
    }
    
//    private func fetchFromLocalDB(){
//        do {
//
//            let predicate = NSPredicate(format:"id='\(id)'")
//            let serial_obj = try PersistenceService.context.fetch(Receiving.fetchRequestWithPredicate(predicate: predicate))
//
//            if let obj = serial_obj.first{
//                self.editLocalDBData = obj
//            }
//
//            //print(self.arrTableData.count)
//
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//    }
    //MARK: - Action
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let addedQty = (self.shippingLineItemData?.maxQuantity)! - remainingquantity
        
        var lot_number = ""
        if let txt = lotTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            lot_number = txt
        }
        
        var quantity = 0
        if let txt = quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            quantity = Int(txt) ?? 0
        }
        
        var expiration_date = ""
        if let txt = expirationDateLabel.accessibilityHint , !txt.isEmpty {
            expiration_date = txt
        }
        
        var isvalidate = true
        if lot_number == "" {
            Utility.showPopup(Title: App_Title, Message: "Please enter Lot.".localized(), InViewC: self)
            isvalidate = false
        }
        
        if quantity == 0 {
            Utility.showPopup(Title: App_Title, Message: "Please enter quantity.".localized(), InViewC: self)
            isvalidate = false
            
        }else if(quantity>(self.shippingLineItemData?.maxQuantity)!){
            Utility.showPopup(Title: App_Title, Message: "Required quantity must not be greater than bought quantity.".localized(), InViewC: self)
            isvalidate = false
        }else if (addedQty + remainingquantity) > self.shippingLineItemData?.maxQuantity ?? 0{
            Utility.showPopup(Title: App_Title, Message: "Required quantity must not be greater than bought quantity.".localized(), InViewC: self)
            isvalidate = false
        }else if (quantity<0 || remainingquantity<0 || addedQty<0){
            Utility.showPopup(Title: App_Title, Message: "Something went wrong.".localized(), InViewC: self)
            isvalidate = false
        }else if(quantity>remainingquantity && isAdd){
            Utility.showPopup(Title: App_Title, Message: "Required quantity must not be greater than bought quantity.".localized(), InViewC: self)
            isvalidate = false

        }
//        if expiration_date == "" {
//            Utility.showPopup(Title: App_Title, Message: "Please enter expiration date.".localized(), InViewC: self)
//            isvalidate = false
//        }
        
        
        if isAdd && isvalidate {
                let obj = ReceiveLotEdit(context: PersistenceService.context)
                
                obj.id = ReceivingEditLotVC.getAutoIncrementId()
                obj.lot_number = lot_number
                obj.expiration_date = expiration_date
                obj.quantity = Int16(quantity)
                obj.lot_type = lotType
                obj.isEditable = true
                obj.shipment_line_item_uuid = shippingLineItemData?.shipment_line_item_uuid
                PersistenceService.saveContext()
                
                Utility.showAlertWithPopAction(Title: Success_Title, Message: "Changes has been saved and will be applied on completion of receiving.".localized(), InViewC: self, isPop: true, isPopToRoot: false)
            
        }else if !isAdd && isvalidate {
            
            let lotitem_id = editLocalDBData?.id ?? 0
            let predicate = NSPredicate(format:"id='\(lotitem_id)'")
            do{
                let serial_obj = try PersistenceService.context.fetch(Receiving.fetchRequestWithPredicate(predicate: predicate))
                
                if serial_obj.isEmpty{
                    
                    let obj = ReceiveLotEdit(context: PersistenceService.context)
                    
                    obj.id = ReceivingEditLotVC.getAutoIncrementId()
                    obj.lot_number = lot_number
                    obj.expiration_date = expiration_date
                    obj.quantity = Int16(quantity)
                    obj.lot_type = lotType
                    obj.isEditable = true
                    obj.shipment_line_item_uuid = shippingLineItemData?.shipment_line_item_uuid
                    PersistenceService.saveContext()
                    
                    Utility.showAlertWithPopAction(Title: Success_Title, Message: "Changes has been saved and will be applied on completion of receiving.".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                }else{
                    
                    if let obj = serial_obj.first {
                        obj.lot_number = lot_number
                        obj.expiration_date = expiration_date
                        obj.quantity = Int16(quantity)
                        obj.lot_type = lotType
                        obj.shipment_line_item_uuid = shippingLineItemData?.shipment_line_item_uuid
                        
                        PersistenceService.saveContext()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Changes has been saved and will be applied on completion of receiving.".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }
                
            }catch let error{
                print(error.localizedDescription)
                
            }
        }
    }
    
    
    //MARK: - End
    
    //MARK: - Private Method
    func setup_initialview(){
        sectionView.roundTopCorners(cornerRadious: 40)
        productView.setRoundCorner(cornerRadious: 10)
        lotView.setRoundCorner(cornerRadious: 10)
        dateView.setRoundCorner(cornerRadious: 10)
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 17.0,color:Utility.hexStringToUIColor(hex: "719898"))
        ownershipButton.setRoundCorner(cornerRadious: ownershipButton.frame.size.height/2.0)
        attachmentButton.setRoundCorner(cornerRadious: attachmentButton.frame.size.height/2.0)
        
        self.btnExpiry.isUserInteractionEnabled = false

        self.lotTextField.isUserInteractionEnabled = false

        self.quantityTextField.isUserInteractionEnabled = false
        
        self.btnDone.isHidden = true
        
        if (editLocalDBData?.lot_number != nil && editData?.lot_number == nil || editData?.lot_number == "") || (editLocalDBData?.lot_number == nil && editData?.lot_number == nil || editData?.lot_number == "") {
            
            self.btnDone.isHidden = false
            self.quantityTextField.isUserInteractionEnabled = true
            self.lotTextField.isUserInteractionEnabled = true
            
        }
        if (editLocalDBData?.expiration_date != nil && editData?.expiration_date == nil || editData?.expiration_date == "") || (editLocalDBData?.expiration_date == nil && editData?.expiration_date == nil || editData?.expiration_date == ""){
            
            self.btnDone.isHidden = false
            self.quantityTextField.isUserInteractionEnabled = true
            self.btnExpiry.isUserInteractionEnabled = true
            
        }
        
    }
    
    func populateDetails() {
        
        self.lotType = isLotBased ? "LOT_BASED" : "SERIAL_BASED"
        var dataStr = ""
        if let txt = shippingLineItemData?.name,!txt.isEmpty{
            dataStr = txt
        }
        self.productName.text = dataStr
        
        //        dataStr = ""
        //        if let txt = dictData.,!txt.isEmpty{
        //            dataStr = txt
        //        }
        //        gtinLabel.text = dataStr
        
        if isAdd {
            quantityTextField.text = "\(remainingquantity)"
        }
        
        if !isAdd{
            
            if let localDBlot =  editLocalDBData{
                
                let outputDateFormat = "MM-dd-yyyy"
                
                if let date = localDBlot.expiration_date,!date.isEmpty{
                    if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: outputDateFormat, dateStr: date){
                        expirationDateLabel.text = formattedDate
                        expirationDateLabel.accessibilityHint = date
                    }
                }
                
                dataStr = ""
                if let txt = localDBlot.lot_number,!txt.isEmpty{
                    dataStr = txt
                }
                lotTextField.text = dataStr
                
                
                dataStr = ""
                let quantity = localDBlot.quantity
                remainingquantity = remainingquantity + Int(quantity)
                dataStr = "\(quantity)"
                
                quantityTextField.text = dataStr
            }else{
                let outputDateFormat = "MM-dd-yyyy"
                
                if let date = editData?.expiration_date,!date.isEmpty{
                    if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: outputDateFormat, dateStr: date){
                        expirationDateLabel.text = formattedDate
                        expirationDateLabel.accessibilityHint = date
                    }
                }
                
                dataStr = ""
                if let txt = editData?.lot_number,!txt.isEmpty{
                    dataStr = txt
                }
                lotTextField.text = dataStr
                
                
                dataStr = ""
                let quantity = editData?.quantity ?? 0
                remainingquantity = remainingquantity + quantity
                dataStr = "\(quantity)"
                
                quantityTextField.text = dataStr
            }
        }
    }
    
    class func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(Receiving.fetchAutoIncrementId())
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
    
    
    //MARK: - DatePickerViewDelegate
    func dateSelectedWithSender(selectedDate: Date, sender: UIButton?) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateStr = formatter.string(from: selectedDate)
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStrForApi = formatter.string(from: selectedDate)
        
        if sender != nil && sender?.tag == 2 {
            expirationDateLabel.text = dateStr
            expirationDateLabel.accessibilityHint = dateStrForApi
        }
    }
    //MARK: - End
    
}

extension ReceivingEditLotVC:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        let outputDateFormat = "MM-dd-yyyy"

       if let value = codeDetails["scannedCodes"] as? String, !value.isEmpty {
            let details = UtilityScanning(with:value).decoded_info
        if (details.keys.contains("10")) {
            if let lot = details["10"]?["value"] as? String{
                self.lotTextField.text = lot
            }
        }else{
            Utility.showPopup(Title: Warning, Message: "Lot is missing in Barcode.", InViewC: self)
        }
        if (details.keys.contains("17")) {
            if let date = details["17"]?["value"] as? String{
                let splitArr = date.split(separator: "T")
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: outputDateFormat, dateStr: String(splitArr[0])){
                        self.expirationDateLabel.text = formattedDate
                        self.expirationDateLabel.accessibilityHint =  String(splitArr[0])
                    }
                }
            }
        }
    }
}
