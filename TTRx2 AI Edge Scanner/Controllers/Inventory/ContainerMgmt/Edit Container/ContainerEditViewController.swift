//
//  ContainerEditViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 01/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ContainerEditViewController: BaseViewController,SingleSelectDropdownDelegate,ConfirmationViewDelegate {
    
    //MARK: - Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    //MARK: End
    //MARK: -
    @IBOutlet weak var generalView: UIView!
    
    
    @IBOutlet weak var serialLabel: UITextField!
    @IBOutlet weak var gs1idLabel: UITextField!
    
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var storageNameLabel: UILabel!
    
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var shelfNameLabel: UILabel!
    
    @IBOutlet weak var containerTypeLabel: UILabel!
    @IBOutlet weak var dispositionLabel: UILabel!
    @IBOutlet weak var businessStepLabel: UILabel!
    
    var allLocations:NSDictionary?
    var selectedLocationUuid:String?
    var storageAreas:Array<Any>?
    var shelfs:Array<Any>?
    var selectedStorageArea:NSDictionary?
    var selectedShelf:NSDictionary?
    var isStorageSelected = false
    var isShelfSelected = false
    
    
    var packageTypeList:Array<Any>?
    var dispositionList:Array<Any>?
    var businessStepList:Array<Any>?
    
    
    var serialNumber = ""
    var disPatchGroup = DispatchGroup()
    var containerDetailsDict = [String:Any](){
        didSet{
            self.populateContainerDetails()
            self.removeSpinner()
        }
    }
    
    
    //MARK: - View Life Cycle
    
    override func loadView() {
        super.loadView()
        //createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        sectionView.roundTopCorners(cornerRadious: 40)
        generalView.layer.cornerRadius = 15.0
        generalView.clipsToBounds = true
        
        storageView.isHidden = true
        shelfView.isHidden = true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        allLocations = UserInfosModel.getLocations()
        self.getContainerDetails()
        
        //        self.disPatchGroup.notify(queue: .main) {
        //            print("BothApi is called")
        //self.populateContainerDetails()
        self.getPackageTypeList()
        self.getDispositionList()
        self.getBusinessStepList()
        
        // }
        
        removeContainerEditDefaults()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //populateGeneralInfo()
        setup_stepview()
    }
    //MARK: End
    
    //MARK: - Private Method
    func removeContainerEditDefaults(){
        defaults.removeObject(forKey: "container_edit_1stStep")
        defaults.removeObject(forKey: "container_edit_2ndStep")
        defaults.removeObject(forKey: "container_edit_details")
        Utility.removeAdjustmentsFromDB()
    }
    func setup_stepview(){
        let isFirstStepCompleted = defaults.bool(forKey: "container_edit_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "container_edit_2ndStep")
        
        
        step1Button.isUserInteractionEnabled = false
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        if isFirstStepCompleted && isSecondStepCompleted{
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted {
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Button.isUserInteractionEnabled = true
        }
        
    }
    
    func populateContainerDetails() {
        if !containerDetailsDict.isEmpty {
            var dataStr = ""
            if let txt = containerDetailsDict["serial"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            serialLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerDetailsDict["gs1_unique_id"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            gs1idLabel.text = dataStr
            
            if let txt = containerDetailsDict["packaging_type_name"] as? String,!txt.isEmpty{
                containerTypeLabel.text = txt
                containerTypeLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            
            if let txt = containerDetailsDict["packaging_type_id"] as? String{
                containerTypeLabel.accessibilityHint = txt
            }else if let txt = containerDetailsDict["packaging_type_id"] as? NSNumber{
                containerTypeLabel.accessibilityHint = "\(txt)"
            }
            
            if let txt = containerDetailsDict["business_step_name"] as? String,!txt.isEmpty{
                businessStepLabel.text = txt.capitalized
                businessStepLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            if let txt = containerDetailsDict["business_step_id"] as? String{
                businessStepLabel.accessibilityHint = txt
            }else if let txt = containerDetailsDict["business_step_id"] as? NSNumber{
                businessStepLabel.accessibilityHint = "\(txt)"
            }
            
            if let txt = containerDetailsDict["disposition_name"] as? String,!txt.isEmpty{
                dispositionLabel.text = txt.capitalized
                dispositionLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            if let txt = containerDetailsDict["disposition_id"] as? String{
                dispositionLabel.accessibilityHint = txt
            }else if let txt = containerDetailsDict["disposition_id"] as? NSNumber{
                dispositionLabel.accessibilityHint = "\(txt)"
            }
            
            /*if let txt = containerDetailsDict["location_name"] as? String{
             locationNameLabel.text = txt
             }
             
             if let txt = containerDetailsDict["storage_area_name"] as? String{
             storageNameLabel.text = txt
             }
             
             if let txt = containerDetailsDict["storage_shelf_name"] as? String{
             shelfNameLabel.text = txt
             }*/
            
            
            if let txt = containerDetailsDict["location_uuid"] as? String,!txt.isEmpty,allLocations != nil{
                
                let dict = allLocations![txt] as! NSDictionary
                let btn = UIButton()
                btn.tag = 2
                selectedItem(itemStr: txt, data: dict,sender:btn)
            }
            
            if let txt = containerDetailsDict["storage_area_uuid"] as? String,!txt.isEmpty, storageAreas != nil{
                for storageArea in storageAreas!{
                    if let storageDict = storageArea as? NSDictionary {
                        if let uuid = storageDict["uuid"] as? String, uuid == txt {
                            let btn = UIButton()
                            btn.tag = 3
                            selecteditem(data: storageDict,sender:btn)
                        }
                    }
                }
            }
            
            
            
        }else{
            getContainerDetails()
        }
    }
    func saveData()->NSMutableDictionary{
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
        if let txt = serialLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "serial")
        }
        
        if let txt = gs1idLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "gs1_unique_id")
        }
        
        if let txt = containerTypeLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "container_type_id")
        }
        
        if let txt = locationNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "location_uuid")
        }
        
        if let txt = storageNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_area_uuid")
        }
        
        if let txt = shelfNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_shelf_uuid")
        }
        
        if let txt = dispositionLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "disposition_id")
        }
        
        if let txt = businessStepLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "business_step_id")
        }
        
        if let txt = containerTypeLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "packaging_type_name")
        }
        
        if let txt = locationNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "location_name")
        }
        
        if let txt = storageNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_area_name")
        }
        
        if let txt = shelfNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_shelf_name")
        }
        
        if let txt = dispositionLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "disposition_name")
        }
        
        if let txt = businessStepLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "business_step_name")
        }
        
        if let txt = containerDetailsDict["uuid"] as? String , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "uuid")
        }
        
        
        
        return otherDetailsDict
        
        
    }
    func formValidation(_ dataDict:NSMutableDictionary)->Bool{
        var isValidated = true
        
        let unique_serial = dataDict["serial"] as? String ?? ""
        let gs1_id_unique_serial = dataDict["gs1_unique_id"] as? String ?? ""
        let container_type_id = dataDict["container_type_id"] as? String ?? ""
        //let location_uuid = dataDict["location_uuid"] as? String ?? ""
        //let storage_area_uuid = dataDict["storage_area_uuid"] as? String ?? ""
        //let storage_shelf_uuid = dataDict["storage_shelf_uuid"] as? String ?? ""
        let disposition_id = dataDict["disposition_id"] as? String ?? ""
        let business_step_id = dataDict["business_step_id"] as? String ?? ""
        
        if unique_serial.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "Please enter Container Unique Serial.".localized(), InViewC: self)
            isValidated = false
        }else if gs1_id_unique_serial.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "Please enter GS1 Serial.".localized(), InViewC: self)
            isValidated = false
        }else if container_type_id.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "Please select Container Type.".localized(), InViewC: self)
            isValidated = false
        }/*else if location_uuid.isEmpty {
         Utility.showPopup(Title: App_Title, Message: "Please select Location.".localized(), InViewC: self)
         isValidated = false
         }else if !storageView.isHidden && storage_area_uuid.isEmpty {
         Utility.showPopup(Title: App_Title, Message: "Please select Storage Area.".localized(), InViewC: self)
         isValidated = false
         }else if !shelfView.isHidden && storage_shelf_uuid.isEmpty{
         Utility.showPopup(Title: App_Title, Message: "Please select Shelf.".localized(), InViewC: self)
         isValidated = false
         }*/else if disposition_id.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "Please select Disposition.".localized(), InViewC: self)
            isValidated = false
         }else if business_step_id.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "Please select Business Step.".localized(), InViewC: self)
            isValidated = false
         }
        
        
        return isValidated
        
    }
    //MARK: End
    
    //MARK: - Call Api
    private func getContainerDetails() {
        
        self.showSpinner(onView: self.view)
        let appendStr = "SERIAL/\(serialNumber)"
        //self.showSpinner(onView: self.view)
        //self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "ContainersDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            
            //            DispatchQueue.main.async{
            //self.removeSpinner()
            //self.disPatchGroup.leave()
            
            if isDone! {
                if let responseDict = responseData as? [String: Any] {
                    self.containerDetailsDict = responseDict
                    //                        self.populateContainerDetails()
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
    
    private func getPackageTypeList(){
        //self.showSpinner(onView: self.view)
        //self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "GetPackageTypeList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            //                 DispatchQueue.main.async{
            //                    self.removeSpinner()
            //self.disPatchGroup.leave()
            
            if isDone! {
                if let dataArray = responseData as? Array<Any> {
                    self.packageTypeList = dataArray
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
            //  }
        }
    }
    
    private func getDispositionList(){
        let appendStr = "dispositions"
        //self.disPatchGroup.enter()
        //self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            //                 DispatchQueue.main.async{
            //
            //                    self.removeSpinner()
            //self.disPatchGroup.leave()
            
            if isDone! {
                if let dataArray = responseData as? Array<Any> {
                    self.dispositionList = dataArray
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
            // }
        }
    }
    
    private func getBusinessStepList(){
        let appendStr = "business_steps"
        //self.disPatchGroup.enter()
        //self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            
            //DispatchQueue.main.async{
            //self.removeSpinner()
            //self.disPatchGroup.leave()
            
            
            if isDone! {
                if let dataArray = responseData as? Array<Any> {
                    self.businessStepList = dataArray
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
            //}
        }
    }
    
    private func getShelfList(storageAreaUUID:String){
        let appendStr:String! = (selectedLocationUuid ?? "") as String + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
        //self.disPatchGroup.enter()
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetShelfList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            //DispatchQueue.main.async{
            self.removeSpinner()
            //  self.disPatchGroup.leave()
            
            if isDone! {
                let responseDict: NSDictionary = responseData as! NSDictionary
                
                if let list = responseDict["data"] as? Array<[String : Any]>{
                    self.shelfs = list
                    
                    if let txt = self.containerDetailsDict["storage_shelf_uuid"] as? String,!txt.isEmpty, self.shelfs != nil {
                        for shelf in self.shelfs!{
                            if let shelfDict = shelf as? NSDictionary {
                                if let uuid = shelfDict["storage_shelf_uuid"] as? String, uuid == txt {
                                    let btn = UIButton()
                                    btn.tag = 4
                                    self.selecteditem(data: shelfDict,sender:btn)
                                }
                            }
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
            
            // }
        }
    }
    //MARK: End
    
    //MARK: - IBAction
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        let dict = saveData()
        if !formValidation(dict){
            return
        }
        Utility.saveObjectTodefaults(key: "container_edit_details", dataObject: dict)
        defaults.set(true, forKey: "container_edit_1stStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerEditItemView") as! ContainerEditItemViewController
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
    
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        if sender.tag == 2 {
            nextButtonPressed(UIButton())
            
        }else if sender.tag == 3 {
            let dict = saveData()
            if !formValidation(dict){
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerEditConfirmView") as! ContainerEditConfirmViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
        
    }
    
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1 {
            if packageTypeList == nil {
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = packageTypeList as! Array<[String:Any]>
            controller.type = "Container Type".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag == 2 {
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
        }else if sender.tag == 3 {
            if storageAreas == nil {
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = storageAreas as! Array<[String:Any]>
            controller.delegate = self
            controller.type = "Storage Area".localized()
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag == 4 {
            if shelfs == nil || shelfs?.count == 0 {
                getShelfList(storageAreaUUID: storageNameLabel.accessibilityHint ?? "")
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = shelfs as! Array<[String:Any]>
            controller.type = "Storage Shelf".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag == 5 {
            if dispositionList == nil {
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = dispositionList as! Array<[String:Any]>
            controller.type = "Disposition".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag == 6 {
            if businessStepList == nil {
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = businessStepList as! Array<[String:Any]>
            controller.type = "Business Step".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func backbuttonPressedEditContainer(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to cancel".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
        
    }
    
    
    //MARK: End
    
    //MARK: - SingleSelectDropdownDelegate
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 2 {
            storageView.isHidden = true
            storageNameLabel.text = "Select Storage Area".localized()
            storageNameLabel.accessibilityHint = ""
            shelfView.isHidden = true
            shelfNameLabel.text = "Select Shelf".localized()
            shelfNameLabel.accessibilityHint = ""
            
            if let name = data["name"] as? String{
                locationNameLabel.text = name
                locationNameLabel.accessibilityHint = itemStr
                locationNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                self.selectedLocationUuid = itemStr
                if let sa_areas = data["sa"] as? Array<Any>{
                    storageAreas = sa_areas
                    storageView.isHidden = false
                }else{
                    storageView.isHidden = true
                    shelfView.isHidden = true
                    
                    if let sa_count = data["sa_count"]as? Int {
                        
                        if sa_count > 0 {
                            let userinfo = UserInfosModel.UserInfoShared
                            self.showSpinner(onView: self.view)
                            userinfo.getStorageAreasOfALocation(location_uuid: itemStr, ServiceCompletion:{ (isDone:Bool? , sa:Array<Any>?) in
                                self.removeSpinner()
                                
                                DispatchQueue.main.async{
                                    if sa != nil && !(sa?.isEmpty ?? false){
                                        self.storageAreas = sa
                                        self.storageView.isHidden = false
                                    }
                                }
                                
                            })
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil{
            if sender?.tag == 1{
                if let name = data["name"] as? String{
                    containerTypeLabel.text = name
                    containerTypeLabel.accessibilityHint = "\(data["id"]!)"
                    containerTypeLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
            }else if sender?.tag == 3{
                shelfView.isHidden = true
                shelfNameLabel.text = "Select Shelf".localized()
                shelfNameLabel.accessibilityHint = ""
                
                if let name = data["name"] as? String{
                    storageNameLabel.text = name
                    storageNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                    if let uuid = data["uuid"] as? String{
                        storageNameLabel.accessibilityHint = uuid
                    }
                    
                    isStorageSelected = true
                }
                
                let isShelf = data["is_have_shelf"] as! Bool
                
                if isShelf {
                    shelfView.isHidden = false
                    isShelfSelected = false
                    getShelfList(storageAreaUUID: storageNameLabel.accessibilityHint ?? "")
                }else{
                    shelfView.isHidden = true
                    shelfNameLabel.text = "Select Shelf".localized()
                    shelfNameLabel.accessibilityHint = ""
                    isShelfSelected = false
                    
                }
            }else if sender?.tag == 4{
                if let name = data["name"] as? String{
                    shelfNameLabel.text = name
                    shelfNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                    if let uuid = data["storage_shelf_uuid"] as? String {
                        shelfNameLabel.accessibilityHint = uuid
                    }
                    
                    isShelfSelected = true
                    
                }
            }else if sender?.tag == 5{
                if let name = data["name"] as? String{
                    dispositionLabel.text = name
                    dispositionLabel.accessibilityHint = "\(data["id"]!)"
                    dispositionLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
            }else if sender?.tag == 6{
                if let name = data["name"] as? String{
                    businessStepLabel.text = name
                    businessStepLabel.accessibilityHint = "\(data["id"]!)"
                    businessStepLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
            }
        }
    }
    //MARK: End
    
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
    //MARK: End
    
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
        
    }
    func cancelConfirmation() {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: End
}

extension ContainerEditViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}
