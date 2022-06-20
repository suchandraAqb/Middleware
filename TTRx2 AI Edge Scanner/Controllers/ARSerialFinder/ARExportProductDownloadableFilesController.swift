//
//  ARExportProductDownloadableFilesController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Nova on 14/01/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sb3

import UIKit

class ARExportProductDownloadableFilesController: BaseViewController, ARExportProductDownloadableSearchViewDelegate { //,,,sb10
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var filterButton: UIButton!//,,,sb10
    @IBOutlet weak var deleteButton: UIButton!//,,,sb10
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""//,,,sb10
    var currentPage = 1
    var totalResult = 0
    var searchDict = [String:Any]()//,,,sb10
    var checkUUIDArray = [] as NSMutableArray//,,,sb10
    var currentSelectedIndex = -1

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        self.downloadable_files_WebserviceCall(callType: "firstLoad")
        self.addPullToRefresh() //,,,sb10
        deleteButton.isHidden = true //,,,sb10
    }
    //MARK: - End
    
    //MARK: - Action
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARExportProductDownloadableSearchViewController") as! ARExportProductDownloadableSearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }//,,,sb10
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let msg = "Do you want to delete selected products ?".localized()
        
        let confirmAlert = UIAlertController(title: "Confrimation".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes".localized(), style: .default) { (UIAlertAction) in
            self.downloadable_files_delete_multiple_WebserviceCall()
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }//,,,sb10
    
    @IBAction func checkUncheckButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let uuid = dataDict["uuid"] as? String
        if checkUUIDArray.contains("\(uuid ?? "")") {
            checkUUIDArray.remove("\(uuid ?? "")")
            sender.setImage(UIImage(named: "uncheck_lot_open.png"), for: .normal)
        }else {
            checkUUIDArray.add("\(uuid ?? "")")
            sender.setImage(UIImage(named: "check_lot_open.png"), for: .normal)
        }
        
        if (checkUUIDArray.count > 0) {
            deleteButton.isHidden = false
            if let i1 : Int = itemsList.firstIndex(where: {$0["uuid"] as? String == checkUUIDArray.lastObject as? String}) {
                currentSelectedIndex = i1
            }else {
                currentSelectedIndex = -1
            }
        }else {
            deleteButton.isHidden = true
            currentSelectedIndex = -1
        }
        
//        print ("checkUUIDArray...",checkUUIDArray)
    }//,,,sb10
    
    @IBAction func viewButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let status = dataDict["status"] as? String
        if (status == "COMPLETED") {
            if let uuid = dataDict["uuid"] as? String,!uuid.isEmpty {
                let file_type = "\(dataDict["file_type"] as? String ?? "")"//,,,sb10
                
                let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
                let controller = storyboard.instantiateViewController(withIdentifier: "ARExportProductDownloadViewController") as! ARExportProductDownloadViewController
                controller.downloadable_files_uuid = uuid
                controller.file_type = file_type//,,,sb10
                controller.modalPresentationStyle = .custom
                self.present(controller, animated: true, completion: {})
            }
        }
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        self.downloadable_files_WebserviceCall(callType: "loadMore")
    }
    //MARK: - End
    
    
    //MARK: - InboundShipmentSearchViewDelegate methods
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?) {
        if (self.checkUUIDArray.count > 0) {
            self.checkUUIDArray.removeAllObjects()
        }
        
        filterButton.isSelected = false
        if searchDict != nil{
            self.searchDict = searchDict!
            if !self.searchDict.isEmpty {
                filterButton.isSelected = true
            }
        }
        
        /*
        if searchDict != nil{
            self.searchDict = searchDict!
            if !self.searchDict.isEmpty {
                filterButton.isSelected = true
                
                /*
                if let txt = self.searchDict["createdDateForApi"] as? String,!txt.isEmpty{
                    if txt=="on" {
                        print("on..",txt)
                    }else if txt=="before"{
                        print("before..",txt)
                    }else if txt=="range"{
                        print("range..",txt)
                    }else{
                        //after
                        print("after..",txt)
                    }
                }*/
            }
        }*///,,,sb11
        
        self.appendStr = appendstr
