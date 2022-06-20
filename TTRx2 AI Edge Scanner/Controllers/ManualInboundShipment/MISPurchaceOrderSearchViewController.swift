//
//  MISPurchaceOrderSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 16/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  MISPurchaceOrderSearchViewDelegate: class {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class MISPurchaceOrderSearchViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var orderIdTextField: UITextField!
    @IBOutlet weak var tradingPartnerTextField: UITextField!
    @IBOutlet weak var poNumberTextField: UITextField!
    @IBOutlet weak var invoiceTextField: UITextField!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
        
    weak var delegate: MISPurchaceOrderSearchViewDelegate?
    var searchDict = [String:Any]()
    
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        setupUI()
        createInputAccessoryView()
        
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
        uuidTextField.delegate = self
        orderIdTextField.delegate = self
        tradingPartnerTextField.delegate = self
        poNumberTextField.delegate = self
        invoiceTextField.delegate = self
    }
    
    func populateSearchData(){
        if !searchDict.isEmpty {
            if let txt = searchDict["uuid"] as? String,!txt.isEmpty{
                uuidTextField.text = txt
            }
            
            if let txt = searchDict["custom_id"] as? String,!txt.isEmpty{
                orderIdTextField.text = txt
            }
            
            if let txt = searchDict["trading_partner_name"] as? String,!txt.isEmpty{
                tradingPartnerTextField.text = txt
            }
            
            if let txt = searchDict["po_nbr"] as? String,!txt.isEmpty{
                poNumberTextField.text = txt
            }
            
            if let txt = searchDict["invoice_nbr"] as? String,!txt.isEmpty{
                invoiceTextField.text = txt
            }
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var uuidstr = ""
        if let str = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            uuidstr = str
        }
        
        var orderidstr = ""
        if let str = orderIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            orderidstr = str
        }
        
        var tradingpartnerstr = ""
        if let str = tradingPartnerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            tradingpartnerstr = str
        }
        
        var invoicestr = ""
        if let str = invoiceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            invoicestr = str
        }
        
        var postr = ""
        if let str = poNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            postr = str
        }
               
        
        var appendStr = ""
        
        if !uuidstr.isEmpty{
            appendStr = appendStr + "uuid=\(uuidstr)&"
            searchDict["uuid"] = uuidstr
        }else{
            searchDict["uuid"] = ""
        }
        
        if !orderidstr.isEmpty{
            appendStr = appendStr + "custom_id=\(orderidstr)&"
            searchDict["custom_id"] = orderidstr
        }else{
            searchDict["custom_id"] = ""
        }
        
        if !tradingpartnerstr.isEmpty{
            appendStr = appendStr + "trading_partner_name=\(tradingpartnerstr)&"
            searchDict["trading_partner_name"] = tradingpartnerstr
        }else{
            searchDict["trading_partner_name"] = ""
        }
        
        if !postr.isEmpty{
            appendStr = appendStr + "po_nbr=\(postr)&"
            searchDict["po_nbr"] = postr
        }else{
            searchDict["po_nbr"] = ""
        }
        
        if !invoicestr.isEmpty{
            appendStr = appendStr + "invoice_nbr=\(invoicestr)&"
            searchDict["invoice_nbr"] = invoicestr
        }else{
            searchDict["invoice_nbr"] = ""
        }
                
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
        
      
        
    }
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        doneTyping()
        searchDict = [String:Any]()
        uuidTextField.text = ""
        orderIdTextField.text = ""
        tradingPartnerTextField.text = ""
        poNumberTextField.text = ""
        invoiceTextField.text = ""
        self.delegate?.clearSearch()
        self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
    }
    //MARK: - End
   
    
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
    
        
    

    

}


