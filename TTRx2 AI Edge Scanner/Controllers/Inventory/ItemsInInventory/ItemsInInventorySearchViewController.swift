//
//  ItemsInInventorySearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 10/11/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  ItemsInInventorySearchViewDelegate: AnyObject {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class ItemsInInventorySearchViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var gtinTextField: UITextField!
    @IBOutlet weak var skuTextField: UITextField!
    @IBOutlet weak var ndcTextField: UITextField!
    @IBOutlet weak var onlyInStockLabel: UILabel!
    @IBOutlet weak var convertLowestSealableUnitLabel: UILabel!
    
    @IBOutlet weak var advanceSearchButton: UIButton!
    
    @IBOutlet weak var uuidView: UIView!
    @IBOutlet weak var uuidTextField: UITextField!
    
    @IBOutlet weak var isActiveView: UIView!
    @IBOutlet weak var isActiveLabel: UILabel!
    
    @IBOutlet weak var upcView: UIView!
    @IBOutlet weak var upcTextField: UITextField!
    
    @IBOutlet weak var gs1CompanyPrefixView: UIView!
    @IBOutlet weak var gs1CompanyPrefixTextField: UITextField!
    
    @IBOutlet weak var gs1IdView: UIView!
    @IBOutlet weak var gs1IdTextField: UITextField!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    weak var delegate: ItemsInInventorySearchViewDelegate?
    var searchDict = [String:Any]()
    var allLocations:NSDictionary?

    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        setupUI()
        //createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        advanceSearchButton.isSelected = true
        advanceSearchButtonPressed(advanceSearchButton)
        allLocations = UserInfosModel.getLocations()
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
    
    //MARK: - IBAction
    
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1{
            if allLocations == nil {
                return
            }
        
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = true
            controller.nameKeyName = "name"
            controller.listItemsDict = allLocations
            controller.delegate = self
            controller.type = "Locations".localized()
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        } else if sender.tag == 2 {
            let parentList = [["name" : "Yes", "value" : "true"],["name" : "No", "value": "false"]]
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = parentList
            controller.type = "Only in stock".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        } else if sender.tag == 3 {
            let parentList = [["name" : "Yes", "value" : "true"],["name" : "No", "value": "false"]]
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = parentList
            controller.type = "Convert lowest sealable unit".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        } else {
            let parentList = [["name" : "All", "value" : ""],["name" : "Yes", "value" : "true"],["name" : "No", "value": "false"]]
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = parentList
            controller.type = "Is Active".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func locationScanButtonPressed(_ sender: UIButton) {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
                controller.delegate = self
                controller.isForLocationSelection=true
                self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func advanceSearchButtonPressed(_ sender: UIButton) {
        advanceSearchButton.isSelected.toggle()
        if advanceSearchButton.isSelected {
            uuidView.isHidden = false
            upcView.isHidden = false
            gs1IdView.isHidden = false
            gs1CompanyPrefixView.isHidden = false
            isActiveView.isHidden=false
            mainScroll.scrollToBottom(animated: true)
         }else{
            uuidView.isHidden = true
            upcView.isHidden = true
            gs1IdView.isHidden = true
            isActiveView.isHidden=true
            gs1CompanyPrefixView.isHidden = true
        }
    }
    
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
                
        var locationstr = ""
        if let str = locationLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            locationstr = str
        }
        var locationstrShow = ""
        if let str = locationLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            locationstrShow = str
        }
        
        var productnamestr = ""
        if let str = productNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            productnamestr = str
        }
        
        var gtinstr = ""
        if let str = gtinTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            gtinstr = str
        }
        
        var skustr = ""
        if let str = skuTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            skustr = str
        }
        
        var ndcstr = ""
        if let str = ndcTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            ndcstr = str
        }
        
        var onlyInStockStr = ""
        if let str = onlyInStockLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            onlyInStockStr = str
        }
        var onlyInStockStrShow = ""
        if let str = onlyInStockLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            onlyInStockStrShow = str
        }
        
        var convertLowestSealableStr = ""
        if let str = convertLowestSealableUnitLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            convertLowestSealableStr = str
        }
        var convertLowestSealableStrShow = ""
        if let str = convertLowestSealableUnitLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            convertLowestSealableStrShow = str
        }
        
