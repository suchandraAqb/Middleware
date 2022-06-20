//
//  AddLotBasedLotViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 25/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

enum LotType:String {
    case LotBased = "LOT_BASED"
    case Serialised = "SERIALIZED"
}

@objc protocol  AddLotBasedLotViewDelegate: class {
    @objc optional func lotAddUpdated()
}

class AddLotBasedLotViewController: BaseViewController,SingleSelectDropdownDelegate,DatePickerViewDelegate,ConfirmationViewDelegate,LotAddConfirmationViewDelegete {
    
    weak var delegate: AddLotBasedLotViewDelegate?
    
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var storageLabel: UILabel!
    @IBOutlet weak var shelfLabel: UILabel!
    @IBOutlet weak var productionDateLabel: UILabel!
    @IBOutlet weak var sellByLabel: UILabel!
    @IBOutlet weak var bestByLabel: UILabel!
    @IBOutlet weak var expirationByLabel: UILabel!
    @IBOutlet weak var qtyProducedLabel: UILabel!
    @IBOutlet weak var qtyheaderabel: UILabel!
    
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var quantityView: UIView!
    @IBOutlet weak var quantityProducedView: UIView!
    
    
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var lotNumberTextField: UITextField!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var lotOpenButton: UIButton!
    @IBOutlet weak var viewSerialRequestButton: UIButton!
    @IBOutlet weak var viewSerialRequestView: UIView!
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    var disPatchGroup = DispatchGroup()
    
    var products = [[String:Any]]()
    var locations = [[String:Any]]()
    var selectedLocationUuid:String?
    var storageAreas:Array<Any>?
    var shelfs:Array<Any>?
    var selectedStorageArea:NSDictionary?
    var selectedShelf:NSDictionary?
    var isStorageSelected = false
    var isShelfSelected = false
    let allLocations = UserInfosModel.getLocations()
    var currentLotType = LotType.LotBased.rawValue
    var isEdit =  false
    var isLotClosed = false
    var lotData = [String:Any]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup_view()
        if !isEdit{
            getProductList()
            getLocationList()
            
        }else{
            getLotDetails()
        }
        
