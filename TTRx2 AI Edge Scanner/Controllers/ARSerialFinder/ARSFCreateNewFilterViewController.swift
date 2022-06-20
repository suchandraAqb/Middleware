//
//  ARSFCreateNewFilterViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 06/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFCreateNewFilterViewController: BaseViewController,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate, ConfirmationViewDelegate {//,,,sb11-1
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var generalView: UIView!
    @IBOutlet weak var criteriaView: UIView!
    @IBOutlet var generalButton: UIButton!
    @IBOutlet var criteriaButton: UIButton!
    @IBOutlet var manageAccessBuutton: UIButton!
    @IBOutlet var addCriteriaButton: UIButton!
    
    @IBOutlet var saveAsPresetSwitch: UISwitch!
    @IBOutlet var nameTextfield: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var cumulativeConditionSwitch: UISwitch!
    @IBOutlet var checkInAggregationSwitch: UISwitch!
    @IBOutlet var companyWideSwitch: UISwitch!
    
    @IBOutlet var listTable: UITableView!
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    //,,,sb11
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var checkInAggregationView: UIView!
    @IBOutlet weak var companyWideSearchFilterView: UIView!
    @IBOutlet weak var infoView: UIView!//,,,sb11-10
    
    var saveAsPresetStatus: String = ""
    var cumulativeConditionStatus: String = "OR"
    var itemsList:Array<Any>?//,,,sb11-1
    var requestDict = [String:Any]()//,,,sb11-1
    //,,,sb11
    var mode: String = ""//,,,sb11-3
    var detailsDict = [String:Any]()//,,,sb11-3
    var mainUUID: String = ""//,,,sb11-6
    var selectedDetailsDict = [String:Any]()//,,,sb11-10

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
        
        //,,,temp sb11
        manageAccessBuutton.isHidden = true
        checkInAggregationView.isHidden = true
        companyWideSearchFilterView.isHidden = true
        //,,,temp sb11
        
        Utility.removeARCriteriasDB()//,,,sb11-1
        
        //,,,sb11-6
        mainUUID = ""
        if let uuid = detailsDict["uuid"] as? String {
            mainUUID = uuid
        }
        //,,,sb11-6
        
        //,,,sb11-3
        if mode == "edit" {
            self.ar_viewer_WebserviceCall()
            headerButton.setTitle("Edit Filter".localized(), for: UIControl.State.normal)
        }
        else if mode == "duplicate" {
            self.ar_viewer_WebserviceCall()
            headerButton.setTitle("Duplicate Filter".localized(), for: UIControl.State.normal)
        }
        else {
            headerButton.setTitle("Create a new Filter".localized(), for: UIControl.State.normal)
        }
        //,,,sb11-3
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCriteriaListFromDB()//,,,sb11-1
    }
    //MARK:- End
    
    //MARK:- Core Data
    func getCriteriaListFromDB(){
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(ARSerialFinder.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                itemsList = arr
//                print("itemsList.....>>>>>",itemsList as Any) //,,,sb11-12
                listTable.reloadData()
            }else{
                itemsList = nil
                listTable.reloadData()
            }
        }catch let error{
            print(error.localizedDescription)
            itemsList = nil
            listTable.reloadData()
        }
        
        //,,,sb11-10
        if itemsList != nil && itemsList!.count > 0 {
            infoView.isHidden = false
        }else {
            infoView.isHidden = true
        }
        //,,,sb11-10
    }//,,,sb11-1
    
    func removeProduct(data:NSDictionary){
        if let id = data["id"] {
            do{
                let predicate = NSPredicate(format:"id='\(id)'")
                let serial_obj = try PersistenceService.context.fetch(ARSerialFinder.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    if let obj = serial_obj.first {
                        PersistenceService.context.delete(obj)
                        PersistenceService.saveContext()
                    }
                }
                
                self.getCriteriaListFromDB()
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }//,,,sb11-1
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: UIButton) {
        nameTextfield.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        if itemsList != nil && itemsList!.count > 0 {            
            //,,,sb11-3
            if mode == "edit" || mode == "duplicate" {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                Utility.showPopupWithAction(Title: Warning, Message: "The criteria you are set will be removed once you exit the page. Do you want to exit?".localized(), InViewC: self, isCancel: true, action:{
                    self.navigationController?.popViewController(animated: true)
                })
            }
            //,,,sb11-3
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func generalButtonPressed(_ sender: UIButton) {
        nameTextfield.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        if !generalButton.isSelected {
            generalButton.isSelected=true
//            generalButton.backgroundColor=UIColor.systemBlue
            generalButton.backgroundColor=Utility.hexStringToUIColor(hex: "00AFEF")//,,,sb11-5
            
            generalView.isHidden=false
            criteriaButton.isSelected=false
            criteriaButton.backgroundColor=UIColor.white
            criteriaView.isHidden=true
        }
    }
    @IBAction func criteriaButtonPressed(_ sender: UIButton) {
        nameTextfield.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        if !criteriaButton.isSelected {
            criteriaButton.isSelected=true
//            criteriaButton.backgroundColor=UIColor.systemBlue
            criteriaButton.backgroundColor=Utility.hexStringToUIColor(hex: "00AFEF")//,,,sb11-5
            
            criteriaView.isHidden=false
            generalButton.isSelected=false
            generalButton.backgroundColor=UIColor.white
            generalView.isHidden=true
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        nameTextfield.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        
        //,,,temp sb11-1
        
        if !formValidation(){
            return
        }//,,,sb11
        else {
            if generalButton.isSelected {
                criteriaButtonPressed(criteriaButton)
            }
            else {
                if itemsList != nil && itemsList!.count > 0 {
                    var resultArray = [[String : Any]]()
                    for dict in self.itemsList! {
                        let dict1 = dict as? NSDictionary
                        var dataStr = ""
                        if let match_type_json = dict1!["match_type_json"] as? String,!match_type_json.isEmpty {
                            dataStr = match_type_json
                        }
                        var match_type = ""
                        if let match_type_jsonDict = self.convertToDictionary(text: dataStr) {
                            if let key = match_type_jsonDict["key"] as? String {
                                match_type = key
                            }
                        }
                        
                        dataStr = ""
                        if let type_json = dict1!["type_json"] as? String,!type_json.isEmpty{
                            dataStr = type_json
                        }
                        var option = ""
                        if let type_jsonDict = self.convertToDictionary(text: dataStr) {
                            if let key = type_jsonDict["key"] as? String {
                                option = key
                            }
                        }
                        
                        dataStr = ""
                        if let critera_type = dict1!["critera_type"] as? String,!critera_type.isEmpty{
                            dataStr = critera_type
                        }
                        
//                        var value_to_match_jsonArr : [String]!
                        var value_to_match_jsonArr : Array<Any>!//,,,sb11-7
                        if dataStr == "CategoryBased" {
                            dataStr = ""
                            if let value_to_match_json = dict1!["value_to_match_json"] as? String,!value_to_match_json.isEmpty {
                                dataStr = value_to_match_json
                            }
//                            value_to_match_jsonArr  = convertJsonStringToArray(text: dataStr)
                            value_to_match_jsonArr = convertToArray(text: dataStr)//,,,sb11-10
                        }
                        else if dataStr == "StatusBased" {
                            dataStr = ""
                            if let value_to_match_json = dict1!["value_to_match_json"] as? String,!value_to_match_json.isEmpty {
                                dataStr = value_to_match_json
                            }
//                            value_to_match_jsonArr  = convertJsonStringToArray(text: dataStr)
                            value_to_match_jsonArr = convertToArray(text: dataStr)//,,,sb11-10
                        }
                        else if dataStr == "DateBoundaryBased" {
                            dataStr = ""
                            if let match_type_json = dict1!["match_type_json"] as? String,!match_type_json.isEmpty{
                                dataStr = match_type_json
                            }
                            
                            let match_type_jsonDict = self.convertToDictionary(text: dataStr)
                            var keyStr = ""
                            if let key = match_type_jsonDict!["key"] as? String,!key.isEmpty{
                                keyStr = key
                            }
                            if keyStr == "OPERATOR_BETWEEN" {
                                dataStr = ""
                                if let value_to_match_json = dict1!["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                                    dataStr = value_to_match_json
                                }
                                value_to_match_jsonArr = convertToArray(text: dataStr)
                            }
                            else {
                                dataStr = ""
                                if let value_to_match_json = dict1!["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                                    dataStr = value_to_match_json
                                }
                                value_to_match_jsonArr = convertToArray(text: dataStr) as? [String]
                            }
                        }//,,,sb11-7
                        else if dataStr == "BooleanBased" {
                            //,,,sb11-10
                            /*
                            dataStr = ""
                            if let value_to_match_json = dict1!["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                                dataStr = value_to_match_json
                            }
                            value_to_match_jsonArr = convertToArray(text: dataStr) as? [String]
                            */
                            value_to_match_jsonArr = []
                            //,,,sb11-10
                        }
                        else {
                            //"TextBased", "IntegerBased"
                            dataStr = ""
                            if let value_to_match_json = dict1!["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                                dataStr = value_to_match_json
                            }
                            value_to_match_jsonArr = convertToArray(text: dataStr) as? [String]
                        }
                        
                        var resultDict = [String : Any]()
                        resultDict ["combination"] = cumulativeConditionStatus
                        resultDict ["match_type"] = match_type
                        resultDict ["option"] = option
                        if value_to_match_jsonArr == nil {
                            resultDict ["value_to_match"] = ""
                        }else {
                            resultDict ["value_to_match"] = value_to_match_jsonArr
                        }
                        resultArray.append(resultDict)
                    }
                    let criteriaArrJsonString = Utility.json(from: resultArray)
                    
                    
                    if mode == "edit" {
                        requestDict["context"] = criteriaArrJsonString
                        requestDict["filter_name"] = nameTextfield.text
                        requestDict["name"] = nameTextfield.text
                        requestDict["description"] = descriptionTextView.text
                        requestDict["combination"] = cumulativeConditionStatus//,,,sb11-7
                    }//,,,sb11-3
                    else {
                        //create, duplicate
                        requestDict["criteria"] = criteriaArrJsonString
                        requestDict["filter_name"] = nameTextfield.text
                        requestDict["name"] = nameTextfield.text
                        requestDict["description"] = descriptionTextView.text
                        requestDict["filter_module"] = "SERIAL_FINDER"
                        requestDict["is_preset"] = saveAsPresetStatus
                        requestDict["combination"] = cumulativeConditionStatus
                    }
                    
//                    print("requestDict....>>>><<<<<",requestDict) //,,,sb11-12
                    
                    if (saveAsPresetStatus == "true") {
                        if mode == "edit" {
                            self.ar_viewer_Update_WebserviceCall()
                        }//,,,sb11-3
                        else {
                            //create, duplicate
                            self.ar_viewer_save_and_search_WebserviceCall()
                        }
                    }
                    else {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
                        controller.confirmationMsg = "By not saving as a preset, the criteria you are set will be discarded once you will be done with this search. Continue?".localized()
                        controller.delegate = self
                        controller.isCancelConfirmation = false
                        controller.controllerName = "ARSFCreateNewFilterViewController"
                        
                        controller.modalPresentationStyle = .custom
                        self.present(controller, animated: true, completion: nil)
                    }
                }
                else {
                    Utility.showPopup(Title: Warning, Message: "Please add criteria".localized(), InViewC: self)
                }
            }
        }
        //,,,temp sb11-1
    }
    @IBAction func addCriteriaButtonPressed(_ sender: UIButton) {
        nameTextfield.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFAddCriteriaSelectionView") as! ARSFAddCriteriaSelectionViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func manageAccessButtonPressed(_ sender: UIButton) {
        nameTextfield.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFManageAccessView") as! ARSFManageAccessViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func saveAsPresetSwitchValueChange(_ sender: UISwitch) {
        nameTextfield.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        //,,,sb11
        if (saveAsPresetSwitch.isOn) {
            saveAsPresetStatus = "true"
            nameView.isHidden = false
            descriptionView.isHidden = false
        }else {
            saveAsPresetStatus = "false"
            nameView.isHidden = true
            descriptionView.isHidden = true
        }
        //,,,sb11
    }
    @IBAction func cumulativeConditionSwitchValueChange(_ sender: UISwitch) {
        nameTextfield.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        //,,,sb11
        if (cumulativeConditionSwitch.isOn) {
            cumulativeConditionStatus = "AND"
        }else {
            cumulativeConditionStatus = "OR"
        }
        //,,,sb11
    }
    @IBAction func checkInAggregationSwitchValueChange(_ sender: UISwitch) {
    }
    @IBAction func companyWideSwitchValueChange(_ sender: UISwitch) {
    }
    //MARK:- End
    
    //MARK: - Webservice Call
    func ar_viewer_Update_WebserviceCall() {
            let appendStr = "/\(mainUUID)"//,,,sb11-6
            self.showSpinner(onView: self.view)
                        
            Utility.PUTServiceCall(type: "ar_viewer", serviceParam: requestDict, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                
                DispatchQueue.main.async {
                    self.removeSpinner()
                    if isDone! {
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if (responseDict["uuid"] as? String) != nil {
                            self.didClickOnCameraWithFilter(uuid: responseDict["uuid"] as! String)
    //                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Shipment Updated Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        }
                    }else {
                        if responseData != nil{
                            let responseDict: NSDictionary = responseData as! NSDictionary
                            if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                                Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                            }else  if let errorMsg = responseDict["message"] as? String {
                                Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            }else{
                                Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                            }
                        }else{
                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                        
                        
                    }
                }
            }
    }//,,,sb11-3
    
    func ar_viewer_save_and_search_WebserviceCall() {
        let appendStr = ""
        DispatchQueue.main.async{
            self.showSpinner(onView: self.view)
        }
        Utility.POSTServiceCall(type: "ar_viewer_save_and_search", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if (responseDict["uuid"] as? String) != nil {
                            self.didClickOnCameraWithFilter(uuid: responseDict["uuid"] as! String)
                        }
                    }else {
                        let dict = responseData as! NSDictionary
                        let error = dict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message:error , InViewC: self)
                    }
                }
        }
    }//,,,sb11-1
    
    func ar_viewer_WebserviceCall() {
        let appendStr = "/\(mainUUID)"//,,,sb11-6
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ar_viewer", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if let name = responseDict["name"] as? String {
                            self.nameTextfield.text = name
                        }
                        if let description = responseDict["description"] as? String {
                            self.descriptionTextView.text = description
                        }
                        if let combination = responseDict["combination"] as? String {
                            if combination == "AND" {
                                self.cumulativeConditionStatus = "AND"
                                self.cumulativeConditionSwitch.isOn = true
                            }
                            else {
                                self.cumulativeConditionStatus = "OR"
                                self.cumulativeConditionSwitch.isOn = false
                            }
                        }//,,,sb11-9
                        
                        if let contextArray = responseDict["context"] as? [[String: Any]] {
                            for dict in contextArray {
//                                print("dict.....",dict) //,,,sb11-12
                                let valueToMatchArray = dict["value_to_match"] as! NSArray
                                let matchTypeDict = dict["match_type"] as! NSDictionary
                                let typeDict = dict["option"] as! NSDictionary

                                var critera_type = ""
                                var key = ""
                                if let txt = typeDict["key"] as? String,!txt.isEmpty {
                                    key = txt
                                }
                                
                                if (key == "PRODUCT_CATEGORY") {
                                    critera_type = "CategoryBased"
                                }
                                else if (key == "PRODUCT_STATUS") {
                                    critera_type = "StatusBased"
                                }
                                else {
                                    var value_type = ""
                                    if let txt = typeDict["value_type"] as? String,!txt.isEmpty {
                                        value_type = txt
                                    }
                                    if (value_type == "date") {
                                        critera_type = "DateBoundaryBased"
                                    }else if (value_type == "int") {
                                        critera_type = "IntegerBased"
                                    }else if (value_type == "boolean") {
                                        critera_type = "BooleanBased"
                                    }else {
                                        //text
                                        critera_type = "TextBased"
                                    }
                                }
                                
                                let valueToMatchArrayJson = Utility.json(from: valueToMatchArray)
                                let matchTypeDictJson = Utility.json(from: matchTypeDict)
                                let typeDictJson = Utility.json(from: typeDict)

                                let obj = ARCriterias(context: PersistenceService.context)
                                obj.id = self.getAutoIncrementId()
                                obj.critera_type = critera_type
                                obj.match_type_json = matchTypeDictJson
                                obj.type_json = typeDictJson
                                obj.value_to_match_json = valueToMatchArrayJson
                                PersistenceService.saveContext()
                            }
                        }
                        self.getCriteriaListFromDB()
                        self.saveAsPresetSwitch.isUserInteractionEnabled = false
                        self.saveAsPresetSwitch.alpha = 0.7//,,,sb11-10
                    }
                }else {
                    if responseData != nil {
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }//,,,sb11-3
    
    func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(ARSerialFinder.fetchAutoIncrementId())
            if !serial_obj.isEmpty{
                if let obj = serial_obj.first {
                    autoId = obj.id + Int16(1)
                }
            }
        }catch let error{
            print(error.localizedDescription)

        }
        return autoId
    }//,,,sb11-3
    //MARK:- End
    
    //MARK: - Privete Method
    func didClickOnCameraWithFilter(uuid:String) {
        
        //,,,sb11-10
        selectedDetailsDict["filter_name"] = nameTextfield.text
        selectedDetailsDict["name"] = nameTextfield.text
        selectedDetailsDict["description"] = descriptionTextView.text
        //,,,sb11-10
        
        mainUUID = uuid//,,,sb11-6
        
        DispatchQueue.main.async{
            defaults.setValue(true, forKey: "IsMultiScan")
            if(defaults.bool(forKey: "IsMultiScan")){
                let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
                let controller = storyboard.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                controller.isOnlySerialFinederAR = true
                controller.isLookWithFilterAR = true
                controller.delegate = self
                controller.mainUUID = uuid
                controller.lookWithfilterSearchRequestDict = self.requestDict
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func prepareView() {
        //,,,sb-lang1
        generalButton.setTitle("General".localized(), for: UIControl.State.selected)
        criteriaButton.setTitle("Criterias".localized(), for: UIControl.State.selected)
        //,,,sb-lang1
        
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 10.0
        detailsView.clipsToBounds = true
        generalButton.setRoundCorner(cornerRadious: 10)
        generalButton.layer.borderWidth=2
//        generalButton.layer.borderColor=UIColor.systemBlue.cgColor
        generalButton.layer.borderColor=Utility.hexStringToUIColor(hex: "00AFEF").cgColor//,,,sb11-5
        
        criteriaButton.setRoundCorner(cornerRadious: 10)
        criteriaButton.layer.borderWidth=2
//        criteriaButton.layer.borderColor=UIColor.systemBlue.cgColor
        criteriaButton.layer.borderColor=Utility.hexStringToUIColor(hex: "00AFEF").cgColor//,,,sb11-5
        
        manageAccessBuutton.setRoundCorner(cornerRadious: 10)
        addCriteriaButton.setRoundCorner(cornerRadious: 10)
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-SemiBold",size: 15.0,color:Utility.hexStringToUIColor(hex: "072144"))
        createInputAccessoryView()
        listTable.reloadData()
        generalButtonPressed(generalButton)
        
        //,,,sb11
        self.saveAsPresetSwitchValueChange(saveAsPresetSwitch)
        nameTextfield.inputAccessoryView = inputAccView
        descriptionTextView.inputAccessoryView = inputAccView
        //,,,sb11
    }
    
    func formValidation()-> Bool {
        let name =  nameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var isValidated = true
        
        if (saveAsPresetStatus == "true") && name.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter name".localized(), InViewC: self)
            isValidated = false
        }
        return isValidated
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }//,,,sb11-1

    func convertToArray(text: String) -> Array<Any>? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? Array<Any>
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }//,,,sb11-1
    
    func convertJsonStringToArray(text: String) -> [String] {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! [String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return [String]()
    }//,,,sb11-1
    //MARK:- End
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        self.didClickOnCameraWithFilter(uuid: "")
    }
    func cancelConfirmation() {

    }
    //MARK: - End
    
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldTobeField = textField
        textViewTobeField = nil
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
      
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }
    //MARK: - End
    
    //MARK: - textView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewTobeField = textView
        textFieldTobeField = nil
    }
    //MARK: - End
    
    //MARK: - Table view datasourse & delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList?.count ?? 0 //,,,sb11-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFCreateNewFilterCell") as! ARSFCreateNewFilterCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        if let dict = self.itemsList![indexPath.row] as? NSDictionary {
            
            var dataStr = ""
            if let match_type_json = dict["match_type_json"] as? String,!match_type_json.isEmpty{
                dataStr = match_type_json
            }
            let match_type_jsonDict = convertToDictionary(text: dataStr)
            
            var match_type_user_abbr = ""
            if let match_type_json_user_abbr = match_type_jsonDict!["user_abbr"] as? String,!match_type_json_user_abbr.isEmpty{
                match_type_user_abbr = match_type_json_user_abbr
            }
            
            dataStr = ""
            if let type_json = dict["type_json"] as? String,!type_json.isEmpty{
                dataStr = type_json
            }
            let type_jsonDict = convertToDictionary(text: dataStr)
            
            var type_user_abbr = ""
            if let type_json_user_abbr = type_jsonDict!["user_abbr"] as? String,!type_json_user_abbr.isEmpty{
                type_user_abbr = type_json_user_abbr
            }
            
            dataStr = ""
            if let critera_type = dict["critera_type"] as? String,!critera_type.isEmpty{
                dataStr = critera_type
            }
            
            if dataStr == "CategoryBased" {
                dataStr = ""
                if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                    dataStr = value_to_match_json
                }
                
                //,,,sb11-10
                cell.valueToMatchView.isHidden = false
                let value_to_match_jsonArray = convertToArray(text: dataStr)
                if value_to_match_jsonArray != nil && value_to_match_jsonArray!.count>0 {
                    let dateArray = value_to_match_jsonArray![0] as? Array<Any>
                    var value_to_match = ""
                    if dateArray != nil && dateArray!.count>1 {
                        value_to_match = dateArray![1] as! String
                        
                        cell.typeLabel.text = type_user_abbr
                        cell.matchTypeLabel.text = match_type_user_abbr
                        cell.valueToMatchLabel.text = value_to_match
                        cell.valueToMatchTitleLabel.text = "Value to match:".localized()
                    }
                }
                
                /*
                let value_to_match_jsonArr = convertJsonStringToArray(text: dataStr)
                var value_to_match = ""
                if value_to_match_jsonArr.count>0 {
                    value_to_match = value_to_match_jsonArr.joined(separator: ", ")
                }
//                cell.titleLabel.text = type_user_abbr + " " + match_type_user_abbr + " " + value_to_match
                cell.typeLabel.text = type_user_abbr
                cell.matchTypeLabel.text = match_type_user_abbr
                cell.valueToMatchLabel.text = value_to_match
                cell.valueToMatchTitleLabel.text = "Value to match:".localized()
                */
                //,,,sb11-10

            }//,,,sb11-1
            else if dataStr == "StatusBased" {
                dataStr = ""
                if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                    dataStr = value_to_match_json
                }
                //,,,sb11-10
                cell.valueToMatchView.isHidden = false
                let value_to_match_jsonArray = convertToArray(text: dataStr)
                if value_to_match_jsonArray != nil && value_to_match_jsonArray!.count>0 {
                    let dateArray = value_to_match_jsonArray![0] as? Array<Any>
                    var value_to_match = ""
                    if dateArray != nil && dateArray!.count>1 {
                        value_to_match = dateArray![1] as! String
                        
                        cell.typeLabel.text = type_user_abbr
                        cell.matchTypeLabel.text = match_type_user_abbr
                        cell.valueToMatchLabel.text = value_to_match
                        cell.valueToMatchTitleLabel.text = "Value to match:".localized()
                    }
                }
                /*
                let value_to_match_jsonArr = convertJsonStringToArray(text: dataStr)
                var value_to_match = ""
                if value_to_match_jsonArr.count>0 {
                    value_to_match = value_to_match_jsonArr.joined(separator: ", ")
                }

//                cell.titleLabel.text = type_user_abbr + " " + match_type_user_abbr + " " + value_to_match
                cell.typeLabel.text = type_user_abbr
                cell.matchTypeLabel.text = match_type_user_abbr
                cell.valueToMatchLabel.text = value_to_match
                cell.valueToMatchTitleLabel.text = "Value to match:".localized()
                */
                //,,,sb11-10
            }//,,,sb11-1
            else if dataStr == "DateBoundaryBased" {
                dataStr = ""
                if let match_type_json = dict["match_type_json"] as? String,!match_type_json.isEmpty{
                    dataStr = match_type_json
                }
                
                cell.valueToMatchView.isHidden = false
                let match_type_jsonDict = self.convertToDictionary(text: dataStr)
                var keyStr = ""
                if let key = match_type_jsonDict!["key"] as? String,!key.isEmpty{
                    keyStr = key
                }
                if keyStr == "OPERATOR_BETWEEN" {
                    dataStr = ""
                    if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                        dataStr = value_to_match_json
                    }
                    let value_to_match_jsonArray = convertToArray(text: dataStr)
                    if value_to_match_jsonArray != nil && value_to_match_jsonArray!.count>0 {
                        let dateArray = value_to_match_jsonArray![0] as? Array<String>
                        
                        var value_to_match = ""
                        if dateArray != nil && dateArray!.count>0 {
                            value_to_match = dateArray!.joined(separator: ", ")
                        }
                        
                        cell.typeLabel.text = type_user_abbr
                        cell.matchTypeLabel.text = match_type_user_abbr
                        cell.valueToMatchLabel.text = value_to_match
                        cell.valueToMatchTitleLabel.text = "Value to match:".localized()
                    }
                }
                else {
                    dataStr = ""
                    if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                        dataStr = value_to_match_json
                    }
                    let value_to_match_jsonArray = convertToArray(text: dataStr) as? Array<String>
                    var value_to_match = ""
                    if value_to_match_jsonArray != nil && value_to_match_jsonArray!.count>0 {
                        value_to_match = value_to_match_jsonArray!.joined(separator: ", ")
                    }
                    cell.typeLabel.text = type_user_abbr
                    cell.matchTypeLabel.text = match_type_user_abbr
                    cell.valueToMatchLabel.text = value_to_match
                    cell.valueToMatchTitleLabel.text = "Value to match:".localized()
                }
            }//,,,sb11-7
            else if dataStr == "BooleanBased" {
                dataStr = ""
                if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                    dataStr = value_to_match_json
                }
                let value_to_match_jsonArray = convertToArray(text: dataStr) as? Array<String>
                var value_to_match = ""
                if value_to_match_jsonArray != nil && value_to_match_jsonArray!.count>0 {
                    value_to_match = value_to_match_jsonArray!.joined(separator: ", ")
                }

                if value_to_match == "" {
                    cell.valueToMatchView.isHidden = true
                }else {
                    cell.valueToMatchView.isHidden = false
                }
                cell.typeLabel.text = type_user_abbr
                cell.matchTypeLabel.text = match_type_user_abbr
                cell.valueToMatchLabel.text = value_to_match
                cell.valueToMatchTitleLabel.text = "Value to match:".localized()
            }//,,,sb11-10
            else {
                //"TextBased", "IntegerBased"
                
                dataStr = ""
                if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                    dataStr = value_to_match_json
                }
                let value_to_match_jsonArray = convertToArray(text: dataStr) as? Array<String>
                var value_to_match = ""
                if value_to_match_jsonArray != nil && value_to_match_jsonArray!.count>0 {
                    value_to_match = value_to_match_jsonArray!.joined(separator: ", ")
                }

                cell.valueToMatchView.isHidden = false
                cell.typeLabel.text = type_user_abbr
                cell.matchTypeLabel.text = match_type_user_abbr
                cell.valueToMatchLabel.text = value_to_match
                cell.valueToMatchTitleLabel.text = "Value to match:".localized()
            }//,,,sb11-1
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            //,,,sb11-1
            if let dict = self.itemsList![indexPath.row] as? NSDictionary {
                var dataStr = ""
                if let critera_type = dict["critera_type"] as? String,!critera_type.isEmpty{
                    dataStr = critera_type
                }
                
                if dataStr == "TextBased" {
                    dataStr = ""
                    if let type_json = dict["type_json"] as? String,!type_json.isEmpty{
                        dataStr = type_json
                    }
                    let type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    dataStr = ""
                    if let match_type_json = dict["match_type_json"] as? String,!match_type_json.isEmpty{
                        dataStr = match_type_json
                    }
                    let match_type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    
                    dataStr = ""
                    if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                        dataStr = value_to_match_json
                    }
                    
                    var arr = Array<Any>()
                    if let value_to_match_jsonArray = self.convertToArray(text: dataStr) {
                        arr = value_to_match_jsonArray
                    }
                    
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFTextBasedCriteriaView") as! ARSFTextBasedCriteriaViewController
                    controller.isAdd = false //,,,sb11-1
                    controller.criteriaDict = dict //,,,sb11-1
                    controller.typeDict = type_jsonDict as NSDictionary? //,,,sb11-1
                    controller.matchTypeDict = match_type_jsonDict as NSDictionary? //,,,sb11-1
                    controller.valueToMatchArray = arr //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else if dataStr == "DateBoundaryBased" {
                    dataStr = ""
                    if let type_json = dict["type_json"] as? String,!type_json.isEmpty{
                        dataStr = type_json
                    }
                    let type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    dataStr = ""
                    if let match_type_json = dict["match_type_json"] as? String,!match_type_json.isEmpty{
                        dataStr = match_type_json
                    }
                    let match_type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    
                    dataStr = ""
                    if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                        dataStr = value_to_match_json
                    }
                    
                    var arr = Array<Any>()
                    if let value_to_match_jsonArray = self.convertToArray(text: dataStr) {
                        arr = value_to_match_jsonArray
                    }
                    
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFDateBoundaryCriteriaView") as! ARSFDateBoundaryCriteriaViewController
                    controller.isAdd = false //,,,sb11-1
                    controller.criteriaDict = dict //,,,sb11-1
                    controller.typeDict = type_jsonDict as NSDictionary? //,,,sb11-1
                    controller.matchTypeDict = match_type_jsonDict as NSDictionary? //,,,sb11-1
                    controller.valueToMatchArray = arr //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else if dataStr == "BooleanBased" || dataStr == "IntegerBased" {
                    dataStr = ""
                    if let type_json = dict["type_json"] as? String,!type_json.isEmpty{
                        dataStr = type_json
                    }
                    let type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    dataStr = ""
                    if let match_type_json = dict["match_type_json"] as? String,!match_type_json.isEmpty{
                        dataStr = match_type_json
                    }
                    let match_type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    dataStr = ""
                    if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                        dataStr = value_to_match_json
                    }
                    
                    var arr = Array<Any>()
                    if let value_to_match_jsonArray = self.convertToArray(text: dataStr) {
                        arr = value_to_match_jsonArray
                    }
                    
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFBooleanBasedCriteriaView") as! ARSFBooleanBasedCriteriaViewController
                    controller.isAdd = false //,,,sb11-1
                    controller.criteriaDict = dict //,,,sb11-1
                    controller.typeDict = type_jsonDict as NSDictionary? //,,,sb11-1
                    controller.matchTypeDict = match_type_jsonDict as NSDictionary? //,,,sb11-1
                    controller.valueToMatchArray = arr //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else if dataStr == "CategoryBased" {
                    dataStr = ""
                    if let type_json = dict["type_json"] as? String,!type_json.isEmpty{
                        dataStr = type_json
                    }
                    let type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    dataStr = ""
                    if let match_type_json = dict["match_type_json"] as? String,!match_type_json.isEmpty{
                        dataStr = match_type_json
                    }
                    let match_type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    
                    dataStr = ""
                    if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                        dataStr = value_to_match_json
                    }
                    
                    //,,,sb11-10
