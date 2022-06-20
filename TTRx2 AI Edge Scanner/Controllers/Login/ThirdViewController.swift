//
//  ThirdViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 14/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit



class ThirdViewController: BaseViewController, UIScrollViewDelegate {
    
//    var userName = ""
//    var isSecondFactor = false
//    var passwordStr = ""
    
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertConentView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var alertContentLabel: UILabel!
    @IBOutlet weak var alertSkipButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var updatePasswordView: UIView!
    @IBOutlet weak var updatePasswordContentView: UIView!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var updateNowButton: UIButton!
    
    @IBOutlet var forgetPasswordView: UIView!
    @IBOutlet weak var forgetPasswordContentView: UIView!
    @IBOutlet weak var forgetPasswordUserNameTextField: UITextField!
    @IBOutlet weak var forgetPasswordNextButton: UIButton!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var secondFactorCodeLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var rememberMeButton:UIButton!
    var isAutoLogin:Bool?
    let deviceDetails = DeviceMgmtModel.DeviceMgmtShared
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.setRoundCorner(cornerRadious: loginButton.frame.size.height / 2.0)
        forgotPasswordButton.isHidden = true
        
        // Do any additional setup after loading the view.
        
//        if userName != ""{
//            userNameTextField.text = userName
//            userNameTextField.isEnabled = false
//            userNameTextField.alpha = 0.5
//        }
        
        alertConentView.setRoundCorner(cornerRadious: 10.0)
        alertSkipButton.setRoundCorner(cornerRadious: alertSkipButton.frame.size.height/2.0)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
        
        
        updatePasswordContentView.setRoundCorner(cornerRadious: 10.0)
        updateNowButton.setRoundCorner(cornerRadious: alertSkipButton.frame.size.height/2.0)
        forgetPasswordContentView.setRoundCorner(cornerRadious: 10.0)
        forgetPasswordNextButton.setRoundCorner(cornerRadious: forgetPasswordNextButton.frame.size.height/2.0)
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.sizeToFit()
        createInputAccessoryView()

        userNameTextField.inputAccessoryView = doneToolbar
        userNameTextField.inputAccessoryView = inputAccView
        userNameTextField.returnKeyType = .done
        
        passwordTextField.inputAccessoryView = doneToolbar
        passwordTextField.inputAccessoryView = inputAccView
        passwordTextField.returnKeyType = .done
        
        oldPasswordTextField.inputAccessoryView = inputAccView
        oldPasswordTextField.returnKeyType = .done
        
        newPasswordTextField.inputAccessoryView = inputAccView
        newPasswordTextField.returnKeyType = .done
        forgetPasswordUserNameTextField.inputAccessoryView = inputAccView
        forgetPasswordUserNameTextField.returnKeyType = .done
        
        if let rememberedUser = defaults.value(forKey: "rememberedUser") as? Bool {
            if rememberedUser {
                if let user = defaults.value(forKey: "email") as? String , let password = defaults.value(forKey: "password") as? String {
                    userNameTextField.text = user
                    passwordTextField.text = password
                    rememberMeButton.isSelected = true
                    let delayTime = DispatchTime.now() + 1.0
                    DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                        self.loginButtonPressed(UIButton())
                    })
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUILanguage()
    }
    //MARK: - End
    
    //MARK: - IBAction
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
     
        guard let tempUserName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!tempUserName.isEmpty else{
            Utility.showPopup(Title: App_Title, Message: "Enter User Email", InViewC: self)
            return
        }
        guard let tempPasswordStr = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !tempPasswordStr.isEmpty else{
            Utility.showPopup(Title: App_Title, Message: "Enter Password".localized(), InViewC: self)
              return
        }
        
