//
//  ReturnShipmentList.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 09/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnShipmentList: BaseViewController {

    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var disPatchGroup = DispatchGroup()
    var searchDict = [String:Any]()
    var product_uuid = String()
    var productName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        self.listTable.delegate = self
        self.listTable.dataSource = self
        loadMoreFooterView()
        getShipmentListWithQueryParam(product_uuid: product_uuid)
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
            // print("itemsList: \(self.itemsList)")
            self.listTable.reloadData()
        }
        
    }
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Return", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "ReturnShipmentSearch") as! ReturnShipmentSearch
        controller.delegate = self
        controller.searchDict = self.searchDict
        controller.productName = self.productName
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func productTapped(_ sender: UIButton) {
        let items = itemsList[sender.tag]
        print("RETURN UUID::", items["uuid"] as? String ?? "Error finding uuid")
        self.searchShipmentForReturns(serial: items["uuid"] as? String ?? "")
    }
    
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
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getShipmentListWithQueryParam(product_uuid: product_uuid)
    }
    
    
    //MARK: - Post Return
    func searchShipmentForReturns(serial : String){
        self.showSpinner(onView: self.view)
        if !serial.isEmpty{
            var requestDict = [String:Any]()
            requestDict["source_type"] = "SHIPMENT_UUID"
            requestDict["shipment_uuid"] = serial
            
            Utility.POSTServiceCall(type: "SearchShipmentForReturns", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                        if let uuid = responseDict["uuid"] as? String{
                            let storyboard = UIStoryboard(name: "Return", bundle: .main)
                            let controller = storyboard.instantiateViewController(withIdentifier: "OutboundShipmentDetailsView") as! OutboundShipmentDetailsViewController
                            controller.returnUuid = uuid
                            
                            if let source_shipment = responseDict["source_shipment"] as? NSDictionary {
                                controller.outboundShipment = source_shipment
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
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
    
    func getShipmentListWithQueryParam(product_uuid: String) {
        
        let url = "?nb_per_page=10&\(appendStr)&sort_by_asc=false&page=\(currentPage)&_=\(Date().currentTimeMillis())&product_uuid=\(product_uuid)"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "OutboundShipments", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
                        let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
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

extension ReturnShipmentList: SearchViewDelegate{
    
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
        getShipmentListWithQueryParam(product_uuid: product_uuid)
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
    }
}

extension ReturnShipmentList: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReturnShipmentCell", for: indexPath) as! ReturnShipmentCell
        
        //cell.selectButton.tag = indexPath.row
        //let indexData = self.listDB?.data?[indexPath.row]
        let item = itemsList[indexPath.row]
        cell.selectButton.tag = indexPath.row
        
        cell.lblproductCount.text = (item["items_count"] as? Int)?.description
        
        let tradingPartner = item["trading_partner"] as? NSDictionary
        cell.lblName.text = tradingPartner?["name"] as? String
        cell.lblShipDate.text = item["shipment_date"] as? String
        cell.lblTrxDate.text = item["shipment_date"] as? String
        
        let billingAdd = item["billing_address"] as? NSDictionary
        
        var soldToAdd = ""
        if let line1 = billingAdd?["line1"] as? String{
            soldToAdd = line1
        }
        if let line2 = billingAdd?["line2"] as? String{
            soldToAdd = "\(soldToAdd), \(line2)"
        }
//        if let line3 = billingAdd?["line3"] as? String{
//            soldToAdd = "\(soldToAdd), \(line3)"
//        }
//        if let line4 = billingAdd?["line4"] as? String{
//            soldToAdd = "\(soldToAdd), \(line4)"
//        }
        if let city = billingAdd?["city"] as? String{
            soldToAdd = "\(soldToAdd), \(city)"
        }
        if let state_name = billingAdd?["state_name"] as? String{
            soldToAdd = "\(soldToAdd), \(state_name)"
        }
        
        if let country_name = billingAdd?["country_name"] as? String{
            soldToAdd = "\(soldToAdd), \(country_name)"
        }
        cell.lblSoldTo.text = soldToAdd

        
        
        let shipping_address = item["shipping_address"] as? NSDictionary
        var shipToAdd = ""
        
        if let line1 = shipping_address?["line1"] as? String{
            shipToAdd = line1
        }
        if let line2 = shipping_address?["line2"] as? String{
            shipToAdd = "\(shipToAdd), \(line2)"
        }
//        if let line3 = shipping_address?["line3"] as? String{
//            shipToAdd = "\(shipToAdd), \(line3)"
//        }
//        if let line4 = shipping_address?["line4"] as? String{
//            shipToAdd = "\(shipToAdd), \(line4)"
//        }
        if let city = shipping_address?["city"] as? String{
            shipToAdd = "\(shipToAdd), \(city)"
        }
        if let state_name = shipping_address?["state_name"] as? String{
            shipToAdd = "\(shipToAdd), \(state_name)"
        }
        
        if let country_name = shipping_address?["country_name"] as? String{
            shipToAdd = "\(shipToAdd), \(country_name)"
        }
        cell.lblShipTo.text = shipToAdd
        
        
        return cell
    }
    
}

class ReturnShipmentCell: UITableViewCell {
    
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var lblTrxDate: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblShipDate: UILabel!
    @IBOutlet var lblSoldTo: UILabel!
    @IBOutlet var lblShipTo: UILabel!
    @IBOutlet var lblproductCount: UILabel!
    @IBOutlet var selectButton: UIButton!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
