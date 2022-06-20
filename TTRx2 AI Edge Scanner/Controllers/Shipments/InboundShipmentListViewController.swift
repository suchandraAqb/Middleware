//
//  InboundShipmentListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 16/07/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

enum DeliveryStatusEnum:String {
    case ALL = "all"
    case SHIPPED = "shipped"
    case RECEIVED = "received"
}



class InboundShipmentListViewController: BaseViewController,InboundShipmentSearchViewDelegate,InboundShipmentStorageSelectionDelegate{
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet var filterButton: UIButton!
    
    @IBOutlet var deleteShipmentPopupView: UIView!
    @IBOutlet var deleteShipmentConfirmButton: UIButton!
    @IBOutlet var deleteShipmentPopupInnerView: UIView!
    @IBOutlet var deleteShipmentPopupShipmentIdLabel: UILabel!
    var shipmentIdToDelete:String?
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var disPatchGroup = DispatchGroup()
    var deliveryStatus = DeliveryStatusEnum.ALL.rawValue
    var searchDict = [String:Any]()
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        deleteShipmentPopupView.isHidden=true
        deleteShipmentPopupInnerView.layer.cornerRadius=15
        deleteShipmentPopupInnerView.clipsToBounds=true
        deleteShipmentConfirmButton.layer.cornerRadius=10
        
        
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
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        if let uuid = dataDict["uuid"] as? String{
            deleteShipmentPopupShipmentIdLabel.text = uuid
            shipmentIdToDelete = uuid
        }
        deleteShipmentPopupView.isHidden=false
    }
    @IBAction func deleteShipmentConfirmButtonPressed(_ sender: UIButton) {
        deleteShipmentPopupView.isHidden=true
        let requestDict = NSMutableDictionary()
        requestDict.setValue("SILENT_DELETE", forKey: "type_of_deletion")
        requestDict.setValue(true, forKey: "is_delete_transaction")
        
        deleteShipmentWebServiceCall(requestData: requestDict)
    }
    @IBAction func deleteShipmentCancelButtonPressed(_ sender: UIButton) {
        deleteShipmentPopupView.isHidden=true
    }
    
    
    
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InboundShipmentSearch") as! InboundShipmentSearchViewController
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
        controller.type = "INBOUND"
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
        let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "PPShipmentDownloadView") as! PPShipmentDownloadViewController

        if let uuid = dataDict["uuid"] as? String{
            controller.shipmentId = uuid
        }

        controller.type = "INBOUND"
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: {})
    }
    
    
    @IBAction func receivedAndVerifiedButtonPressed(_ sender: UIButton) {
        let dataDict = itemsList[sender.tag]
//        let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InboundShipmentStorageSelection") as! InboundShipmentStorageSelectionViewController
        if let uuid = dataDict["uuid"] as? String{
            controller.shipmentId = uuid
        }
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
                deliveryStatus = DeliveryStatusEnum.ALL.rawValue
            }else if btn.isSelected && btn.tag == 1{
                deliveryStatus = DeliveryStatusEnum.RECEIVED.rawValue
            }else if btn.isSelected && btn.tag == 2{
                deliveryStatus = DeliveryStatusEnum.SHIPPED.rawValue
            }
        }
        
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getInboundShipmentList()
        
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getInboundShipmentList()
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
    
    func deleteShipmentWebServiceCall(requestData:NSMutableDictionary){
        let appendStr = "Inbound/\(shipmentIdToDelete!)/delete"
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "deleteShipment", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if (responseDict["uuid"] as? String) != nil {
                        
                        self.shipmentUpdated()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Shipment deleted successfully".localized(), InViewC: self, isPop: false, isPopToRoot: false)
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
    
    
    func getInboundShipmentList() {
        let url = "?nb_per_page=100&sort_by_asc=false&sort_by=created_on&page=\(currentPage)&delivery_status=\(deliveryStatus)&\(appendStr)"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "InboundShipmentList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
    //MARK: - InboundShipmentSearchViewDelegate methods
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?) {
        filterButton.isSelected = false
        if searchDict != nil{
            self.searchDict = searchDict!
            if !self.searchDict.isEmpty {
                filterButton.isSelected = true
                if let txt = self.searchDict["DeliveryStatusForApi"] as? String,!txt.isEmpty{
                    self.deliveryStatus = self.searchDict["DeliveryStatusForApi"] as! String
                    if self.deliveryStatus=="all" {
                        for btn in typeButtons {
                            if btn.tag == 0 {
                                btn.isSelected = true
                            }else{
                                btn.isSelected = false
                            }
                        }
                    }else if self.deliveryStatus=="received"{
                        for btn in typeButtons {
                            if btn.tag == 1 {
                                btn.isSelected = true
                            }else{
                                btn.isSelected = false
                            }
                        }
                    }else if self.deliveryStatus=="shipped"{
                        for btn in typeButtons {
                            if btn.tag == 2 {
                                btn.isSelected = true
                            }else{
                                btn.isSelected = false
                            }
                        }
                    }else{
                        for btn in typeButtons {
                            btn.isSelected=false
                        }
                    }
                }
            }
        }
        
        self.appendStr = appendstr
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getInboundShipmentList()
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
        deliveryStatus = DeliveryStatusEnum.ALL.rawValue
    }
    //MARK: End
    
    //MARK: - InboundShipmentStorageSelectionDelegate
    func didSelectStorage(storage_uuid:String,shelf_uuid:String){
        print(storage_uuid)
        print(shelf_uuid)
    }
    
    func shipmentUpdated() {
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getInboundShipmentList()
    }

}

//MARK: - Tableview Delegate and Datasource
extension InboundShipmentListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "InboundShipmentListCell") as! InboundShipmentListCell
        let item = itemsList[indexPath.row]
        cell.deleteButton.isHidden = true
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
        
        dataStr = ""
        if let txt = item["delivery_status"] as? String,!txt.isEmpty{
            dataStr = txt
            if txt=="SHIPPED" {
                cell.receivedAndVerifiedButton.isHidden=false
                cell.receivedAndVerifiedViewHeightConstraint.constant=45
            }else{
                cell.receivedAndVerifiedButton.isHidden=true
                cell.receivedAndVerifiedViewHeightConstraint.constant=0
            }
        }else{
            cell.receivedAndVerifiedButton.isHidden=true
            cell.receivedAndVerifiedViewHeightConstraint.constant=0
        }
        cell.statusLabel.text = dataStr
        
        dataStr = ""
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        if let shipDate:String = item["ship_date"] as? String{
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
                    dataStr = po
                }
                cell.poNumberLabel.text = dataStr
                
                dataStr = ""
                if let order_number:String = firstTransaction["order_number"] as? String{
                    dataStr = order_number
                }
                cell.orderNumberLabel.text = dataStr
                
                dataStr = ""
                if let invoice_number:String = firstTransaction["invoice_number"] as? String{
                    dataStr = invoice_number
                }
                cell.invoiceNumberLabel.text = dataStr
                
                dataStr = ""
                if let release_number:String = firstTransaction["release_number"] as? String{
                    dataStr = release_number
                }
                cell.releaseNumberLabel.text = dataStr
           }
            
        }
        
        cell.downloadButton.tag = indexPath.row
        cell.detailsButton.tag = indexPath.row
        cell.receivedAndVerifiedButton.tag=indexPath.row
       
        cell.deleteButton.tag = indexPath.row
        
        cell.customView.layoutIfNeeded()
        return cell
    }
}

//MARK: - End

//MARK: - Tableview Cell
class InboundShipmentListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    
    
    @IBOutlet weak var tradingPartnerLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var poNumberLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var invoiceNumberLabel: UILabel!
    @IBOutlet weak var releaseNumberLabel: UILabel!
    @IBOutlet weak var shipDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    
    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet var receivedAndVerifiedButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet weak var receivedAndVerifiedViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        self.customView.setRoundCorner(cornerRadious: 10)
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}

//MARK: - End
