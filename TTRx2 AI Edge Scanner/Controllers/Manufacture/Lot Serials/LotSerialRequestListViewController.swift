//
//  LotSerialRequestListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 01/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class LotSerialRequestListViewController:BaseViewController{
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet var addSerialRequestButton: UIButton!
    @IBOutlet var addSerialRequestView: UIView!
    @IBOutlet var noteView: UIView!
    @IBOutlet var noteLabel: UILabel!
    @IBOutlet weak var addSerialRequestContainerView: UIView!
    @IBOutlet weak var quantityContainerView: UIView!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    var refreshControl = UIRefreshControl()
    
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var currentPage = 1
    var totalResult = 0
    var disPatchGroup = DispatchGroup()
    var isLotClosed = false
    var product_uuid = ""
    var lot_uuid = ""
    
    
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isLotClosed{
            addSerialRequestView.isHidden = true
        }
        addPullToRefresh()
        sectionView.roundTopCorners(cornerRadious: 40)
        addSerialRequestButton.setRoundCorner(cornerRadious: addSerialRequestButton.frame.size.height/2.0)
        addButton.setRoundCorner(cornerRadious: addButton.frame.size.height/2.0)
        cancelButton.setRoundCorner(cornerRadious: cancelButton.frame.size.height/2.0)
        quantityContainerView.setRoundCorner(cornerRadious: 20)
        noteView.setRoundCorner(cornerRadious: 10)
        createInputAccessoryView()
        quantityTextField.inputAccessoryView = inputAccView
        loadMoreFooterView()
        getSerialRequestList()
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
            // print("itemsList: \(self.itemsList)")
            self.listTable.reloadData()
        }
        setup_view()
    }
    //MARK: - End
    
    //MARK: - Action
    
    
    
    @IBAction func detailsButtonpressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let request_uuid = dataDict["uuid"] as? String ?? ""
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialRequestDetailsView") as! SerialRequestDetailsViewController
        controller.lot_uuid = lot_uuid
        controller.product_uuid = product_uuid
        controller.request_uuid = request_uuid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
   
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        let msg = "You are about to delete the resource.\nThis operation can’t be undone.\n\nProceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            let dataDict = self.itemsList[sender.tag]
            let request_uuid = dataDict["uuid"] as? String ?? ""
            self.removeSerialRequest(request_uuid:request_uuid)
            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func addSerialRequestButtonPressed(_ sender: UIButton) {
       
        self.addSerialRequestContainerView.isHidden = false
    }
    
    
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getSerialRequestList()
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.addSerialRequestContainerView.isHidden = true
    }
    
    
    @IBAction func requestNewSerialButtonPressed(_ sender: UIButton) {
        let quantity =   quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if quantity.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "Please enter quantity more than 0".localized(), InViewC: self)
            return
            
        }else if !quantity.isEmpty && Int(quantity) ?? 0 <= 0{
            Utility.showPopup(Title: App_Title, Message: "Please enter quantity more than 0".localized(), InViewC: self)
            return
        }
        
        addNewSerialRequest(qty: quantity)
    }
    
    
    //MARK: - End
    
    //MARK Privae method
    
    func setup_view(){
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 13.0)!]
        let attString = NSMutableAttributedString(string: "Note: ".localized(), attributes: custAttributes)
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let typeStr = NSAttributedString(string: "You can’t edit this field later. You can void serial generated or do an other request for serial generation.".localized(), attributes: custTypeAttributes)
        attString.append(typeStr)
        
        noteLabel.attributedText = attString
    }
    func loadMoreFooterView() {
        loadMoreButton = UIButton(frame: CGRect(x: 0, y: -20, width: self.listTable.frame.width, height: 50))
        //UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.listTable.frame.width, height: 40)))
        loadMoreButton.titleLabel?.textAlignment = .center
        loadMoreButton.setTitleColor(#colorLiteral(red: 0.02745098039, green: 0.1294117647, blue: 0.2666666667, alpha: 1), for: .normal)
        loadMoreButton.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 16.0)
        loadMoreButton.setTitle("Load more", for: .normal)
        loadMoreButton.backgroundColor = .clear
        self.listTable.tableFooterView?.backgroundColor = .clear
        loadMoreButton.addTarget(self, action:#selector(loadMoreButtonPressed), for: .touchUpInside)
        self.listTable.tableFooterView = loadMoreButton
        
    }
    
    func addPullToRefresh(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localized())
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        listTable.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getSerialRequestList()
        refreshControl.endRefreshing()
    }
    //MARK: - End
    
    //MARK: - Call API
    
    
    
    func getSerialRequestList() {
        let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)/serials?nb_per_page=10&sort_by_asc=false&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "AddUpdateManufacturerLot", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.disPatchGroup.leave()
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                        if let dataArray = responseDict["data"] as? [[String: Any]] {
                            self.itemsList += dataArray
                            self.listTable.reloadData()
                        }
                        
                        self.loadMoreButton.isUserInteractionEnabled = true
                        if self.itemsList.count == self.totalResult {
                            self.loadMoreButton.isHidden = true
                        } else {
                            self.loadMoreButton.isHidden = false
                        }
                    }
                }else{
                    self.currentPage -= 1
                    self.loadMoreButton.isUserInteractionEnabled = true
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
    func addNewSerialRequest(qty:String) {
        let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)/serials"
        let request = ["quantity":qty]
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.POSTServiceCall(type: "AddUpdateManufacturerLot", serviceParam:request, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.disPatchGroup.leave()
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if let _ = responseDict["uuid"] as? String{
                             self.lotAddUpdated()
                             self.cancelButtonPressed(UIButton())
                        }
                    }
                }else{
                    self.currentPage -= 1
                    self.loadMoreButton.isUserInteractionEnabled = true
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
    
    func removeSerialRequest(request_uuid:String){
        
        let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)/serials/\(request_uuid)"
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "AddUpdateManufacturerLot", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary

                    if let _ = responseDict["uuid"] as? String {
                       self.lotAddUpdated()
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
    
    
    func lotAddUpdated() {
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getSerialRequestList()
    }
    
    
    
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
    //MARK: - End
    
    
    
}



//MARK: - Tableview Delegate and Datasource
extension LotSerialRequestListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "ManufactureProductListCell") as! ManufactureProductListCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        cell.statusButton.setRoundCorner(cornerRadious: cell.statusButton.frame.size.height/2.0)
        
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["quantity"] as? Int{
            dataStr = "\(txt)"
        }
        cell.quantityLabel.text = dataStr
        
       
        
        
        dataStr = ""
       // let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        if let date = item["created_on"] as? String{
//            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: outputDateFormat, dateStr: date){
//                dataStr = formattedDate
//            }
            
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd HH:mm:ss.SSSSSSZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: date){
                dataStr = formattedDate
            }
        }
        cell.createdLabel.text = dataStr
        
        
        
        
        if let status = item["is_completed"] as? Bool,status{
            cell.statusButton.setTitle("Completed".localized(), for: .normal)
            cell.statusButton.backgroundColor = Utility.hexStringToUIColor(hex: "65dfa7")
            
        }else{
            cell.statusButton.setTitle("In Progress".localized(), for: .normal)
            cell.statusButton.backgroundColor = Utility.hexStringToUIColor(hex: "00AFEF")
            
        }
        
        
        cell.detailsButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        
        
        return cell
    }
}

//MARK: - End
