//
//  PickingListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 06/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

enum LOT_Types:String {
    case LOT_BASED = "LOT_BASED"
    case SERIAL_BASED = "SERIAL_BASED"
    case ALL = ""

}

class PPListViewController: BaseViewController,SearchViewDelegate {
        
    @IBOutlet weak var listTable: UITableView!
    
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet var filterButton: UIButton!
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var quaranTineAdjustmentList: [[String: Any]] = []
    var disPatchGroup = DispatchGroup()
    var searchType = LOT_Types.ALL.rawValue
    var searchDict = [String:Any]()
    
    //MARK: - End
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        let btn = UIButton()
        btn.tag = 3
        typeButtonPressed(btn)
        
        
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
           // print("itemsList: \(self.itemsList)")
           // print("quaranTineAdjustmentList: \(self.quaranTineAdjustmentList)")
            self.listTable.reloadData()
        }
    }
    //MARK: - End
    
    //MARK: - Action
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PPSearchViewController") as! PPSearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func detailsButtonpressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PPShipmentDetailsView") as! PPShipmentDetailsViewController
        
        if let uuid = dataDict["shipment_uuid"] as? String{
            controller.shipmentId = uuid
        }
        
        if let txt = dataDict["transaction_type"] as? String{
            controller.type = txt
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PPShipmentDownloadView") as! PPShipmentDownloadViewController
        
        if let uuid = dataDict["shipment_uuid"] as? String{
            controller.shipmentId = uuid
        }
        
        if let txt = dataDict["transaction_type"] as? String{
            controller.type = txt
        }
        
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: {})
    }
    
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
                searchType = LOT_Types.LOT_BASED.rawValue
            }else if btn.isSelected && btn.tag == 2{
                searchType = LOT_Types.SERIAL_BASED.rawValue
            }else if btn.isSelected && btn.tag == 3{
                searchType = LOT_Types.ALL.rawValue
            }
        }
        
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getProductListWithQueryParam()
        
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getProductListWithQueryParam()
    }
    
    
    //MARK: - End
    
    //MARK Privae method
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
    //MARK: - End
    
    //MARK: - Call API
    func getProductListWithQueryParam() {
        let url = "?nb_per_page=100&\(appendStr)&lot_type=\(searchType)&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "ShipmentLotsItem", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
    
    //MARK: End
    //MARK: - Search View Delegate
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?) {
        
        filterButton.isSelected = false
        if searchDict != nil{
            self.searchDict = searchDict!
            if !self.searchDict.isEmpty {
                filterButton.isSelected = true
            }
        }
        
        self.appendStr = appendstr
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getProductListWithQueryParam()
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
        
    }
    //MARK: End
}

//MARK: - Tableview Delegate and Datasource
extension PPListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "ProductShipmentListCell") as! ProductShipmentListCell
        
        
        
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["product_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.titleLebel.text = dataStr
        
        dataStr = ""
        if let txt = item["us_ndc"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.ndcLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["gtin14"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.gtin14Label.text = dataStr
        
        dataStr = ""
        if let txt = item["transaction_type"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.typeLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["trading_partner_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.partnerLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["lot_quantity"] as? String,!txt.isEmpty{
            dataStr = "\((txt as NSString).integerValue)"
        }
        cell.qtyLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["lot_number"] as? String,!txt.isEmpty{
            if item["lot_type"]as? String == "SERIAL_BASED"{
                dataStr = "SB: \(txt)"
            }else{
                dataStr = "LB: \(txt)"
            }
        }
        cell.lotLabel.text = dataStr
        
        
        dataStr = ""
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        if let shipDate:String = item["shipment_date"] as? String{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                dataStr = formattedDate
            }
        }
        cell.shipDateLabel.text = dataStr
        
        dataStr = ""
        
        if let shipDate:String = item["lot_expiration_date"] as? String{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                dataStr = formattedDate
            }
        }
        cell.expirationDateLabel.text = dataStr

        cell.downloadButton.tag = indexPath.row
        cell.detailsButton.tag = indexPath.row
        
        cell.customView.layoutIfNeeded()
        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class ProductShipmentListCell: UITableViewCell {
    
    @IBOutlet weak var customView: UIView!
    
    @IBOutlet weak var ndcLabel: UILabel!
    @IBOutlet weak var titleLebel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var shipDateLabel: UILabel!
    @IBOutlet weak var gtin14Label: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        self.customView.setRoundCorner(cornerRadious: 10)
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End

