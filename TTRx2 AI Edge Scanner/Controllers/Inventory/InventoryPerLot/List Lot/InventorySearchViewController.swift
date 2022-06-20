//
//  InventorySearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 23/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  InventorySearchViewDelegate: class {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class InventorySearchViewController: BaseViewController {
    
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var ndcTextField: UITextField!
    @IBOutlet weak var gtinTextField: UITextField!
    @IBOutlet weak var lotNumberTextField: UITextField!
    @IBOutlet weak var skuTextField: UITextField!
    
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var gs1IdTextField: UITextField!
    @IBOutlet weak var genericNameTextField: UITextField!
    @IBOutlet weak var gs1CompanyPrefixTextField: UITextField!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    

    @IBOutlet weak var uuidView: UIView!
    @IBOutlet weak var gs1IdView: UIView!
    @IBOutlet weak var genericNameView: UIView!
    @IBOutlet weak var gs1CompanyPrefixView: UIView!
    
    @IBOutlet weak var advanceSearchButton: UIButton!
    
    weak var delegate: InventorySearchViewDelegate?
    var searchDict = [String:Any]()
    
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        setupUI()
        //createInputAccessoryView()
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
        productNameTextField.delegate = self
        ndcTextField.delegate = self
        gtinTextField.delegate = self
        lotNumberTextField.delegate = self
        skuTextField.delegate = self
        uuidTextField.delegate = self
        gs1IdTextField.delegate = self
        genericNameTextField.delegate = self
        gs1CompanyPrefixTextField.delegate = self
        
    }
    
    func populateSearchData(){
        if !searchDict.isEmpty {
                                    
            if let txt = searchDict["product_name"] as? String,!txt.isEmpty{
                productNameTextField.text = txt
            }
            
            if let txt = searchDict["product_ndc"] as? String,!txt.isEmpty{
                ndcTextField.text = txt
            }
            
            if let txt = searchDict["gtin14"] as? String,!txt.isEmpty{
                gtinTextField.text = txt
            }
            
            if let txt = searchDict["lot_number"] as? String,!txt.isEmpty{
                lotNumberTextField.text = txt
            }
            
            if let txt = searchDict["product_sku"] as? String,!txt.isEmpty{
                skuTextField.text = txt
            }
            
                       
            if let txt = searchDict["product_uuid"] as? String,!txt.isEmpty{
                uuidTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["product_gs1_id"] as? String,!txt.isEmpty{
                gs1IdTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["generic_name"] as? String,!txt.isEmpty{
                genericNameTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["product_gcp"] as? String,!txt.isEmpty{
                gs1CompanyPrefixTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            
            
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
     
    @IBAction func advanceSearchButtonPressed(_ sender: UIButton) {
        advanceSearchButton.isSelected.toggle()
        if advanceSearchButton.isSelected {
            uuidView.isHidden = false
            gs1IdView.isHidden = false
            genericNameView.isHidden = false
            gs1CompanyPrefixView.isHidden = false
            mainScroll.scrollToBottom(animated: true)
         }else{
            
            uuidView.isHidden = true
            gs1IdView.isHidden = true
            genericNameView.isHidden = true
            gs1CompanyPrefixView.isHidden = true
            
        }
    }
    
    
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
                
        var productnamestr = ""
        if let str = productNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            productnamestr = str
        }
        
        var ndcstr = ""
        if let str = ndcTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            ndcstr = str
        }
        
        var gtinstr = ""
        if let str = gtinTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            gtinstr = str
        }
        
        var lotnumberstr = ""
        if let str = lotNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            lotnumberstr = str
        }
        
        var skustr = ""
        if let str = skuTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            skustr = str
        }
        
        var uuidstr = ""
        if let str = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            uuidstr = str
        }
        
        var gs1idstr = ""
        if let str = gs1IdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            gs1idstr = str
        }
        
        var genericnamestr = ""
        if let str = genericNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            genericnamestr = str
        }
        
        var gs1companyprefixstr = ""
        if let str = gs1CompanyPrefixTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            gs1companyprefixstr = str
        }
        
        var appendStr = ""
        
        if !productnamestr.isEmpty{
            appendStr = appendStr + "product_name=\(productnamestr)&"
            searchDict["product_name"] = productnamestr
        }else{
            searchDict["product_name"] = ""
        }
        
        if !ndcstr.isEmpty{
            appendStr = appendStr + "product_ndc=\(ndcstr)&"
            searchDict["product_ndc"] = ndcstr
        }else{
            searchDict["product_ndc"] = ""
        }
        
        if !gtinstr.isEmpty{
            appendStr = appendStr + "gtin14=\(gtinstr)&"
            searchDict["gtin14"] = gtinstr
        }else{
            searchDict["gtin14"] = ""
        }
        
        if !lotnumberstr.isEmpty{
            appendStr = appendStr + "lot_number=\(lotnumberstr)&"
            searchDict["lot_number"] = lotnumberstr
        }else{
            searchDict["lot_number"] = ""
        }
        
        if !skustr.isEmpty{
            appendStr = appendStr + "product_sku=\(skustr)&"
            searchDict["product_sku"] = skustr
        }else{
            searchDict["product_sku"] = ""
        }
        
        if !uuidstr.isEmpty{
            appendStr = appendStr + "product_uuid=\(uuidstr)&"
            searchDict["product_uuid"] = uuidstr
        }else{
            searchDict["product_uuid"] = ""
        }
        
        if !gs1idstr.isEmpty{
            appendStr = appendStr + "product_gs1_id=\(gs1idstr)&"
            searchDict["product_gs1_id"] = gs1idstr
        }else{
            searchDict["product_gs1_id"] = ""
        }
        
        if !genericnamestr.isEmpty{
            appendStr = appendStr + "generic_name=\(genericnamestr)&"
            searchDict["generic_name"] = genericnamestr
        }else{
            searchDict["generic_name"] = ""
        }
        
        if !gs1companyprefixstr.isEmpty{
            appendStr = appendStr + "product_gcp=\(gs1companyprefixstr)&"
            searchDict["product_gcp"] = gs1companyprefixstr
        }else{
            searchDict["product_gcp"] = ""
        }
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
        
      
        
    }
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        doneTyping()
        searchDict = [String:Any]()
        productNameTextField.text = ""
        ndcTextField.text = ""
        gtinTextField.text = ""
        lotNumberTextField.text = ""
        skuTextField.text = ""
        uuidTextField.text = ""
        gs1IdTextField.text = ""
        genericNameTextField.text = ""
        gs1CompanyPrefixTextField.text = ""
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
    
}
extension InventorySearchViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}
