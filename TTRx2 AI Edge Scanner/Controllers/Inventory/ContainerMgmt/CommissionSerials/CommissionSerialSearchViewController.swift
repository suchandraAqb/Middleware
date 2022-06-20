//
//  CommissionSerialSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 21/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  CommissionSerialSearchViewDelegate: class {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class CommissionSerialSearchViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var tranctiontypeLabel: UILabel!
    @IBOutlet weak var uuidView: UIView!
    @IBOutlet weak var tranctiontypeView: UIView!
    
    weak var delegate: CommissionSerialSearchViewDelegate?
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
        populateSearchData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    
    //MARK: - Custom Method
    func setupUI(){
        uuidTextField.delegate = self
        
        
    }
    
    func populateSearchData(){
        if !searchDict.isEmpty {
            
            if let txt = searchDict["status"] as? String,!txt.isEmpty{
                tranctiontypeLabel.text = txt
                tranctiontypeLabel.accessibilityHint = txt
                tranctiontypeLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
            if let txt = searchDict["request_uuid"] as? String,!txt.isEmpty{
                uuidTextField.text = txt
            }
            
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        let paymentModeList = [["name" : "Any"],["name" : "Open"],["name" : "Closed"],["name" : "Failed"]]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = paymentModeList
        controller.type = "Status".localized()
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    
   
    
    
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var tranctiontypelabelstr = ""
        if let str = tranctiontypeLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            tranctiontypelabelstr = str.uppercased()
        }
        
        var uuidstr = ""
        if let str = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            uuidstr = str
        }
        
        
        var appendStr = ""
        
        if !tranctiontypelabelstr.isEmpty{
            appendStr = appendStr + "status=\(tranctiontypelabelstr)&"
            searchDict["status"] = tranctiontypelabelstr.capitalized
        }else{
            searchDict["status"] = ""
        }
        
        
        
        if !uuidstr.isEmpty{
            appendStr = appendStr + "request_uuid=\(uuidstr)&"
            searchDict["request_uuid"] = uuidstr
        }else{
            searchDict["request_uuid"] = ""
        }
        
        
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
        
      
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        doneTyping()
        searchDict = [String:Any]()
        uuidTextField.text = ""
        tranctiontypeLabel.text = "Status".localized()
        tranctiontypeLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
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
            if let name = data["name"] as? String{
                tranctiontypeLabel.text = name
                if name != "Any"{
                    tranctiontypeLabel.accessibilityHint = name
                }else{
                    tranctiontypeLabel.accessibilityHint = ""
                }
                
                tranctiontypeLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
        }
    }
}    //MARK: - End
extension CommissionSerialSearchViewController:SingleScanViewControllerDelegate{
        internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
            textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}
    

    



