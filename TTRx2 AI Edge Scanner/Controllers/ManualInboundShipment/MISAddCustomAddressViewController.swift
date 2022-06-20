//
//  MISAddCustomAddressViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 23/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISAddCustomAddressViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var stateView: UIView!
    var countryList:Array<Any>?
    var stateList:Array<Any>?
    var isStateRequired:Bool?
    var postalRegex:String?
    var addressType:String!
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        stateNameLabel.text = ""
        stateNameLabel.accessibilityHint = ""
        
        sectionView.roundTopCorners(cornerRadious: 40)
        containerView.setRoundCorner(cornerRadious: 10)
        getCountryList()
        createInputAccessoryView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    //MARK: - Private Method
    func formValidation()-> Bool{
        
        let postalCode =  postalCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let stateName =   stateNameLabel.text ?? ""
        let email =   emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var isValidated = true
        
        if let rNameStr = rNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), rNameStr.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter recipient name.", InViewC: self)
            isValidated = false
               
        }else if let address = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), address.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter address.", InViewC: self)
            isValidated = false
               
        }else if let city = cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), city.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter city name.", InViewC: self)
            isValidated = false
               
        }else if isStateRequired ?? false && stateName.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "Please select state", InViewC: self)
            isValidated = false
        }
        else if postalCode.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter postal code.", InViewC: self)
            isValidated = false
               
        /*}else if !(postalRegex ?? "").isEmpty && !postalCode.validatedStringWithRegex(regexStr: postalRegex ?? ""){
            Utility.showPopup(Title: App_Title, Message: "Please enter valid postal code.", InViewC: self)
            isValidated = false*/
        }else if !email.isEmpty && !email.isValidEmail(){
            Utility.showPopup(Title: App_Title, Message: "Please enter valid Email.", InViewC: self)
            isValidated = false
        }
        
        
      return isValidated
        
   }
    
    func getCountryList(){
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetCountryDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        if let response = responseData as? Array<Any>{
                            self.countryList = response
                            
                            if let firstData = response[0] as? NSDictionary {
                                let btn = UIButton()
                                btn.tag = 1
                                self.selecteditem(data: firstData, sender: btn)
                            }
                            
                        }
                        
                        
                }else{
                   
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       
                      Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                       
                   }else{
                      Utility.showAlertWithPopAction(Title: App_Title, Message: message ?? "", InViewC: self, isPop: true, isPopToRoot: false)
                   }
                       
                       
                }
                  
            }
        }
        
    }
    
    func getStatteList(countryId:String){
        
        let appendStr = "\(countryId)/states"
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetCountryDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        if let response = responseData as? Array<Any>{
                            self.stateList = response
                        }
                        
                        
                }else{
                   
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       
                      Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                       
                   }else{
                      Utility.showAlertWithPopAction(Title: App_Title, Message: message ?? "", InViewC: self, isPop: true, isPopToRoot: false)
                   }
                       
                       
                }
                  
            }
        }
        
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
    
    //MARK: - IBAction
    
    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1 {
            if countryList == nil || countryList?.count == 0 {
                    return
            }
           let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
           controller.isDataWithDict = false
           controller.nameKeyName = "name"
           controller.listItems = countryList as! Array<[String:Any]>
           controller.type = "Country"
           controller.delegate = self
           controller.sender = sender
            controller.modalPresentationStyle = .custom
           self.present(controller, animated: true, completion: nil)
        }else{
            if stateList == nil || stateList?.count == 0 {
                     return
             }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = stateList as! Array<[String:Any]>
            controller.type = "State"
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
        }
        
    }
    
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        doneTyping()
        if formValidation(){
            
            let address_dict = NSMutableDictionary()
            address_dict.setValue("", forKey: "uuid")
            address_dict.setValue("", forKey: "gs1_id")
            address_dict.setValue("", forKey: "gs1_sgln")
            address_dict.setValue("", forKey: "created_on")
            address_dict.setValue("", forKey: "address_nickname")
            address_dict.setValue(rNameTextField.text ?? "", forKey: "recipient_name")
            address_dict.setValue(addressTextField.text ?? "", forKey: "line1")
            address_dict.setValue("", forKey: "line2")
            address_dict.setValue("", forKey: "line3")
            address_dict.setValue("", forKey: "line4")
            address_dict.setValue(countryNameLabel.text ?? "", forKey: "country_name")
            address_dict.setValue("", forKey: "country_code")
            address_dict.setValue(countryNameLabel.accessibilityHint ?? "", forKey: "country_id")
            address_dict.setValue(stateNameLabel.text ?? "", forKey: "state_name")
            address_dict.setValue("", forKey: "state_code")
            address_dict.setValue(stateNameLabel.accessibilityHint ?? "", forKey: "state_id")
            address_dict.setValue(cityTextField.text ?? "", forKey: "city")
            address_dict.setValue(postalCodeTextField.text ?? "", forKey: "zip")
            address_dict.setValue(phoneTextField.text ?? "", forKey: "phone")
            address_dict.setValue("", forKey: "phone_ext")
            address_dict.setValue(emailTextField.text ?? "", forKey: "email")
            address_dict.setValue("", forKey: "address_ref")
            address_dict.setValue(false, forKey: "is_default_address")
            
            
            Utility.saveDictTodefaults(key: addressType, dataDict: address_dict)
            
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: MISConfirmViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
            self.navigationController?.pushViewController(controller, animated: false)
        
            
        }
    }
    
    //MARK: - End
    //MARK: - SingleSelectDropdownDelegate
    
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        
        var itemName = ""
        var itemid = -1
        
        if let name = data["name"] as? String{
            itemName =  name
            
            if let uuid = data["db_id"] as? Int {
                itemid = uuid
            }
        }
        
        if sender != nil {
            
            if sender?.tag == 1 {
                countryNameLabel.text = itemName
                countryNameLabel.accessibilityHint = "\(itemid)"
                stateNameLabel.text = ""
                stateNameLabel.accessibilityHint = ""
                
                if let is_hide_state_field = data["is_hide_state_field"] as? Bool {
                    if(is_hide_state_field){
                        stateView.isHidden = true
                    }else{
                        getStatteList(countryId: "\(itemid)")
                        stateView.isHidden = false
                    }
                }
                
                if let is_state_required = data["is_require_state"] as? Bool {
                    
                    isStateRequired = is_state_required
                    
                }
                
                if let postalRegexStr = data["postal_code_validation_regex"] as? String {
                    postalRegex = postalRegexStr
                }
                
                
                
                
            }else{
                
                stateNameLabel.text = itemName
                stateNameLabel.accessibilityHint = "\(itemid)"
            }
            
        }
        
    }
    //MARK: - End

}
