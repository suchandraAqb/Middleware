//
//  UserProfileViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 25/08/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class UserProfileViewController: BaseViewController {
    
    @IBOutlet weak var selectionContainer: UIView!
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet var fullNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        getBasicProfileApiCall()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let fullName =   fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email =   emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let title =   titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if fullName.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Full name cannot be empty.".localized(), InViewC: self)
              return
        }
        if email.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Email cannot be empty.".localized(), InViewC: self)
              return
        }
        if !email.isEmpty && !email.isValidEmail() {
            Utility.showPopup(Title: App_Title, Message: "Please enter valid Email.".localized(), InViewC: self)
              return
        }
        
        var requestDict = [String:Any]()
        requestDict["fullname"] = fullName
        requestDict["email"] = email
        requestDict["title"] = title
        updateBasicProfileApiCall(requestDict: requestDict)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    //MARK: - End
    
    //MARK: - Private Method
    func prepareView(){
        sectionView.roundTopCorners(cornerRadious: 40)
        selectionContainer.setRoundCorner(cornerRadious: 10)
        fullNameView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        emailView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        titleView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        saveButton.setRoundCorner(cornerRadious: saveButton.frame.size.height/2.0)
        createInputAccessoryView()
    }
    //MARK: - End
    
    //MARK: - Webservice Call
    func getBasicProfileApiCall() {
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "basic_profile", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                  if let responseDict = responseData as? NSDictionary {
                    if let txt:String = responseDict["full_name"] as? String{
                        self.fullNameTextField.text=txt
                    }
                    if let txt:String = responseDict["email"] as? String{
                        self.emailTextField.text=txt
                    }
                    if let txt:String = responseDict["title"] as? String{
                        self.titleTextField.text=txt
                    }
                  }
              }else{
                 if responseData != nil{
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    let errorMsg = responseDict["message"] as! String
                     Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                 }else{
                    Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                 }
              }
          }
      }
        
    }
    
    func updateBasicProfileApiCall(requestDict:[String:Any]){
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "basic_profile", serviceParam: requestDict, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    Utility.showAlertWithPopAction(Title: Success_Title, Message: "Profile Updated Successfully.".localized(), InViewC: self, isPop: true, isPopToRoot: false)
              }else{
                 if responseData != nil{
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    let errorMsg = responseDict["message"] as! String
                     Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                 }else{
                    Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
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
}
