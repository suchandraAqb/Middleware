//
//  OutboundShipmentListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 22/07/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class OutboundShipmentListViewController: BaseViewController,OutboundShipmentSearchViewDelegate,ToShipEditDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet var filterButton: UIButton!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var disPatchGroup = DispatchGroup()
    var isReceived=""
    var isReadyToShip=""
    var isShipped="true"
    var searchDict = [String:Any]()
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        let btn = UIButton()
        btn.tag = 0
        typeButtonPressed(btn)
        
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
            self.listTable.reloadData()
        }
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "OutboundShipmentSearch") as! OutboundShipmentSearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func detailsButtonpressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "PPShipmentDetailsView") as! PPShipmentDetailsViewController

        if let uuid = dataDict["uuid"] as? String{
            controller.shipmentId = uuid
        }
        controller.type = "OUTBOUND"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "PPShipmentDownloadView") as! PPShipmentDownloadViewController

        if let uuid = dataDict["uuid"] as? String{
            controller.shipmentId = uuid
        }
        controller.type = "OUTBOUND"
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: {})
    }
    
    @IBAction func toShipButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ToShipEdit") as! ToShipEditViewController

        if let uuid = dataDict["uuid"] as? String{
            controller.shipmentId = uuid
        }
        controller.type = "OUTBOUND"
        controller.delegate=self
        self.navigationController?.pushViewController(controller, animated: true)
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
            if btn.isSelected && btn.tag == 0{
                isReadyToShip=""
                isReceived=""
            }else if btn.isSelected && btn.tag == 1{
                isReadyToShip=""
                isReceived="true"
            }else if btn.isSelected && btn.tag == 2{
                isReadyToShip="true"
                isReceived=""
            }
        }
        
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getOutboundShipmentList()
        
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getOutboundShipmentList()
    }
    //MARK: - End
    
    //MARK: - Privae method
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
    
    
    
    //MARK: - API Call
    func getOutboundShipmentList() {
        if isReadyToShip=="true" {
            isShipped="false"
        }else{
            isShipped="true"
        }
        
        let url = "?nb_per_page=100&sort_by_asc=false&sort_by=created_on&page=\(currentPage)&type=OUTBOUND&is_received=\(isReceived)&is_shipped=\(isShipped)&is_ready_to_ship=\(isReadyToShip)&\(appendStr)"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "OutboundShipmentList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
    
    // MARK: - ToShipEditDelegate methods
    func shipmentUpdated() {
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getOutboundShipmentList()
    }
    
    
   // MARK: - OutboundShipmentSearchViewDelegate methods
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?) {
        filterButton.isSelected = false
        if searchDict != nil{
            self.searchDict = searchDict!
            if !self.searchDict.isEmpty {
                filterButton.isSelected = true
                if let txt = self.searchDict["DeliveryStatusForApi"] as? String,!txt.isEmpty{
                    let deliveryStatus = self.searchDict["DeliveryStatusForApi"] as! String
                    if deliveryStatus=="all" {
                        isReadyToShip=""
                        isReceived=""
                        for btn in typeButtons {
                            if btn.tag == 0 {
                                btn.isSelected = true
                            }else{
                                btn.isSelected = false
                            }
                        }
                    }else if deliveryStatus=="received"{
                        isReadyToShip=""
                        isReceived="true"
                        for btn in typeButtons {
                            if btn.tag == 1 {
                                btn.isSelected = true
                            }else{
                                btn.isSelected = false
                            }
                        }

                    }
                }
            }
        }

        self.appendStr = appendstr
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getOutboundShipmentList()
    }

    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
        for btn in typeButtons {
            if btn.tag == 0 {
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
        }
        isReadyToShip=""
        isReceived=""
    }
}
//MARK: End

//MARK: - Tableview Delegate and Datasource
extension OutboundShipmentListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "OutboundShipmentListCell") as! OutboundShipmentListCell
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["uuid"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.uuidLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["trading_partner_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.tradingPartnerLabel.text = dataStr
        
        dataStr = ""
        if let shipDate = item["created_on"] as? String{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd HH:mm:ss.SSSSSSZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: shipDate){
                dataStr = formattedDate
            }
        }
        cell.createdOnLabel.text = dataStr
        
//        dataStr = ""
//        if let txt = item["delivery_status"] as? String,!txt.isEmpty{
//            dataStr = txt
//        }
//        cell.statusLabel.text = dataStr
        
        dataStr = ""
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        if let shipDate:String = item["shipment_date"] as? String{
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                dataStr = formattedDate
            }
        }
        cell.shipDateLabel.text = dataStr
        
        
        if let transactions:[[String: Any]] = item["transactions"] as? [[String: Any]]{
            if transactions.count>0{
                let firstTransaction:NSDictionary = transactions.first as NSDictionary? ?? NSDictionary()
                dataStr = ""
                if let po:String = firstTransaction["po_number"] as? String{
                    dataStr=po
                }
                cell.poNumberLabel.text = dataStr
                
                dataStr = ""
                if let order_number:String = firstTransaction["custom_order_id"] as? String{
                    dataStr = order_number
                }
                cell.orderIdLabel.text = dataStr
                    
                dataStr = ""
                if let invoice_number:String = firstTransaction["invoice_number"] as? String{
                    dataStr = invoice_number
                }
                cell.invoiceNumberLabel.text = dataStr
           }
        }
        
        let rts = item["is_shipped"] as? Bool //is_ready_to_ship
        if !rts! {
            cell.toShipButton.isHidden=false
            cell.toShipViewHeightConstraint.constant=45
            cell.downloadButtonView.isHidden=true

        }else{
            cell.toShipButton.isHidden=true
            cell.toShipViewHeightConstraint.constant=0
            cell.downloadButtonView.isHidden=false

        }
        
        
        cell.downloadButton.tag = indexPath.row
        cell.detailsButton.tag = indexPath.row
            cell.toShipButton.tag=indexPath.row
        cell.customView.layoutIfNeeded()
        return cell
    }
}

//MARK: - End

//MARK: - Tableview Cell
class OutboundShipmentListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var tradingPartnerLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var shipDateLabel: UILabel!
    @IBOutlet weak var poNumberLabel: UILabel!
    @IBOutlet weak var invoiceNumberLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var detailsButtonView: UIView!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadButtonView: UIView!
    
    
    @IBOutlet var toShipButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    @IBOutlet var toShipViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        self.customView.setRoundCorner(cornerRadious: 10)
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}

//MARK: - End

