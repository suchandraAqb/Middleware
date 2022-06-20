//
//  ChangePasswordViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 25/08/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseViewController {

    @IBOutlet weak var selectionContainer: UIView!
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    @IBOutlet weak var currentPasswordView: UIView!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var retypeNewPasswordView: UIView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var currentPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let currentPassword = currentPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let newPassword = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentPassword!.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Current password cannot be empty".localized(), InViewC: self)
              return
        }else if currentPassword!.count<8{
            Utility.showPopup(Title: App_Title, Message: "Current password must be of atleast 8 characters".localized(), InViewC: self)
              return
        }else if newPassword!.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "New password cannot be empty".localized(), InViewC: self)
              return
        }else if newPassword!.count<8{
            Utility.showPopup(Title: App_Title, Message: "New password must be of atleast 8 characters".localized(), InViewC: self)
              return
        }else if newPassword! != confirmPassword!{
            Utility.showPopup(Title: App_Title, Message: "New password doesnot match with retype password".localized(), InViewC: self)
              return
        }
        currentPasswordTextField.text=""
        newPasswordTextField.text=""
        confirmPasswordTextField.text=""
        
        changePasswordApiCall(currentPassword: currentPassword!, newPassword: newPassword!)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    //MARK:- End
    
    //MARK:- Private Method
    func prepareView(){
        sectionView.roundTopCorners(cornerRadious: 40)
        selectionContainer.setRoundCorner(cornerRadious: 10)
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 17.0,color:Utility.hexStringToUIColor(hex: "719898"))
        currentPasswordView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        newPasswordView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        retypeNewPasswordView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        saveButton.setRoundCorner(cornerRadious: saveButton.frame.size.height/2.0)
        createInputAccessoryView()
    }
    //MARK:- End
    
    //MARK:- Webservice Call
    func changePasswordApiCall(currentPassword:String,newPassword:String){
        var requestDict = [String:Any]()
        requestDict["old_password"] = currentPassword
        requestDict["new_password"] = newPassword
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "change_password", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    Utility.showAlertWithPopAction(Title: Success_Title, Message: "Password Changed Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
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
    //MARK:- End
    
    
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
