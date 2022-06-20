//
//  FailedItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Dhiman on 19/01/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol PickingFilterItemsViewDelegate: class{
    @objc optional func searchFilterData(productUuid:String,productName:String,lot:String,serial:String,ndc:String,dateStr:String)
    @objc optional func clearAll()

}

class PickingFilterItemsViewController: BaseViewController,DatePickerViewDelegate {

    @IBOutlet var productuuidTextField : UITextField!
    @IBOutlet var productNameTextField: UITextField!
    @IBOutlet var lotTextField : UITextField!
    @IBOutlet var ndcTextField: UITextField!
    @IBOutlet var serialTextField: UITextField!
    @IBOutlet weak var searchButton:UIButton!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var dateButton:UIButton!
    @IBOutlet weak var dateView:UIView!
    @IBOutlet weak var serialView:UIView!
    
    weak var delegate : PickingFilterItemsViewDelegate?
    var searchDict = NSMutableDictionary()
    var fromItemsPickedSection:Bool = false

    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height/2.0)
        dateButton.setTitle("Expiration Date".localized(), for: .normal)
        dateButton.setTitleColor(Utility.hexStringToUIColor(hex: "719898"), for: .normal)
        if fromItemsPickedSection{
            serialView.isHidden = true
        }else{
            serialView.isHidden = false
        }
        self.createInputAccessoryView()
        self.populateSearchCriteria()
       
    }
    
    // END
    
    //MARK: - Private Function
    func populateSearchCriteria(){
        var productuuid = ""
        if let product_uuid = searchDict["product_uuid"] as? String,!product_uuid.isEmpty{
            productuuid = product_uuid
        }
        productuuidTextField.text = productuuid
        
        var productname = ""
        if let product_name = searchDict["product_name"] as? String,!product_name.isEmpty{
            productname = product_name
        }
        productNameTextField.text = productname
        
        var lot = ""
        if let lotNumber = searchDict["lot"] as? String,!lotNumber.isEmpty{
            lot = lotNumber
        }
        lotTextField.text = lot
        
        var expirationStr = "Expiration Date".localized()
        dateButton.setTitleColor(Utility.hexStringToUIColor(hex: "719898"), for: .normal)

        if let expirationdate = searchDict["expirationDate"] as? String,!expirationdate.isEmpty{
            if expirationdate != "Expiration Date".localized(){
                expirationStr = expirationdate
                dateButton.setTitleColor(Utility.hexStringToUIColor(hex: "072144"), for: .normal)
            }
        }
        dateButton.setTitle(expirationStr, for: .normal)
        
        var ndc = ""
        if let ndcValue = searchDict["NDC"] as? String,!ndcValue.isEmpty{
            ndc = ndcValue
        }
        ndcTextField.text = ndc

        var productSerial = ""
        if let product_serial = searchDict["serial"] as? String,!product_serial.isEmpty{
            productSerial = product_serial
        }
        serialTextField.text = productSerial
    }
    
    //MARK: - IBAction
    @IBAction func searchButtonPressed(_ sender : UIButton){
        var dateStr:String = (dateButton.titleLabel?.text)!
        if dateStr == "Expiration Date".localized(){
            dateStr = ""
        }
        if productuuidTextField.text!.isEmpty && productNameTextField.text!.isEmpty && lotTextField.text!.isEmpty && dateStr.isEmpty && ndcTextField.text!.isEmpty && serialTextField.text!.isEmpty {
            return
        }
        doneTyping()
        var productuuid = ""
        if let product_uuid = productuuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!product_uuid.isEmpty{
                productuuid = product_uuid
            }
        var productname = ""
        if let product_name = productNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!product_name.isEmpty{
                productname = product_name
            }
        var lot = ""
        if let lotNumber = lotTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!lotNumber.isEmpty{
                lot = lotNumber
            }

        
        var ndc = ""
        if let ndcValue = ndcTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!ndcValue.isEmpty{
                ndc = ndcValue
            }

        var productSerial = ""
        if let product_serial = serialTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!product_serial.isEmpty{
                productSerial = product_serial
            }
        
        if let dateStr = dateButton.titleLabel?.text,!dateStr.isEmpty{
            if dateStr == "Expiration Date".localized(){
                dateButton.setTitle("", for: .normal)
            }
        }
              
        self.delegate?.searchFilterData!(productUuid: productuuid as String, productName: productname as String, lot: lot as String, serial: productSerial as String, ndc: ndc as String,dateStr: (dateButton.titleLabel?.text!)! as String)
        self.navigationController?.popViewController(animated: true)
        }
    
    @IBAction func clearAllButtonPressed(_ sender: UIButton){
        productuuidTextField.text = ""
        productNameTextField.text = ""
        lotTextField.text = ""
        ndcTextField.text = ""
        serialTextField.text = ""
        dateButton.setTitle("Expiration Date".localized(), for: .normal)
        dateButton.setTitleColor(Utility.hexStringToUIColor(hex: "719898"), for: .normal)
        searchDict = NSMutableDictionary()
        self.delegate?.clearAll!()
      //  self.navigationController?.popViewController(animated: true)

    }
    @IBAction func productScanButtonPressed(_ sender:UIButton){
        let controller1 = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller1.delegate = self
        controller1.isFromPickingSingleItemScan = true
        self.navigationController?.pushViewController(controller1, animated: true)
    }
    @IBAction func datePickerButtonPressed(_ sender:UIButton){
        doneTyping()
        let controller1 = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller1.delegate = self
        controller1.sender = sender
        self.present(controller1, animated: true, completion: nil)
    }
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
//            formatter.dateFormat = "MM-dd-yyyy"
           // let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            dateButton.setTitle(dateStrForApi, for: .normal)
            dateButton.setTitleColor(Utility.hexStringToUIColor(hex: "072144"), for: .normal)
        }
    }
}
extension PickingFilterItemsViewController:SingleScanViewControllerDelegate{
    internal func didScanPickingFilterOption(verifiedItem:[[String:Any]]){
        if verifiedItem.count > 0 {
            let verifiedDict = verifiedItem.first as NSDictionary?
        
            if let lotvalue = verifiedDict?["lot_number"] as? String, !lotvalue.isEmpty {
                self.lotTextField.text = lotvalue
            }
            if let serialvalue = verifiedDict?["serial"] as? String, !serialvalue.isEmpty {
                self.serialTextField.text = serialvalue
            }
            if let expirationDatevalue = verifiedDict?["expiration_date"] as? String, !expirationDatevalue.isEmpty {
                self.dateButton.setTitle(expirationDatevalue, for: .normal)
                dateButton.setTitleColor(Utility.hexStringToUIColor(hex: "072144"), for: .normal)

            }
            if let ndcvalue = verifiedDict?["product_ndc"] as? String, !ndcvalue.isEmpty {
                self.ndcTextField.text = ndcvalue
            }
            if let uuidvalue = verifiedDict?["product_uuid"] as? String, !uuidvalue.isEmpty {
                self.productuuidTextField.text = uuidvalue
            }
            if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                let filteredArray = allproducts.filter { $0["uuid"] as? String == self.productuuidTextField.text}
                if filteredArray.count > 0 {
                    let dict = filteredArray.first
                    self.productNameTextField.text = dict!["name"] as? String
                    }
                }
            }
        }
}
//MARK: - DatePickerViewDelegate

//MARK: - End
