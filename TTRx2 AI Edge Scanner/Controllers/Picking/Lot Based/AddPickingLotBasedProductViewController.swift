//
//  AddPickingLotBasedProductViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 26/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  AddPickingLotBasedDelegate: class {
    @objc optional func addedProduct(data:NSDictionary)
}

class AddPickingLotBasedProductViewController:BaseViewController,UITableViewDataSource, UITableViewDelegate,SingleSelectDropdownDelegate
{
    
    weak var delegate: AddPickingLotBasedDelegate?
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var lotlistTable: UITableView!
    var itemsList:Array<Any>?
    
    
    @IBOutlet weak var selectedProductView: UIView!
    @IBOutlet weak var selectedProductNameLabel: UILabel!
    @IBOutlet weak var selectedProductNDCLabel: UILabel!
    @IBOutlet weak var selectedProductGTINLabel: UILabel!
    
    @IBOutlet weak var selectionContainer: UIView!
    @IBOutlet weak var selectProductView: UIView!
    @IBOutlet weak var searchProductView: UIView!
    @IBOutlet weak var searchTypeLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var lotQuantityView: UIView!
    @IBOutlet weak var lotView: UIView!
    @IBOutlet weak var lotNameLabel: UILabel!
    
    
    @IBOutlet weak var quantityView: UIView!
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var autoSearchView: UIView!
    @IBOutlet weak var autoSearchSectionView: UIView!
    @IBOutlet weak var searchTextFieldView: UIView!
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var lotAutoSearchView: UIView!
    @IBOutlet weak var lotAutoSearchSectionView: UIView!
    @IBOutlet weak var lotSearchTextFieldView: UIView!
    @IBOutlet weak var lotSearchContainer: UIView!
    @IBOutlet weak var lotSearchTextField: UITextField!
    
    @IBOutlet weak var searchViewbackButton: UIButton!
    
    
    
    var products:Array<Any>?
    var lots:Array<Any>?
    var masterLots:Array<Any>?
    var selectedProductIndex = -1
    var selectedSearchType = 0
    var selectedProductDict:NSDictionary?
    var existingproducts:Array<Any>?
    var existingArrobjectIdx = -1
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.isHidden = true
        selectedProductView.isHidden = true
        lotQuantityView.isHidden = true
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        autoSearchSectionView.roundTopCorners(cornerRadious: 40)
        lotAutoSearchSectionView.roundTopCorners(cornerRadious: 40)
        selectionContainer.setRoundCorner(cornerRadious: 10)
        searchContainer.setRoundCorner(cornerRadious: 10)
        lotSearchContainer.setRoundCorner(cornerRadious: 10)
        selectedProductView.setRoundCorner(cornerRadious: 10)
        
        selectProductView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchProductView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchTextFieldView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        lotSearchTextFieldView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        
        lotView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quantityView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchTextField.addLeftViewPadding(padding: 12.0)
        quantityTextField.addLeftViewPadding(padding: 12.0)
        lotSearchTextField.addLeftViewPadding(padding: 12.0)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        lotSearchTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        createInputAccessoryView()
        searchTextField.inputAccessoryView = inputAccView
        lotSearchTextField.inputAccessoryView = inputAccView
        quantityTextField.inputAccessoryView = inputAccView
        
        if let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any> {
            existingproducts = exProducts
        }
        
        
        getProductsList()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    //MARK: - End
    
    //MARK: - IBAction
    
    
    
    
    
