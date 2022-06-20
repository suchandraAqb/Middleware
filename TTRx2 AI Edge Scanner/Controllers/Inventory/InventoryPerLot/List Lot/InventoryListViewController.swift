//
//  InventoryListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 22/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class InventoryListViewController: BaseViewController, InventorySearchViewDelegate,EditLotViewDelegate {
    
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var lotType = ""
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var searchDict = [String:Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        
        let btn = UIButton()
        btn.tag = 1
        typeButtonPressed(btn)
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Action
    
    @IBAction func typeButtonPressed(_ sender: UIButton) {
    
       if sender.isSelected {
           return
       }
       for btn in typeButtons {
           
           if btn.tag == sender.tag {
               btn.isSelected = true
           }else{
               btn.isSelected = false
           }
           
           if btn.isSelected && btn.tag == 1{
               lotType = "ANY"
           }else if btn.isSelected && btn.tag == 2{
               lotType = "LOT_BASED"
           }else if btn.isSelected && btn.tag == 3{
               lotType = "SERIAL_BASED"
           }
       }
        
       currentPage = 1
       itemsList = []
       listTable.reloadData()
       getInventoryListWithQueryParam()
       
    }
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InventorySearchView") as! InventorySearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ViewLotView") as! ViewLotViewController
        controller.lotDetailsDict = self.itemsList[sender.tag]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "EditLotView") as! EditLotViewController
        controller.lotDetailsDict = self.itemsList[sender.tag]
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getInventoryListWithQueryParam()
        
    }
    //MARK: - End
    

    //MARK Privae method
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
    
    func getInventoryListWithQueryParam() {
        let url = "lots/?is_in_stock_only=true&sort_by=lot_expiration&sort_by_asc=true&lot_type=\(lotType)&nb_per_page=10&\(appendStr)&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        
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
        getInventoryListWithQueryParam()
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        self.appendStr = ""
        filterButton.isSelected = false
        
    }
    //MARK: End
    
    //MARK: - Edit View Delegate
    func lotUpdated() {
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getInventoryListWithQueryParam()
    }
    
    //MARK: End

}


//MARK: - Tableview Delegate and Datasource
extension InventoryListViewController: UITableViewDelegate, UITableViewDataSource {

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
        let cell = listTable.dequeueReusableCell(withIdentifier: "InventoryTableViewCell") as! InventoryTableViewCell
        
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
        if let txt = item["gtin14"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.gtinLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["product_ndc"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.ndcLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["lot_number"] as? String,!txt.isEmpty{
            if item["lot_type"]as? String == "SERIAL_BASED"{
                dataStr = "SB: \(txt)"
            }else{
                dataStr = "LB: \(txt)"
            }
        }
        cell.lotLabel.text = dataStr
        
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        dataStr = ""
        if let txt = item["lot_expiration"] as? String,!txt.isEmpty{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: txt){
                dataStr = formattedDate
            }
        }
        cell.expirationDateLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["inventory_in_stock"] as? NSNumber{
            dataStr = "\(txt)"
        }
        cell.stockQtyLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["inventory_avail"] as? NSNumber{
            dataStr = "\(txt)"
        }
        cell.availQtyLabel.text = dataStr
        
        
        cell.editButton.tag = indexPath.row
        cell.viewButton.tag = indexPath.row
        
        
        return cell
    }
}
//MARK: - End



//MARK: - Tableview Cell
class InventoryTableViewCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var gtinLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var ndcLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var stockQtyLabel: UILabel!
    @IBOutlet weak var availQtyLabel: UILabel!
    
    @IBOutlet weak var stockQtyView: UIView!
    @IBOutlet weak var availQtyView: UIView!
    
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End
