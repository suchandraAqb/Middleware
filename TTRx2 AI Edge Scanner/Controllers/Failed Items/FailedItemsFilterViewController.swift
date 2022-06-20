//
//  FailedItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Dhiman on 19/01/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol FailedItemsFilterViewDelegate: class{
    @objc optional func searchFilterData(productUuid:String,productName:String,lot:String,serial:String,ndc:String,gtin14:String)
    @objc optional func clearAll()

}

class FailedItemsFilterViewController: BaseViewController {

    @IBOutlet var productuuidTextField : UITextField!
    @IBOutlet var productNameTextField: UITextField!
    @IBOutlet var lotTextField : UITextField!
    @IBOutlet var gtin14TextField: UITextField!
    @IBOutlet var ndcTextField: UITextField!
    @IBOutlet var serialTextField: UITextField!
    @IBOutlet weak var searchButton:UIButton!
    @IBOutlet weak var searchContainer: UIView!
    weak var delegate : FailedItemsFilterViewDelegate?
    var searchDict = NSMutableDictionary()


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
        
        var gtin14 = ""
        if let product_gtin14 = searchDict["gtin14"] as? String,!product_gtin14.isEmpty{
            gtin14 = product_gtin14
        }
        gtin14TextField.text = gtin14
        
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
        if productuuidTextField.text!.isEmpty && productNameTextField.text!.isEmpty && lotTextField.text!.isEmpty && gtin14TextField.text!.isEmpty && ndcTextField.text!.isEmpty && serialTextField.text!.isEmpty {
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
        var gtin14 = ""
        if let product_gtin14 = gtin14TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!product_gtin14.isEmpty{
                gtin14 = product_gtin14
            }
        var ndc = ""
        if let ndcValue = ndcTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!ndcValue.isEmpty{
                ndc = ndcValue
            }

        var productSerial = ""
        if let product_serial = serialTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!product_serial.isEmpty{
                productSerial = product_serial
            }
              
        self.delegate?.searchFilterData!(productUuid: productuuid as String, productName: productname as String, lot: lot as String, serial: productSerial as String, ndc: ndc as String, gtin14: gtin14 as String)
        self.navigationController?.popViewController(animated: true)
        }
    
    @IBAction func clearAllButtonPressed(_ sender: UIButton){
        productuuidTextField.text = ""
        productNameTextField.text = ""
        lotTextField.text = ""
        gtin14TextField.text = ""
        ndcTextField.text = ""
        serialTextField.text = ""
        searchDict = NSMutableDictionary()
        self.delegate?.clearAll!()
      //  self.navigationController?.popViewController(animated: true)

    }
    @IBAction func productScanButtonPressed(_ sender:UIButton){
        let controller1 = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller1.delegate = self
        controller1.isFromBarCodeCpature = true
        self.navigationController?.pushViewController(controller1, animated: true)
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
}
//MARK: - End
extension FailedItemsFilterViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
         if let value = codeDetails["scannedCodes"] as? String, !value.isEmpty {
            let details = UtilityScanning(with:value).decoded_info
            if (details.keys.contains("10")) {
                if let lot = details["10"]?["value"] as? String{
                    self.lotTextField.text = lot
                    }
                }
             if(details.keys.contains("21")){
                 if let serial = details["21"]?["value"] as? String{
                     self.serialTextField.text = serial
                 }
             }
             if(details.keys.contains("01")){
                 if let gtin14 = details["01"]?["value"] as? String{
                     self.gtin14TextField.text = gtin14
                 }
            }
             if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                let filteredArray = allproducts.filter { $0["gtin14"] as? String == self.gtin14TextField.text }
                 if filteredArray.count > 0 {
                     let dict = filteredArray.first
                     self.productuuidTextField.text = dict!["uuid"] as? String
                     self.productNameTextField.text = dict!["name"] as? String
                     self.ndcTextField.text = dict!["identifier_us_ndc"] as? String
                 }
             }
        }
    }
}
