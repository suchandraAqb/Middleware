//
//  ProductEditViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 22/01/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit


class ProductEditViewController: BaseViewController, DatePickerViewDelegate {
    
    
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var lotView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var ownershipButton: UIButton!
    @IBOutlet weak var attachmentButton: UIButton!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    @IBOutlet weak var lotTextField: UITextField!
    @IBOutlet var lotButtons: [UIButton]!
    
    @IBOutlet weak var bestByDateLabel: UILabel!
    @IBOutlet weak var referenceTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var productionDateLabel: UILabel!
    @IBOutlet weak var sellByDateLabel: UILabel!
    
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var gtinLabel: UILabel!
    
    var lotType = ""
    var isAdd = true
    var productDict:NSDictionary?
    var lotDict:NSDictionary?
    
    var remainingquantity:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createInputAccessoryViewAddedScan()
        
        setup_initialview()
        
        let btn = UIButton()
        btn.tag = 1
        lotButtonsPressed(btn)
        
        populateDetails()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    //MARK: - Action
    @IBAction func lotButtonsPressed(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        for btn in lotButtons {
            
            if btn.tag == sender.tag {
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
            
            if btn.isSelected && btn.tag == 1{
                lotType = "SERIAL_BASED"
            }else if btn.isSelected && btn.tag == 2{
                lotType = "LOT_BASED"
            }
        }
    }
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        var lot_number = ""
        if let txt = lotTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            lot_number = txt
        }
        
        var sdi = ""
        if let txt = referenceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            sdi = txt
        }
        
        var quantity = 0
        if let txt = quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            quantity = Int(txt) ?? 0
        }
        
        var best_by_date = ""
        if let txt = bestByDateLabel.accessibilityHint , !txt.isEmpty {
            best_by_date = txt
        }
        
        var expiration_date = ""
        if let txt = expirationDateLabel.accessibilityHint , !txt.isEmpty {
            expiration_date = txt
        }
        
        var production_date = ""
        if let txt = productionDateLabel.accessibilityHint , !txt.isEmpty {
            production_date = txt
        }
        
        var sell_by_date = ""
        if let txt = sellByDateLabel.accessibilityHint , !txt.isEmpty {
            sell_by_date = txt
        }
        
        var isvalidate = true
        
        if sdi == "" {
            Utility.showPopup(Title: App_Title, Message: "Please enter reference.".localized(), InViewC: self)
            isvalidate = false
        }
        
        if lot_number == "" {
            Utility.showPopup(Title: App_Title, Message: "Please enter Lot.".localized(), InViewC: self)
            isvalidate = false
        }
        
        //,,,sb12
