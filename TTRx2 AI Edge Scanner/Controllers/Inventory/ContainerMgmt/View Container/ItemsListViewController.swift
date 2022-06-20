//
//  ContainerListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 17/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ItemsListViewController: BaseViewController,ItemsDeleteViewDelegate {
        
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var checkAllButton: UIButton!
    
    var itemsList: [[String: Any]] = []
    var disPatchGroup = DispatchGroup()
    var serialNumber:String = ""
    
    var selectedRow: [[String: Any]] = []
    var storageAreaUuid:String = ""
    var storageShelfUuid:String = ""
    let allproducts = UserInfosModel.getAllProducts()
       
    @IBOutlet weak var checkAllView: UIView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        getItemsListWithQueryParam()
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
            self.listTable.reloadData()
        }
    }
    //MARK: - End
    
    //MARK: - Action
    
    
    @IBAction func checkAllButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.selectedRow = itemsList
        } else {
            self.selectedRow.removeAll()
        }
        self.listTable.reloadData()
    }
    
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let obj = itemsList[sender.tag]

        if (self.selectedRow as NSArray).contains(obj) {
            let index = (self.selectedRow as NSArray).index(of: obj)
            self.selectedRow.remove(at: index)
        } else {
            self.selectedRow.append(obj)
        }
        if self.selectedRow.count == self.itemsList.count {
            self.checkAllButton.isSelected = true
        } else {
            self.checkAllButton.isSelected = false
        }

        self.listTable.reloadData()
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        if self.selectedRow.count > 0 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsDeleteView") as! ItemsDeleteViewController
            controller.selectedItem = self.selectedRow
            controller.serialNumber = self.serialNumber
            controller.storageAreaUuid = self.storageAreaUuid
            controller.storageShelfUuid = self.storageShelfUuid
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)            
        }else{
            let msg = "Please select at least one item".localized()
            Utility.showPopup(Title: App_Title, Message:  msg, InViewC: self)
        }
    }
    
    //MARK: - End
    
    
    //MARK: - Call API
    
    
    
    func getItemsListWithQueryParam() {
        let url = "SERIAL/\(serialNumber)/content?recursive=true&include_child_product=false&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "ContainersDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.disPatchGroup.leave()
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if let dataArray = responseDict["data"] as? [[String: Any]] {
                            self.itemsList = dataArray
                            self.listTable.reloadData()
                        }
                        if let txt = responseDict["storage_area_uuid"] as? String,!txt.isEmpty{
                            self.storageAreaUuid = txt
                        }
                        if let txt = responseDict["storage_shelf_uuid"] as? String,!txt.isEmpty{
                            self.storageShelfUuid = txt
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
    
    
    //MARK: - Items Delete View Delegate
    func doneItemDelete() {
        self.selectedRow = []
        self.itemsList = []
        self.listTable.reloadData()
        self.getItemsListWithQueryParam()
    }
    //MARK: End
    
}

//MARK: - Tableview Delegate and Datasource
extension ItemsListViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "ItemListCell") as! ItemListCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        cell.checkButton.tag = indexPath.row
        
        let item = itemsList[indexPath.row]
        
        if let itemType = item["type"] as? String,!itemType.isEmpty{
            var dataStr = ""
            if let txt = item["serial"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.serialLabel.text = dataStr
            if itemType == "PRODUCT" {
                cell.titleButton.isSelected = false
                cell.typeLabel.text = "Item".localized()
                if let product = item["product"] as? [String: Any] {
                    dataStr = ""
                    if let txt = product["product_name"] as? String,!txt.isEmpty{
                        dataStr = txt
                    }
                    cell.titleLabel.text = dataStr
                    dataStr = ""
//                    if let txt = product["sku"] as? String,!txt.isEmpty{
//                        dataStr = txt
//                    }
                   
                    
                     if let txt = product["uuid"] as? String,!txt.isEmpty{
                        if allproducts != nil {
                            if let prod = allproducts![txt] as? [String:Any]{
                                
                                if let txt = prod["gtin14"] as? String,!txt.isEmpty{
                                    dataStr = txt
                                }
                                
                            }
                        }
                     }
                    
                     cell.skuLabel.text = dataStr
                    
                    if let product_identifiers = product["product_identifiers"] as? [[String: Any]] {
                        dataStr = ""
                        if let txt = product_identifiers.first?["value"] as? String,!txt.isEmpty{
                            dataStr = txt
                        }
                        cell.ndcLabel.text = dataStr
                    }
                }
            }else if itemType == "CONTAINER" {
                cell.titleButton.isSelected = true
                cell.typeLabel.text = "Aggregation".localized()
                cell.titleLabel.text = "Container".localized()
                cell.skuLabel.text = ""
                cell.ndcLabel.text = ""
            }
            dataStr = "1"
            if let txt = item["lot_quantity"] as? NSNumber {
                dataStr = "\(txt)"
                cell.typeLabel.text = "Lot Based Item".localized()
                cell.serialView.isHidden = true
            }else{
                cell.serialView.isHidden = false
            }
            cell.quantityLabel.text = dataStr
        }
        
        
        if self.checkAllButton.isSelected {
            cell.checkButton.isSelected = true
        } else {
            if (self.selectedRow as NSArray).contains(item) {
                cell.checkButton.isSelected = true
            } else {
                cell.checkButton.isSelected = false
            }
        }
        
        
        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class ItemListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
  
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var ndcLabel: UILabel!
    @IBOutlet weak var serialView: UIView!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End