    @IBAction func selectSearchTypeButtonPressed(_ sender: UIButton) {
        
        let popUpAlert = UIAlertController(title: "Confirmation".localized(), message: "Select search type".localized(), preferredStyle: .actionSheet)
      
        let nameAction = UIAlertAction(title: "Name".localized(), style: .default, handler:  { (UIAlertAction) in
            self.selectedSearchType = 0
            self.searchTypeLabel.text = "Search by Name".localized()
            self.searchViewbackButton.setTitle("Search by Name".localized(), for: .normal)
            self.searchTextField.text = ""
            self.autoCompleteWithStr(searchStr: "")
            self.startTypingButtonPressed(UIButton())
        })
        
        let idAction = UIAlertAction(title: "NDC", style: .default, handler:  { (UIAlertAction) in
            self.selectedSearchType = 1
            self.searchTypeLabel.text = "Search by NDC".localized()
            self.searchViewbackButton.setTitle("Search by NDC".localized(), for: .normal)
            self.searchTextField.text = ""
            self.autoCompleteWithStr(searchStr: "")
            self.startTypingButtonPressed(UIButton())
        })
        
        let gs1Action = UIAlertAction(title: "GTIN14", style: .default, handler:  { (UIAlertAction) in
            self.selectedSearchType = 2
            self.searchTypeLabel.text = "Search by GTIN14".localized()
            self.searchViewbackButton.setTitle("Search by GTIN14".localized(), for: .normal)
            self.searchTextField.text = ""
            self.autoCompleteWithStr(searchStr: "")
            self.startTypingButtonPressed(UIButton())
        })
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:  { (UIAlertAction) in
            
        })
        
