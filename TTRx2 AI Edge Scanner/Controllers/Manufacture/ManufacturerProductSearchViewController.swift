//
//  ManufacturerProductSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 25/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  ManufacturerProductSearchViewDelegate: class {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class ManufacturerProductSearchViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productUuidTextField: UITextField!
    @IBOutlet weak var lotUuidTextField: UITextField!
    @IBOutlet weak var lotNumberTextField: UITextField!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var voidedLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    private var s : String?
    
    weak var delegate: ManufacturerProductSearchViewDelegate?
    var searchDict = [String:Any]()
    var locationsArr = [[String:Any]]()
    
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        setupUI()
        //createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        let global = ["uuid":"","name":"Global"]
        locationsArr.append(global)
        
        
        if let locations = UserInfosModel.getLocations(){
            for (_, data) in locations.enumerated() {
                var dict = [String : Any]()
                dict["uuid"] = data.key
                if let value = data.value as? NSDictionary{
                    dict["name"] = value["name"] ?? ""
                }
                
                locationsArr.append(dict)
               
            }
            
            let btn = UIButton()
            btn.tag = 1
            selecteditem(data: global as NSDictionary, sender: btn)
            
        }
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
        productUuidTextField.delegate = self
        lotUuidTextField.delegate = self
        lotNumberTextField.delegate = self
    }
    
    func populateSearchData(){
        if !searchDict.isEmpty {
            
            
            
            if let txt = searchDict["product_name"] as? String,!txt.isEmpty{
                productNameTextField.text = txt
            }
            
            if let txt = searchDict["product_uuid"] as? String,!txt.isEmpty{
                productUuidTextField.text = txt
            }
            
            if let txt = searchDict["lot_number"] as? String,!txt.isEmpty{
                lotNumberTextField.text = txt
            }
            
            if let txt = searchDict["lot_uuid"] as? String,!txt.isEmpty{
                lotUuidTextField.text = txt
            }
            
            if let txt = searchDict["location_name"] as? String,!txt.isEmpty{
                locationLabel.text = txt
            }
            
            if let txt = searchDict["location_uuid"] as? String,!txt.isEmpty{
                locationLabel.accessibilityHint = txt
            }
            
            if let txt = searchDict["voided"] as? String,!txt.isEmpty{
                voidedLabel.text = txt
            }else{
                voidedLabel.text = "All"
            }
            
            if let txt = searchDict["status"] as? String,!txt.isEmpty{
                statusLabel.text = txt
            }else{
                statusLabel.text = "Open And Closed"
            }
            
        }else{
            voidedLabel.text = "All"
            statusLabel.text = "Open And Closed"
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    @IBAction func voidedButtonPressed(_ sender: UIButton) {
        doneTyping()
        let modeList = [["name" : "All"],["name" : "Yes"],["name" : "No"]]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = modeList
        controller.type = "Voided"
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = locationsArr
        controller.type = "Locations"
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func locationScanButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller.delegate = self
        controller.isForLocationSelection=true
        self.navigationController?.pushViewController(controller, animated: true)
                
//                self.didReceiveBarcodeLocationScan(codeDetails: ["scannedCodes":"b592af47-4319-4739-824b-9ca8d93d34cc"])

    }
    
    
    
    @IBAction func statusButtonPressed(_ sender: UIButton) {
        
        let modeList = [["name" : "Open and Closed"],["name" : "Open Only"],["name" : "Closed Only"]]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = modeList
        controller.type = "Status"
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var locationStr = ""
        if let str = locationLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            locationStr = str
        }
        
        
        var productnamestr = ""
        if let str = productNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            productnamestr = str
        }
        
        var productuuidStr = ""
        if let str = productUuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            productuuidStr = str
        }
        
        
        
        var lotnumberstr = ""
        if let str = lotNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            lotnumberstr = str
        }
        
        var voided = ""
        if let str = voidedLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            voided = str
        }
        
        var status = ""
        if let str = statusLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            status = str
        }
        
//        var lotuuidstr = ""
//        if let str = lotUuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
//            lotuuidstr = str
//        }
        
        
                    
        var appendStr = ""
        
        if !locationStr.isEmpty{
            appendStr = appendStr + "location_uuid=\(locationStr)&"
            searchDict["location_uuid"] = locationStr
        }else{
            searchDict["location_uuid"] = ""
        }
        
        if !productnamestr.isEmpty{
            appendStr = appendStr + "product_name=\(productnamestr)&"
            searchDict["product_name"] = productnamestr
        }else{
            searchDict["product_name"] = ""
        }
        
        if !productuuidStr.isEmpty{
            appendStr = appendStr + "product_uuid=\(productuuidStr)&"
            searchDict["product_uuid"] = productuuidStr
        }else{
            searchDict["product_uuid"] = ""
        }
        
       
        
        if !lotnumberstr.isEmpty{
            appendStr = appendStr + "lot_number=\(lotnumberstr)&"
            searchDict["lot_number"] = lotnumberstr
        }else{
            searchDict["lot_number"] = ""
        }
        
        if !voided.isEmpty{
            searchDict["voided"] = voided
            
            if voided == "Yes"{
                appendStr = appendStr + "is_voided=true&"
            }else if voided == "No"{
                appendStr = appendStr + "is_voided=false&"
            }
            
            
        }else{
            searchDict["voided"] = "All"
        }
        
        if !status.isEmpty{
            searchDict["status"] = status
            
            if status == "Open Only"{
                appendStr = appendStr + "is_open=true&"
            }else if status == "Closed Only"{
                appendStr = appendStr + "is_open=false&"
            }
        }else{
            searchDict["status"] = "Open And Closed"
        }
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        doneTyping()
        searchDict = [String:Any]()
        productNameTextField.text = ""
        productUuidTextField.text = ""
        lotUuidTextField.text = ""
        lotNumberTextField.text = ""
        locationLabel.text = "Global"
        locationLabel.accessibilityHint = ""
        voidedLabel.text = "All"
        statusLabel.text = "Open And Closed"
        self.delegate?.clearSearch()
        self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
        
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
           if sender?.tag == 1{
                if let name = data["name"] as? String{
                    locationLabel.text = name
                    locationLabel.accessibilityHint = (data["uuid"] as? String) ?? ""
                }
            }else if sender?.tag == 2{
                if let name = data["name"] as? String{
                    voidedLabel.text = name
                    voidedLabel.accessibilityHint = name
                }
            }else if sender?.tag == 3{
                if let name = data["name"] as? String{
                    statusLabel.text = name
                    statusLabel.accessibilityHint = name
                }
            }
            
        }
    }
    //MARK: - End
}

//MARK: - Scan view delegate
extension ManufacturerProductSearchViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
    
    func didReceiveBarcodeLocationScan(codeDetails:[String:Any]){
        let locationCode = codeDetails["scannedCodes"] as! String
        print(locationCode)
        let predicate = NSPredicate(format:"uuid='\(locationCode)'")
        let filterArray = (locationsArr as NSArray).filtered(using: predicate)
        if filterArray.count>0 {
            let dict=filterArray[0]
            let btn=UIButton()
            btn.tag=1
            self.selecteditem(data: dict as! NSDictionary,sender:btn)
        }else{
            Utility.showPopup(Title: "Error!", Message: "Selected location is not available.".localized() , InViewC: self)
        }
    }
}



