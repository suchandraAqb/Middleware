//
//  PurchaseOrderListFilter.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 26/05/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PurchaseOrderListFilter: BaseViewController, SingleSelectDropdownDelegate {
    
    @IBOutlet weak var txtPoNumber: UITextField!
    @IBOutlet weak var txtOrderNumber: UITextField!
//    @IBOutlet weak var gtinTextField: UITextField!
//    @IBOutlet weak var genericNameTextField: UITextField!
//    @IBOutlet weak var upcTextField: UITextField!
//    @IBOutlet weak var skuTextField: UITextField!
//    @IBOutlet weak var uuidTextField: UITextField!
//    @IBOutlet weak var productgs1TextField: UITextField!
//    @IBOutlet weak var productgs1idTextField: UITextField!
    
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
//    @IBOutlet weak var identifierLabel: UILabel!
//    @IBOutlet weak var productgs1View: UIView!
//    @IBOutlet weak var productgs1idView: UIView!
//    @IBOutlet weak var uuidView: UIView!
//    @IBOutlet weak var genericNameView: UIView!
//    @IBOutlet weak var upcView: UIView!
    
    @IBOutlet weak var advanceSearchButton: UIButton!
    
    weak var delegate: SearchViewDelegate?
    var searchDict = [String:Any]()
    
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        setupUI()
//        createInputAccessoryView()
        createInputAccessoryViewAddedScan()

        advanceSearchButton.isSelected = true
        advanceSearchButtonPressed(advanceSearchButton)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateSearchData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    
    //MARK: - Custom Method
    func setupUI(){
        txtPoNumber.delegate = self
        txtOrderNumber.delegate = self
//        gtinTextField.delegate = self
//        genericNameTextField.delegate = self
//        skuTextField.delegate = self
//        uuidTextField.delegate = self
//        productgs1TextField.delegate = self
//        productgs1idTextField.delegate = self
    }
    
    func populateSearchData(){
        
        if !searchDict.isEmpty {
            
//            if let txt = searchDict["identifier_us_ndc__precision_option"] as? String,!txt.isEmpty{
//                identifierLabel.text = txt
//                identifierLabel.accessibilityHint = txt
//                identifierLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
//                advanceSearchButtonPressed(advanceSearchButton)
//            }
            
            if let txt = searchDict["po_nbr"] as? String,!txt.isEmpty{
                txtPoNumber.text = txt
            }
            
            if let txt = searchDict["order_nbr"] as? String,!txt.isEmpty{
                txtOrderNumber.text = txt
            }
            
//            if let txt = searchDict["gtin14"] as? String,!txt.isEmpty{
//                gtinTextField.text = txt
//            }
            
//            if let txt = searchDict["class_pharmaceutical__generic_name"] as? String,!txt.isEmpty{
//                genericNameTextField.text = txt
//            }
            
//            if let txt = searchDict["sku"] as? String,!txt.isEmpty{
//                skuTextField.text = txt
//            }
//            if let txt = searchDict["upc"] as? String,!txt.isEmpty{
//                upcTextField.text = txt
//            }
//
//            if let txt = searchDict["uuid"] as? String,!txt.isEmpty{
//                uuidTextField.text = txt
//                if !advanceSearchButton.isSelected{
//                   advanceSearchButtonPressed(advanceSearchButton)
//                }
//            }
//
//            if let txt = searchDict["gs1_company_prefix"] as? String,!txt.isEmpty{
//                productgs1TextField.text = txt
//                if !advanceSearchButton.isSelected{
//                   advanceSearchButtonPressed(advanceSearchButton)
//                }
//            }
//
//            if let txt = searchDict["gs1_id"] as? String,!txt.isEmpty{
//                productgs1idTextField.text = txt
//                if !advanceSearchButton.isSelected{
//                   advanceSearchButtonPressed(advanceSearchButton)
//                }
//            }
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        let paymentModeList = [["name" : "All Possible Values"],["name" : "Strict"],["name" : "Replace Dash Only"],["name" : "Replace Dash Or Incomplete Value"]]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = paymentModeList
        controller.type = "Trading Partners"
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func advanceSearchButtonPressed(_ sender: UIButton) {
        
        advanceSearchButton.isSelected.toggle()
        if advanceSearchButton.isSelected {
            
//            productgs1View.isHidden = false
//            productgs1idView.isHidden = false
//            uuidView.isHidden = false
//            genericNameView.isHidden = false
//            upcView.isHidden = false
//            mainScroll.scrollToBottom(animated: true)
            
         }else{
            
//            productgs1View.isHidden = true
//            productgs1idView.isHidden = true
//            uuidView.isHidden = true
//            genericNameView.isHidden = true
//            upcView.isHidden = true
//            UIView.animate(withDuration: 0.3) {
//                self.mainScroll.layoutIfNeeded()
//            }
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
//        var identifier = ""
//        if let str = identifierLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            identifier = str.uppercased()
//        }
        
        var po_no = ""
        if let str = txtPoNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            po_no = str
        }
        
        var order_no = ""
        if let str = txtOrderNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            order_no = str
        }
        
//        var gtinstr = ""
//        if let str = gtinTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            gtinstr = str
//        }
//
//        var genericName = ""
//        if let str = genericNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            genericName = str
//        }
//
//        var skustr = ""
//        if let str = skuTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            skustr = str
//        }
//
//        var uuidstr = ""
//        if let str = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            uuidstr = str
//        }
//
//        var productgs1str = ""
//        if let str = productgs1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            productgs1str = str
//        }
//
//        var productgs1idstr = ""
//        if let str = productgs1idTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            productgs1idstr = str
//        }
//
//        var upc = ""
//        if let str = upcTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            upc = str
//        }
        
        var appendStr = ""
        
//        if !identifier.isEmpty{
//            appendStr = appendStr + "identifier_us_ndc__precision_option=\(identifier)&"
//            searchDict["identifier_us_ndc__precision_option"] = identifier.capitalized
//        }else{
//            searchDict["identifier_us_ndc__precision_option"] = ""
//        }
        
        if !po_no.isEmpty{
            appendStr = appendStr + "po_nbr=\(po_no)&"
            searchDict["po_nbr"] = po_no
        }else{
            searchDict["po_nbr"] = ""
        }
        
        if !order_no.isEmpty{
            appendStr = appendStr + "order_nbr=\(order_no)&"
            searchDict["order_nbr"] = order_no
        }else{
            searchDict["order_nbr"] = ""
        }
        
//        if !gtinstr.isEmpty{
//            appendStr = appendStr + "gtin14=\(gtinstr)&"
//            searchDict["gtin14"] = gtinstr
//        }else{
//            searchDict["gtin14"] = ""
//        }
//
//        if !genericName.isEmpty{
//            appendStr = appendStr + "class_pharmaceutical__generic_name=\(genericName)&"
//            searchDict["class_pharmaceutical__generic_name"] = genericName
//        }else{
//            searchDict["class_pharmaceutical__generic_name"] = ""
//        }
//
//        if !skustr.isEmpty{
//            appendStr = appendStr + "sku=\(skustr)&"
//            searchDict["sku"] = skustr
//        }else{
//            searchDict["sku"] = ""
//        }
//
//        if !uuidstr.isEmpty{
//            appendStr = appendStr + "uuid=\(uuidstr)&"
//            searchDict["uuid"] = uuidstr
//        }else{
//            searchDict["uuid"] = ""
//        }
//
//        if !productgs1str.isEmpty{
//            appendStr = appendStr + "gs1_company_prefix=\(productgs1str)&"
//            searchDict["gs1_company_prefix"] = productgs1str
//        }else{
//            searchDict["gs1_company_prefix"] = ""
//        }
//
//        if !productgs1idstr.isEmpty{
//            appendStr = appendStr + "gs1_id=\(productgs1idstr)&"
//            searchDict["gs1_id"] = productgs1idstr
//        }else{
//            searchDict["gs1_id"] = ""
//        }
//
//        if !upc.isEmpty{
//            appendStr = appendStr + "upc=\(upc)&"
//            searchDict["upc"] = upc
//        }else{
//            searchDict["upc"] = ""
//        }
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
    }
     
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        
        doneTyping()
        searchDict = [String:Any]()
        txtPoNumber.text = ""
        txtOrderNumber.text = ""
//        gtinTextField.text = ""
//        genericNameTextField.text = ""
//        skuTextField.text = ""
//        uuidTextField.text = ""
//        productgs1TextField.text = ""
//        productgs1idTextField.text = ""
//        identifierLabel.text = "Identifier US NDC precision option"
//        identifierLabel.accessibilityHint = ""
//        identifierLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        self.delegate?.clearSearch()
        self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
        advanceSearchButton.isSelected = true
        advanceSearchButtonPressed(advanceSearchButton)
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
    //MARK: - SingleSelectDropdownDelegate
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil{
            if let name = data["name"] as? String{
//                identifierLabel.text = name
//                identifierLabel.accessibilityHint = name
//                identifierLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
        }
    }
    //MARK: - End
}

extension PurchaseOrderListFilter:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}