        popUpAlert.addAction(nameAction)
        popUpAlert.addAction(idAction)
        popUpAlert.addAction(gs1Action)
        popUpAlert.addAction(cancel)
        if let popoverController = popUpAlert.popoverPresentationController{
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            
        }
        self.present(popUpAlert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func searchViewCloseButtonPressed(_ sender: UIButton) {
        doneTyping()
        autoSearchView.isHidden = true
        searchTextField.text = ""
        listTable.isHidden = true
    }
    @IBAction func lotSearchViewCloseButtonPressed(_ sender: UIButton) {
        doneTyping()
        lotAutoSearchView.isHidden = true
        lotSearchTextField.text = ""
        lots = masterLots
        lotlistTable.reloadData()
    }
    @IBAction func startTypingButtonPressed(_ sender: UIButton) {
        autoSearchView.isHidden = false
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func selectLotButtonPressed(_ sender: UIButton) {
        if lots == nil || lots?.count == 0 {
            Utility.showPopup(Title: App_Title, Message: "There is no lot available for this product".localized(), InViewC: self)
            return
        }
        /*let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
         controller.isDataWithDict = false
         controller.nameKeyName = "lot"
         controller.listItems = lots as! Array<[String:Any]>
         controller.type = "Lots"
         controller.delegate = self
         controller.sender = sender
         controller.modalPresentationStyle = .custom
         self.present(controller, animated: true, completion: nil)*/
        lotAutoSearchView.isHidden = false
        lotSearchTextField.becomeFirstResponder()
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        let lotNo =   lotNameLabel.accessibilityHint ?? ""
        var quantity =   quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let totalQuantity =   quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if selectedProductDict == nil {
            Utility.showPopup(Title: App_Title, Message: "Please select products first.".localized(), InViewC: self)
            return
        }else if lotNo.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please select Lot.".localized(), InViewC: self)
            return
        }else if (quantity as NSString).intValue <= 0 {
            Utility.showPopup(Title: App_Title, Message: "Enter quantity more than 0".localized(), InViewC: self)
            return
        }else if (quantity as NSString).intValue > (lotNo as NSString).intValue {
            Utility.showPopup(Title: App_Title, Message: "Quantity not available. Max available quantity".localized() +  "\(lotNo)", InViewC: self)
            return
        }
        
        
        var isAdd = true
        
        if existingproducts != nil {
            let lot = lotNameLabel.text ?? ""
            let exProd = existingproducts as NSArray?
            let predicate = NSPredicate(format:"lot ='\(lot)'")
            if let filterArray = exProd?.filtered(using: predicate){
                if filterArray.count > 0 {
                    let curQuantity = (quantity as NSString).intValue
                    let firstObj = filterArray.first as? NSDictionary ?? NSDictionary()
                    existingArrobjectIdx = exProd?.index(of: firstObj) ?? -1
                    let prvQuan = firstObj["quantity"] as! Int32
                    var newQuantity = 0
                    if curQuantity > prvQuan {
                        newQuantity = Int(curQuantity - prvQuan)
                    }else{
                        isAdd = false
                        newQuantity = Int(prvQuan - curQuantity)
                    }
                    quantity = "\(newQuantity)"
                }
            }
        }
        
        addProduct(quantity: quantity,isAdd: isAdd,totalQuantity: totalQuantity)
        
    }
    
    //MARK: - End
    
    //MARK: - Private Method
    
    func resetLot(){
        lotNameLabel.text = "Select Lot No.".localized()
        lotNameLabel.accessibilityHint = ""
        quantityTextField.text = ""
    }
    
    func populateSelectedProductView(){
        
        selectedProductDict = products?[selectedProductIndex] as? NSDictionary
        
        var custName = ""
        if let name = selectedProductDict!["name"] as? String{
            custName = name
        }
        
        lots = nil
        if let uuid = selectedProductDict!["uuid"] as? String{
            
            getProductsLotList(uuid: uuid)
            
        }
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!]
        let attString = NSMutableAttributedString(string: custName, attributes: custAttributes)
        
        selectedProductNameLabel.attributedText = attString
        
        
        var dataStr = ""
        if let name = selectedProductDict!["identifier_us_ndc"] as? String{
            dataStr = name
        }
        
        selectedProductNDCLabel.text = "NDC: " + dataStr
        
        dataStr = ""
        if let name = selectedProductDict!["gtin14"] as? String{
            dataStr = name
        }
        
        selectedProductGTINLabel.text = "GTIN14: " + dataStr
        
        selectedProductView.isHidden = false
        lotQuantityView.isHidden = false
        
    }
    func autoCompleteWithStr(searchStr:String?){
        
        //        if !selectedCustomeView.isHidden{
        //            selectedCustomeView.isHidden = true
        //        }
        
        var predicate:NSPredicate?
        if selectedSearchType == 0 { // Using Name
            predicate = NSPredicate(format: "name CONTAINS[c] '\(searchStr ?? "")'")
            
        }else if selectedSearchType == 1 { // Using Customer ID
            predicate = NSPredicate(format: "identifier_us_ndc CONTAINS[c] '\(searchStr ?? "")'")
            
        }else if selectedSearchType == 2 { // Using GS1 ID
            predicate = NSPredicate(format: "gtin14 CONTAINS[c] '\(searchStr ?? "")'")
            
        }
        
        if let masterArr = itemsList as NSArray? , let masterDictArr = itemsList as? [[String:Any]]{
            
            var filteredArray = NSArray()
            
            if searchStr?.count == 1 {
                
                if selectedSearchType == 0 { // Using Name
                    filteredArray = masterDictArr.filter({ return ($0["name"] as? String ?? "").first?.lowercased().contains((searchStr?.first ?? Character("")).lowercased()) ?? false}) as NSArray
                }else if selectedSearchType == 1 { // Using Customer ID
                    filteredArray = masterDictArr.filter({ return ($0["identifier_us_ndc"] as? String ?? "").first?.lowercased().contains((searchStr?.first ?? Character("")).lowercased()) ?? false}) as NSArray
                }else if selectedSearchType == 2 { // Using GS1 ID
                    filteredArray = masterDictArr.filter({ return ($0["gtin14"] as? String ?? "").first?.lowercased().contains((searchStr?.first ?? Character("")).lowercased()) ?? false}) as NSArray
                }
                
            }else{
                filteredArray = masterArr.filtered(using: predicate!) as NSArray
            }
            
            if filteredArray.count>0{
                listTable.isHidden = false
                products = (filteredArray as! Array<Any>)
                listTable.reloadData()
            }else{
                products = nil
                listTable.reloadData()
                listTable.isHidden = true
            }
        }
    }
    func autoCompleteLotWithStr(searchStr:String?){
        
        var predicate:NSPredicate?
        predicate = NSPredicate(format: "lot CONTAINS[c] '\(searchStr ?? "")'")
        
        if let masterArr = masterLots as NSArray? {
            let filteredArray = masterArr.filtered(using: predicate!) as NSArray
            
            if filteredArray.count>0{
                lots = (filteredArray as! Array<Any>)
            }else{
                lots = masterLots
                
            }
            lotlistTable.reloadData()
        }
        
        
    }
    func getProductsList(){
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetProducts", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let dataArray = responseDict["data"] as? Array<Any> {
                        self.products = dataArray
                        self.itemsList = dataArray
                        self.listTable.reloadData()
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
    
    func getProductsLotList(uuid:String){
        
        var location_uuid = ""
        
        if let selected_location_uuid = defaults.object(forKey: "selectedLocation") as? String{
            location_uuid = selected_location_uuid
        }else{
            location_uuid = UserInfosModel.UserInfoShared.default_location_uuid ?? ""
        }
        
        
        let appendStr = "\(uuid)/lots?location_uuid=\(location_uuid)"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetProducts", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let dataArray = responseData as? NSArray {
                        
                        let predicate = NSPredicate(format:"get_qty_lot_based > 0 and get_total_available_items > 0")
                        let filterArr = dataArray.filtered(using: predicate)
                        
                        if filterArr.count>0{
                            self.lots = filterArr
                            self.masterLots = filterArr
                        }else{
                            self.lots = nil
                            self.masterLots = nil
                        }
                        
                        //self.lots = dataArray
                    }else{
                        self.lots = nil
                        self.masterLots = nil
                    }
                    
                    self.lotlistTable.reloadData()
                    
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
    
    func addProduct(quantity:String, isAdd:Bool , totalQuantity:String){
        
        var requestDict = [String:Any]()
        requestDict["type"] = "sales_order_by_picking"
        requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id") ?? ""
        requestDict["product_uuid"] = selectedProductDict?["uuid"] ?? ""
        requestDict["lot_number"] = lotNameLabel.text ?? ""
        requestDict["quantity"] = quantity
        if isAdd{
            requestDict["action"] = "ADD"
        }else{
            requestDict["action"] = "REMOVE"
        }
        
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "AddPickingLotBasedProduct", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "",isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    let modDict = NSMutableDictionary(dictionary: responseDict)
                    if let _ = responseDict["uuid"] as? String {
                        modDict["quantity"] = (totalQuantity as NSString).intValue
                        
                        if self.existingproducts != nil && self.existingArrobjectIdx >= 0 {
                            let arr = NSMutableArray(array: self.existingproducts!)
                            arr.replaceObject(at: self.existingArrobjectIdx, with: modDict)
                            Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr)
                        }else if self.existingproducts != nil {
                            let arr = NSMutableArray(array: self.existingproducts!)
                            arr.add(modDict)
                            Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr)
                        }else{
                            let arr = NSMutableArray()
                            arr.add(modDict)
                            Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr)
                        }
                        
