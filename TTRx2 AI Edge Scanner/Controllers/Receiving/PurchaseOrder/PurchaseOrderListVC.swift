//
//  PurchaseOrderListVC.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 19/05/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PurchaseOrderListVC: BaseViewController {
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet var filterButton: UIButton!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var disPatchGroup = DispatchGroup()
    var searchDict = [String:Any]()
    var shipmentId:String?
    
    public var dictShipmentDetails: NSDictionary?
    public var dictPo: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        self.getPOListWithQueryParam()
        self.disPatchGroup.notify(queue: .main) {
            print("Api is called")
            // print("itemsList: \(self.itemsList)")
            self.tblList.reloadData()
        }
    }
    //MARK Privae method
    func loadMoreFooterView() {
        loadMoreButton = UIButton(frame: CGRect(x: 0, y: -20, width: self.tblList.frame.width, height: 50))
        //UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.listTable.frame.width, height: 40)))
        loadMoreButton.titleLabel?.textAlignment = .center
        loadMoreButton.setTitleColor(#colorLiteral(red: 0.02745098039, green: 0.1294117647, blue: 0.2666666667, alpha: 1), for: .normal)
        loadMoreButton.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 16.0)
        loadMoreButton.setTitle("Load more", for: .normal)
        loadMoreButton.backgroundColor = .clear
        self.tblList.tableFooterView?.backgroundColor = .clear
        loadMoreButton.addTarget(self, action:#selector(loadMoreButtonPressed), for: .touchUpInside)
        self.tblList.tableFooterView = loadMoreButton
        
    }
    //MARK: - End
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getPOListWithQueryParam()
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        let item = itemsList[sender.tag]
        self.shipmentId = item["uuid"] as? String ?? ""
        self.getShipmentDetails(id: item["uuid"] as? String ?? "")
        
    }
    //ee2a8ba6-e72a-4af5-ab23-fa717b8d42c4
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "PurchaseOrderListFilter") as! PurchaseOrderListFilter
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func getPOListWithQueryParam() {
        
        //        var appendStr = ""
        //        if let ship_uuid = shipmentId{
        //            appendStr = appendStr + "uuid=\(ship_uuid)"
        //        }
        //is_exclude_all_items_shipped=true&
        let url = "?is_exclude_all_items_shipped=true&nb_per_page=10&\(appendStr)&sort_by_asc=false&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        //let url = "/\(uuid)?_=\(Date().currentTimeMillis())"
        DispatchQueue.main.async {
            self.showSpinner(onView: self.view)
        }
        
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "PurchaseOrder", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.disPatchGroup.leave()
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                        if let dataArray = responseDict["data"] as? [[String: Any]] {
                            self.itemsList += dataArray
                            self.tblList.reloadData()
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
    
    func getShipmentDetails(id: String){
        
        let url = "/\(id)?_=\(Date().currentTimeMillis())"
        
        DispatchQueue.main.async{
            self.showSpinner(onView: self.view)
        }
        
        Utility.GETServiceCall(type: "PurchaseOrder", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict = responseData as? NSDictionary
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderAllocVC") as! PurchaseOrderAllocVC
                    
                    if let responseData = responseDict{
                        
                        guard let po = responseData["po_nbr"] as? String else {
                            Utility.showPopup(Title: App_Title, Message: "No purchase order number found".localized() , InViewC: self)
                            return
                        }
                        
                        let line_item = self.dictPo?["line_items"] as? [[String:Any]] ?? [[String: Any]]()
                        
                        let dicPO = ["po_number": po,
                                     
                                     "date": responseData["transaction_date"] as? String ?? "",
                                     "order_number": responseData["order_nbr"] as? String ?? "",
                                     "line_items": line_item] as [String: Any]
                        
                        controller.dictPo = dicPO
                        
                        if let ship_lines_item = self.dictShipmentDetails?["ship_lines_item"] as? [[String: Any]]{
                            controller.ship_lines_item = ship_lines_item
                        }
                        

                        self.navigationController?.pushViewController(controller, animated: true)
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
}
extension PurchaseOrderListVC: SearchViewDelegate{
    
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
        tblList.reloadData()
        DispatchQueue.global(qos: .userInteractive).async {
            self.getPOListWithQueryParam()
        }
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
    }
}
extension PurchaseOrderListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
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
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return self.itemsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "POCell", for: indexPath) as! POCell
        (cell.btnView.tag, cell.btnSelect.tag) = (indexPath.section, indexPath.section)
        
        let item = itemsList[indexPath.section]
        cell.lblCustOrderNo.text = item["order_nbr"] as? String
        cell.lblPoNo.text = item["po_nbr"] as? String
        cell.lblDate.text = item["transaction_date"] as? String
        
        return cell
    }
}
class POCell: UITableViewCell{
    
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var lblCustOrderNo: UILabel!
    @IBOutlet var lblPoNo: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var btnView: UIButton!
    @IBOutlet var btnSelect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
}