        loginWebServiceCall()
        
    }
    @IBAction func rememberMeButtonPressed(_ sender:UIButton){
        rememberMeButton.isSelected = !rememberMeButton.isSelected
        
    }
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        if let txt = userNameTextField.text,!txt.isEmpty {
            forgetPasswordUserNameTextField.text=txt
        }
        forgetPasswordView.isHidden = false

    }
    
    @IBAction func alertCloseButtonPressed(_ sender: UIButton) {
        alertView.isHidden = true
    }
    
    @IBAction func alertSkipButtonPressed(_ sender: UIButton) {
        alertCloseButtonPressed(UIButton())
        self.deviceDetails.setAppUpdateSkipStatus(true)
        self.loginButtonPressed(UIButton())
    }
    
    @IBAction func alertConfirmButtonPressed(_ sender: UIButton) {
        
         alertCloseButtonPressed(UIButton())
        if sender.tag == 1 { //Allow Device Enrollment
            self.deviceDetails.setEnrollmentStatus(DeviceEnrollmentRequestStatus.EnrollConfirmed.rawValue)
            self.loginButtonPressed(UIButton())
            
        }else if sender.tag == 2 { //Update App
            if let url = URL(string: AppStoreURL),UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url)
            }
            
        }
    }
    
    @IBAction func passwordUpdateButtonPressed(_ sender: UIButton) {
        
        guard let oldPasswordStr = oldPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !oldPasswordStr.isEmpty else {
            
            Utility.showPopup(Title: App_Title, Message: "Enter Old Password".localized(), InViewC: self)
              return
        }
        
        guard let newPasswordStr = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newPasswordStr.isEmpty else {
            
            Utility.showPopup(Title: App_Title, Message: "Enter New Password".localized(), InViewC: self)
              return
        }
        
        if oldPasswordStr == newPasswordStr {
            Utility.showPopup(Title: App_Title, Message: "Old and New Password can't be same.".localized(), InViewC: self)
            return
        }
        
        updatePasswordWebServiceCall()
        
    }
    
    @IBAction func passwordUpdateCloseButtonPressed(_ sender: UIButton) {
        
        updatePasswordView.isHidden = true
    }
    
    @IBAction func forgetPasswordCrossButtonPressed(_ sender: UIButton) {
        forgetPasswordView.isHidden = true
    }
    @IBAction func forgetPasswordNextButtonPressed(_ sender: UIButton) {
        guard let userNameStr = forgetPasswordUserNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userNameStr.isEmpty else {
            Utility.showPopup(Title: App_Title, Message: "Enter Username".localized(), InViewC: self)
            return
        }
        let clientUdid = (defaults.value(forKey: "client_udid") ?? "") as! String
        var requestDict = [String:Any]()
        requestDict["client_uuid"] = clientUdid // Test Client ID
        requestDict["username"] = userNameStr
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "lost_password", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if responseData != nil{
                        self.forgetPasswordView.isHidden=true
                        let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                        let result = responseDict["result"] as! NSDictionary
                        let errorMsg = result["msg"] as! String
                        Utility.showPopup(Title: Success_Title, Message: errorMsg , InViewC: self)
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
    
    //MARK: - End
    //MARK: - Private Method
    func loginWebServiceCall(){
        
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"Login")
        requestDict["email"] = userNameTextField.text
        requestDict["password"] = passwordTextField.text

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "Login", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let responseDict: NSDictionary = responseData as? NSDictionary{
                       let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            let dict = Utility.convertToDictionary(text: responseDict["data"] as! String) as NSDictionary?
                            if let session = dict?["session"] as? String,!session.isEmpty{
                                self.updatePasswordView.isHidden = false
                                defaults.setValue(session, forKey: "sessionId")
                                defaults.setValue(self.userNameTextField.text, forKey: "email")

                        }else{
                            defaults.setValue(self.userNameTextField.text, forKey: "email")
                            defaults.setValue(self.passwordTextField.text, forKey: "password")
                            self.updatePasswordView.isHidden = true
                            self.processLoginResponse(dict!)
                            
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
    func updatePasswordWebServiceCall(){
        
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"NewPasswordRequird")
        requestDict["email"] = defaults.object(forKey:"email")
        requestDict["password"] = newPasswordTextField.text
        requestDict["session"] = defaults.object(forKey:"sessionId")

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "NewPasswordRequird", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let responseDict: NSDictionary = responseData as? NSDictionary{
                       let statusCode = responseDict["status_code"] as? Bool
                        if statusCode! {
                            
                            defaults.setValue(self.newPasswordTextField.text, forKey: "password")
                            self.updatePasswordView.isHidden = true
                            let dict = Utility.convertToDictionary(text: responseDict["data"] as! String) as NSDictionary?
                            self.processLoginResponse(dict!)

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
   // MARK: - Private Method
    private func processLoginResponse(_ responseDict:NSDictionary){
        if let access_token = responseDict["access_token"] as? String,!access_token.isEmpty{
            defaults.setValue(access_token, forKey: "accesstoken")
        }
        if let refresh_token = responseDict["refresh_token"] as? String,!refresh_token.isEmpty{
            defaults.setValue(refresh_token , forKey: "refreshtoken")
        }
        if self.rememberMeButton.isSelected{
            defaults.setValue(true, forKey: "rememberedUser")
        }else{
            defaults.setValue(false, forKey: "rememberedUser")
        }
        if let userDict = responseDict["user"] as? NSDictionary{
            if let domainName = userDict["domain"] as? String,!domainName.isEmpty{
                defaults.setValue(domainName, forKey: "domainname")
            }
            if let configDetails = userDict["is_configured"] as? Bool{
                defaults.setValue(configDetails, forKey: "configSet")
            }
            if let subName = userDict["sub"] as? String,!subName.isEmpty{
                defaults.setValue(subName, forKey: "sub")
            }
            if let userName = userDict["name"] as? String,!userName.isEmpty{
                defaults.setValue(userName, forKey: "userName")
            }
            
            if let isconfig = userDict["is_configured"] as? Bool{
                if !isconfig {
                    self.moveToSettingsView()
                }else{
                    Utility.moveToHomeAsRoot()
                }
            }
        }
    }
    private func moveToSettingsView(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SettingsPageView") as! SettingsPageViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
//    private func processLoginResponse(_ responseDict:NSDictionary){
//
//        if let appUpdateStatus = responseDict["rapid_rx_version_status"] as? String,!appUpdateStatus.isEmpty,appUpdateStatus == AppUpdateStatus.Ok.rawValue{
//
//            if responseDict["result"] as! String == "REQUIRE_2ND_FACTOR"{
//                 self.isSecondFactor = true
//                 self.welcomeLabel.isHidden = true
//                 self.secondFactorCodeLabel.isHidden=false
//                 self.instructionLabel.text = "Enter".localized()
//                 self.passwordTextField.text = ""
//                 self.passwordTextField.placeholder = ""
//                 self.passwordTextField.keyboardType = UIKeyboardType.numberPad
//                 defaults.set(self.passwordStr, forKey: "password")
//
//            }else if responseDict["result"] as! String == "OK"{
//                 if !self.isSecondFactor{
//                    defaults.set(self.passwordStr, forKey: "password")
//                 }
//                let authToken = responseDict["session_token"] as! String
//                defaults.set(authToken, forKey: "session_token")
//                defaults.set(self.userName, forKey: "userName")
//                self.deviceDetails.setEnrollmentStatus(DeviceEnrollmentRequestStatus.Enrolled.rawValue)
//
//                Utility.moveToHomeAsRoot()
//
//            }else if responseDict["result"] as! String == "REQUIRE_NEW_PASSWORD"{
//
//                self.updatePasswordView.isHidden = false
//            }
//            else if responseDict["result"] as! String == "FAIL"{
//
//                if let status = responseDict["rapid_rx_status"] as? String,!status.isEmpty,status == DeviceEnrollmentResponseStatus.UnknownDevice.rawValue ,let license_uuid = responseDict["rapid_rx_licence_uuid"] as? String,!license_uuid.isEmpty{
//
//                    self.deviceDetails.setEnrollmentStatus(DeviceEnrollmentRequestStatus.Enrolled.rawValue)
//                    self.deviceDetails.setLicenseUUID(license_uuid)
//                    self.loginButtonPressed(UIButton())
//
//
//                }else if let status = responseDict["rapid_rx_status"] as? String,!status.isEmpty,status == DeviceEnrollmentResponseStatus.EnrollAccepted.rawValue ,let license_uuid = responseDict["rapid_rx_licence_uuid"] as? String,!license_uuid.isEmpty{
//
//                    self.deviceDetails.setEnrollmentStatus(DeviceEnrollmentRequestStatus.Enrolled.rawValue)
//                    self.deviceDetails.setLicenseUUID(license_uuid)
//                    self.loginButtonPressed(UIButton())
//                }
//
//                else if let status = responseDict["rapid_rx_status"] as? String,!status.isEmpty,status == DeviceEnrollmentResponseStatus.UnknownDevice.rawValue{
//
//                    var msg = ""
//                    if let str = responseDict["error_message"] as? String,!str.isEmpty{
//                        msg = str
//                    }
//
//                    alertForDeviceEnrollmentConfirmation(msg: msg)
//
//                }else if let status = responseDict["rapid_rx_status"] as? String,!status.isEmpty,status == DeviceEnrollmentResponseStatus.EnrollDenied.rawValue{
//
//                    var msg = "Device enrollment denied."
//                    if let str = responseDict["error_message"] as? String,!str.isEmpty{
//                        msg = str
//                    }
//
//                    Utility.showPopup(Title: App_Title, Message: "\(msg)\n\nRef ID: \(deviceDetails.currentDeviceId)", InViewC: self)
//
//                }else if let status = responseDict["rapid_rx_status"] as? String,!status.isEmpty,status == DeviceEnrollmentResponseStatus.BlockedDevice.rawValue{
//
//                    var msg = "Device enrollment blocked."
//                    if let str = responseDict["error_message"] as? String,!str.isEmpty{
//                        msg = str
//                    }
//
//                    alertForDeviceBlock(msg: "\(msg)\n\nRef ID: \(deviceDetails.currentDeviceId)")
//                }else{
//                    var msg = "Device enrollment error."
//                    if let str = responseDict["error_message"] as? String,!str.isEmpty{
//                        msg = str
//                    }
//
//                    Utility.showPopup(Title: App_Title, Message: "\(msg)\n\nRef ID: \(deviceDetails.currentDeviceId)", InViewC: self)
//                }
//
//            }else{
//                Utility.showPopup(Title: App_Title, Message: "Incorrect username", InViewC: self)
//            }
//
//        }else if let appUpdateStatus = responseDict["rapid_rx_version_status"] as? String,!appUpdateStatus.isEmpty,appUpdateStatus == AppUpdateStatus.UpdateAvailable.rawValue{
//
//            var msg = ""
//            if let str = responseDict["error_message"] as? String,!str.isEmpty{
//                msg = str
//            }
//            alertForAppUpdateAvailable(msg: msg)
//
//        }else if let appUpdateStatus = responseDict["rapid_rx_version_status"] as? String,!appUpdateStatus.isEmpty,appUpdateStatus == AppUpdateStatus.UpdateRequired.rawValue{
//
//            var msg = ""
//            if let str = responseDict["error_message"] as? String,!str.isEmpty{
//                msg = str
//            }
//            alertForAppUpdateRequired(msg: msg)
//
//        }else if responseDict["result"] as! String == "REQUIRE_2ND_FACTOR"{
//             self.isSecondFactor = true
//             self.welcomeLabel.isHidden = true
//             self.secondFactorCodeLabel.isHidden=false
//             self.instructionLabel.text = "Enter".localized()
//             self.passwordTextField.text = ""
//             self.passwordTextField.placeholder = ""
//             self.passwordTextField.keyboardType = UIKeyboardType.numberPad
//             defaults.set(self.passwordStr, forKey: "password")
//
//        }else if responseDict["result"] as! String == "OK"{
//             if !self.isSecondFactor{
//                defaults.set(self.passwordStr, forKey: "password")
//             }
//            let authToken = responseDict["session_token"] as! String
//            defaults.set(authToken, forKey: "session_token")
//            defaults.set(self.userName, forKey: "userName")
//            self.deviceDetails.setEnrollmentStatus(DeviceEnrollmentRequestStatus.Enrolled.rawValue)
//            //GO TO DASHBOARD
//            Utility.moveToHomeAsRoot()
//
//        }else if responseDict["result"] as! String == "REQUIRE_NEW_PASSWORD"{
//
//            self.updatePasswordView.isHidden = false
//        }
//    }
    
    func alertForDeviceEnrollmentConfirmation(msg:String){
        let msg = "\(msg)\n" + "Would you like to enroll this device?".localized()
        alertLabel.text = "Enroll Your Device".localized()
        alertContentLabel.text = msg
        alertSkipButton.isHidden = true
        confirmButton.setTitle("ENROLL NOW".localized(), for: .normal)
        confirmButton.tag = 1
        alertView.isHidden = false
        
        
        
//        let confirmAlert = UIAlertController(title:"Device Enrollment", message: msg, preferredStyle: .alert)
//        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
//        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
//            self.deviceDetails.setEnrollmentStatus(DeviceEnrollmentRequestStatus.EnrollConfirmed.rawValue)
//            self.loginButtonPressed(UIButton())
//
//        })
//
//        confirmAlert.addAction(action)
//        confirmAlert.addAction(okAction)
//        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    func alertForAppUpdateAvailable(msg:String){
        let msg = "\(msg)\n" + "Would you like to update the App?".localized()
        
        alertLabel.text = "App Update Available".localized()
        alertContentLabel.text = msg
        alertSkipButton.isHidden = false
        confirmButton.setTitle("UPDATE NOW".localized(), for: .normal)
        confirmButton.tag = 2
        alertView.isHidden = false
        
//        let confirmAlert = UIAlertController(title:"App Update Available", message: msg, preferredStyle: .alert)
//        let action = UIAlertAction(title: "Skip".localized(), style: .cancel, handler: { (UIAlertAction) in
//            self.deviceDetails.setAppUpdateSkipStatus(true)
//            self.loginButtonPressed(UIButton())
//
//        })
//        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
//
//            if let url = URL(string: AppStoreURL),UIApplication.shared.canOpenURL(url){
//                UIApplication.shared.open(url)
//            }
//        })
//
//        confirmAlert.addAction(action)
//        confirmAlert.addAction(okAction)
//        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    func alertForAppUpdateRequired(msg:String){
        let msg = "\(msg)\n" + "Please update the App to continue?".localized()
        
        alertLabel.text = "App Update Required".localized()
        alertContentLabel.text = msg
        alertSkipButton.isHidden = true
        confirmButton.setTitle("UPDATE NOW".localized(), for: .normal)
        confirmButton.tag = 2
        alertView.isHidden = false
        
        
//        let confirmAlert = UIAlertController(title:"App Update Required", message: msg, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: { (UIAlertAction) in
//
//            if let url = URL(string: AppStoreURL),UIApplication.shared.canOpenURL(url){
//                UIApplication.shared.open(url)
//            }
//        })
//
//        confirmAlert.addAction(okAction)
//        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        
    }
    
    func alertForDeviceBlock(msg:String){
        let msg = "\(msg)"
        
        let confirmAlert = UIAlertController(title:"Device Blocked".localized(), message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: { (UIAlertAction) in
        })
        
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    func updateUILanguage(){
        userNameTextField.placeholder = "Username".localized()
        passwordTextField.placeholder = "Password".localized()
        //backButton.setTitle("Back".localized(), for: .normal)
        welcomeLabel.text = "Welcome".localized()
        instructionLabel.text = "EnterPassword".localized()
        //secondFactorCodeLabel.text = "SFC".localized()
        loginButton.setTitle("Login".localized(), for: .normal)
        forgotPasswordButton.setTitle("ForgotPassword".localized(), for: .normal)
        forgetPasswordNextButton.setTitle("NEXT".localized(), for: .normal)
    }
    //MARK: - End
    
    //MARK: - textField Delegate
       func textFieldDidBeginEditing(_ textField: UITextField) {
          
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