                        self.delegate?.addedProduct?(data: responseDict)
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Product Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
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
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        
        if sender == searchTextField {
            if selectedProductIndex > -1 {
                selectedProductIndex = -1
            }
            autoCompleteWithStr(searchStr: sender.text!)
        }else{
            autoCompleteLotWithStr(searchStr: sender.text!)
        }
        
    }
    
    //MARK: - End
    //MARK: - Tableview Delegate and Datasource
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        doneTyping()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 5))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        if tableView == listTable {
            return products?.count ?? 0
        }else{
            return lots?.count ?? 0
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell") as! ProductListCell
        cell.bgView.layer.cornerRadius = 10
        cell.bgView.layer.masksToBounds = true
        cell.bgView.clipsToBounds = true
        
        
        if tableView == listTable {
            let dataDict:NSDictionary = products?[indexPath.section] as! NSDictionary
            var dataStr:String = ""
            
            var custName = ""
            if let name = dataDict["name"] as? String{
                custName = name
            }
            
            cell.productNameLabel.text = dataStr
            
            dataStr = ""
            if let name = dataDict["identifier_us_ndc"] as? String{
                dataStr = name
            }
            
            cell.productNDCLabel.text = "NDC: " + dataStr
            
            dataStr = ""
            if let name = dataDict["gtin14"] as? String{
                dataStr = name
            }
            
            cell.productGTINLabel.text = "GTIN14: " + dataStr
            
            
            if selectedProductIndex == indexPath.section{
                
                let custAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!]
                let attString = NSMutableAttributedString(string: custName, attributes: custAttributes)
                
                cell.productNameLabel.attributedText = attString
                
                cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "00AFEF")
                cell.productNDCLabel.textColor = Utility.hexStringToUIColor(hex: "BFF1FF")
                cell.productGTINLabel.textColor = Utility.hexStringToUIColor(hex: "BFF1FF")
                
                
                
            }else{
                
                let custAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "00AFEF"),
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!]
                let attString = NSMutableAttributedString(string: custName, attributes: custAttributes)
                
                cell.productNameLabel.attributedText = attString
                
                cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "E3F1F7")
                cell.productNDCLabel.textColor = Utility.hexStringToUIColor(hex: "5691A2")
                cell.productGTINLabel.textColor = Utility.hexStringToUIColor(hex: "5691A2")
            }
        }else{
            cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "E3F1F7")
            let dataDict:NSDictionary = lots?[indexPath.section] as! NSDictionary
            var dataStr:String = ""
            if let name = dataDict["lot"] as? String{
                dataStr = name
            }
            
            cell.productNameLabel.text = dataStr
            
            dataStr = ""
            if let items = dataDict["get_total_available_items"] as? Int {
                dataStr = "\(items)"
            }
            
            cell.quantityLabel.text = dataStr
            
            
        }
        
        
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == listTable {
            
            if selectedProductIndex == indexPath.section{
                selectedProductIndex = -1
                
            }else{
                selectedProductIndex = indexPath.section
                populateSelectedProductView()
            }
            
            resetLot()
            listTable.reloadData()
            searchViewCloseButtonPressed(UIButton())
            view.endEditing(true)
            
        }else{
            let data:NSDictionary = lots?[indexPath.section] as! NSDictionary
            var itemName = ""
            var availableItem = 0
            
            if let name = data["lot"] as? String{
                itemName =  name
                
                if let items = data["get_total_available_items"] as? Int {
                    availableItem = items
                }
            }
            
            
            
            lotNameLabel.text = itemName
            lotNameLabel.accessibilityHint = "\(availableItem)"
            quantityTextField.text = "\(availableItem)"
            lotSearchViewCloseButtonPressed(UIButton())
            
        }
        
        
        
    }
    
    //MARK: - End
    //MARK: - SingleSelectDropdownDelegate
    
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        
        var itemName = ""
        var availableItem = 0
        
        if let name = data["lot"] as? String{
            itemName =  name
            
            if let items = data["get_total_available_items"] as? Int {
                availableItem = items
            }
        }
        
        if sender != nil {
            
            lotNameLabel.text = itemName
            lotNameLabel.accessibilityHint = "\(availableItem)"
            
        }
        
    }
    //MARK: - End
    
    
    
    
    
}

class ProductListCell: UITableViewCell
{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productNDCLabel: UILabel!
    @IBOutlet weak var productGTINLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet var multiLingualViews: [UIView]!
  
    @IBOutlet weak var firstView:UIView!
    @IBOutlet weak var secondView:UIView!
    @IBOutlet weak var thirdView:UIView!
    @IBOutlet weak var firstLabel:UILabel!
    @IBOutlet weak var secondLabel:UILabel!
    @IBOutlet weak var thirdLabel:UILabel!
    override func awakeFromNib() {
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
        
    }
}