//                    let value_to_match_jsonArray = self.convertJsonStringToArray(text: dataStr)
                    var arr = Array<Any>()
                    if let value_to_match_jsonArray = self.convertToArray(text: dataStr) {
                        if value_to_match_jsonArray.count > 0 {
                            arr = value_to_match_jsonArray[0] as! [Any]
                        }
                    }
                    //,,,sb11-10
                    
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFCategoryCriteriaView") as! ARSFCategoryCriteriaViewController
                    controller.isAdd = false //,,,sb11-1
                    controller.criteriaDict = dict //,,,sb11-1
                    controller.typeDict = type_jsonDict as NSDictionary? //,,,sb11-1
                    controller.matchTypeDict = match_type_jsonDict as NSDictionary? //,,,sb11-1
//                    controller.selectedCategoryArray = value_to_match_jsonArray
                    controller.selectedCategoryArray = arr//,,,sb11-10
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else if dataStr == "StatusBased" {
                    dataStr = ""
                    if let type_json = dict["type_json"] as? String,!type_json.isEmpty{
                        dataStr = type_json
                    }
                    let type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    dataStr = ""
                    if let match_type_json = dict["match_type_json"] as? String,!match_type_json.isEmpty{
                        dataStr = match_type_json
                    }
                    let match_type_jsonDict = self.convertToDictionary(text: dataStr)
                    
                    
                    dataStr = ""
                    if let value_to_match_json = dict["value_to_match_json"] as? String,!value_to_match_json.isEmpty{
                        dataStr = value_to_match_json
                    }
                    
                    //,,,sb11-10
//                    let value_to_match_jsonArray = self.convertJsonStringToArray(text: dataStr)
                    var arr = Array<Any>()
                    if let value_to_match_jsonArray = self.convertToArray(text: dataStr) {
                        if value_to_match_jsonArray.count > 0 {
                            arr = value_to_match_jsonArray[0] as! [Any]
                        }
                    }
                    //,,,sb11-10
                    
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFStatusCriteriaView") as! ARSFStatusCriteriaViewController
                    controller.isAdd = false //,,,sb11-1
                    controller.criteriaDict = dict //,,,sb11-1
                    controller.typeDict = type_jsonDict as NSDictionary? //,,,sb11-1
                    controller.matchTypeDict = match_type_jsonDict as NSDictionary? //,,,sb11-1
//                    controller.selectedStatusArray = value_to_match_jsonArray
                    controller.selectedStatusArray = arr//,,,sb11-10
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            //,,,sb11-1
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //,,,sb11-1
            let msg = "You are about to delete the resource.".localized() + "\n" + "This operation can’t be undone.".localized() + "\n\n" + "Proceed to the deletion?".localized()
            
            let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
                
                if let dict = self.itemsList![indexPath.row] as? NSDictionary {
                    self.removeProduct(data: dict)
                }
            })
            confirmAlert.addAction(action)
            confirmAlert.addAction(okAction)
            self.navigationController?.present(confirmAlert, animated: true, completion: nil)
            //,,,sb11-1
        }
    }
    //MARK:- End
}

