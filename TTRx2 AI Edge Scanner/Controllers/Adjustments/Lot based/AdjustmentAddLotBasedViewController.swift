//
//  AdjustmentAddLotBasedViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 03/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  AdjustmentAddLotBasedDelegate: class {
    @objc optional func didProductAdded()
}

class AdjustmentAddLotBasedViewController:BaseViewController,UITableViewDataSource, UITableViewDelegate,SingleSelectDropdownDelegate,ProductLotStorageDelegate
{
    
    weak var delegate: AdjustmentAddLotBasedDelegate?
    
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
    var item_location_uuid = ""
    var item_storage_uuid = ""
    var item_shelf_uuid = ""
    var selectedLot = [String:Any]()
    
    
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
        
        let idAction = UIAlertAction(title: "NDC".localized(), style: .default, handler:  { (UIAlertAction) in
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
        
        if let popoverController = popUpAlert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
//            popoverController.permittedArrowDirections = []
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
        
        let maxLotQuan =   lotNameLabel.accessibilityHint ?? ""
        let totalQuantity =   quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if selectedProductDict == nil {
            Utility.showPopup(Title: App_Title, Message: "Please select products first.".localized(), InViewC: self)
            return
        }else if maxLotQuan.isEmpty {
            Utility.showPopup(Title: App_Title, Message: "Please select Lot.".localized(), InViewC: self)
            return
        }else if (totalQuantity as NSString).intValue <= 0 {
            Utility.showPopup(Title: App_Title, Message: "Enter quantity more than 0".localized(), InViewC: self)
            return
        }else if (totalQuantity as NSString).intValue > (maxLotQuan as NSString).intValue {
            Utility.showPopup(Title: App_Title, Message: "Quantity not available. Max available quantity".localized() + " \(maxLotQuan)", InViewC: self)
            return
        }
        
        
        addProduct(quantity: totalQuantity,lot:lotNameLabel.text ?? "" , maxQuantity:maxLotQuan)
        
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
        
        selectedProductNDCLabel.text = "NDC: ".localized() + dataStr
        
        dataStr = ""
        if let name = selectedProductDict!["gtin14"] as? String{
            dataStr = name
        }
        
        selectedProductGTINLabel.text = "GTIN14: ".localized() + dataStr
        
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
        
        
        if let masterArr = itemsList as NSArray?, let masterDictArr = itemsList as? [[String:Any]]{
            
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
        if let dataDict = Utility.getDictFromdefaults(key: "adjustment_general_info") {
           if let txt =  dataDict["location_uuid"] as? String, !txt.isEmpty {
             location_uuid = txt
            }
        }else if let dataDict = Utility.getDictFromdefaults(key: "container_edit_details") {
           if let txt =  dataDict["location_uuid"] as? String, !txt.isEmpty {
             location_uuid = txt
            }
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
    
    func addProduct(quantity:String,lot:String,maxQuantity:String){
            
        let obj = Adjustments(context: PersistenceService.context)
        obj.is_send_for_verification = true
        obj.is_lot_based = true
        obj.is_valid = true
        obj.quantity = Int16(quantity) ?? 0
        obj.product_name = (selectedProductDict?["name"] as? String) ?? ""
        obj.product_uuid = (selectedProductDict?["uuid"] as? String) ?? ""
        obj.lot_no = lot
        obj.gtin = (selectedProductDict?["gtin14"] as? String) ?? ""
        obj.lot_max_quantity = Int16(maxQuantity) ?? 0
        obj.location_uuid = item_location_uuid
        obj.storage_uuid = item_storage_uuid
        obj.shelf_uuid = item_shelf_uuid
        obj.identifier_type = "NDC"
        obj.identifier_value = (selectedProductDict?["identifier_us_ndc"] as? String) ?? ""
        
        if !selectedLot.isEmpty{
            
            if let ed = selectedLot["expiration_date"] as? String,!ed.isEmpty{
                obj.expiration_date = ed
            }
            
        }
        
        PersistenceService.saveContext()
        self.delegate?.didProductAdded?()
        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Product Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
      
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
           
            cell.productNDCLabel.text = "NDC: ".localized() + dataStr
           
           dataStr = ""
           if let name = dataDict["gtin14"] as? String{
               dataStr = name
           }
           
            cell.productGTINLabel.text = "GTIN14: ".localized() + dataStr
           
           
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
            selectedLot = data as! [String : Any]
            var itemName = ""
            
            if let name = data["lot"] as? String{
                itemName =  name
            }
            
            //lotNameLabel.text = itemName
            
            
            let product = products?[selectedProductIndex] as? NSDictionary
            
           
            if let uuid = product?["uuid"] as? String{
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ProductLotStorageView") as! ProductLotStorageViewController
                controller.productLot = itemName
                controller.product_uuid = uuid
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: false)
            }
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
    
    //MARK: - ProductLotStorageDelegate
   func didSelectStorage(data: NSDictionary, productLot: String, product_uuid: String) {
        
        if let txt = data["location_uuid"] as? String, !txt.isEmpty {
            item_location_uuid = txt
        }
        
        if let txt = data["storage_area_uuid"] as? String, !txt.isEmpty {
            item_storage_uuid = txt
        }
        
        if let txt = data["storage_shelf_uuid"] as? String, !txt.isEmpty {
            item_shelf_uuid = txt
        }
        
        if let txt = data["quantity"] as? String {
            lotNameLabel.text = productLot
            lotNameLabel.accessibilityHint = "\(Int16(Float(txt) ?? 0))"
            quantityTextField.text = "\(Int16(Float(txt) ?? 0))"
        }
        
       
        lotSearchViewCloseButtonPressed(UIButton())
        
        
    }
    
    //MARK: - End
    
    
    
    

    

}
