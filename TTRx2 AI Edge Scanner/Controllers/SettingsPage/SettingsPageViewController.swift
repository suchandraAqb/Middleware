//
//  SettingsPageViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Dhiman on 20/06/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class SettingsPageViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,SingleSelectDropdownDelegate {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var settingTableView: UITableView!
    var arrCount = 1
    var inputViewForTableView : UIView?
    var erpList = [Any]()
    var isdropdownItemSelected : Bool = false
    var indexValue : Int = 0
    var selectedDict = NSDictionary()
    var credentialsArr = NSMutableArray()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.setRoundCorner(cornerRadious: saveButton.frame.size.height/2)
        sectionView.roundTopCorners(cornerRadious: 40)
        self.createInputAccessoryViewForTableView()
        self.erpActionWebServiceCall()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - End
    
    //MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender:UIButton){
        if (textFieldTobeField != nil) {
            textFieldTobeField.resignFirstResponder()
        }//,,,sbm1
        
        var isEmpty = false
        for i in 0..<credentialsArr.count {
            let dict = (credentialsArr[i] as? NSMutableDictionary)!
            if let userName = dict["username"] as? String,userName.isEmpty{
                isEmpty = true
            }
            if let password = dict["password"] as? String,password.isEmpty{
                isEmpty = true
            }
            if isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please fill all the details", InViewC: self)
                return
            }
        }
        
        let arr = NSMutableArray()
        for i in 0..<credentialsArr.count {
            var dict = NSMutableDictionary()
            dict = (credentialsArr[i] as? NSMutableDictionary)!
            dict.removeObject(forKey: "erp")
            arr.add(dict)
        }
        self.saveuserSettingsWebServiceCall(arr: arr)
    }
    //MARK: - End
    
    //MARK: - Private Functions
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            settingTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        settingTableView.contentInset = .zero
    }
    
    func createInputAccessoryViewForTableView()
    {
        inputViewForTableView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 40.0))
        inputViewForTableView?.backgroundColor = UIColor.init(red: 198/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        let btnDone: UIButton = UIButton(type: .custom)
        btnDone.frame = CGRect(x: (UIScreen.main.bounds.size.width - 80.0), y: 0.0, width: 80.0, height: 40.0)
        btnDone.setTitle("Done".localized(), for: UIControl.State())
        btnDone.setTitleColor(UIColor.black, for: UIControl.State())
        btnDone.addTarget(self, action: #selector(doneTyping), for: .touchUpInside)
        inputViewForTableView!.addSubview(btnDone)
        
        let btnCancel: UIButton = UIButton(type: .custom)
        btnCancel.frame = CGRect(x: 0, y: 0.0, width: 80.0, height: 40.0)//(UIScreen.main.bounds.size.width - 300.0)
        btnCancel.setTitle("Cancel".localized(), for: UIControl.State())
        btnCancel.setTitleColor(UIColor.black, for: UIControl.State())
        btnCancel.addTarget(self, action: #selector(cancelTyping), for: .touchUpInside)
        inputViewForTableView!.addSubview(btnCancel)
        
    }
    
    func populateCrendentialsArr(){
        if credentialsArr.count == 0{
            for i in 0..<erpList.count{
                let dict = NSMutableDictionary()
                let erpDict = erpList[i] as? NSDictionary
                dict.setValue("", forKey: "username")
                dict.setValue("", forKey: "password")
                dict.setValue(erpDict?["erp_name"] as! String, forKey:"erp")
                dict.setValue(erpDict?["erp_uuid"] as! String, forKey: "erp_uuid")
                credentialsArr.add(dict)
            }
        }
        settingTableView.reloadData()
    }
    
    
    //MARK: - End
    
    //MARK: - Webservice call
    func erpActionWebServiceCall(){
        
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"erpAction")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["target_action"] = Utility.getActionId(type: "getuserSettings")
        

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ErpAction", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let responseDict: NSDictionary = responseData as? NSDictionary{
                       let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            //,,,sbm1
                            /*
                            let erpArr = Utility.converJsonToArray(string: responseDict["data"] as! String)
                                if erpArr.count > 0 {
                                    self.erpList = erpArr
                                }
                            self.populateCrendentialsArr()
                            */
                            
                            if let dataDict = Utility.convertToDictionary(text: responseDict["data"] as! String) {
//                                print("dataDict.....?????",dataDict)
                                if let erpArr = dataDict ["target_erps"] as? [Any] {
                                    if erpArr.count > 0 {
                                        self.erpList = erpArr
                                    }
                                }
                                self.populateCrendentialsArr()
                            }
                            //,,,sbm1
                        }else {
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
    func saveuserSettingsWebServiceCall(arr:NSArray){
        
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"saveusersettings")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["credentials"] = Utility.json(from:arr)

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "saveuserSettings", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let responseDict: NSDictionary = responseData as? NSDictionary{
                       let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            Utility.moveToHomeAsRoot()

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
    
    //MARK: - textField Delegate
    
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            let pointInTable = textField.superview!.convert(textField.frame.origin, to: settingTableView)
            var tableVContentOffset = settingTableView.contentOffset
            tableVContentOffset.y = pointInTable.y
            if let accessoryView = textField.inputAccessoryView {
                tableVContentOffset.y -= accessoryView.frame.size.height
            }
            settingTableView.setContentOffset(tableVContentOffset, animated: true)
            return true;
      }
    
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.inputAccessoryView = inputViewForTableView
            textFieldTobeField = textField

        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            let dict = credentialsArr.object(at: textField.tag) as? NSMutableDictionary

            if textField.accessibilityHint == "Username"{
                dict?.setValue(textField.text, forKey: "username")

            }
            if textField.accessibilityHint == "Password"{
                dict?.setValue(textField.text, forKey: "password")

            }
            credentialsArr.replaceObject(at: textField.tag, with: dict!)
            settingTableView.reloadData()
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool
        {
            //textField.resignFirstResponder()
            settingTableView.setContentOffset(CGPoint(x:0,y: 0), animated: true)
            return true
        }
    
    //MARK: - End
    
    //MARK: - UItableViewDataSource & UITableviewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 10
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        return view
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return erpList.count
   }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        cell.usernameTextfield.inputAccessoryView = inputViewForTableView
        cell.passwordTextfield.inputAccessoryView = inputViewForTableView
        cell.usernameTextfield.addLeftViewPadding(padding: 10)
        cell.passwordTextfield.addLeftViewPadding(padding: 10)
        
        if let dict = credentialsArr[indexPath.section] as? NSDictionary{
            
            var userStr = ""
            if let userName = dict["username"] as? String , !userName.isEmpty{
                userStr = userName
            }
            cell.usernameTextfield.text = userStr
            
            var passwordStr = ""
            if let password = dict["password"] as? String , !password.isEmpty{
                passwordStr = password
            }
            cell.passwordTextfield.text = passwordStr
            
            var erpvalueStr = ""
            if let erpvalue = dict["erp"] as? String, !erpvalue.isEmpty{
                erpvalueStr = erpvalue
            }
            
            cell.credentialsLabel.text = "\(erpvalueStr) Credentials"
        }
        cell.usernameTextfield.tag = indexPath.section
        cell.passwordTextfield.tag = indexPath.section
        cell.usernameTextfield.accessibilityHint = "Username"
        cell.passwordTextfield.accessibilityHint = "Password"

        return cell
    
   }
    //MARK: - SingleSelectDropdownDelegate

    func selecteditem(data: NSDictionary,sender:UIButton?) {
        isdropdownItemSelected = true
        indexValue = sender!.tag
        selectedDict = data
        var dict = NSMutableDictionary()
        dict = credentialsArr.object(at: sender!.tag) as! NSMutableDictionary
        dict.setValue(data["name"], forKey: "erp")
        dict.setValue(dict["username"], forKey: "username")
        dict.setValue(dict["password"], forKey: "password")

        credentialsArr.replaceObject(at: sender!.tag, with: dict)
        settingTableView.reloadData()
    }
}
 class SettingsTableViewCell : UITableViewCell{
    @IBOutlet weak var usernameTextfield:UITextField!
    @IBOutlet weak var passwordTextfield:UITextField!
    @IBOutlet weak var dropdownButton:UIButton!
    @IBOutlet weak var credentialsLabel:UILabel!
     
     override func awakeFromNib() {
         usernameTextfield.setRoundCorner(cornerRadious: 10)
         usernameTextfield.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10)
         passwordTextfield.setRoundCorner(cornerRadious: 10)
         passwordTextfield.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10)
         
     }
}
