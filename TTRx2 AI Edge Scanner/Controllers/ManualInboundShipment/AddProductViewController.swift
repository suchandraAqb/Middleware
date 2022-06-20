//
//  AddProductViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 20/01/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  AddProductDelegate: class {
    @objc optional func didProductAdded()
}

class AddProductViewController:BaseViewController,UITableViewDataSource, UITableViewDelegate,SingleSelectDropdownDelegate,ProductLotStorageDelegate
{
    
    weak var delegate: AddProductDelegate?
    
    @IBOutlet weak var listTable: UITableView!
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
    
    @IBOutlet weak var quantityView: UIView!
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var autoSearchView: UIView!
    @IBOutlet weak var autoSearchSectionView: UIView!
    @IBOutlet weak var searchTextFieldView: UIView!
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var searchViewbackButton: UIButton!
    
    
    
    var products:Array<Any>?
    var selectedProductIndex = -1
    var selectedSearchType = 0
    var selectedProductDict:NSDictionary?
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.isHidden = true
        selectedProductView.isHidden = true
        lotQuantityView.isHidden = true
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        autoSearchSectionView.roundTopCorners(cornerRadious: 40)
        
        selectionContainer.setRoundCorner(cornerRadious: 10)
        searchContainer.setRoundCorner(cornerRadious: 10)
        
        selectedProductView.setRoundCorner(cornerRadious: 10)
        
        selectProductView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchProductView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchTextFieldView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
       
        
        quantityView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchTextField.addLeftViewPadding(padding: 12.0)
        quantityTextField.addLeftViewPadding(padding: 12.0)
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        
        createInputAccessoryView()
        searchTextField.inputAccessoryView = inputAccView
        
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
    
    @IBAction func startTypingButtonPressed(_ sender: UIButton) {
        autoSearchView.isHidden = false
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        let quantity =   quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if selectedProductDict == nil {
            Utility.showPopup(Title: App_Title, Message: "Please select products first.".localized(), InViewC: self)
            return
        }else if (quantity as NSString).intValue <= 0 {
            Utility.showPopup(Title: App_Title, Message: "Enter quantity more than 0".localized(), InViewC: self)
            return
        }
        
        var product_uuid = ""
        if let txt = selectedProductDict?["uuid"] as? String,!txt.isEmpty{
            product_uuid = txt
        }
        
        var product_name = ""
        if let txt = selectedProductDict?["name"] as? String,!txt.isEmpty{
            product_name = txt
        }
        
        var gtin14 = ""
        if let txt = selectedProductDict?["gtin14"] as? String,!txt.isEmpty{
            gtin14 = txt
        }
        
        addProduct(product_uuid: product_uuid, product_name: product_name, gtin14: gtin14, quantity: Int16(quantity) ?? 0)
        
    }
    
    //MARK: - End
    
    //MARK: - Private Method
    
    
    func populateSelectedProductView(){
        
        selectedProductDict = products?[selectedProductIndex] as? NSDictionary
        
        var custName = ""
        if let name = selectedProductDict!["name"] as? String{
            custName = name
        }
        
        
        if let uuid = selectedProductDict!["uuid"] as? String{
            
            print(uuid)
            
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
    
    
    
    func addProduct(product_uuid:String, product_name:String, gtin14:String, quantity:Int16){
        let obj = MISItem(context: PersistenceService.context)
        obj.product_uuid = product_uuid
        obj.product_name = product_name
        obj.gtin14 = gtin14
        obj.quantity = quantity
        obj.id = getAutoIncrementId()
        
        PersistenceService.saveContext()
        
        self.navigationController?.popViewController(animated: true)
//        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Product Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
    }
    
    
    func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchAutoIncrementId())
            if !serial_obj.isEmpty{
                if let obj = serial_obj.first {
                    autoId = obj.id + Int16(1)
                }
            }
        }catch let error{
            print(error.localizedDescription)

        }
        return autoId
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
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell") as! ProductListCell
        cell.bgView.layer.cornerRadius = 10
        cell.bgView.layer.masksToBounds = true
        cell.bgView.clipsToBounds = true
        
        
        if tableView == listTable {
            let dataDict:NSDictionary = products?[indexPath.section] as? NSDictionary ?? NSDictionary()
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
            
           listTable.reloadData()
           searchViewCloseButtonPressed(UIButton())
           view.endEditing(true)
            
        }else{
           
            var itemName = ""
            
//            if let name = data["lot"] as? String{
//                itemName =  name
//            }
            
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
            
            
        
        }
        
    }
    //MARK: - End
    
   
    
    
    
    

    

}

