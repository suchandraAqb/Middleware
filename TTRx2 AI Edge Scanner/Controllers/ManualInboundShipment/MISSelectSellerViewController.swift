//
//  MISSelectSellerViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 04/01/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  MISSelectSellerViewDelegate: class {
    func doneButtonPressed(tradingPartnerName: String,tradingPartnerUuid: String)
}

class MISSelectSellerViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    var itemsList:Array<Any>?
    
    
    @IBOutlet weak var selectedCustomeView: UIView!
    @IBOutlet weak var selectedCustomerNameLabel: UILabel!
    @IBOutlet weak var selectedCustomerIdLabel: UILabel!
    @IBOutlet weak var selectedCustomerglnLabel: UILabel!
    
    @IBOutlet weak var selectionContainer: UIView!
    @IBOutlet weak var selectCustomerView: UIView!
    @IBOutlet weak var searchCustomerView: UIView!
    @IBOutlet weak var searchTypeLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    @IBOutlet weak var autoSearchView: UIView!
    @IBOutlet weak var autoSearchSectionView: UIView!
    @IBOutlet weak var searchTextFieldView: UIView!
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var searchViewbackButton: UIButton!
    
       
    var tradingPartners:Array<Any>?
    var selectedCustomerIndex = -1
    var selectedSearchType = 0
    var selectedCustomerDict:NSDictionary?
    
    var selectedTtadingPartnerName = ""
    var selectedTtadingPartnerUUID = ""
    
    weak var delegate: MISSelectSellerViewDelegate?
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.isHidden = true
        selectedCustomeView.isHidden = true
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        autoSearchSectionView.roundTopCorners(cornerRadious: 40)
        selectionContainer.setRoundCorner(cornerRadious: 10)
        searchContainer.setRoundCorner(cornerRadious: 10)
        selectedCustomeView.setRoundCorner(cornerRadious: 10)
        
        selectCustomerView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchCustomerView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchTextFieldView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchTextField.addLeftViewPadding(padding: 12.0)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        createInputAccessoryView()
        searchTextField.inputAccessoryView = inputAccView
        getTradingPartnersList()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK: - End
    
    //MARK: - IBAction
   
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if selectedTtadingPartnerUUID != "" {
            
            self.delegate?.doneButtonPressed(tradingPartnerName: self.selectedTtadingPartnerName,tradingPartnerUuid: self.selectedTtadingPartnerUUID)
            self.navigationController?.popViewController(animated: true)
        }
        
        print("selected Customer Index")
    }
    
    
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
        
        let idAction = UIAlertAction(title: "Customer ID".localized(), style: .default, handler:  { (UIAlertAction) in
            self.selectedSearchType = 1
            self.searchTypeLabel.text = "Search by Customer ID".localized()
            self.searchViewbackButton.setTitle("Search by Customer ID".localized(), for: .normal)
            self.searchTextField.text = ""
            self.autoCompleteWithStr(searchStr: "")
            self.startTypingButtonPressed(UIButton())
        })
        
        let gs1Action = UIAlertAction(title: "GS1 ID".localized(), style: .default, handler:  { (UIAlertAction) in
            self.selectedSearchType = 2
            self.searchTypeLabel.text = "Search by GS1 ID".localized()
            self.searchViewbackButton.setTitle("Search by GS1 ID".localized(), for: .normal)
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
        autoSearchView.isHidden = true
        searchTextField.text = ""
        listTable.isHidden = true
    }
    @IBAction func startTypingButtonPressed(_ sender: UIButton) {
        autoSearchView.isHidden = false
        searchTextField.becomeFirstResponder()
        
        
    }
    //MARK: - End
    
    //MARK: - Private Method
    func populateSelectedCustomerView(){
        
        selectedCustomerDict = tradingPartners?[selectedCustomerIndex] as? NSDictionary
        
        Utility.saveDictTodefaults(key: "MIS_selectedSeller", dataDict: selectedCustomerDict!)
        
        var custName = ""
        if let name = selectedCustomerDict!["name"]  as? String{
            custName = name
            selectedTtadingPartnerName = name
        }
        
        var custType = ""
        if let type = selectedCustomerDict!["type"]  as? String{
            custType = "\n(\(type))"
        }
        
        let _ = CustomerAddressesModel.CustomerAddShared
        
        if let uuid = selectedCustomerDict!["uuid"] as? String{
            self.showSpinner(onView: self.view)
            defaults.removeObject(forKey: "MIS_soldBy")
            defaults.removeObject(forKey: "MIS_shipFrom")
            CustomerAddressesModel.updateCustomerId(customerId: uuid) { (isDone:Bool?) in
               self.removeSpinner()
            }
            
            
        }
        
        if let uuid = selectedCustomerDict!["uuid"] as? String{
            selectedTtadingPartnerUUID = uuid
        }
        
        let custAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!]
        let attString = NSMutableAttributedString(string: custName, attributes: custAttributes)
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "BFF1FF"),
        NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15.0)!]
        
        let typeStr = NSAttributedString(string: custType, attributes: custTypeAttributes)
        attString.append(typeStr)
        
        selectedCustomerNameLabel.attributedText = attString
        
        
        var dataStr = ""
        if let name = selectedCustomerDict!["customer_id"]  as? String{
            dataStr = name
        }
        
        selectedCustomerIdLabel.text = "CUST ID: " + dataStr
        
        dataStr = ""
        if let name = selectedCustomerDict!["gs1_sgln"]  as? String{
            dataStr = name
        }
        
        selectedCustomerglnLabel.text = "GLN: " + dataStr
        
        selectedCustomeView.isHidden = false
        
    }
    func autoCompleteWithStr(searchStr:String?){
       
//        if !selectedCustomeView.isHidden{
//            selectedCustomeView.isHidden = true
//        }
        
        var predicate:NSPredicate?
        if selectedSearchType == 0 { // Using Name
            predicate = NSPredicate(format: "name CONTAINS[c] '\(searchStr ?? "")'")
            
        }else if selectedSearchType == 1 { // Using Customer ID
            predicate = NSPredicate(format: "customer_id CONTAINS[c] '\(searchStr ?? "")'")
            
        }else if selectedSearchType == 2 { // Using GS1 ID
            predicate = NSPredicate(format: "gs1_sgln CONTAINS[c] '\(searchStr ?? "")'")
            
        }
        
        
        if let masterArr = itemsList as NSArray?, let masterDictArr = itemsList as? [[String:Any]]{
            
            var filteredArray = NSArray()
            
            if searchStr?.count == 1 {
                if selectedSearchType == 0 { // Using Name
                    filteredArray = masterDictArr.filter({ return ($0["name"] as? String ?? "").first?.lowercased().contains((searchStr?.first ?? Character("")).lowercased()) ?? false}) as NSArray
                }else if selectedSearchType == 1 { // Using Customer ID
                    filteredArray = masterDictArr.filter({ return ($0["customer_id"] as? String ?? "").first?.lowercased().contains((searchStr?.first ?? Character("")).lowercased()) ?? false}) as NSArray
                }else if selectedSearchType == 2 { // Using GS1 ID
                    filteredArray = masterDictArr.filter({ return ($0["gs1_sgln"] as? String ?? "").first?.lowercased().contains((searchStr?.first ?? Character("")).lowercased()) ?? false}) as NSArray
                }
                
            }else{
                filteredArray = masterArr.filtered(using: predicate!) as NSArray
            }
            
            if filteredArray.count>0{
                listTable.isHidden = false
                tradingPartners = (filteredArray as! Array<Any>)
                listTable.reloadData()
            }else{
                tradingPartners = nil
                listTable.reloadData()
                listTable.isHidden = true
            }
        }
        
    }
    func getTradingPartnersList(){
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetTradingPartners", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        
                        if let dataArray = responseDict["data"] as? Array<Any> {
                            self.tradingPartners = dataArray
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
        
        if selectedCustomerIndex > -1 {
            selectedCustomerIndex = -1
        }
        autoCompleteWithStr(searchStr: sender.text!)
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
        return tradingPartners?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MISCustomerListCell") as! MISCustomerListCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        
        
        
        let dataDict:NSDictionary = tradingPartners?[indexPath.section] as! NSDictionary
        var dataStr:String = ""
        
        var custName = ""
        if let name = dataDict["name"]  as? String{
            custName = name
        }
        
        var custType = ""
        if let type = dataDict["type"]  as? String{
            custType = " (\(type))"
        }
        
        
        
        
        cell.customerNameLabel.text = dataStr
        
        dataStr = ""
        if let name = dataDict["customer_id"]  as? String{
            dataStr = name
        }
        
        cell.custIdLabel.text = "CUST ID: " + dataStr
        
        dataStr = ""
        if let name = dataDict["gs1_sgln"]  as? String{
            dataStr = name
        }
        
        cell.glnNoLabel.text = "GLN: " + dataStr
        
        
        if selectedCustomerIndex == indexPath.section{
            
            let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!]
            let attString = NSMutableAttributedString(string: custName, attributes: custAttributes)
            
            let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "BFF1FF"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
            
            let typeStr = NSAttributedString(string: custType, attributes: custTypeAttributes)
            attString.append(typeStr)
            
            cell.customerNameLabel.attributedText = attString
            
            cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "00AFEF")
            cell.custIdLabel.textColor = Utility.hexStringToUIColor(hex: "BFF1FF")
            cell.glnNoLabel.textColor = Utility.hexStringToUIColor(hex: "BFF1FF")
            
            
            
        }else{
            
            let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "00AFEF"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!]
            let attString = NSMutableAttributedString(string: custName, attributes: custAttributes)
            
            let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "5691A2"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
            
            let typeStr = NSAttributedString(string: custType, attributes: custTypeAttributes)
            attString.append(typeStr)
            
            cell.customerNameLabel.attributedText = attString
            
            cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "E3F1F7")
            cell.custIdLabel.textColor = Utility.hexStringToUIColor(hex: "5691A2")
            cell.glnNoLabel.textColor = Utility.hexStringToUIColor(hex: "5691A2")
        }
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedCustomerIndex == indexPath.section{
            selectedCustomerIndex = -1
            
        }else{
            selectedCustomerIndex = indexPath.section
            populateSelectedCustomerView()
        }
        
        listTable.reloadData()
        searchViewCloseButtonPressed(UIButton())
        view.endEditing(true)
        
    }
    
    //MARK: - End
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
    }
    
    func cancelConfirmation() {
        
        
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End

    

}

class MISCustomerListCell: UITableViewCell
{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var custIdLabel: UILabel!
    @IBOutlet weak var glnNoLabel: UILabel!
    
    override func awakeFromNib() {
        
    }
}

