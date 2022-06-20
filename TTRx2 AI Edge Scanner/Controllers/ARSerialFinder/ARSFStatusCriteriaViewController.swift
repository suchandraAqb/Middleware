//
//  ARSFStatusCriteriaViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 07/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFStatusCriteriaViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var detailsView: UIView!
    @IBOutlet var typeNameLabel: UILabel!//,,,sb2
    @IBOutlet var deleteCriteriaButton: UIButton!
    
    @IBOutlet var matchTypeListTable: UITableView!
    @IBOutlet var matchTypeListTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var statusListTable: UITableView!
    @IBOutlet var statusListTableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    
    //,,,sb11-1
    var criteriaDict: NSDictionary!
    var typeDict: NSDictionary!
    var matchTypeDict: NSDictionary!
//    var selectedStatusArray = [NSDictionary]()
//    var selectedStatusArray = [String]()
    var selectedStatusArray = [Any]()//,,,sb11-10
    var checkUncheckCategoryArray = [String]()//,,,sb11-10
    //,,,sb11-1
    
    var matchTypeListArray:Array<Any>?//,,,sb2
    var statusListArray:Array<Any>?//,,,sb2
    var isAdd = true //,,,sb11-1
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        deleteCriteriaButton.setRoundCorner(cornerRadious: 10)
        deleteCriteriaButton.isHidden = true //,,,sb11-1

        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-SemiBold",size: 15.0,color:Utility.hexStringToUIColor(hex: "072144"))
        
        
        if selectedStatusArray.count > 1 {
            let name = selectedStatusArray[1] as! String
            checkUncheckCategoryArray.removeAll()
            checkUncheckCategoryArray.append(name)
        }//,,,sb11-10
        
        matchTypeListTable.reloadData()
        statusListTable.reloadData()
        
        //,,,sb2
        let user_abbr = typeDict ["user_abbr"] as! String
        typeNameLabel.text = user_abbr
        self.get_filter_operators_WebserviceCall()
        self.status_list_WebserviceCall()
        //,,,sb2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        matchTypeListTable.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        statusListTable.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        matchTypeListTable.removeObserver(self, forKeyPath: "contentSize")
        statusListTable.removeObserver(self, forKeyPath: "contentSize")
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        var isvalidate = true
        if selectedStatusArray.count == 0 {
            isvalidate = false
            Utility.showPopup(Title: App_Title, Message: "Please select status.".localized(), InViewC: self)
        }
        if matchTypeDict == nil {
            isvalidate = false
            Utility.showPopup(Title: App_Title, Message: "Please select match type.".localized(), InViewC: self)
        }
        
        if isvalidate {
            //,,,sb11-10
            var valueToMatchArray = Array<Any>()
            valueToMatchArray.append(selectedStatusArray)
            //,,,sb11-10
            
//            let valueToMatchArrayJson = Utility.json(from: selectedStatusArray)
            let valueToMatchArrayJson = Utility.json(from: valueToMatchArray)//,,,sb11-10
            let matchTypeDictJson = Utility.json(from: matchTypeDict as Any)
            let typeDictJson = Utility.json(from: typeDict as Any)
            
            if isAdd {
                let obj = ARCriterias(context: PersistenceService.context)
                obj.id = getAutoIncrementId()
                obj.critera_type = "StatusBased"
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
        matchTypeListTableHeightConstraint.constant=matchTypeListTable.contentSize.height
        statusListTableHeightConstraint.constant=statusListTable.contentSize.height
        self.updateViewConstraints()
    }
    //MARK:- End
    
    
    //MARK: - Webservice Call
    func status_list_WebserviceCall() {
        let callback_url = typeDict ["callback_url"] as! String
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: callback_url) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let response = responseData as? Array<Any> {
                         self.statusListArray = response
//                         print("self.statusListArray...>>>",self.statusListArray as Any,self.statusListArray!.count) //,,,sb11-12
                         self.statusListTable.reloadData()
                    }
                }else {
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        
                        Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: false, isPopToRoot: false)
                    }else{
                        Utility.showAlertWithPopAction(Title: App_Title, Message: message ?? "", InViewC: self, isPop: false, isPopToRoot: false)
                    }
                }
            }
        }
    }//,,,sb2
    
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
                         self.matchTypeListArray = response
