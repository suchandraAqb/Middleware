//
//  GenerateSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 24/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  GenerateSerialsViewDelegate: class {
    @objc optional func serialGenerated()
}

class GenerateSerialsViewController: BaseViewController,UITextViewDelegate,SingleSelectDropdownDelegate,ConfirmationViewDelegate {
    
    
    weak var delegate: GenerateSerialsViewDelegate?
    var adjustmentType = ""
    @IBOutlet weak var confirmButton: UIButton!
    
    
    @IBOutlet weak var quantityView: UIView!
    @IBOutlet weak var quantitySubView: UIView!
    @IBOutlet weak var quantityTextField: UITextField!
    
    
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    
    
    //MARK: Destination Location View For Transfer
    @IBOutlet weak var destinationLocationView: UIView!
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
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height / 2.0)
        destinationLocationView.isHidden = false
        storageView.isHidden = true
        shelfView.isHidden = true
        
        
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 17.0,color:Utility.hexStringToUIColor(hex: "719898"))
        quantityTextField.addLeftViewPadding(padding: 15.0)
        quantityTextField.inputAccessoryView = inputAccView
        sectionView.roundTopCorners(cornerRadious: 40)
        allLocations = UserInfosModel.getLocations()
        destinationLocationView.setRoundCorner(cornerRadious: 10)
        quantityView.setRoundCorner(cornerRadious: 10)
        
        
        
        desLocationSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        storageSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        shelfSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quantitySubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        
        
        
    }
    
    
    func saveData()->NSMutableDictionary{
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
         otherDetailsDict.setValue("GENERATE_COMMISSION_ALL_AND_CLOSE", forKey: "gen_option")
        
        
        
        if let txt = desLocationNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "location_uuid")
        }
        
        if let txt = desLocationNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "location_uuid_name")
        }
        
        if let txt = storageNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_area_uuid")
        }
        
        if let txt = storageNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_area_uuid_name")
        }
        
        
        
        if let txt = shelfNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_shelf_uuid")
        }
        
        if let txt = shelfNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_shelf_uuid_name")
        }
        
        
        
        
        if let txt = quantityTextField.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "quantity")
        }
        
        
        return otherDetailsDict
        
        
    }
    func formValidation(_ dataDict:NSMutableDictionary)->Bool{
        var isValidated = true
        
            
            let toLocation = dataDict["location_uuid"] as? String ?? ""
            let storage = dataDict["storage_area_uuid"] as? String ?? ""
            let shelf = dataDict["storage_shelf_uuid"] as? String ?? ""
            let quantity = dataDict["quantity"] as? String ?? ""
            
            if toLocation.isEmpty {
               Utility.showPopup(Title: App_Title, Message: "Please select destination Location".localized(), InViewC: self)
               isValidated = false
            }else if !storageView.isHidden && storage.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select a Storage Area".localized(), InViewC: self)
                isValidated = false
            }else if !shelfView.isHidden && shelf.isEmpty{
                Utility.showPopup(Title: App_Title, Message: "Please select a Shelf.".localized(), InViewC: self)
                isValidated = false
            }else if quantity.isEmpty{
                Utility.showPopup(Title: App_Title, Message: "Please enter quantity.".localized(), InViewC: self)
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
    
    func confirmSerialRequest(requestData:NSMutableDictionary){
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "GetContainerSerials", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["container_serial_request_uuid"] as? String {
                        self.delegate?.serialGenerated?()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Generating Commissioning Serials".localized() + "\n" + "You can safely dismiss this box, this operation will be handled in the background".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                    }
                    
                    
                }else{
                    
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
    }
    
    //MARK: - End
    //MARK: - IBAction
   @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let dict = saveData()
        if !formValidation(dict){
            return
        }
        
        confirmSerialRequest(requestData: dict)
        
        
       
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
    
    @IBAction func locationScanButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller.delegate = self
        controller.isForLocationSelection=true
        self.navigationController?.pushViewController(controller, animated: true)
                
//                self.didReceiveBarcodeLocationScan(codeDetails: ["scannedCodes":"b592af47-4319-4739-824b-9ca8d93d34cc"])

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
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want cancel Serial Generation Request".localized().firstUppercased
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
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
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
        
    }
    func cancelConfirmation() {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - End
}

extension GenerateSerialsViewController:SingleScanViewControllerDelegate{
    func didReceiveBarcodeLocationScan(codeDetails:[String:Any]){
        let locationCode = codeDetails["scannedCodes"] as! String
        print(locationCode)
        if let dict = allLocations![locationCode] as? Dictionary<String,Any> {
            let btn=UIButton()
            btn.tag=2
            self.selectedItem(itemStr: locationCode, data: dict as NSDictionary,sender: btn)
        }else{
            Utility.showPopup(Title: "Error!", Message: "Selected location is not available.".localized() , InViewC: self)
        }
    }
}

