//
//  ItemsDeleteViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 31/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  ItemsDeleteViewDelegate: class {
    func doneItemDelete()
}


class ItemsDeleteViewController: BaseViewController,UITextViewDelegate,SingleSelectDropdownDelegate {
    
    weak var delegate: ItemsDeleteViewDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var gs1View: UIView!
    
    @IBOutlet weak var gs1SerialTextField: UITextField!
       
    @IBOutlet weak var gs1SubView: UIView!
    @IBOutlet var moveButtons: [UIButton]!
    
    //MARK: Storage Area
    
    @IBOutlet weak var storageAreaView: UIView!
    
    @IBOutlet weak var desLocationSelectionView: UIView!
    @IBOutlet weak var desLocationNameLabel: UILabel!
    
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var storageSelectionView: UIView!
    @IBOutlet weak var storageNameLabel: UILabel!
    
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var shelfSelectionView: UIView!
    @IBOutlet weak var shelfNameLabel: UILabel!
    //MARK: - End
    
    
    var allLocations:NSDictionary?
    var selectedDesLocationUuid:String?
    var storageAreas:Array<Any>?
    var shelfs:Array<Any>?
    var selectedStorageArea:NSDictionary?
    var selectedShelf:NSDictionary?
    var isStorageSelected = false
    var isShelfSelected = false
    
    var moveType:String = ""
    var selectedItem: [[String: Any]] = []
    var serialNumber:String = ""
    var storageAreaUuid:String = ""
    var storageShelfUuid:String = ""

