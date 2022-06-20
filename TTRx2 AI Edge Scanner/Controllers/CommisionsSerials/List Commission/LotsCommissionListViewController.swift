//
//  LotsCommissionListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 13/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class LotsCommissionListViewController:BaseViewController,LotsCommissionSearchViewDelegate,AddLotBasedLotViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var addLotButton: UIButton!
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var disPatchGroup = DispatchGroup()
    var searchDict = [String:Any]()
    
    //MARK: - End
    
    override func loadView() {
        super.loadView()

    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver( self, selector: #selector(self.addEditCommmissionNotification),name: NSNotification.Name(rawValue: "RefreshCommissionList"), object: nil)
        
        sectionView.roundTopCorners(cornerRadious: 40)
        addLotButton.setRoundCorner(cornerRadious: addLotButton.frame.size.height/2.0)
        loadMoreFooterView()
        //getCommissionListWithQueryParam()
        SearchButtonPressed(appendstr: "is_open=true&", searchDict: ["status": "Open Only"])
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
            // print("itemsList: \(self.itemsList)")
            self.listTable.reloadData()
            //self.view.layoutIfNeeded()
        }
    }
    //MARK: - End
    
    //MARK: - Action
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotsCommissionSearchView") as! LotsCommissionSearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func detailsButtonpressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        
        let storyboard = UIStoryboard.init(name: "Manufacturer", bundle: .main)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "AddLotBasedLotView") as! AddLotBasedLotViewController
        controller.currentLotType = LotType.Serialised.rawValue
        controller.delegate =  self
        controller.isEdit = true
        controller.lotData = dataDict
        if dataDict["type"]as? String == LotType.Serialised.rawValue{
            controller.currentLotType = LotType.Serialised.rawValue
        }else{
            controller.currentLotType = LotType.LotBased.rawValue
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func commissionButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommissionSerialsView") as! CommissionSerialsViewController
        controller.isEdit = true
        controller.commissionDetailsDict = self.itemsList[sender.tag]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func lockButtonPressed(_ sender: UIButton) {
        let msg = "Once closed, the lot cannot be re-opened. Are you sure you want to close this lot?".localized()
        
        let confirmAlert = UIAlertController(title: "Closing Lot".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            let dataDict = self.itemsList[sender.tag]
            
            let product_uuid = dataDict["product_uuid"] as? String ?? ""
            let lot_number = dataDict["uuid"] as? String ?? ""
            self.closeLotRequest(product_uuid: product_uuid , lot_uuid: lot_number)
            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func commissionGS1SerialsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommissionSerialsView") as! CommissionSerialsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getCommissionListWithQueryParam()
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
    
    
    
    func getCommissionListWithQueryParam() {
        let url = "lot?sort_by_asc=true&nb_per_page=10&\(appendStr)&sort_by_asc=false&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "Manufacturer", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
    
    func closeLotRequest(product_uuid:String,lot_uuid:String){
        let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)/close"
        let requestParam = NSMutableDictionary()
        requestParam.setValue(true, forKey: "is_closed")
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "AddUpdateManufacturerLot", serviceParam: requestParam, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["uuid"] as? String {
//                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Close Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        self.currentPage = 1
                        self.itemsList = []
                        self.listTable.reloadData()
                        self.getCommissionListWithQueryParam()
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
        getCommissionListWithQueryParam()
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
        
    }
    //MARK: End
    
    //MARK: - Search View Delegate
    func lotAddUpdated() {
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getCommissionListWithQueryParam()
    }
    
    //MARK: End
    
    //MARK: Local Notification
    @objc private func addEditCommmissionNotification(notification: NSNotification){
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getCommissionListWithQueryParam()
    }
    //MARK: End
    
    
}



//MARK: - Tableview Delegate and Datasource
extension LotsCommissionListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "LotsCommissionListCell") as! LotsCommissionListCell
        
        
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["product_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.titleLebel.text = dataStr
        
        dataStr = ""
        if let txt = item["location_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.locationLabel.text = dataStr
        
        
        
        dataStr = ""
        if let txt = item["lot_number"] as? String,!txt.isEmpty{
            if item["type"]as? String == "SERIALIZED"{
                dataStr = "SB: \(txt)"
            }else{
                dataStr = "LB: \(txt)"
            }
        }
        cell.lotLabel.text = dataStr
        
        
        dataStr = ""
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        if let shipDate = item["production_date"] as? String{
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                dataStr = formattedDate
            }
        }
        cell.productionDateLabel.text = dataStr
        
        dataStr = ""
        
        if let shipDate = item["expiration_date"] as? String{
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                dataStr = formattedDate
            }
        }
        cell.expirationDateLabel.text = dataStr
        
        dataStr = ""
        
        if let shipDate = item["created_on"] as? String{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.sZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: shipDate){
                dataStr = formattedDate
            }
        }
        cell.createdLabel.text = dataStr
        
        
        dataStr = ""
        if let txt = item["total_requested_serials_count"] as? NSNumber{
            dataStr = "\(txt)"
        }
        cell.serialCountLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["uncomissionned_serials_count"] as? NSNumber{
            dataStr = "\(txt)"
        }
        cell.uncommissionSerialCountLabel.text = dataStr
        
        cell.commissionView.isHidden =  true
        cell.lockView.isHidden = true
        
        if let status = item["is_open"] as? Bool,status{
            cell.statusButton.setTitle("Open".localized(), for: .normal)
            cell.statusButton.backgroundColor = Utility.hexStringToUIColor(hex: "65dfa7")
            if item["type"]as? String == "SERIALIZED"{
                cell.commissionView.isHidden =  false
            }
            cell.lockView.isHidden = false
        }else{
            cell.statusButton.setTitle("Closed".localized(), for: .normal)
            cell.statusButton.backgroundColor = Utility.hexStringToUIColor(hex: "00AFEF")
            cell.commissionView.isHidden =  true
            cell.lockView.isHidden = true
        }
        
        cell.commissionButton.tag = indexPath.row
        cell.detailsButton.tag = indexPath.row
        cell.lockButton.tag = indexPath.row
        cell.customView.layoutIfNeeded()
        
        return cell
    }
}

//MARK: - End

//MARK: - Tableview Cell
class LotsCommissionListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    
    
    @IBOutlet weak var titleLebel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var productionDateLabel: UILabel!
    
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    @IBOutlet weak var serialCountLabel: UILabel!
    @IBOutlet weak var uncommissionSerialCountLabel: UILabel!
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var commissionView: UIView!
    @IBOutlet weak var commissionButton: UIButton!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        self.customView.setRoundCorner(cornerRadious: 10)
        self.statusButton.setRoundCorner(cornerRadious: self.statusButton.frame.size.height/2.0)
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End

