//
//  ContainerSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 17/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  ContainerSearchViewDelegate: class {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class ContainerSearchViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var gs1TextField: UITextField!
    @IBOutlet weak var uuidTextField: UITextField!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var packageTypeLabel: UILabel!
    @IBOutlet weak var haveParentLabel: UILabel!
    
    var allLocations:NSDictionary?
    var packageTypes:Array<Any>?
    
    weak var delegate: ContainerSearchViewDelegate?
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
        allLocations = UserInfosModel.getLocations()
        getPackageTypeList()
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
        gs1TextField.delegate = self
        uuidTextField.delegate = self
    }
    
    func populateSearchData(){
        if !searchDict.isEmpty {
            if let txt = searchDict["location_uuid"] as? String,!txt.isEmpty{
                locationLabel.accessibilityHint = txt
                locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                
            }
            
            if let txt = searchDict["packaging_type_id"] as? String,!txt.isEmpty{
                packageTypeLabel.accessibilityHint = txt
                packageTypeLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                
            }
            
            if let txt = searchDict["have_parent"] as? String,!txt.isEmpty{
                haveParentLabel.accessibilityHint = txt
                haveParentLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                
            }
            
            if let txt = searchDict["location_uuid_show"] as? String,!txt.isEmpty{
                locationLabel.text = txt
            }
            
            if let txt = searchDict["packaging_type_id_show"] as? String,!txt.isEmpty{
                packageTypeLabel.text = txt
            }
            
            if let txt = searchDict["have_parent_show"] as? String,!txt.isEmpty{
                haveParentLabel.text = txt
            }
            
            if let txt = searchDict["container_uuid"] as? String,!txt.isEmpty{
                uuidTextField.text = txt
            }
            
            if let txt = searchDict["gs1_id"] as? String,!txt.isEmpty{
                gs1TextField.text = txt
            }
            
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1{
            if allLocations == nil {
                return
            }
        
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = true
            controller.nameKeyName = "name"
            controller.listItemsDict = allLocations
            controller.delegate = self
            controller.type = "Locations".localized()
            controller.sender = sender
            controller.modalPresentationStyle = .custom
                
            self.present(controller, animated: true, completion: nil)
        } else if sender.tag == 2 {
            if packageTypes == nil {
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = packageTypes as! Array<[String:Any]>
            controller.type = "Package Type".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        } else {
            let parentList = [["name" : "Yes", "value" : "true"],["name" : "No", "value": "false"]]
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = parentList
            controller.type = "Have Parent".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func locationScanButtonPressed(_ sender: UIButton) {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
                controller.delegate = self
                controller.isForLocationSelection=true
                self.navigationController?.pushViewController(controller, animated: true)
                
//                self.didReceiveBarcodeLocationScan(codeDetails: ["scannedCodes":"b592af47-4319-4739-824b-9ca8d93d34cc"])

    }
    
    
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var locationstr = ""
        if let str = locationLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            locationstr = str
        }
        
        var packagestr = ""
        if let str = packageTypeLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            packagestr = str
        }
        
        var haveparentstr = ""
        if let str = haveParentLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            haveparentstr = str
        }
        
        var locationstrShow = ""
        if let str = locationLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            locationstrShow = str
        }
        
        var packagestrShow = ""
        if let str = packageTypeLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            packagestrShow = str
        }
        
        var haveparentstrShow = ""
        if let str = haveParentLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            haveparentstrShow = str
        }
        
        var gs1str = ""
        if let str = gs1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            gs1str = str
        }
        
        var uuidstr = ""
        if let str = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            uuidstr = str
        }
               
        
        var appendStr = ""
        
        if !locationstr.isEmpty{
            appendStr = appendStr + "location_uuid=\(locationstr)&"
            searchDict["location_uuid"] = locationstr
            searchDict["location_uuid_show"] = locationstrShow
        }else{
            searchDict["location_uuid"] = ""
            searchDict["location_uuid_show"] = ""
        }
        
        if !packagestr.isEmpty{
            appendStr = appendStr + "packaging_type_id=\(packagestr)&"
            searchDict["packaging_type_id"] = packagestr
            searchDict["packaging_type_id_show"] = packagestrShow
        }else{
            searchDict["packaging_type_id"] = ""
            searchDict["packaging_type_id_show"] = ""
        }
        
        if !haveparentstr.isEmpty{
            appendStr = appendStr + "have_parent=\(haveparentstr)&"
            searchDict["have_parent"] = haveparentstr
            searchDict["have_parent_show"] = haveparentstrShow
        }else{
            searchDict["have_parent"] = ""
            searchDict["have_parent_show"] = ""
        }
        
        if !gs1str.isEmpty{
            appendStr = appendStr + "gs1_id=\(gs1str)&"
            searchDict["gs1_id"] = gs1str
        }else{
            searchDict["gs1_id"] = ""
        }
        
        if !uuidstr.isEmpty{
            appendStr = appendStr + "container_uuid=\(uuidstr)&"
            searchDict["container_uuid"] = uuidstr
        }else{
            searchDict["container_uuid"] = ""
        }
                
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
        
      
        
    }
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        doneTyping()
        searchDict = [String:Any]()
        gs1TextField.text = ""
        uuidTextField.text = ""
        locationLabel.text = "Location".localized()
        locationLabel.accessibilityHint = ""
        locationLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        packageTypeLabel.text = "Package Type".localized()
        packageTypeLabel.accessibilityHint = ""
        packageTypeLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        haveParentLabel.text = "Have Parent".localized()
        haveParentLabel.accessibilityHint = ""
        haveParentLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        self.delegate?.clearSearch()
        self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
    }
    //MARK: - End
    
    //MARK: getList
    func getPackageTypeList(){
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetPackageTypeList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    if let dataArray = responseData as? Array<Any> {
                        self.packageTypes = dataArray
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
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 1 {
            
            if let name = data["name"] as? String{
                locationLabel.text = name
                locationLabel.accessibilityHint = itemStr
                locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
        }
    }
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil{
            if sender?.tag == 2{
                if let name = data["name"] as? String{
                    packageTypeLabel.text = name
                    packageTypeLabel.accessibilityHint = "\(data["id"]!)"
                    packageTypeLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
            }else{
                if let name = data["name"] as? String{
                    haveParentLabel.text = name
                    haveParentLabel.accessibilityHint = name
                    haveParentLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
                if let valuestr = data["value"] as? String{
                    haveParentLabel.accessibilityHint = valuestr
                }
            }
            
        }
    }
    //MARK: - End
}

extension ContainerSearchViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
    
    func didReceiveBarcodeLocationScan(codeDetails:[String:Any]){
        let locationCode = codeDetails["scannedCodes"] as! String
        print(locationCode)
        if let dict = allLocations![locationCode] as? Dictionary<String,Any> {
            let btn=UIButton()
            btn.tag=1
            self.selectedItem(itemStr: locationCode, data: dict as NSDictionary,sender: btn)
        }else{
            Utility.showPopup(Title: "Error!", Message: "Selected location is not available.".localized() , InViewC: self)
        }
    }
}