        self.disPatchGroup.notify(queue: .main) {
            if self.isEdit{
                self.populateLotInfos()
            }
            
        }
    }
    //MARK: - End
    
    //MARK: - Custom Methods
    func setup_view(){
        lotOpenButton.isSelected = true
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Regular",size: 15.0,color:Utility.hexStringToUIColor(hex: "719898"))
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        addButton.setRoundCorner(cornerRadious: addButton.frame.size.height / 2.0)
        viewSerialRequestButton.setRoundCorner(cornerRadious: viewSerialRequestButton.frame.size.height / 2.0)
       // createInputAccessoryView()
        createInputAccessoryViewAddedScan()
        
        if currentLotType == LotType.Serialised.rawValue{
            headerButton.setTitle("Add Serial Based Lot".localized(), for: .normal)
            viewSerialRequestView.isHidden = false
            //storageView.isHidden = true
            //shelfView.isHidden = true
            quantityView.isHidden = true
            quantityProducedView.isHidden = true
        }else{
            //storageView.isHidden = false
            headerButton.setTitle("Add Lot Based Lot".localized(), for: .normal)
            viewSerialRequestView.isHidden = true
        }
        
        if isEdit{
            headerButton.setTitle("Manufacturer Lot".localized(), for: .normal)
            addButton.isHidden = true
            addButton.setTitle("Update".localized(), for: .normal)
            lotNumberTextField.isUserInteractionEnabled = false
            lotNumberTextField.alpha = 0.5
            productLabel.alpha = 0.5
            locationLabel.alpha = 0.5
            storageLabel.alpha = 0.5
            shelfLabel.alpha = 0.5
            qtyheaderabel.text = "Increase Quantity".localized()
        }else{
            viewSerialRequestView.isHidden = true
            addButton.isHidden = false
        }
        
        
        
        
    }
    func populateLotInfos(){
        if !lotData.isEmpty{
            
            
            if let txt = lotData["product_name"] as? String,!txt.isEmpty{
                productLabel.text = txt
            }
            
            if let txt = lotData["product_uuid"] as? String,!txt.isEmpty{
                productLabel.accessibilityHint = txt
            }
            
            if let txt = lotData["location_name"] as? String,!txt.isEmpty{
                locationLabel.text = txt
            }
            
            if let txt = lotData["storage_area_name"] as? String,!txt.isEmpty{
                storageLabel.text = txt
            }
            
            if let txt = lotData["storage_area_uuid"] as? String,!txt.isEmpty{
                storageView.isHidden = false
                storageLabel.accessibilityHint = txt
            }else{
                storageView.isHidden = true
            }
            
            if let txt = lotData["storage_shelf_name"] as? String,!txt.isEmpty{
                shelfLabel.text = txt
            }
            
            if let txt = lotData["storage_shelf_uuid"] as? String,!txt.isEmpty{
                shelfView.isHidden = false
                shelfLabel.accessibilityHint = txt
            }else{
                shelfView.isHidden = true
            }
            
            if let txt = lotData["location_uuid"] as? String,!txt.isEmpty{
                locationLabel.accessibilityHint = txt
            }
            
            if let txt = lotData["lot_number"] as? String,!txt.isEmpty{
                lotNumberTextField.text = txt
            }
            
            if let txt = lotData["actual_quantity_produced"] as? Int{
                qtyProducedLabel.text = "\(txt)"
            }
            
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let date = lotData["production_date"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: date){
                    productionDateLabel.text = formattedDate
                    productionDateLabel.accessibilityHint = date
                }
            }
            
            if let date = lotData["expiration_date"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: date){
                    expirationByLabel.text = formattedDate
                    expirationByLabel.accessibilityHint = date
                }
            }
            
            if let date = lotData["best_by_date"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: date){
                    bestByLabel.text = formattedDate
                    bestByLabel.accessibilityHint = date
                }
            }
            
            if let date = lotData["sell_by_date"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: date){
                    sellByLabel.text = formattedDate
                    sellByLabel.accessibilityHint = date
                }
            }
            
            if let status = lotData["is_open"] as? Bool{
                lotOpenButton.isSelected = status
            }
            
            if !lotOpenButton.isSelected{
                headerButton.setTitle("View Manufacturer Lot".localized(), for: .normal)
                isLotClosed = true
                quantityView.isHidden = true
                addButton.isHidden = true
                lotOpenButton.isUserInteractionEnabled = false
            }else{
                headerButton.setTitle("Edit Manufacturer Lot".localized(), for: .normal)
                addButton.isHidden = false
            }
            
            
            
        }
    }
    func getProductList(){
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "Manufacturer", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "products_list") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                self.disPatchGroup.leave()
                if isDone! {
                    if let dataArray = responseData as? [[String:Any]] {
                        self.products = dataArray
                        
                        if !self.products.isEmpty {
                            let btn = UIButton()
                            btn.tag = 1
                            self.selecteditem(data: self.products.first! as NSDictionary, sender: btn)
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
    
    func getLotDetails(){
        
        var product_uuid = ""
        var lot_uuid = ""
        if !lotData.isEmpty{
            if let uuid = lotData["uuid"] as? String,!uuid.isEmpty{
                lot_uuid = uuid
            }
            
            if let uuid = lotData["product_uuid"] as? String,!uuid.isEmpty{
                product_uuid = uuid
            }
        }
        
        let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)"
        
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "AddUpdateManufacturerLot", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                self.disPatchGroup.leave()
                if isDone! {
                    if let dataDict = responseData as? [String:Any] {
                        self.lotData = dataDict
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
    
    func getLocationList(){
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "Manufacturer", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "locations_list") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                self.disPatchGroup.leave()
                if isDone! {
                    if let dataArray = responseData as? [[String:Any]] {
                        self.locations = dataArray
                        
                        if !self.locations.isEmpty {
                            let btn = UIButton()
                            btn.tag = 2
                            self.selecteditem(data: self.locations.first! as NSDictionary, sender: btn)
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
    func getShelfList(storageAreaUUID:String){
        let appendStr:String! = (selectedLocationUuid ?? "") as String + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
        //self.disPatchGroup.enter()
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetShelfList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                //  self.disPatchGroup.leave()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let list = responseDict["data"] as? Array<[String : Any]>{
                        self.shelfs = list
                        let btn = UIButton()
                        btn.tag = 4
                        self.selecteditem(data: self.shelfs?.first as! NSDictionary, sender: btn)
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
    func saveData(){
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
        
        
        
        if let txt = locationLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "location_uuid")
        }
        
        if currentLotType == LotType.LotBased.rawValue{
            if let txt = quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
                
                if isEdit{
                    otherDetailsDict.setValue(txt, forKey: "increase_quantity")
                }else{
                    otherDetailsDict.setValue(txt, forKey: "quantity")
                }
                
            }
            
            if let txt = storageLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "storage_area_uuid")
            }
            
            if let txt = shelfLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "storage_shelf_uuid")
            }
        }
        
        
        
        if let txt = lotNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "lot_number")
        }
        
        
        
        
        
        otherDetailsDict.setValue(currentLotType, forKey: "type")
        
        if let txt = productionDateLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "production_date")
        }
        
        if let txt = sellByLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "sell_by_date")
        }
        
        if let txt = bestByLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "best_by_date")
        }
        
        if let txt = expirationByLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "expiration_date")
        }
        
        
        otherDetailsDict.setValue(lotOpenButton.isSelected, forKey: "is_open")
        
        
        var product_uuid = ""
        
        if let txt = productLabel.accessibilityHint , !txt.isEmpty {
            product_uuid = txt
        }
        
        if isEdit{
            var lot_uuid = ""
            if !lotData.isEmpty{
                if let uuid = lotData["uuid"] as? String,!uuid.isEmpty{
                    lot_uuid = uuid
                }
            }
            updateLotRequest(requestData: otherDetailsDict, product_uuid: product_uuid,lot_uuid: lot_uuid)
        }else{
            addLotRequest(requestData: otherDetailsDict, product_uuid: product_uuid)
        }
        
        
        
    }
    
    func addLotRequest(requestData:NSMutableDictionary,product_uuid:String){
        
        let appendStr = "\(product_uuid)/manufacturer/lot/"
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "AddUpdateManufacturerLot", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["uuid"] as? String {
                        self.delegate?.lotAddUpdated?()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Lot Added Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
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
    
    func updateLotRequest(requestData:NSMutableDictionary,product_uuid:String,lot_uuid:String){
        
        let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)"
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "AddUpdateManufacturerLot", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["uuid"] as? String {
                        self.delegate?.lotAddUpdated?()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Lot Updated Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
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
    
    func formValidation()-> Bool{
        
        let lotNumber =  lotNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let quantity =   quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let production_date = productionDateLabel.accessibilityHint ?? ""
        let expiration_date = expirationByLabel.accessibilityHint ?? ""
        let bestBy = bestByLabel.accessibilityHint ?? ""
        let sellBy = sellByLabel.accessibilityHint ?? ""
        
        let storage_area_uuid = storageLabel.accessibilityHint ?? ""
        let storage_shelf_uuid = shelfLabel.accessibilityHint ?? ""
        
        
        var pDate:Date?
        if !production_date.isEmpty{
            pDate = Utility.dateFromString(sourceformat: "yyyy-MM-dd", dateStr: production_date)
        }
        
        var eDate:Date?
        if !expiration_date.isEmpty{
            eDate = Utility.dateFromString(sourceformat: "yyyy-MM-dd", dateStr: expiration_date)
        }
        
        var bDate:Date?
        if !bestBy.isEmpty{
            bDate = Utility.dateFromString(sourceformat: "yyyy-MM-dd", dateStr: bestBy)
        }
        
        var sDate:Date?
        if !sellBy.isEmpty{
            sDate = Utility.dateFromString(sourceformat: "yyyy-MM-dd", dateStr: sellBy)
        }
        
        var isValidated = true
        
        if !storageView.isHidden && storage_area_uuid.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please select Storage Area.".localized(), InViewC: self)
            isValidated = false
        }else if !shelfView.isHidden && storage_shelf_uuid.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "Please select Shelf.".localized(), InViewC: self)
            isValidated = false
            
        }else if lotNumber.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please enter Lot.".localized(), InViewC: self)
            isValidated = false
            
        }else if currentLotType == LotType.LotBased.rawValue && quantity.isEmpty && !isEdit{
            Utility.showPopup(Title: App_Title, Message: "Please enter quantity more than 0".localized(), InViewC: self)
            isValidated = false
        }else if currentLotType == LotType.LotBased.rawValue && !quantity.isEmpty && Int(quantity) ?? 0 <= 0 && !isEdit{
            Utility.showPopup(Title: App_Title, Message: "Please enter quantity more than 0".localized(), InViewC: self)
            isValidated = false
        }
        else if production_date.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please select production date.".localized(), InViewC: self)
            isValidated = false
            
        }else if expiration_date.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please select expiration date.".localized(), InViewC: self)
            isValidated = false
        }else if pDate != nil && eDate != nil && eDate!.isBeforeDate(pDate!){
            Utility.showPopup(Title: App_Title, Message: "Expiration date can not be before production date.".localized(), InViewC: self)
            isValidated = false
            
        }else if bDate != nil && eDate != nil && eDate!.isBeforeDate(bDate!){
            Utility.showPopup(Title: App_Title, Message: "Expiration date can not be before best by date.".localized(), InViewC: self)
            isValidated = false
            
        }else if sDate != nil && eDate != nil && eDate!.isBeforeDate(sDate!){
            Utility.showPopup(Title: App_Title, Message: "Expiration date can not be before sell by date.".localized(), InViewC: self)
            isValidated = false
        }else if bDate != nil && pDate != nil && bDate!.isBeforeDate(pDate!){
            Utility.showPopup(Title: App_Title, Message: "Best by date can not be before production date.".localized(), InViewC: self)
            isValidated = false
            
        }else if sDate != nil && pDate != nil && sDate!.isBeforeDate(pDate!){
            Utility.showPopup(Title: App_Title, Message: "Sell by date can not be before production date.".localized(), InViewC: self)
            isValidated = false
        }
        
        
        return isValidated
        
    }
    //MARK: - End
    //MARK: - IBAction
    
    //MARK: - End
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        
        if isLotClosed {
            return
        }
        
        if sender.tag == 1{
            
            if isEdit {
                return
            }
            
            if products.isEmpty{
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = products
            controller.type = "Products".localized()
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
        }else if sender.tag == 2{
            if isEdit {
                return
            }
            
            if locations.isEmpty{
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = locations
            controller.type = "Locations".localized()
            controller.delegate = self
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
                getShelfList(storageAreaUUID: storageLabel.accessibilityHint ?? "")
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
        else if sender.tag >= 5{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
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
    
    @IBAction func lotOpenButtonPressed(_ sender: UIButton) {
        lotOpenButton.isSelected.toggle()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        if !formValidation(){
            return
        }
        
        if currentLotType == LotType.Serialised.rawValue{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
            controller.confirmationMsg = "Are you sure you want to confirm".localized()
            controller.delegate = self
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
            
        }else{
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotAddConfirmationView") as! LotAddConfirmationViewController
            controller.modalPresentationStyle = .custom
            controller.delegate = self
            controller.isLotOpen = lotOpenButton.isSelected
            self.present(controller, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        if isLotClosed{
            cancelConfirmation()
            return
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to cancel".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewSerialRequestButtonPressed(_ sender: UIButton) {
        
        if !lotData.isEmpty{
            let product_uuid = lotData["product_uuid"] as? String ?? ""
            let lot_uuid = lotData["uuid"] as? String ?? ""
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotSerialRequestListView") as! LotSerialRequestListViewController
            controller.product_uuid = product_uuid
            controller.lot_uuid = lot_uuid
            controller.isLotClosed = isLotClosed
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    //MARK: - End
    
    //MARK: - SingleSelectDropdownDelegate
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        
        if sender != nil{
            if sender?.tag == 1{
                if let name = data["name"] as? String{
                    productLabel.text = name
                    productLabel.accessibilityHint = "\(data["uuid"] as? String ?? "")"
                    
                }
            }else if sender!.tag == 2 {
                storageView.isHidden = true
                storageLabel.text = "Select Storage Area".localized()
                storageLabel.accessibilityHint = ""
                shelfView.isHidden = true
                shelfLabel.text = "Select Shelf".localized()
                shelfLabel.accessibilityHint = ""
                
                let uuid = data["uuid"] as? String ?? ""
                
                if let name = data["name"] as? String{
                    locationLabel.text = name
                    locationLabel.accessibilityHint = uuid
                    locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                    self.selectedLocationUuid = uuid
                    
                    storageView.isHidden = true
                    shelfView.isHidden = true
                    
                    if currentLotType == LotType.Serialised.rawValue{
                        return
                    }
                    
                    if let data = allLocations?[uuid] as? NSDictionary{
                        
                        if let sa_areas = data["sa"] as? Array<Any>{
                            storageAreas = sa_areas
                            storageView.isHidden = false
                            let btn = UIButton()
                            btn.tag = 3
                            selecteditem(data: sa_areas.first as! NSDictionary, sender: btn)
                        }else{
                            storageView.isHidden = true
                            shelfView.isHidden = true
                            
                            if let sa_count = data["sa_count"]as? Int {
                                
                                if sa_count > 0 {
                                    let userinfo = UserInfosModel.UserInfoShared
                                    self.showSpinner(onView: self.view)
                                    userinfo.getStorageAreasOfALocation(location_uuid: uuid, ServiceCompletion:{ (isDone:Bool? , sa:Array<Any>?) in
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
                        
                    }else{
                        let userinfo = UserInfosModel.UserInfoShared
                        self.showSpinner(onView: self.view)
                        userinfo.getStorageAreasOfALocation(location_uuid: uuid, ServiceCompletion:{ (isDone:Bool? , sa:Array<Any>?) in
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
                
            else if sender?.tag == 3{
                shelfView.isHidden = true
                shelfLabel.text = "Select Shelf".localized()
                shelfLabel.accessibilityHint = ""
                
                if let name = data["name"] as? String{
                    storageLabel.text = name
                    storageLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                    if let uuid = data["uuid"] as? String{
                        storageLabel.accessibilityHint = uuid
                    }
                    
                    isStorageSelected = true
                }
                
                let isShelf = data["is_have_shelf"] as! Bool
                //let isShelf = true
                
                if isShelf {
                    shelfView.isHidden = false
                    isShelfSelected = false
                    getShelfList(storageAreaUUID: storageLabel.accessibilityHint ?? "")
                }else{
                    shelfView.isHidden = true
                    shelfLabel.text = "Select Shelf".localized()
                    shelfLabel.accessibilityHint = ""
                    isShelfSelected = false
                    
                }
            }else if sender?.tag == 4{
                if let name = data["name"] as? String{
                    shelfLabel.text = name
                    
                    if let uuid = data["storage_shelf_uuid"] as? String {
                        shelfLabel.accessibilityHint = uuid
                    }
                    
                    isShelfSelected = true
                    
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
    
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        saveData()
    }
    func cancelConfirmation() {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - End
    
    //MARK: - DatePickerViewDelegate
    func dateSelectedWithSender(selectedDate: Date, sender: UIButton?) {
        if sender != nil{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            
            
            if sender?.tag == 5 {
                productionDateLabel.text = dateStr
                productionDateLabel.accessibilityHint = dateStrForApi
            }else if sender?.tag == 6 {
                sellByLabel.text = dateStr
                sellByLabel.accessibilityHint = dateStrForApi
            }else if sender?.tag == 7 {
                bestByLabel.text = dateStr
                bestByLabel.accessibilityHint = dateStrForApi
            }else if sender?.tag == 8 {
                expirationByLabel.text = dateStr
                expirationByLabel.accessibilityHint = dateStrForApi
            }
            
        }
    }
    //MARK: - End
    //MARK: - LotAddConfirmationViewDelegete
    func didClickOnAddLotbasedButton(_ isLotOpen: Bool) {
        lotOpenButton.isSelected = isLotOpen
        saveData()
    }
    //MARK: - End
    
    
    
}
extension AddLotBasedLotViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
    
    func didReceiveBarcodeLocationScan(codeDetails:[String:Any]){
        let locationCode = codeDetails["scannedCodes"] as! String
        print(locationCode)
        let predicate = NSPredicate(format:"uuid='\(locationCode)'")
        let filterArray = (locations as NSArray).filtered(using: predicate)
        if filterArray.count>0 {
            let dict=filterArray[0]
            let btn=UIButton()
            btn.tag=2
            self.selecteditem(data: dict as! NSDictionary,sender:btn)
        }else{
            Utility.showPopup(Title: "Error!", Message: "Selected location is not available.".localized() , InViewC: self)
        }
    }
}
