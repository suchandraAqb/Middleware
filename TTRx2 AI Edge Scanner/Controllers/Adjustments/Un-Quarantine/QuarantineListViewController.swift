//
//  QuarantineListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by rupshikha anand on 30/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class QuarantineListViewController: BaseViewController {
    
    weak var delegate: QuarantineOptionViewControllerDelegete?
    weak var delegates: ConfirmationViewDelegate?
    @IBOutlet weak var listTable: UITableView!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var quaranTineAdjustmentList: [[String: Any]] = []
    var disPatchGroup = DispatchGroup()
    
    //MARK: - End
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        getQuarantineListWithQueryParam(appendStr:appendStr)
        getAdjustmentList(type: "QUARANTINE")
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
           // print("itemsList: \(self.itemsList)")
           // print("quaranTineAdjustmentList: \(self.quaranTineAdjustmentList)")
            self.listTable.reloadData()
        }
    }
    //MARK: - End
    
    //MARK: - Action
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func unQuarantineButtonPressed(_ sender: UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Do you want to Un-Quarantine this item?".localized()
        controller.delegate = self
        controller.isIndexRequired = true
        controller.indexNumber = sender.tag
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsPressed(_ sender: UIButton) {
        
        if let item = itemsList[sender.tag] as? [String:Any], let uuid = item["uuid"] as? String {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "QuarantineProductListView") as! QuarantineProductListViewController
            controller.adjustment_uuid = uuid
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getQuarantineListWithQueryParam(appendStr:appendStr)
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
    
    func getAdjustmentList(type:String){
        let appendStr = "inventory_adjustments_reasons?Type=\(type)"
        self.disPatchGroup.enter()
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.disPatchGroup.leave()
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if let dataArr = responseDict["data"] as? [[String: Any]] {
                            self.quaranTineAdjustmentList = dataArr
                        }
                    }
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        
                        Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                        
                    }else{
                        Utility.showAlertWithPopAction(Title: App_Title, Message: message ?? "", InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }
                
            }
        }
    }
    
    func getQuarantineListWithQueryParam(appendStr:String) {
        let url = appendStr + "&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "GetQuarantineList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
}

//MARK: - Tableview Delegate and Datasource
extension QuarantineListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "QuarantineListCell") as! QuarantineListCell
        
        cell.unQuarantineButton.tag = indexPath.row
        cell.customView.setRoundCorner(cornerRadious: 20)
        cell.unQuarantineButton.setRoundCorner(cornerRadious: cell.unQuarantineButton.frame.size.height / 2.0)
        cell.viewItemsButton.tag = indexPath.row
        cell.viewItemsButton.setRoundCorner(cornerRadious: cell.viewItemsButton.frame.size.height / 2.0)
        let items = itemsList[indexPath.row]
        cell.udidValueLabel.text = (items["uuid"] as? String) ?? ""
        cell.itemsCountLabel.text = String(items["items_count"] as? Int ?? 0)
        cell.productCountLabel.text = String(items["products_count"] as? Int ?? 0)
        cell.referenceLabel.text = (items["reference_num"] as? String) ?? ""
        
        if let uuid = (items["reason_uuid"] as? String)?.lowercased() {
            let predicate = NSPredicate(format: "uuid == '\(uuid)'")
            let filterArray = (self.quaranTineAdjustmentList as NSArray).filtered(using: predicate)
            if filterArray.count > 0 {
                let quarantineObject = (filterArray.first as? [String: Any])
                if quarantineObject != nil {
                    if let uuidReason = quarantineObject?["name"] as? String {
                        cell.reasonLabel.text = uuidReason
                    }else{
                        cell.reasonLabel.text = (items["reason_text"] as? String) ?? ""
                    }
                }else{
                    cell.reasonLabel.text = (items["reason_text"] as? String) ?? ""
                }
            } else {
                cell.reasonLabel.text = (items["reason_text"] as? String) ?? ""
            }
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let shipDate:String = items["created_on"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                    cell.dateLabel.text = formattedDate
                }
            }
            
        }
        return cell
    }
}

//MARK: - End

//MARK: - Tableview Cell
class QuarantineListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var udidValueLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var remainimgItemCountLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var remainimgProductCountLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var unQuarantineButton: UIButton!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End

//MARK: - ConfirmationViewDelegate
extension QuarantineListViewController: ConfirmationViewDelegate {
    
    func doneButtonPressed() {
        print("done")
    }
    
    func doneButtonPressedWithIndex(index: Int) {
        print("UnQuarantine done")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineGeneralView") as! UnQuarantineGeneralViewController
        controller.itemsList =  itemsList[index]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func cancelConfirmation() {
        print("cancle")
    }
}
//MARK: - End
