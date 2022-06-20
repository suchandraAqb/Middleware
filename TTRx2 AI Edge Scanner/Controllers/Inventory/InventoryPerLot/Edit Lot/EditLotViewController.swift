//
//  EditLotViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 07/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  EditLotViewDelegate: class {
    @objc optional func lotUpdated()
}

class EditLotViewController: BaseViewController,DatePickerViewDelegate,ConfirmationViewDelegate {
    
    weak var delegate: EditLotViewDelegate?
    
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lotNumberTextField: UITextField!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    @IBOutlet weak var prductionDateLabel: UILabel!
    @IBOutlet weak var sellByDateLabel: UILabel!
    @IBOutlet weak var bestByDateLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    var lotDetailsDict = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        lotNumberTextField.inputAccessoryView = inputAccView
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.setRoundCorner(cornerRadious: 10)
        
        saveButton.setRoundCorner(cornerRadious: saveButton.frame.size.height/2.0)
        
        popuLateDetails()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Custom Methods
    func saveData()->NSMutableDictionary{
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
        if let txt = lotNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "new_lot_number")
        }
        
        if let txt = lotDetailsDict["lot_number"] as? String,!txt.isEmpty{
            otherDetailsDict.setValue(txt, forKey: "lot_number")
        }
        
        if let txt = prductionDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "production_date")
        }
        
        if let txt = sellByDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "sell_by_date")
        }
        
        if let txt = bestByDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "best_by_date")
        }
        
        if let txt = expirationDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "expiration_date")
        }
        
        return otherDetailsDict
        
        
    }
    
    func formValidation(_ dataDict:NSMutableDictionary)->Bool{
        
        var isValidated = true
            
        let lot_number = dataDict["new_lot_number"] as? String ?? ""
        let production_date = dataDict["production_date"] as? String ?? ""
        let expiration_date = dataDict["expiration_date"] as? String ?? ""
        let bestBy = dataDict["best_by_date"] as? String ?? ""
        let sellBy = dataDict["sell_by_date"] as? String ?? ""
        
        var pDate:Date?
        if !production_date.isEmpty{
            pDate = Utility.dateFromString(sourceformat: "yyyy-MM-dd", dateStr: production_date)
        }
      
        var eDate:Date?
        if !expiration_date.isEmpty{
            eDate = Utility.dateFromString(sourceformat: "yyyy-MM-dd", dateStr: expiration_date)
        }
        
        var bDate:Date?
        if !bestBy.isEmpty{
            bDate = Utility.dateFromString(sourceformat: "yyyy-MM-dd", dateStr: bestBy)
        }
        
        var sDate:Date?
        if !sellBy.isEmpty{
            sDate = Utility.dateFromString(sourceformat: "yyyy-MM-dd", dateStr: sellBy)
        }
        
    
        if lot_number.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter Lot.".localized(), InViewC: self)
           isValidated = false
        }else if production_date.isEmpty {
           Utility.showPopup(Title: App_Title, Message: "Please select production date.".localized(), InViewC: self)
            isValidated = false
               
        }else if expiration_date.isEmpty {
           Utility.showPopup(Title: App_Title, Message: "Please select expiration date.".localized(), InViewC: self)
            isValidated = false
        }
        else if pDate != nil && eDate != nil && eDate!.isBeforeDate(pDate!){
           Utility.showPopup(Title: App_Title, Message: "Expiration date can not be before production date.".localized(), InViewC: self)
           isValidated = false
           
        }else if bDate != nil && eDate != nil && eDate!.isBeforeDate(bDate!){
           Utility.showPopup(Title: App_Title, Message: "Expiration date can not be before best by date.".localized(), InViewC: self)
           isValidated = false
           
        }else if sDate != nil && eDate != nil && eDate!.isBeforeDate(sDate!){
           Utility.showPopup(Title: App_Title, Message: "Expiration date can not be before sell by date.".localized(), InViewC: self)
           isValidated = false
        }else if bDate != nil && pDate != nil && bDate!.isBeforeDate(pDate!){
           Utility.showPopup(Title: App_Title, Message: "Best by date can not be before production date.".localized(), InViewC: self)
           isValidated = false
           
        }else if sDate != nil && pDate != nil && sDate!.isBeforeDate(pDate!){
           Utility.showPopup(Title: App_Title, Message: "Sell by date can not be before production date.".localized(), InViewC: self)
           isValidated = false
        }
        return isValidated
    }
    
    func popuLateDetails(){
        if !lotDetailsDict.isEmpty {
            var dataStr = ""
            if let txt = lotDetailsDict["product_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            titleLabel.text = dataStr
            dataStr = ""
            
            if let txt = lotDetailsDict["lot_number"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            lotNumberTextField.text = dataStr

            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let date = lotDetailsDict["lot_production_date"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: date){
                    prductionDateLabel.text = formattedDate
                    prductionDateLabel.accessibilityHint = date
                }
            }
            
            if let date = lotDetailsDict["lot_sell_by"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: date){
                    sellByDateLabel.text = formattedDate
                    sellByDateLabel.accessibilityHint = date
                }
            }
            
            if let date = lotDetailsDict["lot_best_by"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: date){
                    bestByDateLabel.text = formattedDate
                    bestByDateLabel.accessibilityHint = date
                }
            }
            
            if let date = lotDetailsDict["lot_expiration"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: date){
                    expirationDateLabel.text = formattedDate
                    expirationDateLabel.accessibilityHint = date
                }
            }
        }
    }
    
    func updateLotRequest(requestData:NSMutableDictionary,product_uuid:String){
        
        let appendStr = "\(product_uuid)/lot"
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "GetProducts", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["product_uuid"] as? String {
                        self.delegate?.lotUpdated?()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Lot Updated Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
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
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to cancel".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to confirm".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - End
    
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
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
        if sender != nil{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            
            
            if sender?.tag == 1 {
                prductionDateLabel.text = dateStr
                prductionDateLabel.accessibilityHint = dateStrForApi
            }else if sender?.tag == 2 {
                sellByDateLabel.text = dateStr
                sellByDateLabel.accessibilityHint = dateStrForApi
            }else if sender?.tag == 3 {
                bestByDateLabel.text = dateStr
                bestByDateLabel.accessibilityHint = dateStrForApi
            }else if sender?.tag == 4 {
                expirationDateLabel.text = dateStr
                expirationDateLabel.accessibilityHint = dateStrForApi
            }
            
        }
    }
    //MARK: - End
    
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        let dict = saveData()
        if !formValidation(dict){
            return
        }
        
        if let product_uuid = lotDetailsDict["product_uuid"] as? String,!product_uuid.isEmpty{
            updateLotRequest(requestData: dict, product_uuid: product_uuid)
        }
    }
    func cancelConfirmation() {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - End

}
extension EditLotViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}
