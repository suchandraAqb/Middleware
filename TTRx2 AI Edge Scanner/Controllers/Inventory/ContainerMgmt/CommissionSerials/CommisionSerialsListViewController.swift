//
//  CommisionSerialsListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 20/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit


enum SerialGenStatus:String {
    case Open = "OPEN"
    case Closed = "CLOSED"
    case Generating = "GENERATING"
    case Failed = "FAILED"
}

class CommisionSerialsListViewController: BaseViewController,CommissionSerialSearchViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var newSerialButton: UIButton!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var disPatchGroup = DispatchGroup()
    var searchDict = [String:Any]()
    var refreshControl = UIRefreshControl()
    
    //MARK: - End
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        newSerialButton.setRoundCorner(cornerRadious: newSerialButton.frame.size.height/2.0)
        loadMoreFooterView()
        addPullToRefresh()
        getSerialListWithQueryParam()
        
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
            // print("itemsList: \(self.itemsList)")
            self.listTable.reloadData()
        }
    }
    //MARK: - End
    
    //MARK: - Action
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommissionSerialSearchView") as! CommissionSerialSearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func detailsButtonpressed(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommissionedSerialsView") as! CommissionedSerialsViewController
        if let txt = self.itemsList[sender.tag]["uuid"] as? String,!txt.isEmpty{
            controller.serialsUuid = txt
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
        
    }
    
    
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to remove this serial request?".localized()
        controller.delegate = self
        controller.isIndexRequired = true
        controller.indexNumber = sender.tag
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func addNewSerialsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "GenerateSerialsView") as! GenerateSerialsViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getSerialListWithQueryParam()
    }
    
    
    //MARK: - End
    
    //MARK Privae method
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
        getSerialListWithQueryParam()
        refreshControl.endRefreshing()
    }
    
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
    
    func populateLabelView(str1:String,str2:String,statusColor:UIColor,label:UILabel){
        
        let firstAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let firstStr = NSMutableAttributedString(string: str1, attributes: firstAttributes)
        
        let secondAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: statusColor,
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let secondStr = NSAttributedString(string: "\(str2)", attributes: secondAttributes)
        
        
        firstStr.append(secondStr)
        label.attributedText = firstStr
        
    }
    //MARK: - End
    
    //MARK: - Call API
    
    func deleteSerialRequest(uuid:String){
        
        let appendStr = "/\(uuid)"
        
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "GetContainerSerials", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let _ = responseDict["uuid"] as? String{
                        
                        Utility.showPopup(Title: Success_Title, Message:"Request Deleted.".localized(), InViewC: self)
                        self.getSerialListWithQueryParam()
                           
                        
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
    
    func getSerialListWithQueryParam() {
        let url = "?sort_by_asc=false&nb_per_page=100&\(appendStr)&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "GetContainerSerials", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
        getSerialListWithQueryParam()
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
        
    }
    //MARK: End
}

//MARK: - Tableview Delegate and Datasource
extension CommisionSerialsListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "CommissionSerialListCell") as! CommissionSerialListCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        let item = itemsList[indexPath.row]
        var status = ""
        
        var dataStr = ""
        
        if let txt = item["status"] as? String{
            status = txt
            dataStr = txt
        }
        
        var color = Utility.hexStringToUIColor(hex: "F25E5E")
        if dataStr == SerialGenStatus.Closed.rawValue{
            color = Utility.hexStringToUIColor(hex: "57c497")
        }
        
        populateLabelView(str1: "Status".localized() + ": ", str2: dataStr.capitalized, statusColor: color, label: cell.statusLabel)
        dataStr = ""
        
        if let txt = item["uuid"] as? String{
            dataStr = txt
        }
        cell.uuidLabel.text = dataStr
        
        dataStr = ""
        if let date:String = item["created_on"] as? String{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd HH:mm:ss.SSSSSSZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: date){
                dataStr = formattedDate
            }
        }
        cell.requestedOnLebel.text = dataStr
        
        dataStr = "0"
        
        if let txt = item["quantity_generated"] as? Int{
            dataStr = "\(txt)"
        }
        
        cell.qtyGenerateLabel.text = dataStr
        
        dataStr = "0"
        
        if let txt = item["quantity_commissioned"] as? Int{
            dataStr = "\(txt)"
            
            if txt == 0 && status == SerialGenStatus.Open.rawValue{
                cell.deleteView.isHidden = false
            }else{
                cell.deleteView.isHidden = true
            }
        }
        
        cell.qtyCommissionLabel.text = dataStr
        
        
        
        cell.deleteButton.tag = indexPath.row
        cell.detailsButton.tag = indexPath.row
        
        
        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class CommissionSerialListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var deleteView: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var requestedOnLebel: UILabel!
    @IBOutlet weak var qtyGenerateLabel: UILabel!
    @IBOutlet weak var qtyCommissionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End

//MARK: - ConfirmationViewDelegate
extension CommisionSerialsListViewController : ConfirmationViewDelegate{
    func doneButtonPressed() {
    }
    func doneButtonPressedWithIndex(index: Int) {
        
        let item = itemsList[index]
        if let txt = item["uuid"] as? String{
            self.deleteSerialRequest(uuid: txt)
        }
        
       
    }
    func cancelConfirmation() {
        
    }
}
//MARK: - End

//MARK: - ConfirmationViewDelegate
extension CommisionSerialsListViewController : GenerateSerialsViewDelegate{
    func serialGenerated() {
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getSerialListWithQueryParam()
    }
}
//MARK: - End