    //MARK: View Life Cyscle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        createInputAccessoryView()
        setup_initialview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    //MARK: - End
    //MARK: - Private Method
    func setup_initialview(){
        let btn = UIButton()
        btn.tag = 1
        moveButtonPressed(btn)
        
        addButton.setRoundCorner(cornerRadious: addButton.frame.size.height / 2.0)
        storageAreaView.isHidden = false
        storageView.isHidden = true
        shelfView.isHidden = true
        
        gs1SerialTextField.addLeftViewPadding(padding: 15.0)
        gs1SerialTextField.inputAccessoryView = inputAccView
        sectionView.roundTopCorners(cornerRadious: 40)
        allLocations = UserInfosModel.getLocations()
        storageAreaView.setRoundCorner(cornerRadious: 10)
        
        gs1View.setRoundCorner(cornerRadious: 10)
        gs1SubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        desLocationSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        storageSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        shelfSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
    }
    
    
    func saveData()->NSMutableDictionary{
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
        if let txt = desLocationNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "location_uuid")
        }
        
        if let txt = storageNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "move_to_storage_area_uuid")
        }
        
        if let txt = shelfNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "move_to_storage_shelf_uuid")
        }
                
        if let txt = gs1SerialTextField.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "move_to_new_container_gs1_id")
        }
        
        return otherDetailsDict
    }
    
    func formValidation(_ dataDict:NSMutableDictionary)->Bool{
        var isValidated = true
        
            
        let toLocation = dataDict["location_uuid"] as? String ?? ""
        let storage = dataDict["move_to_storage_area_uuid"] as? String ?? ""
        let shelf = dataDict["move_to_storage_shelf_uuid"] as? String ?? ""
        let gs1_id = dataDict["move_to_new_container_gs1_id"] as? String ?? ""
    
        if moveType == "STORAGE" {
            if toLocation.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select a Location".localized(), InViewC: self)
               isValidated = false
            }else if !storageView.isHidden && storage.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select a Storage Area".localized(), InViewC: self)
                isValidated = false
            }else if !shelfView.isHidden && shelf.isEmpty{
                Utility.showPopup(Title: App_Title, Message: "Please select a Shelf".localized(), InViewC: self)
                isValidated = false
            }
        }else if moveType == "GS1" {
            if gs1_id.isEmpty{
                Utility.showPopup(Title: App_Title, Message: "Please enter Destination GS1 Container Unique Serial.".localized(), InViewC: self)
                isValidated = false
            }
        }else{
            isValidated = false
        }
        
        
        return isValidated
        
    }
    
    
    func getShelfList(storageAreaUUID:String){
        
        let appendStr:String! = (selectedDesLocationUuid ?? "") as String + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetShelfList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                    
                        if let list = responseDict["data"] as? Array<[String : Any]>{
                            self.shelfs = list
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
    
    
    func deleteContainerItems(requestData:NSMutableDictionary){
        let appendStr = "SERIAL/\(serialNumber)/content/"
        var tempItems = [[String : Any]]()
        for item in selectedItem {
            var itemTemp = [String : Any]()
            if let txt = item["lot_quantity"] as? NSNumber {
                itemTemp["type"] = "PRODUCT_LOT"
                itemTemp["serial"] = ""
                if let product = item["product"] as? [String: Any] {
                    if let txt = product["uuid"] as? String,!txt.isEmpty{
                        itemTemp["product_uuid"] = txt
                    }
                }
                if let txt = item["lot_no"] as? String,!txt.isEmpty{
                    itemTemp["lot"] = txt
                }
                itemTemp["quantity"] = txt
                itemTemp["storage_area_uuid"] = storageAreaUuid
                itemTemp["storage_shelf_uuid"] = storageShelfUuid
            }else{
                if let txt = item["gs1_id"] as? String,!txt.isEmpty{
                    itemTemp["type"] = "GS1_UNIQUE_ID"
                    itemTemp["serial"] = txt
                }
            }
            tempItems.append(itemTemp)
        }
        let requestParam = NSMutableDictionary()
        requestParam.setValue(Utility.json(from: tempItems), forKey: "items")
        if moveType == "GS1" {
            if let txt = requestData["move_to_new_container_gs1_id"] as? String,!txt.isEmpty{
                requestParam.setValue(txt, forKey: "move_to_new_container_gs1_id")
            }
        }else if moveType == "STORAGE" {
            if let txt = requestData["move_to_storage_area_uuid"] as? String,!txt.isEmpty{
                requestParam.setValue(txt, forKey: "move_to_storage_area_uuid")
            }
            if let txt = requestData["move_to_storage_shelf_uuid"] as? String,!txt.isEmpty{
                requestParam.setValue(txt, forKey: "move_to_storage_shelf_uuid")
            }
        }
    
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "ContainersDetails", serviceParam: requestParam, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let _ = responseDict["task_queue_uuid"] as? String{
                        self.delegate?.doneItemDelete()
                        self.navigationController?.popViewController(animated: true)
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
    //MARK: - IBAction
    
    @IBAction func moveButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        for btn in moveButtons {
            
            if btn.tag == sender.tag {
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
            
            if btn.isSelected && btn.tag == 1{
                moveType = "GS1"
            }else if btn.isSelected && btn.tag == 2{
                moveType = "STORAGE"
            }
        }
    }
      
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let dict = saveData()
        if !formValidation(dict){
            return
        }
        Utility.showAlertDefaultWithPopAction(Title: "Note".localized(), Message: "This process may take some time to complete. Please check after some time.".localized(), InViewC: self, action: {
            self.deleteContainerItems(requestData: dict)
        })
    }
    
    
    @IBAction func locationSelectionButtonPressed(_ sender: UIButton) {
        
        doneTyping()
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
    }
    
    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 5{
            
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
            
        }else if sender.tag == 6{
            
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
        }
    }
     
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - End
    
    //MARK: - textField Delegate
       func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
          
       }
       func textFieldDidEndEditing(_ textField: UITextField) {
          
       }
       func textFieldShouldReturn(_ textField: UITextField) -> Bool
       {
           textField.resignFirstResponder()
           return true
       }
    //MARK: - End
    //MARK: - textView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
         textView.inputAccessoryView = inputAccView
    }
       
    //MARK: - End
    
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
                desLocationNameLabel.text = name
                desLocationNameLabel.accessibilityHint = itemStr
                self.selectedDesLocationUuid = itemStr
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
         if sender != nil && sender!.tag == 5 {
            
            shelfView.isHidden = true
            shelfNameLabel.text = "Select Shelf".localized()
            shelfNameLabel.accessibilityHint = ""
            
            if let name = data["name"] as? String{
                storageNameLabel.text = name
                
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
        }else if sender != nil && sender!.tag == 6 {
            
            if let name = data["name"] as? String{
                shelfNameLabel.text = name
                
                if let uuid = data["storage_shelf_uuid"] as? String {
                    shelfNameLabel.accessibilityHint = uuid
                }
                
                isShelfSelected = true
                
            }
        }
    }
    //MARK: - End
}


