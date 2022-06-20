//
//  ARSFDateBoundaryCriteriaViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 07/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFDateBoundaryCriteriaViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,DatePickerViewDelegate {

    @IBOutlet weak var detailsView: UIView!
    @IBOutlet var typeNameLabel: UILabel!//,,,sb2

    @IBOutlet var deleteCriteriaButton: UIButton!
    @IBOutlet var dayTextField: UITextField!
    
    @IBOutlet var listTable: UITableView!
    @IBOutlet var listTableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    //,,,sb11-3
    @IBOutlet weak var daysView: UIView!
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var startDateTitleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateButton: UIButton!
    
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateButton: UIButton!
    //,,,sb11-3
    
    //,,,sb11-1
    var criteriaDict: NSDictionary!
    var typeDict: NSDictionary!
    var matchTypeDict: NSDictionary!
    var valueToMatchArray = Array<Any>()
    //,,,sb11-1
    
    var listArray:Array<Any>?//,,,sb2
    var isAdd = true //,,,sb11-1
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        deleteCriteriaButton.setRoundCorner(cornerRadious: 10)
        deleteCriteriaButton.isHidden = true //,,,sb11-1
        
        //,,,sb11-3
        daysView.isHidden = false
        startDateView.isHidden = true
        endDateView.isHidden = true
        //,,,sb11-3

        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-SemiBold",size: 15.0,color:Utility.hexStringToUIColor(hex: "072144"))
        createInputAccessoryView()
        listTable.reloadData()
        
        //,,,sb2
        let user_abbr = typeDict ["user_abbr"] as! String
        typeNameLabel.text = user_abbr
        self.get_filter_operators_WebserviceCall()
        //,,,sb2
        
        //,,,sb11-1
        if matchTypeDict != nil {
            let matchTypeKeyString = matchTypeDict!["key"] as? String
            if matchTypeKeyString == "OPERATOR_DAYS_BEFORE_TODAY" ||  matchTypeKeyString == "OPERATOR_DAYS_AFTER_TODAY" {
                self.daysView.isHidden = false
                self.startDateView.isHidden = true
                self.endDateView.isHidden = true
                
                self.startDateLabel.text = "Select Date".localized()
                self.startDateLabel.accessibilityHint = ""
                self.startDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                
                self.endDateLabel.text = "Select Date".localized()
                self.endDateLabel.accessibilityHint = ""
                self.endDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                
                if valueToMatchArray.count > 0 {
                    let daysString = valueToMatchArray[0] as? String
//                    dayTextField.text = daysString!.replacingOccurrences(of: "days", with: "", options: NSString.CompareOptions.literal, range: nil)
                    dayTextField.text = daysString//,,,sb11-7
                }
            }
            else if matchTypeKeyString == "OPERATOR_BETWEEN" {
                self.daysView.isHidden = true
                self.startDateView.isHidden = false
                self.startDateTitleLabel.text = "Start Date".localized()
                
                //,,,sb11-4
                let custAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
                    NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!]
                let custTypeAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: UIColor.red,
                    NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!]
                let descText = NSMutableAttributedString(string: self.startDateTitleLabel.text ?? "", attributes: custAttributes)
                let starText = NSAttributedString(string: "*", attributes: custTypeAttributes)
                descText.append(starText)
                self.startDateTitleLabel.attributedText = descText
                //,,,sb11-4

                self.endDateView.isHidden = false
                
                self.dayTextField.text = ""
                
                if valueToMatchArray.count > 0 {
                    if let dateArray = valueToMatchArray[0] as? Array<Any> {
                        if dateArray.count > 1 {
                            let daysString = dateArray[0] as? String
                            self.startDateLabel.text = daysString
                            self.startDateLabel.accessibilityHint = daysString
                            self.startDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                            
                            let daysString1 = dateArray[1] as? String
                            self.endDateLabel.text = daysString1
                            self.endDateLabel.accessibilityHint = daysString1
                            self.endDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                        }
                    }
                }
            }
            else {
                self.daysView.isHidden = true
                self.startDateView.isHidden = false
                self.startDateTitleLabel.text = "Date".localized()
                
                //,,,sb11-4
                let custAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
                    NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!]
                let custTypeAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: UIColor.red,
                    NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!]
                let descText = NSMutableAttributedString(string: self.startDateTitleLabel.text ?? "", attributes: custAttributes)
                let starText = NSAttributedString(string: "*", attributes: custTypeAttributes)
                descText.append(starText)
                self.startDateTitleLabel.attributedText = descText
                //,,,sb11-4

                self.endDateView.isHidden = true
                
                self.dayTextField.text = ""
                self.endDateLabel.text = "Select Date".localized()
                self.endDateLabel.accessibilityHint = ""
                self.endDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                
                if valueToMatchArray.count > 0 {
                    let daysString = valueToMatchArray[0] as? String
                    self.startDateLabel.text = daysString
                    self.startDateLabel.accessibilityHint = daysString
                    self.startDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
            }
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
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        if valueToMatchArray.count > 0 {
            valueToMatchArray.removeAll()
        }
        
        var isvalidate = true
        if matchTypeDict == nil {
            isvalidate = false
            Utility.showPopup(Title: App_Title, Message: "Please select match type.".localized(), InViewC: self)
            return
        }
        
        let matchTypeKeyString = self.matchTypeDict!["key"] as? String
        if matchTypeKeyString == "OPERATOR_DAYS_BEFORE_TODAY" ||  matchTypeKeyString == "OPERATOR_DAYS_AFTER_TODAY" {
            if let s = dayTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!s.isEmpty{
//                let days = s + " days"
                let days = s//,,,sb11-7
                valueToMatchArray.append(days)
            }
            
            if valueToMatchArray.count == 0 {
                isvalidate = false
                Utility.showPopup(Title: App_Title, Message: "Please enter days.".localized(), InViewC: self)
                return
            }
        }
        else if matchTypeKeyString == "OPERATOR_BETWEEN" {
            var dateArray = Array<Any>()//,,,sb11-7
            
            var startDateString = ""
            if let startDate = startDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines),!startDate.isEmpty {
//                valueToMatchArray.append(startDate)
                dateArray.append(startDate)//,,,sb11-7
                startDateString = startDate
            }
            
            var endDateString = ""
            if let endDate = endDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines),!endDate.isEmpty {
//                valueToMatchArray.append(endDate)
                dateArray.append(endDate)//,,,sb11-7
                endDateString = endDate
            }
            
            if dateArray.count>0 {
                valueToMatchArray.append(dateArray)
            }//,,,sb11-7
            
            if startDateString == "" {
                isvalidate = false
                Utility.showPopup(Title: App_Title, Message: "Please enter start date.".localized(), InViewC: self)
                return
            }
            if endDateString == "" {
                isvalidate = false
                Utility.showPopup(Title: App_Title, Message: "Please enter end date.".localized(), InViewC: self)
                return
            }
        }
        else {
            if let startDate = startDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines),!startDate.isEmpty {
                valueToMatchArray.append(startDate)
            }
            if valueToMatchArray.count == 0 {
                isvalidate = false
                Utility.showPopup(Title: App_Title, Message: "Please enter date.".localized(), InViewC: self)
                return
            }
        }
        
        if isvalidate {
            let valueToMatchArrayJson = Utility.json(from: valueToMatchArray)
            let matchTypeDictJson = Utility.json(from: matchTypeDict as Any)
            let typeDictJson = Utility.json(from: typeDict as Any)
            
            if isAdd {
                let obj = ARCriterias(context: PersistenceService.context)
                obj.id = getAutoIncrementId()
                obj.critera_type = "DateBoundaryBased"
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
    
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        if sender == startDateButton {
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
        else if sender == endDateButton {
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
            controller.delegate = self
            controller.sender = sender
            if (startDateLabel.accessibilityHint != nil && startDateLabel.accessibilityHint != "") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from:startDateLabel.accessibilityHint!)!
                controller.minimumDate = date
            }
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }
    
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
        
        let str = "SERIAL FINDER".addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        
        let appendStr = "?filter_module=\(str ?? "")&operand_type=\(operand_type)"
        
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
    
    //MARK: - DatePickerViewDelegate
    func dateSelectedWithSender(selectedDate: Date, sender: UIButton?) {
        if sender != nil {
            
            let formatter = DateFormatter()
//            formatter.dateFormat = "MM-dd-yyyy"
//            let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            
            if sender == startDateButton {
//                startDateLabel.text = dateStr
                startDateLabel.text = dateStrForApi
                startDateLabel.accessibilityHint = dateStrForApi
                startDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                
                endDateLabel.text = "Select Date".localized()
                endDateLabel.accessibilityHint = ""
                endDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
            }
            else if sender == endDateButton {
                endDateLabel.text = dateStrForApi
                endDateLabel.accessibilityHint = dateStrForApi
                endDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
        }
    }
    //MARK: - End
    
    //MARK: - TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
        textViewTobeField = nil
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
            //,,,sb11-13
            if let s = dayTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),!s.isEmpty {
                let valueToMatch = dayTextField.text ?? ""
                let doubleV = Double(valueToMatch) ?? 0
    //            print("doubleV.....",doubleV)
                let intV = Int(doubleV)
    //            print("intV.....",intV)
                let absInt = abs(intV)
    //            print("absInt.....",absInt)
                let myString = String(absInt)
    //            print("myString.....",myString)
                dayTextField.text = myString
            }
            //,,,sb11-13
        }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFDateBoundaryCriteriaCell") as! ARSFDateBoundaryCriteriaCell
        
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
            let cell = tableView.cellForRow(at: indexPath) as! ARSFDateBoundaryCriteriaCell
