//
//  ShipmentListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 25/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ShipmentListViewController: BaseViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    
    var itemsList: [[String: Any]] = []
    var productUuid = ""
    var lotNumber = ""
    var shipmentType = ""
    var subAppendStr = ""
    var tempKey = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        
        if shipmentType == "Outbound" {
            backButton.setTitle("Outbound Shipments".localized(), for: .normal)
            subAppendStr = "is_include_outbound_shipments=true"
            tempKey = "outbound_shipments"
        }else if shipmentType == "Inbound" {
            backButton.setTitle("Inbound Shipments".localized(), for: .normal)
            subAppendStr = "is_include_inbound_shipments=true"
            tempKey = "inbound_shipments"
        }
        
        getShipmentsListWithQueryParam()

        // Do any additional setup after loading the view.
    }
    

    //MARK: - Action
    
    @IBAction func viewButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "PPShipmentDetailsView") as! PPShipmentDetailsViewController
        if let uuid = dataDict["uuid"] as? String{
            controller.shipmentId = uuid
        }
        if shipmentType == "Outbound" {
            controller.type = shipmentType
        }else if shipmentType == "Inbound" {
            controller.type = shipmentType
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
        let dataDict = itemsList[sender.tag]
        let controller = storyboard.instantiateViewController(withIdentifier: "PPShipmentDownloadView") as! PPShipmentDownloadViewController
        
        if let uuid = dataDict["uuid"] as? String{
            controller.shipmentId = uuid
        }
        controller.type = shipmentType
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: {})
    }
    
    //MARK: - End
    
    //MARK: - Call Api
    func getShipmentsListWithQueryParam() {
        let appendStr = "\(self.productUuid)/lot?lot_number=\(self.lotNumber)&\(self.subAppendStr)&_=\(Date().currentTimeMillis())"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetProducts", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if let dataArray = responseDict[self.tempKey] as? [[String: Any]] {
                            self.itemsList = dataArray
                            self.listTable.reloadData()
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
    //MARK: - End
}


//MARK: - Tableview Delegate and Datasource
extension ShipmentListViewController: UITableViewDelegate, UITableViewDataSource {
    
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "InventoryShipmentListCell") as! InventoryShipmentListCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String

        let item = itemsList[indexPath.row]

        var dataStr = ""
        if let txt = item["trading_partner_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.tradingPartnerLabel.text = dataStr

        dataStr = ""
        if let txt = item["shipment_date"] as? String,!txt.isEmpty{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: txt){
                dataStr = formattedDate
            }
        }
        cell.shipmentDateLabel.text = dataStr

        dataStr = ""
        if let txt = item["items_count"] as? NSNumber{
            dataStr = "\(txt)"
        }
        cell.quantityLabel.text = dataStr

        if let transactions = item["transactions"] as? [[String: Any]] {
            dataStr = ""
            if let txt = transactions.first?["invoice_number"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.invoiceLabel.text = dataStr

            dataStr = ""
            if let txt = transactions.first?["order_number"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.orderLabel.text = dataStr

            dataStr = ""
            if let txt = transactions.first?["po_number"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.poLabel.text = dataStr
        }


        cell.downloadButton.tag = indexPath.row
        cell.viewButton.tag = indexPath.row

        
        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class InventoryShipmentListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    
    @IBOutlet weak var tradingPartnerLabel: UILabel!
    @IBOutlet weak var shipmentDateLabel: UILabel!
    @IBOutlet weak var poLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var invoiceLabel: UILabel!
    
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End