//                         print("self.matchTypeListArray...>>>",operand_type,self.matchTypeListArray as Any,self.matchTypeListArray!.count) //,,,sb11-12
                         self.matchTypeListTable.reloadData()
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
        if tableView == matchTypeListTable {
            return matchTypeListArray?.count ?? 0//,,,sb2
        }else if tableView == statusListTable{
            return statusListArray?.count ?? 0//,,,sb2
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = UITableViewCell()
        if tableView == matchTypeListTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFStatusCriteriaMatchTypeListCell") as! ARSFStatusCriteriaMatchTypeListCell
            
            
            //,,,sb2
    //        cell.titleButton.setTitle(matchTypeListArray[indexPath.row], for: .normal)
            
            let dict = self.matchTypeListArray![indexPath.row] as? NSDictionary
            var dataStr = ""
            if let txt = dict!["user_abbr"] as? String,!txt.isEmpty {
                dataStr = txt
            }
            cell.titleLabel.text = dataStr//,,,sb11-1
            //,,,sb2
            
            
            cell.titleLabel.tag = indexPath.row //,,,sb11-1
            if indexPath.row == matchTypeListArray!.count-1 {
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
//                    cell.titleLabel.textColor = UIColor.blue
                    cell.titleLabel.textColor = Utility.hexStringToUIColor(hex: "00AFEF")//,,,sb11-5
                }
            }
            //,,,sb11-1
            
            return cell
        }else if tableView == statusListTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFStatusCriteriaStatusListCell") as! ARSFStatusCriteriaStatusListCell
            
            //,,,sb2
//            cell.checkUncheckButton.setTitle(statusListArray[indexPath.row], for: .normal)
            let dict = self.statusListArray![indexPath.row] as? NSDictionary
            var dataStr = ""
            if let txt = dict!["name"] as? String,!txt.isEmpty {
                dataStr = txt
            }
            cell.checkUncheckButton.setTitle(dataStr, for: .normal)
            //,,,sb2
            
            cell.checkUncheckButton.tag=indexPath.row
            
            //,,,sb11-1
            /*
            if let categoryDict = self.statusListArray![indexPath.row] as? NSDictionary {
                print("\(categoryDict)")
                if selectedStatusArray.contains(categoryDict) {
                    cell.checkUncheckButton.isSelected = true
                }
                else {
                    cell.checkUncheckButton.isSelected = false
                }
            }*/
            
            if checkUncheckCategoryArray.contains(dataStr) {//,,,sb11-10
                cell.checkUncheckButton.isSelected = true
            }
            else {
                cell.checkUncheckButton.isSelected = false
            }
            //,,,sb11-1
            
            return cell
        }else{
            return c
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView == matchTypeListTable{
            let cell = tableView.cellForRow(at: indexPath) as! ARSFStatusCriteriaMatchTypeListCell
            
//            cell.titleLabel.textColor = UIColor.blue //,,,sb11-1
            cell.titleLabel.textColor = Utility.hexStringToUIColor(hex: "00AFEF")//,,,sb11-5

            self.matchTypeDict = self.matchTypeListArray![indexPath.row] as? NSDictionary//,,,sb11-1
            
            self.matchTypeListTable.reloadData()//,,,sb11-1
            
        }else if tableView == statusListTable{
            let cell = tableView.cellForRow(at: indexPath) as! ARSFStatusCriteriaStatusListCell
            cell.checkUncheckButton.isSelected = !cell.checkUncheckButton.isSelected
            
            //,,,sb11-1
            if let categoryDict = self.statusListArray![indexPath.row] as? NSDictionary {
//                print("\(categoryDict)") //,,,sb11-12
                /*
                if selectedStatusArray.contains(categoryDict) {
                    /*if let index = selectedStatusArray.firstIndex(of: categoryDict) {
                        selectedStatusArray.remove(at: index)
                    }*///,,,sb11-9
                }
                else {
                    selectedCategoryArray.removeAll()//,,,sb11-9
                    selectedStatusArray.append(categoryDict)
                }
                */
                
                /*
                if let txt = categoryDict["name"] as? String,!txt.isEmpty {
                    if selectedStatusArray.contains(txt) {
                        /*if let index = selectedStatusArray.firstIndex(of: txt) {
                            selectedStatusArray.remove(at: index)
                        }*///,,,sb11-9
                    }
                    else {
                        selectedStatusArray.removeAll()//,,,sb11-9
                        selectedStatusArray.append(txt)
                    }
                }*/
                
                //,,,sb11-10
                if let value = categoryDict["value"] as? String {
                    var name = ""
                    if let txt = categoryDict["name"] as? String,!txt.isEmpty {
                        name = txt
                    }
                    
                    selectedStatusArray.removeAll()
                    selectedStatusArray.append(value)
                    selectedStatusArray.append(name)
                    
                    checkUncheckCategoryArray.removeAll()
                    checkUncheckCategoryArray.append(name)
                }
                //,,,sb11-10
            }
            
            self.statusListTable.reloadData()//,,,sb11-9
            //,,,sb11-1
        }
    }
    //MARK:- End
}


class ARSFStatusCriteriaMatchTypeListCell:UITableViewCell{
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

class ARSFStatusCriteriaStatusListCell:UITableViewCell{
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var checkUncheckButton: UIButton!
    @IBOutlet var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}