extension ARSFCreateNewFilterViewController : ScanViewControllerDelegate{
    func didScanCodeForReceiveSerialVerificationAndCodeDetails(scannedCode:[String], codeDetailsArray:[[String : Any]]) {
        
        //,,,sb11-10
//        print("mainUUID.....",mainUUID)//,,,sb11-12
        if mainUUID != "" {
            if (saveAsPresetStatus == "true") {
                mode = "edit"
                requestDict = [String:Any]()
                headerButton.setTitle("Edit Filter".localized(), for: UIControl.State.normal)
                self.saveAsPresetSwitch.isUserInteractionEnabled = false
                self.saveAsPresetSwitch.alpha = 0.7//,,,sb11-10
            }
        }
        //,,,sb11-10
        
        DispatchQueue.main.async{
            let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARSFProductFoundListView") as! ARSFProductFoundListViewController
            
            controller.scancode = scannedCode
            controller.controllerName = "ARSFCreateNewFilterViewController"//,,,sb11-2
            controller.lookWithFilterSearchArray = codeDetailsArray//,,,sb11-2
            controller.selectedDetailsDict = self.selectedDetailsDict//,,,sb11-10
            
            self.navigationController?.pushViewController(controller, animated: false)
//            print("Scanned Barcodes") //,,,sb11-12
        }
    }//,,,sb11-2
    
    func backToScanViewController() {
//        print("mainUUID.....",mainUUID) //,,,sb11-12
        if mainUUID != "" {
            if (saveAsPresetStatus == "true") {
                mode = "edit"
                requestDict = [String:Any]()
                headerButton.setTitle("Edit Filter".localized(), for: UIControl.State.normal)
                self.saveAsPresetSwitch.isUserInteractionEnabled = false
                self.saveAsPresetSwitch.alpha = 0.7//,,,sb11-10
            }
        }
    }//,,,sb11-6
}

//MARK:  Table view cell class
class ARSFCreateNewFilterCell:UITableViewCell{
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var matchTypeLabel: UILabel!
    @IBOutlet weak var valueToMatchView: UIView!//,,,sb11-10
    @IBOutlet weak var valueToMatchTitleLabel: UILabel!
    @IBOutlet weak var valueToMatchLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
