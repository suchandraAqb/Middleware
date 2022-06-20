//
//  MISPurchaceOrderListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 16/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISPurchaceOrderListViewController: BaseViewController,MISPurchaceOrderSearchViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var searchDict = [String:Any]()
    
    var clickFor = ""
    
    var purchaseOrderDetailsDict = [String:Any]()
    var tradingPartners:Array<Any>?
    
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        getPurchaseListWithQueryParam()
        
    }
    //MARK: - End
    
    //MARK: - Action
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISPurchaceOrderSearchView") as! MISPurchaceOrderSearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewButtonPressed(_ sender: UIButton) {
        clickFor = "View"
        if let uuid = self.itemsList[sender.tag]["uuid"] as? String,!uuid.isEmpty{
            getPurchaseOrder(uuid: uuid)
        }
    }
    
    
    @IBAction func selectButtonPreesed(_ sender: UIButton) {
        clickFor = "Select"
        if let uuid = self.itemsList[sender.tag]["uuid"] as? String,!uuid.isEmpty{
            getPurchaseOrder(uuid: uuid)
        }
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getPurchaseListWithQueryParam()
        
    }
    
    //MARK: - End
    
    //MARK: - Privae method
    func loadMoreFooterView() {
        loadMoreButton = UIButton(frame: CGRect(x: 0, y: -20, width: self.listTable.frame.width, height: 50))
        //UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.listTable.frame.width, height: 40)))
        loadMoreButton.titleLabel?.textAlignment = .center
        loadMoreButton.setTitleColor(#colorLiteral(red: 0.02745098039, green: 0.1294117647, blue: 0.2666666667, alpha: 1), for: .normal)
        loadMoreButton.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 16.0)
        loadMoreButton.setTitle("Load more".localized(), for: .normal)
        loadMoreButton.backgroundColor = .clear
        self.listTable.tableFooterView?.backgroundColor = .clear
        loadMoreButton.addTarget(self, action:#selector(loadMoreButtonPressed), for: .touchUpInside)
        self.listTable.tableFooterView = loadMoreButton
        
    }
    
    func goToView() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISPurchaseOrderDetailsView") as! MISPurchaseOrderDetailsViewController
        controller.purchaseOrderDetailsDict = purchaseOrderDetailsDict as NSDictionary
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToSelect() {
        if purchaseOrderDetailsDict.count > 0 {
            
            if let lineItems = purchaseOrderDetailsDict["line_items"] as? [[String:Any]] {
                for lineItem in lineItems {
                    
                    var maxquantity = 0
                    var product_name = ""
                    var gtin14 = ""
                    var line_item_uuid = ""
                    var product_uuid = ""
                    
                    if let quantity_shipped = lineItem["quantity_shipped"] , let quantity = lineItem["quantity"] {
                        
                        let formater = NumberFormatter()
                        formater.locale = Locale(identifier: "en_US")
                        
                        if let quantitystr = quantity as? String , let quantity_shippedstr = quantity_shipped as? String{
                            if let quantityint = formater.number(from: quantitystr)?.intValue , quantityint > 0{
                                let quantity_shippedint = formater.number(from: quantity_shippedstr)?.intValue ?? 0
                            
                                maxquantity = quantityint - quantity_shippedint
                            }
                            
                        }
                    }
                    
                    if let tmpline_item_uuid = lineItem["uuid"] as? String, !tmpline_item_uuid.isEmpty {
                        line_item_uuid = tmpline_item_uuid
                    }
                    
                    if let product = lineItem["product"] as? [String:Any] {
                        if let descriptions = product["descriptions"] as? [[String:Any]], let description = descriptions.first {
                            if let tmpname = description["name"] as? String {
                                product_name = tmpname
                            }
                        }
                        
                        if let tmpuuid = product["uuid"] as? String, !tmpuuid.isEmpty {
                            product_uuid = tmpuuid
                        }
                        
                        if let tmpgtin14 = product["gtin14"] as? String, !tmpgtin14.isEmpty {
                            gtin14 = tmpgtin14
                        }
                    }
                    
                    if maxquantity > 0 {
                    
                        let obj = MISItem(context: PersistenceService.context)
                        obj.line_item_uuid = line_item_uuid
                        obj.product_uuid = product_uuid
                        obj.product_name = product_name
                        obj.gtin14 = gtin14
                        obj.quantity = Int16(maxquantity)
                        obj.maxquantity = Int16(maxquantity)
                        obj.id = getAutoIncrementId()

                        PersistenceService.saveContext()
                    }
                    
                }
            }
            
            
            var tempProductCount = 0
            
            do{
                let predicate = NSPredicate(format:"TRUEPREDICATE")
                let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    let count = serial_obj.count
                    if count > 0 {
                        tempProductCount = count
                    }
                }else{
                    tempProductCount = 0
                }
            }catch let error{
                print(error.localizedDescription)
                tempProductCount = 0
            }
            
            if tempProductCount > 0 {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISPurchaseOrderView") as! MISPurchaseOrderViewController
                controller.purchaseOrderDetailsDict = purchaseOrderDetailsDict
                self.navigationController?.pushViewController(controller, animated: true)
                
            }else{
                Utility.showPopup(Title: App_Title, Message: "All products are shipped of this purchase order. Please select another".localized(), InViewC: self)
            }            
            
        }
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
    
    //MARK: - Call API
    func getPurchaseListWithQueryParam() {
        let url = "?is_exclude_all_items_shipped=true&nb_per_page=10&\(appendStr)&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "PurchaseOrder", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
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
    
    func getPurchaseOrder(uuid:String) {
        let url = "/\(uuid)?_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "PurchaseOrder", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        self.purchaseOrderDetailsDict = responseDict
                        if self.clickFor == "Select"{
                            self.goToSelect()
                        }else if self.clickFor == "View" {
                            self.goToView()
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
    
    //MARK: End
    //MARK: - Search View Delegate
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?) {
        
        filterButton.isSelected = false
        if searchDict != nil{
            self.searchDict = searchDict!
        }
        
        self.appendStr = appendstr
        if !self.appendStr.isEmpty {
            filterButton.isSelected = true
        }
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getPurchaseListWithQueryParam()        
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        self.appendStr = ""
        filterButton.isSelected = false
        
    }
    //MARK: End
    
    
}

//MARK: - Tableview Delegate and Datasource
extension MISPurchaceOrderListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "PurchaceOrderListCell") as! PurchaceOrderListCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["uuid"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.uuidLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["custom_id"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.orderIdLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["trading_partner_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.customerLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["po_nbr"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.poLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["invoice_nbr"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.invoiceNumberLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["transaction_date"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.transationDateLabel.text = dataStr
                
        cell.selectButton.tag = indexPath.row
        cell.viewButton.tag = indexPath.row
        
        
        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class PurchaceOrderListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    
    
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var poLabel: UILabel!
    @IBOutlet weak var invoiceNumberLabel: UILabel!
    @IBOutlet weak var transationDateLabel: UILabel!
    

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End



