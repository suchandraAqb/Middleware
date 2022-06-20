//
//  SecondViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 14/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class SecondViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var rememberLabel: UILabel!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var enterUsernameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    var isAutoLogin:Bool?
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CreateNewSession"), object: nil)
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.createNewSession(_:)), name: NSNotification.Name(rawValue: "CreateNewSession"), object: nil)
        
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.sizeToFit()
        createInputAccessoryView()
        
        userNameTextField.inputAccessoryView = doneToolbar
        userNameTextField.inputAccessoryView = inputAccView
        userNameTextField.returnKeyType = .done
        
        if let rememberedUser = defaults.value(forKey: "rememberedUser") as? Bool {
            if rememberedUser {
                if let user = defaults.value(forKey: "userName") as? String {
                    userNameTextField.text = user
                    rememberMeButton.isSelected = true
                    
                    if isAutoLogin != nil && isAutoLogin ?? false {
                        nextButtonPressed(UIButton())
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUILanguage()
    }
    
    @objc func createNewSession(_ notification: NSNotification) {

        if let rememberedUser = defaults.value(forKey: "rememberedUser") as? Bool {
            if rememberedUser {
                if let user = defaults.value(forKey: "userName") as? String {
                    userNameTextField.text = user
                    rememberMeButton.isSelected = true
                    
                    if isAutoLogin != nil && isAutoLogin ?? false {
                        nextButtonPressed(UIButton())
                    }
                }
            }
        }
    }
    
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func nextButtonPressed(_ sender:UIButton){
        guard let userNameStr = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userNameStr.isEmpty else {
            Utility.showPopup(Title: App_Title, Message: "EnterUsername".localized(), InViewC: self)
            return
        }
        
        let clientUdid = (defaults.value(forKey: "client_udid") ?? "") as! String
        
        var requestDict = [String:Any]()
        requestDict["client_uuid"] = clientUdid // Test Client ID
        requestDict["username"] = userNameStr
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "Login", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                    self.processLoginResponse(responseDict, userNameStr: userNameStr)
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
    
    @IBAction func rememberMeButtonPressed(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
    }
    
    
    //MARK: - End
    //MARK: - Private Method
    func processLoginResponse(_ responseDict:NSDictionary,userNameStr:String){
        
        if responseDict["result"] as! String == "REQUIRE_PASSWORD"{
            
            if self.rememberMeButton.isSelected{
                defaults.set(userNameStr, forKey: "userName")
                defaults.set(true, forKey: "rememberedUser")
            }else{
                defaults.set(nil, forKey: "userName")
                defaults.set(nil, forKey: "password")
                defaults.set(false, forKey: "rememberedUser")
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ThirdView") as! ThirdViewController
//            controller.userName = userNameStr
            if self.isAutoLogin != nil && self.isAutoLogin ?? false {
                controller.isAutoLogin = self.isAutoLogin
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
            
        }else if responseDict["result"] as! String == "OK"{
            if self.rememberMeButton.isSelected{
                defaults.set(userNameStr, forKey: "userName")
                defaults.set(true, forKey: "rememberedUser")
            }else{
                defaults.set(nil, forKey: "userName")
                defaults.set(nil, forKey: "password")
                defaults.set(false, forKey: "rememberedUser")
            }
            
            Utility.moveToHomeAsRoot()
            
        }else{
            Utility.showPopup(Title: App_Title, Message: "Incorrect username", InViewC: self)
        }
        
    }
    func updateUILanguage(){
        rememberLabel.text = "RememberMe".localized()
        userNameTextField.placeholder = "Username".localized()
        backButton.setTitle("Back".localized(), for: .normal)
        welcomeLabel.text = "Welcome".localized()
        enterUsernameLabel.text = "EnterUsername".localized()
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
