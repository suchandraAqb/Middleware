//
//  ViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 13/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class InitialViewController: BaseViewController, UIScrollViewDelegate  {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    @IBOutlet var languageButtons: [UIButton]!
    
    var urlString:String?
    var isAutoLogin:Bool?

    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let paddingLabelView = UILabel(frame: CGRect(x: 0, y: 0, width: 15, height: urlTextField.frame.size.height))
        paddingLabelView.font = UIFont(name: "Poppins-Regular", size: 16.0)
        paddingLabelView.textColor = UIColor.white
        paddingLabelView.text = "https://"
        paddingLabelView.alpha = 0.5
        urlTextField.leftView = paddingLabelView
        urlTextField.leftViewMode = .always
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.sizeToFit()
        createInputAccessoryView()
        urlTextField.inputAccessoryView = doneToolbar
        urlTextField.inputAccessoryView = inputAccView
        urlTextField.returnKeyType = .done
        
        //urlString = "https://test-client-tt2qbo-connector-services.tracktraceweb.com/" // LIVE URL
        //urlString = "https://test-client-ttrx-ai-edge-scanner.test.tracktraceweb.com/" // DEV URL
        //urlString = "https://rapidrxdemo2020.tracktraceweb.com/" // PRODUCTION TEST URL
        
        //urlString = "vrstest.test.tracktraceweb.com/"
        
        //urlString = "https://test-client-ttrx-ai-edge-scanner.pre-test.tracktraceweb.com/"
        
        //urlTextField.text = urlString
        
        let btn = UIButton()
        if let lang = defaults.object(forKey: AppLanguage) as? String{
            if lang == "en"{
                btn.tag = 1
            }else if lang == "fr"{
                btn.tag = 2
            }else{
                btn.tag = 3
            }
        }else{ 
            btn.tag = 1
        }
        
        languageButtonPressed(btn)
        if isAutoLogin != nil && isAutoLogin ?? false {
            if let postUrl = defaults.object(forKey: "PortalBaseUrl") as? String{
                urlString = postUrl
                urlTextField.text = postUrl.replacingOccurrences(of: "https://", with: "")
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SecondView") as! SecondViewController
            controller.isAutoLogin = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected, defaultColorCode: "FFFFFF")
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected, defaultColorCode: "FFFFFF")
        
       
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func toggleSingleMultiScan(_ sender: UIButton) {
        sender.isSelected.toggle()
        defaults.set(sender.isSelected, forKey: "IsMultiScan")
        multiButton.isSelected = sender.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected , defaultColorCode: "FFFFFF")
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected, defaultColorCode: "FFFFFF")
    }
    
    @IBAction func nextButtonPressed(_ sender:UIButton){
        if urlString != nil{
            if validateURL(){
                if (!urlString!.hasPrefix("http://") && !urlString!.hasPrefix("https://"))
                {
                    urlString = "https://" + urlString!
                }
                var updatedUrlStr = ""
                if urlString!.hasSuffix("/"){
                    updatedUrlStr = urlString! + "auth/get_client_info/"
                }else{
                    updatedUrlStr = urlString! + "/auth/get_client_info/"
                }
                
                if let url = URL(string: updatedUrlStr) , UIApplication.shared.canOpenURL(url){
                    getClientDetails(appendStr: updatedUrlStr)
                }else{
                    Utility.showPopup(Title: App_Title, Message: "Please enter valid URL", InViewC: self)
                }
                
            }
        }else{
            Utility.showPopup(Title: App_Title, Message: "Please enter URL", InViewC: self)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender:UIButton){
        /* if(defaults.bool(forKey: "IsMultiScan")){
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
         controller.isForEndPointURLScan = true
         controller.delegate = self
         self.navigationController?.pushViewController(controller, animated: true)
         }else{
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
         controller.isForEndPointURLScan = true
         controller.delegate = self
         self.navigationController?.pushViewController(controller, animated: true)
         }*/
        
        let storyBoard = UIStoryboard(name: "Scanner", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "ScannerVC") as! ScannerVC
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func languageButtonPressed(_ sender:UIButton){
        
        if sender.isSelected{
            return
        }
        
        for btn in languageButtons{
            
            if btn.tag == sender.tag{
                btn.isSelected = true
                defaults.set(btn.accessibilityHint, forKey: AppLanguage)
                Utility.setAppLanguage(language: btn.accessibilityHint ?? "") //en , pt-BR , fr
            }else{
                btn.isSelected = false
            }
        }
    }
    
    
    //MARK: - End
    //MARK: - Private Method
    func validateURL()->Bool{
        var isvalidated = true
        urlString = urlString!.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString!.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter URL", InViewC: self)
            isvalidated = false
        }
        return isvalidated
    }
    
    func getClientDetails(appendStr:String?){
        self.showSpinner(onView: self.view)
        
        Utility.GETServiceCall(type: "", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let client_udid = responseDict["client_uuid"] as? String {
                        defaults.set(client_udid, forKey: "client_udid")
                        
                        //                            if let lang = responseDict["lang"] {
                        //                               Utility.setAppLanguage(language: lang as! String)
                        //                            }
                        
                        if let api_endpoint = responseDict["rest_endpoint"] as? String{
                            
                            var urlStr:String = api_endpoint
                            
                            if !urlStr.hasSuffix("/"){
                                urlStr = urlStr + "/"
                            }
                            
                            defaults.set(urlStr, forKey: "BaseURL")
                        }
                        
                        if let portal_base_url = responseDict["portal_base_url"] as? String{
                            defaults.set(portal_base_url, forKey: "PortalBaseUrl")
                        }
                        
                        if let api_endpoint = responseDict["opt_rest_endpoint"] as? String{
                            
                            var urlStr:String = api_endpoint
                            
                            if !urlStr.hasSuffix("/"){
                                urlStr = urlStr + "/"
                            }
                            
                            defaults.set(urlStr, forKey: "BaseOptURL")
                            
                        }
                        
                        var actualFormat = "y-m-d"
                        if let dateFormat:String = responseDict["date_format"] as? String {
                            if dateFormat == "us_mmddyyyy" {
                                actualFormat = "mm-dd-yyyy"
                            }else if dateFormat == "yyyymmdd"{
                                actualFormat = "yyyy-mm-dd"
                            }else if dateFormat == "ddmmyyyy"{
                                actualFormat = "dd-mm-yyyy"
                            }
                        }
                        
                        defaults.set(actualFormat, forKey: "dateformat")
                        
                        var timeFormat = "hh:mm a"
                        if let tformat:String = responseDict["time_format"] as? String {
                            
                            if tformat == "12h"{
                                timeFormat = "hh:mm a"
                            }else{
                                timeFormat = "HH:mm"
                            }
                            
                        }
                        
                        defaults.set(timeFormat, forKey: "timeFormat")
                        
                        if let tZone = responseDict["time_zone"] as? String {
                            defaults.set(tZone, forKey: "time_zone")
                        }
                        
                        if let clientFriendlyName = responseDict["client_friendly_name"] as? String{
                            defaults.set(clientFriendlyName, forKey: "client_friendly_name")
                        }
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SecondView") as! SecondViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    
                    if let license = responseDict["scandit_licence_key"] as? String {
                        defaults.set(license, forKey: "scandit_licence_key")
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        urlString = textField.text
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    //MARK: - End
    
    
}

extension InitialViewController : ScanViewControllerDelegate{
    func didScanCompleteForEndPointURL(urlString: String) {
        var updatedUrlStr = ""
        if urlString.hasSuffix("/"){
            updatedUrlStr = urlString + "auth/get_client_info/"
        }else{
            updatedUrlStr = urlString + "/auth/get_client_info/"
        }
        if (updatedUrlStr.hasPrefix("http://") || !updatedUrlStr.hasPrefix("https://"))
        {
            if updatedUrlStr.contains("http://"){
                updatedUrlStr = updatedUrlStr.replacingOccurrences(of: "http://", with: "https://")
            }else{
                updatedUrlStr = "https://" + updatedUrlStr
            }
        }
        
        DispatchQueue.main.async{
            if let url = URL(string: updatedUrlStr) , UIApplication.shared.canOpenURL(url){
                self.getClientDetails(appendStr: updatedUrlStr)
            }else{
                Utility.showPopup(Title: App_Title, Message: "Invalid URL", InViewC: self)
            }
        }
        
    }
}
extension InitialViewController : SingleScanViewControllerDelegate{
    func didSingleScanCompleteForEndPointURL(urlString: String) {
        var updatedUrlStr = ""
        if urlString.hasSuffix("/"){
            updatedUrlStr = urlString + "auth/get_client_info/"
        }else{
            updatedUrlStr = urlString + "/auth/get_client_info/"
        }
        if (updatedUrlStr.hasPrefix("http://") || !updatedUrlStr.hasPrefix("https://"))
        {
            if updatedUrlStr.contains("http://"){
                updatedUrlStr = updatedUrlStr.replacingOccurrences(of: "http://", with: "https://")
            }else{
                updatedUrlStr = "https://" + updatedUrlStr
            }
        }
        DispatchQueue.main.async{
            if let url = URL(string: updatedUrlStr) , UIApplication.shared.canOpenURL(url){
                self.getClientDetails(appendStr: updatedUrlStr)
            }else{
                Utility.showPopup(Title: App_Title, Message: "Invalid URL", InViewC: self)
            }
        }
    }
}

extension InitialViewController : ScannerDelegate {
    func didScanned(code: String) {
        var updatedUrlStr = ""
        if code.hasSuffix("/"){
            updatedUrlStr = code + "auth/get_client_info/"
        }else{
            updatedUrlStr = code + "/auth/get_client_info/"
        }
        if (updatedUrlStr.hasPrefix("http://") || !updatedUrlStr.hasPrefix("https://"))
        {
            if updatedUrlStr.contains("http://"){
                updatedUrlStr = updatedUrlStr.replacingOccurrences(of: "http://", with: "https://")
            }else{
                updatedUrlStr = "https://" + updatedUrlStr
            }
        }
        urlString = code
        urlTextField.text = code.replacingOccurrences(of: "https://", with: "")

        DispatchQueue.main.async{
            if let url = URL(string: updatedUrlStr) , UIApplication.shared.canOpenURL(url){
                self.getClientDetails(appendStr: updatedUrlStr)
            }else{
                Utility.showPopup(Title: App_Title, Message: "Invalid URL", InViewC: self)
            }
        }
    }
}
