//
//  ARSFBooleanBasedCriteriaViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 07/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFBooleanBasedCriteriaViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var detailsView: UIView!
    @IBOutlet var typeNameLabel: UILabel!//,,,sb2
    @IBOutlet weak var valueToMatchView: UIView!
    @IBOutlet var valueToMatchTextField: UITextField!

    @IBOutlet var deleteCriteriaButton: UIButton!
    
    @IBOutlet var listTable: UITableView!
    @IBOutlet var listTableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    //,,,sb11-1
    var criteriaDict: NSDictionary!
    var typeDict: NSDictionary!
    var matchTypeDict: NSDictionary!
    var valueToMatchArray = Array<Any>()
    //,,,sb11-1
    
    var listArray:Array<Any>?//,,,sb2
    var isAdd = true //,,,sb11-1
    var actualValueType = ""
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        deleteCriteriaButton.setRoundCorner(cornerRadious: 10)
        deleteCriteriaButton.isHidden = true //,,,sb11-1
        valueToMatchTextField.keyboardType = UIKeyboardType.numberPad //,,,sb11-1

        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-SemiBold",size: 15.0,color:Utility.hexStringToUIColor(hex: "072144"))
        createInputAccessoryView()
        listTable.reloadData()
        
        //,,,sb2
        let user_abbr = typeDict ["user_abbr"] as! String
        typeNameLabel.text = user_abbr
        
        let value_type = typeDict ["value_type"] as! String
        if value_type == "boolean" {
            actualValueType = "boolean"
            valueToMatchView.isHidden = true
        }else {
            actualValueType = "int"
            valueToMatchView.isHidden = false
        }
        
        self.get_filter_operators_WebserviceCall()
        //,,,sb2
        
        //,,,sb11-1
        if valueToMatchArray.count > 0 {
            valueToMatchTextField.text = valueToMatchArray[0] as? String
        }
        //,,,sb11-1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listTable.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listTable.removeObserver(self, forKeyPath: "contentSize")
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        var isvalidate = true
        
        if actualValueType == "int" {
            if valueToMatchArray.count > 0 {
                valueToMatchArray.removeAll()
            }
            if let s = valueToMatchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!s.isEmpty{
                valueToMatchArray.append(s)
            }
            
            if valueToMatchArray.count == 0 {
                isvalidate = false
                Utility.showPopup(Title: App_Title, Message: "Please enter value to match.".localized(), InViewC: self)
            }
        }
        
        if matchTypeDict == nil {
            isvalidate = false
            Utility.showPopup(Title: App_Title, Message: "Please select match type.".localized(), InViewC: self)
        }
        
        if isvalidate {
            var critera_type = "BooleanBased"
            if actualValueType == "int" {
                critera_type = "IntegerBased"
            }
            
            let valueToMatchArrayJson = Utility.json(from: valueToMatchArray)!
//            print("valueToMatchArrayJson....",valueToMatchArrayJson) //,,,sb11-12

            let matchTypeDictJson = Utility.json(from: matchTypeDict as Any)
            let typeDictJson = Utility.json(from: typeDict as Any)
            
            if isAdd {
                let obj = ARCriterias(context: PersistenceService.context)
                obj.id = getAutoIncrementId()
                obj.critera_type = critera_type
                obj.match_type_json = matchTypeDictJson
                obj.type_json = typeDictJson
                obj.value_to_match_json = valueToMatchArrayJson
                PersistenceService.saveContext()
                
                Utility.showPopupWithAction(Title: Success_Title, Message: "Criteria Added".localized(), InViewC: self, action:{
                    
                    guard let controllers = self.navigationController?.viewControllers else { return }
                    for  controller in controllers {
                        if controller.isKind(of: ARSFCreateNewFilterViewController.self){
                            self.navigationController?.popToViewController(controller, animated: false)
                            return
                        }
                    }
                })
            }
            else {
                if let criteria_id = criteriaDict?["id"] as? Int16 {
                    let predicate = NSPredicate(format:"id='\(criteria_id)'")
                    do{
                        let serial_obj = try PersistenceService.context.fetch(ARSerialFinder.fetchRequestWithPredicate(predicate: predicate))
                        if let obj = serial_obj.first {
                            obj.match_type_json = matchTypeDictJson
                            obj.type_json = typeDictJson
                            obj.value_to_match_json = valueToMatchArrayJson
                            PersistenceService.saveContext()
                            
                            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Criteria Edited".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        }
                    }catch let error{
                        print(error.localizedDescription)

                    }
                }
            }
        }
    }//,,,sb11-1
    
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
    }//,,,sb11-1
    
    //MARK:- End
    
    
    //MARK: - Privete Method
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        listTableHeightConstraint.constant=listTable.contentSize.height
        self.updateViewConstraints()
    }
    
    //MARK:- End
    
    
    //MARK: - Webservice Call
    func get_filter_operators_WebserviceCall() {
        let operand_type = typeDict ["value_type"] as! String
        let key = typeDict ["key"] as! String//,,,sb11-8

        let str = "SERIAL FINDER".addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        
//        let appendStr = "?filter_module=\(str ?? "")&operand_type=\(operand_type)"
        let appendStr = "?filter_module=\(str ?? "")&operand_type=\(operand_type)&key=\(key)"//,,,sb11-8

        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "get_filter_operators", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let response = responseData as? Array<Any> {
                         self.listArray = response
//                         print("self.listArray...>>>",operand_type,self.listArray as Any,self.listArray!.count) //,,,sb11-12
                         self.listTable.reloadData()
                    }
                }else {
                    
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
    }//,,,sb2
    //MARK:- End
    
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
        textViewTobeField = nil
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
      
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
       textField.resignFirstResponder()
       return true
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
        return listArray?.count ?? 0//,,,sb2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFBooleanBasedCriteriaCell") as! ARSFBooleanBasedCriteriaCell
        //,,,sb2
//        cell.titleButton.setTitle(listArray![indexPath.row], for: .normal)
        
        let dict = self.listArray![indexPath.row] as? NSDictionary
        var dataStr = ""
        if let txt = dict!["user_abbr"] as? String,!txt.isEmpty {
            dataStr = txt
        }
        cell.titleLabel.text = dataStr
        //,,,sb2
        
        
        cell.titleLabel.tag=indexPath.row
        if indexPath.row == listArray!.count-1 {
            cell.bottomView.isHidden=true
        }else{
            cell.bottomView.isHidden=false
        }
        
        //,,,sb11-1
        dataStr = ""
        if let keyString = dict!["key"] as? String,!keyString.isEmpty {
            dataStr = keyString
        }

        cell.titleLabel.textColor = UIColor.black
        if matchTypeDict != nil {
            let matchTypeKeyString = matchTypeDict!["key"] as? String
            if matchTypeKeyString == dataStr {
//                cell.titleLabel.textColor = UIColor.blue
                cell.titleLabel.textColor = Utility.hexStringToUIColor(hex: "00AFEF")//,,,sb11-5
            }
        }
        //,,,sb11-1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        DispatchQueue.main.async {
            let cell = tableView.cellForRow(at: indexPath) as! ARSFBooleanBasedCriteriaCell
//            cell.titleLabel.textColor = UIColor.blue
            cell.titleLabel.textColor = Utility.hexStringToUIColor(hex: "00AFEF")//,,,sb11-5

            self.matchTypeDict = self.listArray![indexPath.row] as? NSDictionary//,,,sb11-1
            
            self.listTable.reloadData()
        }
    }//,,,sb11
    //MARK:- End

}

class ARSFBooleanBasedCriteriaCell:UITableViewCell{
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var titleLabel: UILabel!//,,,sb11

    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