//        print("self.appendStr...",self.appendStr)

        currentPage = 1
        self.itemsList = []
        listTable.reloadData()
        self.downloadable_files_WebserviceCall(callType: "search")
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
    }
    //MARK: End
        
    //MARK: - Privae method
    func addPullToRefresh(){
        //,,,sb5
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localized())
        refreshControl.addTarget(self, action:#selector(pullToRefresh), for: .valueChanged)
        listTable.refreshControl = refreshControl
        //,,,sb5
    }//,,,sb10
    
    @objc func pullToRefresh(refreshControl: UIRefreshControl) {
        if (self.checkUUIDArray.count > 0) {
            self.checkUUIDArray.removeAllObjects()
        }
        
        currentPage = 1
        self.itemsList = []//,,,sb10
        listTable.reloadData()
        self.downloadable_files_WebserviceCall(callType: "pullToRefresh")
        refreshControl.endRefreshing()
    }//,,,sb5
    
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
    
    //MARK: - Webservice Call
    func getInvidualProductList(uuid:String)->[[String:Any]]{
        var filterList = [[String:Any]]()
        
        let predicate = NSPredicate(format: "uuid = '\(uuid)'")
        
        filterList = (itemsList as NSArray).filtered(using: predicate) as! [[String : Any]]
        
        return filterList
    }//,,,sb10
    
    func downloadable_files_delete_multiple_WebserviceCall() {
        /*
        let checkUUIDArrayJsonString = Utility.json(from: checkUUIDArray)
        var requestDict = [String:Any]()//,,,sb3
        requestDict["uuids"] = checkUUIDArrayJsonString
        print ("requestDict....first",requestDict)
        
            let appendStr = ""
        DispatchQueue.main.async{
            self.showSpinner(onView: self.view)
        }
        Utility.POSTServiceCall(type: "downloadable_files_delete_multiple", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        if (self.checkUUIDArray.count > 0) {
                            self.checkUUIDArray.removeAllObjects()
                        }
                        
                        self.currentPage = 1
                        self.itemsList = []
                        self.listTable.reloadData()
                        self.downloadable_files_WebserviceCall(callType: "firstLoad")
                        
                    }else {
                        let dict = responseData as! NSDictionary
                        let error = dict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message:error , InViewC: self)
                    }
                }
        }
        */
        
        let checkUUIDArrayJsonString = Utility.json(from: checkUUIDArray)
        var requestDict = [String:Any]()//,,,sb3
        requestDict["uuids"] = checkUUIDArrayJsonString
//        print ("requestDict....first",requestDict)

            let appendStr = ""
        DispatchQueue.main.async {
            self.showSpinner(onView: self.view)
        }
        
        Utility.POSTServiceCall(type: "downloadable_files_delete_multiple", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    
                    if isDone! {
//                        self.removeSpinner()
//                        print ("self.itemsList....>>>~~~del ",self.itemsList.count)
                        for uuid in self.checkUUIDArray {
                            let newArray = self.itemsList.filter({ (dictionary) -> Bool in
                                if let value = dictionary["uuid"] as? String{
                                    return value != uuid as! String
                                }
                                return false
                            })
                            self.itemsList = newArray
                        }
                        
                        self.listTable.reloadData()
                        if (self.checkUUIDArray.count > 0) {
                            self.checkUUIDArray.removeAllObjects()
                        }
//                        print ("self.itemsList....>>>del1",self.itemsList.count)
                        
                        self.downloadable_files_WebserviceCall(callType: "delete")//,,,sb10
                        
                    }else {
                        self.removeSpinner()
                        
                        let dict = responseData as! NSDictionary
                        let error = dict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message:error , InViewC: self)
                    }
                }
        }
    }
    
    func downloadable_files_WebserviceCall(callType:String) {
        //,,,temp sb3
        let nb_per_page = 100
//        let nb_per_page = 10
        //,,,temp sb3

        if callType == "delete" {
            let d1: Double = Double(self.itemsList.count) / Double(nb_per_page)
//            print ("d1>><<...>>>",d1) //,,,sb11-12
            let y6 = d1.rounded(.up)
            self.currentPage = Int(y6)
//            print ("currentPage...~~~",currentPage) //,,,sb11-12
        }//,,,sb10
        else {
            DispatchQueue.main.async{
                self.showSpinner(onView: self.view)
            }
        }

        let str = "SERIAL FINDER".addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let url = "?nb_per_page=\(nb_per_page)&sort_by_asc=false&sort_by=created_on&page=\(currentPage)&scenario=\(str ?? "")&\(appendStr)"//,,,sb10
        
        Utility.GETServiceCall(type: "downloadable_files", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
//                    print ("self.itemsList....pre",self.itemsList.count)
                    if let responseDict = responseData as? [String: Any] {
                        self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                        if let dataArray = responseDict["data"] as? [[String: Any]] {
                            
                             if callType == "delete" {
                                let n = (self.currentPage - 1) * nb_per_page
//                                print ("n>><<...",n) //,,,sb11-12
//                                print ("self.itemsList.count>><<...",self.itemsList.count) //,,,sb11-12

                                let indexes = NSMutableIndexSet(index: n)
                                for i in n..<self.itemsList.count {
                                    indexes.add(i)
                                }
//                                print ("indexes....???",indexes)

                                for deletionIndex in indexes.reversed() {
//                                    print ("deletionIndex....???",deletionIndex)
                                    self.itemsList.remove(at: deletionIndex)
                                }

//                                print ("itemsList....???",self.itemsList.count)
                                self.listTable.reloadData()
                            }//,,,sb10

                            self.itemsList += dataArray
                            self.listTable.reloadData()
                            
                            /*
                            if callType == "delete" {
                                if (self.itemsList.count > 0) {
                                    if (self.currentSelectedIndex >= 0 &&  (self.currentSelectedIndex < self.itemsList.count)) {
                                        let indexPath = IndexPath(row: self.currentSelectedIndex, section: 0)
                                        self.listTable.scrollToRow(at: indexPath, at: .top, animated: true)
                                    }
                                    else {
                                        let indexPath = IndexPath(row: self.itemsList.count-1, section: 0)
                                        self.listTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
                                    }
                                }
                            }//,,,sb10
                            */
                        }
                        
//                        print ("self.itemsList....",self.itemsList.count)
//                        print ("self.totalResult....",self.totalResult)
                        
                        self.loadMoreButton.isUserInteractionEnabled = true
                        if self.itemsList.count == self.totalResult {
                            self.loadMoreButton.isHidden = true
                        } else {
                            self.loadMoreButton.isHidden = false
                        }
                    }

                    /*
                    if let path = Bundle.main.path(forResource: "downloadable_files", ofType: "json") {
                        do {
                              let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                              let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                              if let responseDict = jsonResult as? [String: Any] {
                                self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                                if let dataArray = responseDict["data"] as? [[String: Any]] {
                                    if callType == "pullToRefresh" {
                                        self.itemsList = []
                                    }
                                    self.itemsList += dataArray
                                    print ("self.itemsList....",self.itemsList.count)
                                    self.listTable.reloadData()
                                }
                                self.loadMoreButton.isUserInteractionEnabled = true
                                if self.itemsList.count == self.totalResult {
                                    self.loadMoreButton.isHidden = true
                                } else {
                                    self.loadMoreButton.isHidden = false
                                }
                            }
                          } catch {
                               print("JSON parsing Error")
                          }
                    }
                    */

                }else {
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
}

//MARK: - Tableview Delegate and Datasource
extension ARExportProductDownloadableFilesController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "ProductDownloadableFilesCell") as! ProductDownloadableFilesCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["display_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.customerLabel.text = dataStr
        
        dataStr = ""
        if let created_on = item["created_on"] as? String {
            let formattedDateString:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd HH:mm:ss.SSSSSSZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: created_on) ?? ""
            dataStr = formattedDateString
        }
        cell.createdOnLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["status"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        
        cell.checkUncheckButton.isHidden = true//,,,sb10
        if dataStr == "COMPLETED" {
            cell.viewButton.setTitle("COMPLETED".localized(), for: UIControl.State.normal)
            cell.viewButton.setTitleColor(UIColor.green, for: UIControl.State.normal)
            
            cell.checkUncheckButton.isHidden = false//,,,sb10
        }
        else if dataStr == "FAILED" {
            cell.viewButton.setTitle("FAILED".localized(), for: UIControl.State.normal)
            cell.viewButton.setTitleColor(UIColor.red, for: UIControl.State.normal)
            
            cell.checkUncheckButton.isHidden = false//,,,sb10
        }
        else if dataStr == "QUEQED" {
            cell.viewButton.setTitle("QUEQED".localized(), for: UIControl.State.normal)
            cell.viewButton.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: UIControl.State.normal)
        }
        else if dataStr == "QUEUED" {
            cell.viewButton.setTitle("QUEUED".localized(), for: UIControl.State.normal)
            cell.viewButton.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: UIControl.State.normal)
        }//,,,sb-lang1
        else {
            cell.viewButton.setTitle(dataStr, for: UIControl.State.normal)
            cell.viewButton.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: UIControl.State.normal)
        }
                
        //,,,sb10
        dataStr = ""
        if let txt = item["file_type"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.fileTypeLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["uuid"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        if checkUUIDArray.contains(dataStr) {
            cell.checkUncheckButton.setImage(UIImage(named: "check_lot_open.png"), for: .normal)
        }else {
            cell.checkUncheckButton.setImage(UIImage(named: "uncheck_lot_open.png"), for: .normal)
        }
        if (checkUUIDArray.count > 0) {
            deleteButton.isHidden = false
        }else {
            deleteButton.isHidden = true
        }
        //,,,sb10

        cell.viewButton.tag = indexPath.row
        cell.checkUncheckButton.tag = indexPath.row//,,,sb10

        return cell
    }
}
//MARK: - End

//MARK: - Tableview Cell
class ProductDownloadableFilesCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var checkUncheckButton: UIButton!//,,,sb10
    @IBOutlet weak var fileTypeLabel: UILabel!//,,,sb10

    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
//MARK: - End




