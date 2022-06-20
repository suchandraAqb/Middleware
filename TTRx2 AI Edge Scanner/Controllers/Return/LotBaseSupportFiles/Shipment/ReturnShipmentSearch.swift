//
//  ReturnShipmentSearch.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 10/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnShipmentSearch: BaseViewController, SingleSelectDropdownDelegate {
    
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var txtLotNumber: UITextField!
    @IBOutlet weak var txtTPName: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtZipCode: UITextField!
    
    ///ADVANCE
    @IBOutlet weak var txtPoNumber: UITextField!
    @IBOutlet weak var txtInvoice: UITextField!
    @IBOutlet weak var txtReleaseNo: UITextField!
    @IBOutlet weak var txtIRNo: UITextField!
    @IBOutlet weak var txtCustomOrder: UITextField!
    @IBOutlet weak var txtOrderNo: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtLine1: UITextField!
    
    @IBOutlet weak var viewPoNumber: UIView!
    @IBOutlet weak var viewInvoice: UIView!
    @IBOutlet weak var viewReleaseNo: UIView!
    @IBOutlet weak var viewIRNo: UIView!
    @IBOutlet weak var viewCustomerOrder: UIView!
    @IBOutlet weak var viewOrderNo: UIView!
    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var viewLine: UIView!
    ///End
    
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    
    
    @IBOutlet weak var advanceSearchButton: UIButton!
    
    weak var delegate: SearchViewDelegate?
    var searchDict = [String:Any]()
    var productName = String()
    

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
        self.productNameTextField.text = productName
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
        txtLotNumber.delegate = self
        txtTPName.delegate = self
        txtCity.delegate = self
        txtZipCode.delegate = self
        txtPoNumber.delegate = self
        txtInvoice.delegate = self
        txtReleaseNo.delegate = self
        txtIRNo.delegate = self
        txtCustomOrder.delegate = self
        txtOrderNo.delegate = self
        txtCountry.delegate = self
        txtLine1.delegate = self
    }
    
    func populateSearchData(){
        
        if !searchDict.isEmpty {
            
            
//            if let txt = searchDict["name"] as? String,!txt.isEmpty{
//                productNameTextField.text = txt
//            }
            
            if let txt = searchDict["lot_number"] as? String,!txt.isEmpty{
                txtLotNumber.text = txt
            }
            
            if let txt = searchDict["trading_partner_name"] as? String,!txt.isEmpty{
                txtTPName.text = txt
            }
            
            if let txt = searchDict["city"] as? String,!txt.isEmpty{
                txtCity.text = txt
            }
            
            if let txt = searchDict["zip"] as? String,!txt.isEmpty{
                txtZipCode.text = txt
            }
            
            if let txt = searchDict["po_number"] as? String,!txt.isEmpty{
                txtPoNumber.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["invoice_number"] as? String,!txt.isEmpty{
                txtInvoice.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["release_number"] as? String,!txt.isEmpty{
                txtReleaseNo.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["internal_reference_number"] as? String,!txt.isEmpty{
                txtIRNo.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["custom_id"] as? String,!txt.isEmpty{
                txtCustomOrder.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["order_number"] as? String,!txt.isEmpty{
                txtOrderNo.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["country"] as? String,!txt.isEmpty{
                txtCountry.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
            
            if let txt = searchDict["address_line_1"] as? String,!txt.isEmpty{
                txtLine1.text = txt
                if !advanceSearchButton.isSelected{
                   advanceSearchButtonPressed(advanceSearchButton)
                }
            }
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
    @IBAction func productNameTapped(_ sender: UIButton) {
        if let viewControllers = self.navigationController?.viewControllers{
            for viewController in viewControllers{
                if viewController is ReturnProductListVC{
                    self.navigationController?.popToViewController(viewController, animated: true)
                    return
                }
            }
        }
    }
    
    @IBAction func advanceSearchButtonPressed(_ sender: UIButton) {
        
        advanceSearchButton.isSelected.toggle()
        if advanceSearchButton.isSelected {
            
            viewPoNumber.isHidden = false
            viewInvoice.isHidden = false
            viewReleaseNo.isHidden = false
            viewIRNo.isHidden = false
            viewCustomerOrder.isHidden = false
            viewOrderNo.isHidden = false
            viewCountry.isHidden = false
            viewLine.isHidden = false
            
            mainScroll.scrollToBottom(animated: true)
            
         }else{
            
            viewPoNumber.isHidden = true
            viewInvoice.isHidden = true
            viewReleaseNo.isHidden = true
            viewIRNo.isHidden = true
            viewCustomerOrder.isHidden = true
            viewOrderNo.isHidden = true
            viewCountry.isHidden = true
            viewLine.isHidden = true
            
            UIView.animate(withDuration: 0.3) {
                self.mainScroll.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var lotNumber = ""
        if let str = txtLotNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            lotNumber = str
        }
        
        var tpName = ""
        if let str = txtTPName.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            tpName = str
        }
        
        var city = ""
        if let str = txtCity.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            city = str
        }
        
        var zipCode = ""
        if let str = txtZipCode.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            zipCode = str
        }
        
        var poNumber = ""
        if let str = txtPoNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            poNumber = str
        }
        
        var invoice = ""
        if let str = txtInvoice.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            invoice = str
        }
        
        var releaseNo = ""
        if let str = txtReleaseNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            releaseNo = str
        }
       
        var irnNo = ""
        if let str = txtIRNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            irnNo = str
        }
        
        var customerOrder = ""
        if let str = txtCustomOrder.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            customerOrder = str
        }
        
        var orderNo = ""
        if let str = txtOrderNo.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            orderNo = str
        }
        
        var country = ""
        if let str = txtCountry.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            country = str
        }
        
        var line1 = ""
        if let str = txtLine1.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            line1 = str
        }
        
        
        var appendStr = ""
        
        if !lotNumber.isEmpty{
            appendStr = appendStr + "lot_number=\(lotNumber)&"
            searchDict["lot_number"] = lotNumber
        }else{
            searchDict["lot_number"] = ""
        }
        
        if !tpName.isEmpty{
            appendStr = appendStr + "trading_partner_name=\(tpName)&"
            searchDict["trading_partner_name"] = tpName
        }else{
            searchDict["trading_partner_name"] = ""
        }
        
        if !city.isEmpty{
            appendStr = appendStr + "city=\(city)&"
            searchDict["city"] = city
        }else{
            searchDict["city"] = ""
        }
        
        if !zipCode.isEmpty{
            appendStr = appendStr + "zip=\(zipCode)&"
            searchDict["zip"] = zipCode
        }else{
            searchDict["zip"] = ""
        }
        
        if !poNumber.isEmpty{
            appendStr = appendStr + "po_number=\(poNumber)&"
            searchDict["po_number"] = poNumber
        }else{
            searchDict["po_number"] = ""
        }
        
        if !invoice.isEmpty{
            appendStr = appendStr + "invoice_number=\(invoice)&"
            searchDict["invoice_number"] = invoice
        }else{
            searchDict["invoice_number"] = ""
        }
        
        if !releaseNo.isEmpty{
            appendStr = appendStr + "release_number=\(releaseNo)&"
            searchDict["release_number"] = releaseNo
        }else{
            searchDict["release_number"] = ""
        }
        
        if !irnNo.isEmpty{
            appendStr = appendStr + "internal_reference_number=\(irnNo)&"
            searchDict["internal_reference_number"] = irnNo
        }else{
            searchDict["internal_reference_number"] = ""
        }
        
        if !customerOrder.isEmpty{
            appendStr = appendStr + "custom_id=\(customerOrder)&"
            searchDict["custom_id"] = customerOrder
        }else{
            searchDict["custom_id"] = ""
        }
        
        if !orderNo.isEmpty{
            appendStr = appendStr + "order_number=\(orderNo)&"
            searchDict["order_number"] = orderNo
        }else{
            searchDict["order_number"] = ""
        }
        
        if !country.isEmpty{
            appendStr = appendStr + "country=\(country)&"
            searchDict["country"] = country
        }else{
            searchDict["country"] = ""
        }
        
        if !line1.isEmpty{
            appendStr = appendStr + "address_line_1=\(line1)&"
            searchDict["address_line_1"] = line1
        }else{
            searchDict["address_line_1"] = ""
        }
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        doneTyping()
        searchDict = [String:Any]()
        //productNameTextField.text = ""
        txtLotNumber.text = ""
        txtTPName.text = ""
        txtCity.text = ""
        txtZipCode.text = ""
        txtPoNumber.text = ""
        txtInvoice.text = ""
        txtReleaseNo.text = ""
        txtIRNo.text = ""
        txtCustomOrder.text = ""
        txtOrderNo.text = ""
        txtCountry.text = ""
        txtLine1.text = ""
        
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
//            if let name = data["name"] as? String{
//                identifierLabel.text = name
//                identifierLabel.accessibilityHint = name
//                identifierLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
//            }
            
        }
    }
    //MARK: - End
}

extension ReturnShipmentSearch:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}