//        if quantity == 0 {
        if quantity <= 0 {
        //,,,sb12
            Utility.showPopup(Title: App_Title, Message: "Please enter quantity.".localized(), InViewC: self)
            isvalidate = false
        }else if quantity > remainingquantity {
            Utility.showPopup(Title: App_Title, Message: "Required quantity must not be greater than bought quantity.".localized(), InViewC: self)
            isvalidate = false
        }
        
        if let misitem_id = productDict?["id"] as? Int16 {
            if isAdd && isvalidate {
                
                let obj = MISLotItem(context: PersistenceService.context)
                
                obj.id = getAutoIncrementId()
                obj.misitem_id = misitem_id
                obj.lot_number = lot_number
                obj.best_by_date = best_by_date
                obj.expiration_date = expiration_date
                obj.production_date = production_date
                obj.sell_by_date = sell_by_date
                obj.quantity = Int16(quantity)
                obj.sdi = sdi
                obj.lot_type = lotType
                
                
                PersistenceService.saveContext()
                Utility.showAlertWithPopAction(Title: Success_Title, Message: "Lot Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
            }else if !isAdd && isvalidate {
                
                if let lotitem_id = lotDict?["id"] as? Int16 {
                    let predicate = NSPredicate(format:"id='\(lotitem_id)'")
                    do{
                        let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                        if let obj = serial_obj.first {
                            obj.misitem_id = misitem_id
                            obj.lot_number = lot_number
                            obj.best_by_date = best_by_date
                            obj.expiration_date = expiration_date
                            obj.production_date = production_date
                            obj.sell_by_date = sell_by_date
                            obj.quantity = Int16(quantity)
                            obj.sdi = sdi
                            obj.lot_type = lotType
                            
                            PersistenceService.saveContext()
                            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Lot Edited".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        }
                    }catch let error{
                        print(error.localizedDescription)
                        
                    }
                }
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
    }
    
    func populateDetails() {
        var dataStr = ""
        if let txt = self.productDict?["product_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        productName.text = dataStr
        
        dataStr = ""
        if let txt = self.productDict?["gtin14"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        gtinLabel.text = dataStr
        
        if isAdd {
            quantityTextField.text = "\(remainingquantity)"
            referenceTextField.text = "\(getAutoIncrementId())"
        }
        
        referenceTextField.isUserInteractionEnabled = false//,,,sb13
        
        if !isAdd{
            referenceTextField.isUserInteractionEnabled = false
            let outputDateFormat = "MM-dd-yyyy"
            
            if let date = self.lotDict?["best_by_date"] as? String,!date.isEmpty{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: outputDateFormat, dateStr: date){
                    bestByDateLabel.text = formattedDate
                    bestByDateLabel.accessibilityHint = date
                }
            }
            
            
            if let date = self.lotDict?["expiration_date"] as? String,!date.isEmpty{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: outputDateFormat, dateStr: date){
                    expirationDateLabel.text = formattedDate
                    expirationDateLabel.accessibilityHint = date
                }
            }
            
            
            if let date = self.lotDict?["production_date"] as? String,!date.isEmpty{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: outputDateFormat, dateStr: date){
                    productionDateLabel.text = formattedDate
                    productionDateLabel.accessibilityHint = date
                }
            }
            
            if let date = self.lotDict?["sell_by_date"] as? String,!date.isEmpty{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd", outputFormat: outputDateFormat, dateStr: date){
                    sellByDateLabel.text = formattedDate
                    sellByDateLabel.accessibilityHint = date
                }
            }
            
            dataStr = ""
            if let txt = self.lotDict?["lot_number"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            lotTextField.text = dataStr
            
            
            if let txt = self.lotDict?["lot_type"] as? String,!txt.isEmpty{
                let btn = UIButton()
                if txt == "SERIAL_BASED" {
                    btn.tag = 1
                }else if txt == "LOT_BASED" {
                    btn.tag = 2
                }
                lotButtonsPressed(btn)
            }
            
            
            dataStr = ""
            if let quantity = self.lotDict?["quantity"] as? Int{
                remainingquantity = remainingquantity + quantity
                dataStr = "\(quantity)"
            }
            quantityTextField.text = dataStr
            
            dataStr = ""
            if let txt = self.lotDict?["sdi"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            referenceTextField.text = dataStr
            
            
        }
    }
    
    func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchAutoIncrementId())
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
        
        if sender != nil && sender?.tag == 1 {
            bestByDateLabel.text = dateStr
            bestByDateLabel.accessibilityHint = dateStrForApi
        }else if sender != nil && sender?.tag == 2 {
            expirationDateLabel.text = dateStr
            expirationDateLabel.accessibilityHint = dateStrForApi
        }else if sender != nil && sender?.tag == 3 {
            productionDateLabel.text = dateStr
            productionDateLabel.accessibilityHint = dateStrForApi
        }else if sender != nil && sender?.tag == 4 {
            sellByDateLabel.text = dateStr
            sellByDateLabel.accessibilityHint = dateStrForApi
        }
    }
    //MARK: - End
    
}
extension ProductEditViewController:SingleScanViewControllerDelegate{
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
                        self.expirationDateLabel.accessibilityHint = String(splitArr[0])
                    }
                }
            }
        }
    }
}