//            cell.titleLabel.textColor = UIColor.blue
            cell.titleLabel.textColor = Utility.hexStringToUIColor(hex: "00AFEF")//,,,sb11-5

            self.matchTypeDict = self.listArray![indexPath.row] as? NSDictionary//,,,sb11-1
            
            let matchTypeKeyString = self.matchTypeDict!["key"] as? String
            if matchTypeKeyString == "OPERATOR_DAYS_BEFORE_TODAY" ||  matchTypeKeyString == "OPERATOR_DAYS_AFTER_TODAY" {
                self.daysView.isHidden = false
                self.startDateView.isHidden = true
                self.endDateView.isHidden = true
                
                self.startDateLabel.text = "Select Date".localized()
                self.startDateLabel.accessibilityHint = ""
                self.startDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                
                self.endDateLabel.text = "Select Date".localized()
                self.endDateLabel.accessibilityHint = ""
                self.endDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
            }
            else if matchTypeKeyString == "OPERATOR_BETWEEN" {
                self.daysView.isHidden = true
                self.startDateView.isHidden = false
                self.startDateTitleLabel.text = "Start Date".localized()
                
                //,,,sb11-4
                let custAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
                    NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!]
                let custTypeAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: UIColor.red,
                    NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!]
                let descText = NSMutableAttributedString(string: self.startDateTitleLabel.text ?? "", attributes: custAttributes)
                let starText = NSAttributedString(string: "*", attributes: custTypeAttributes)
                descText.append(starText)
                self.startDateTitleLabel.attributedText = descText
                //,,,sb11-4
                
                self.endDateView.isHidden = false
                
                self.dayTextField.text = ""
            }
            else {
                self.daysView.isHidden = true
                self.startDateView.isHidden = false
                self.startDateTitleLabel.text = "Date".localized()
                
                //,,,sb11-4
                let custAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
                    NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!]
                let custTypeAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: UIColor.red,
                    NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 15.0)!]
                let descText = NSMutableAttributedString(string: self.startDateTitleLabel.text ?? "", attributes: custAttributes)
                let starText = NSAttributedString(string: "*", attributes: custTypeAttributes)
                descText.append(starText)
                self.startDateTitleLabel.attributedText = descText
                //,,,sb11-4

                self.endDateView.isHidden = true
                
                self.dayTextField.text = ""
                
                self.endDateLabel.text = "Select Date".localized()
                self.endDateLabel.accessibilityHint = ""
                self.endDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
            }
            self.listTable.reloadData()
        }
    }//,,,sb11
    //MARK:- End
}

//MARK:  Table view cell class
class ARSFDateBoundaryCriteriaCell:UITableViewCell{
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