//---- Advance search
        var uuidstr = ""
        if let str = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            uuidstr = str
        }
        
        var isActiveStr = ""
        if let str = isActiveLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            isActiveStr = str
        }
        var isActiveStrShow = ""
        if let str = isActiveLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            isActiveStrShow = str
        }
        
        var upcstr = ""
        if let str = upcTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            upcstr = str
        }
        
        var gs1idstr = ""
        if let str = gs1IdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            gs1idstr = str
        }
        
        var gs1companyprefixstr = ""
        if let str = gs1CompanyPrefixTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            gs1companyprefixstr = str
        }
        
        var appendStr = ""
        
        if !locationstr.isEmpty{
            appendStr = appendStr + "location_uuid=\(locationstr)&"
            searchDict["location_uuid"] = locationstr
            searchDict["location_uuid_show"] = locationstrShow
        }else{
            searchDict["location_uuid"] = ""
            searchDict["location_uuid_show"] = ""
        }
        
        if !productnamestr.isEmpty{
            appendStr = appendStr + "product_name=\(productnamestr)&"
            searchDict["product_name"] = productnamestr
        }else{
            searchDict["product_name"] = ""
        }
        
        
        if !gtinstr.isEmpty{
            appendStr = appendStr + "gtin14=\(gtinstr)&"
            searchDict["gtin14"] = gtinstr
        }else{
            searchDict["gtin14"] = ""
        }
        
        if !skustr.isEmpty{
            appendStr = appendStr + "sku=\(skustr)&"
            searchDict["product_sku"] = skustr
        }else{
            searchDict["product_sku"] = ""
        }
        
        if !ndcstr.isEmpty{
            appendStr = appendStr + "identifiers_value=\(ndcstr)&"
            searchDict["product_ndc"] = ndcstr
        }else{
            searchDict["product_ndc"] = ""
        }
        
        if !onlyInStockStr.isEmpty{
            appendStr = appendStr + "only_in_stock=\(onlyInStockStr)&"
            searchDict["onlyInStock"] = onlyInStockStr
            searchDict["onlyInStockShow"] = onlyInStockStrShow
        }else{
            searchDict["onlyInStock"] = ""
            searchDict["onlyInStockShow"] = ""
        }
        
        if !convertLowestSealableStr.isEmpty{
            appendStr = appendStr + "is_convert_lowest_sealable_unit=\(convertLowestSealableStr)&"
            searchDict["convertLowestSealable"] = convertLowestSealableStr
            searchDict["convertLowestSealableShow"] = convertLowestSealableStrShow
        }else{
            searchDict["convertLowestSealable"] = ""
            searchDict["convertLowestSealableShow"] = ""
        }
        
        
        //-----advance
        
        if !uuidstr.isEmpty{
            appendStr = appendStr + "product_uuid=\(uuidstr)&"
            searchDict["product_uuid"] = uuidstr
        }else{
            searchDict["product_uuid"] = ""
        }
        
        if !isActiveStr.isEmpty{
            appendStr = appendStr + "is_active=\(isActiveStr)&"
            searchDict["isActive"] = isActiveStr
            searchDict["isActiveShow"] = isActiveStrShow
        }else{
            searchDict["isActive"] = ""
            searchDict["isActiveShow"] = ""
        }
        
        
        if !upcstr.isEmpty{
            appendStr = appendStr + "upc=\(upcstr)&"
            searchDict["product_upc"] = upcstr
        }else{
            searchDict["product_upc"] = ""
        }
        
        if !gs1idstr.isEmpty{
            appendStr = appendStr + "gs1_id=\(gs1idstr)&"
            searchDict["product_gs1_id"] = gs1idstr
        }else{
            searchDict["product_gs1_id"] = ""
        }
        
        
        if !gs1companyprefixstr.isEmpty{
            appendStr = appendStr + "gs1_company_prefix=\(gs1companyprefixstr)&"
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
        
        locationLabel.text = "Location".localized()
        locationLabel.accessibilityHint = ""
        locationLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        
        productNameTextField.text = ""
        ndcTextField.text = ""
        gtinTextField.text = ""
        skuTextField.text = ""
        
        onlyInStockLabel.text = "Only in stock".localized()
        onlyInStockLabel.accessibilityHint = ""
        onlyInStockLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        
        convertLowestSealableUnitLabel.text = "Convert lowest sealable unit".localized()
        convertLowestSealableUnitLabel.accessibilityHint = ""
        convertLowestSealableUnitLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        
        
        uuidTextField.text = ""
        
        isActiveLabel.text = "Is Active".localized()
        isActiveLabel.accessibilityHint = ""
        isActiveLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        
        upcTextField.text = ""
        gs1IdTextField.text = ""
        gs1CompanyPrefixTextField.text = ""
        
        self.delegate?.clearSearch()
        self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
        advanceSearchButton.isSelected = true
        advanceSearchButtonPressed(advanceSearchButton)
    }
    //MARK: - End
    
    //MARK: - Private Method
    func setupUI(){
        productNameTextField.delegate = self
        ndcTextField.delegate = self
        gtinTextField.delegate = self
        skuTextField.delegate = self
        uuidTextField.delegate = self
        upcTextField.delegate = self
        gs1IdTextField.delegate = self
        gs1CompanyPrefixTextField.delegate = self
    }
    
    func populateSearchData(){
        if !searchDict.isEmpty {
            
            if let txt = searchDict["location_uuid"] as? String,!txt.isEmpty{
                locationLabel.accessibilityHint = txt
                locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
            if let txt = searchDict["location_uuid_show"] as? String,!txt.isEmpty{
                locationLabel.text=txt
            }
            
            
                                    
            if let txt = searchDict["product_name"] as? String,!txt.isEmpty{
                productNameTextField.text = txt
            }
            
            if let txt = searchDict["gtin14"] as? String,!txt.isEmpty{
                gtinTextField.text = txt
            }
            
            if let txt = searchDict["product_sku"] as? String,!txt.isEmpty{
                skuTextField.text = txt
            }
            
            if let txt = searchDict["product_ndc"] as? String,!txt.isEmpty{
                ndcTextField.text = txt
            }
            
            if let txt = searchDict["onlyInStock"] as? String,!txt.isEmpty{
                onlyInStockLabel.accessibilityHint = txt
                onlyInStockLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            if let txt = searchDict["onlyInStockShow"] as? String,!txt.isEmpty{
                onlyInStockLabel.text=txt
            }
            
            if let txt = searchDict["convertLowestSealable"] as? String,!txt.isEmpty{
                convertLowestSealableUnitLabel.accessibilityHint = txt
                convertLowestSealableUnitLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            if let txt = searchDict["convertLowestSealableShow"] as? String,!txt.isEmpty{
                convertLowestSealableUnitLabel.text=txt
            }
            
            
            
                       
            if let txt = searchDict["product_uuid"] as? String,!txt.isEmpty{
                uuidTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["isActive"] as? String,!txt.isEmpty{
                isActiveLabel.accessibilityHint = txt
                isActiveLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            if let txt = searchDict["isActiveShow"] as? String,!txt.isEmpty{
                isActiveLabel.text=txt
            }
            
            
            if let txt = searchDict["product_upc"] as? String,!txt.isEmpty{
                upcTextField.text = txt
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
            
            
            if let txt = searchDict["product_gcp"] as? String,!txt.isEmpty{
                gs1CompanyPrefixTextField.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
        }
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
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 1 {
            if let name = data["name"] as? String{
                locationLabel.text = name
                locationLabel.accessibilityHint = itemStr
                locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
        }
    }
    
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil{
            if sender?.tag == 2{
                if let name = data["name"] as? String{
                    onlyInStockLabel.text = name
                    onlyInStockLabel.accessibilityHint = name
                    onlyInStockLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
                if let valuestr = data["value"] as? String{
                    onlyInStockLabel.accessibilityHint = valuestr
                }
            } else if sender?.tag == 3{
                if let name = data["name"] as? String{
                    convertLowestSealableUnitLabel.text = name
                    convertLowestSealableUnitLabel.accessibilityHint = name
                    convertLowestSealableUnitLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
                if let valuestr = data["value"] as? String{
                    convertLowestSealableUnitLabel.accessibilityHint = valuestr
                }
            } else{
                if let name = data["name"] as? String{
                    isActiveLabel.text = name
                    isActiveLabel.accessibilityHint = name
                    isActiveLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
                if let valuestr = data["value"] as? String{
                    isActiveLabel.accessibilityHint = valuestr
                }
            }
        }
    }
    //MARK: - End
    
    
}

extension ItemsInInventorySearchViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
    
    func didReceiveBarcodeLocationScan(codeDetails:[String:Any]){
        let locationCode = codeDetails["scannedCodes"] as! String
        print(locationCode)
        if let dict = allLocations![locationCode] as? Dictionary<String,Any> {
            let btn=UIButton()
            btn.tag=1
            self.selectedItem(itemStr: locationCode, data: dict as NSDictionary,sender: btn)
        }else{
            Utility.showPopup(Title: "Error!", Message: "Selected location is not available.".localized() , InViewC: self)
        }
    }
}
