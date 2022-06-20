//
//  ItemsInInventoryListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 09/11/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ItemsInInventoryListViewController: BaseViewController,ItemsInInventorySearchViewDelegate {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var lotType = ""
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var searchDict = [String:Any]()

    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        itemsList = []
        listTable.reloadData()
        getItemsInInventoryList()

    }
    //MARK: - End
    
    //MARK: - IBActions
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        self.getItemsInInventoryList()
    }
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsInInventorySearchView") as! ItemsInInventorySearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewInventoryButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotInventoryView") as! LotInventoryViewController
        let item = itemsList[sender.tag]
        if let txt = item["product_uuid"] as? String,!txt.isEmpty{
            controller.productUuid = txt
        }
        controller.isForItemsInInventory = true
        controller.isShowViewLotButton = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewLotsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsInInventoryLotListView") as! ItemsInInventoryLotListViewController
        let item = itemsList[sender.tag]
        if let txt = item["product_uuid"] as? String,!txt.isEmpty{
            controller.productUuid = txt
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewLocationButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotInventoryLocationView") as! LotInventoryLocationViewController
        let item = itemsList[sender.tag]
        if let txt = item["product_uuid"] as? String,!txt.isEmpty{
            controller.productUuid = txt
        }
        controller.isForItemsInInventory = true
        self.navigationController?.pushViewController(controller, animated: true)
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
    //MARK: - End
    
    //MARK: - Call API
    func getItemsInInventoryList() {
        let url = "inventory/?is_wrap_results_in_generic_search_object=true&status=AVAILABLE&sort_by_asc=false&nb_per_page=10&\(appendStr)&page=\(currentPage)&sort_by=total_available_items&_=\(Date().currentTimeMillis())"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetProducts", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
        getItemsInInventoryList()
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        self.appendStr = ""
        filterButton.isSelected = false
        
    }
    //MARK: End
    
    
}
//End of class

//MARK: - Tableview Delegate and Datasource
extension ItemsInInventoryListViewController: UITableViewDelegate, UITableViewDataSource {

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
        let cell = listTable.dequeueReusableCell(withIdentifier: "ItemsInInventoryTableViewCell") as! ItemsInInventoryTableViewCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        cell.stockQtyView.setRoundCorner(cornerRadious: cell.stockQtyView.frame.size.height/2.0)
        cell.availQtyView.setRoundCorner(cornerRadious: cell.availQtyView.frame.size.height/2.0)
        
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["product_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.productNameLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["product_uuid"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.productUuidLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["product_category_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.categoryLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["qty_in_stock"] as? NSNumber{
            dataStr = "\(txt)"
        }
        cell.stockQtyLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["get_total_available_items"] as? NSNumber{
            dataStr = "\(txt)"
        }
        cell.availQtyLabel.text = dataStr
        
        cell.viewInventoryButton.tag = indexPath.row
        cell.viewLotButton.tag = indexPath.row
        cell.viewLocationButton.tag = indexPath.row
        
        
        return cell
    }
    //MARK: - End
    
    
}

//MARK: - End


//MARK: - Tableview Cell
class ItemsInInventoryTableViewCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet var productUuidLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet weak var stockQtyView: UIView!
    @IBOutlet weak var availQtyView: UIView!
    @IBOutlet weak var stockQtyLabel: UILabel!
    @IBOutlet weak var availQtyLabel: UILabel!
    @IBOutlet var viewInventoryButton: UIButton!
    @IBOutlet var viewLotButton: UIButton!
    @IBOutlet var viewLocationButton: UIButton!
    
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
//MARK: - End
