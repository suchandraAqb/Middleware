//
//  ShipmentsListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 07/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ShipmentsListViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate,ConfirmationViewDelegate {

    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var shipmentCountLabel: UILabel!
    var itemsList: [[String: Any]] = []
    var selectedShipment:NSDictionary?
    var loadMoreButton = UIButton()
    var currentPage = 1
    var totalResult = 0
    var appendStr = ""
    var isfromSearchmanually:Bool!

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shipmentCountLabel.text = "0 " + "found".localized()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        if !itemsList.isEmpty{
            self.shipmentCountLabel.text = "\(self.itemsList.count) " + "found".localized()
        }else{
            loadMoreFooterView()
            getShipmentListWithQueryParam(appendStr: self.appendStr)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
    }
    //MARK: - End
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        print("ddd")
        if currentPage != totalResult {
            currentPage += 1
            sender.isUserInteractionEnabled = false
            getShipmentListWithQueryParam(appendStr:appendStr)
        }
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
    
    
    func getShipmentListWithQueryParam(appendStr:String){
        let url = appendStr + "sort_by_asc=false&sort_by=ship_date&nb_per_page=100&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ShipmentDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
              self.removeSpinner()
              if isDone! {
                  if let responseDict = responseData as? [String: Any] {
                      self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                      if let dataArray = responseDict["data"] as? [[String: Any]] {
                          self.itemsList += dataArray
                          self.listTable.reloadData()
                      }
                    
                    self.shipmentCountLabel.text = "\(self.totalResult) " + "found".localized()
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
    
    //MARK: - IBAction
    @IBAction func selectShipmentButtonPressed(_ sender: UIButton) {
       
        let data = itemsList[sender.tag]
        selectedShipment = data as NSDictionary
        
       let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Do you want to receive this shipment?".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
       
    }
    //MARK: - End
    
    //MARK: - Private Method
    //MARK: - End
    
    //MARK: - Tableview Delegate and Datasource
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
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return itemsList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShipmentListCell") as! ShipmentListCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        let dataDict = itemsList[indexPath.section]
        
        var dataStr:String = ""
        
        if let uuid = dataDict["uuid"] as? String{
            dataStr = uuid
        }
        
        
        cell.uuidLabel.text = dataStr
        
        dataStr = ""
        
        if let tpName = dataDict["trading_partner_name"] as? String{
            dataStr = tpName
        }
        
        cell.tpLabel.text = dataStr
        
        if let transactions:Array<Any> = dataDict["transactions"] as? Array<Any>{
            
            if transactions.count>0{
                let firstTransaction:NSDictionary = transactions.first as? NSDictionary ?? NSDictionary()
                
                if let po:String = firstTransaction["po_number"] as? String{
                    cell.poNoLabel.text = po
                }
                
                
                if let order_number:String = firstTransaction["order_number"] as? String{
                    cell.orderNoLabel.text = order_number
                }
                
                if let release_number:String = firstTransaction["release_number"] as? String{
                    cell.releaseNoLabel.text = release_number
                }
                
                
                if let invoice_number:String = firstTransaction["invoiceNumberLabel"] as? String{
                    cell.invoiceNumberLabel.text = invoice_number
                }
            
                
                let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
                
                if let shipDate:String = firstTransaction["date"] as? String{
                    if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                        cell.shipDateLabel.text = formattedDate
                    }
                }
            }
        }
        
        cell.selectButton.tag = indexPath.section
        return cell
        
    }
    //MARK: - End
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        if selectedShipment != nil{
            
            if let uuid = selectedShipment!["uuid"] as? String{
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentDetailsView") as! ShipmentDetailsViewController
                controller.shipmentId = uuid
                controller.isfromSearchmanually = isfromSearchmanually
                self.navigationController?.pushViewController(controller, animated: true)
                
            }
            
        }
       
        
    }
    func cancelButtonPressed() {
        selectedShipment = nil
    }
    //MARK: - End
    

}

class ShipmentListCell: UITableViewCell
{
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var tpLabel: UILabel!
    @IBOutlet weak var poNoLabel: UILabel!
    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var releaseNoLabel: UILabel!
    @IBOutlet weak var shipDateLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var invoiceNumberLabel:UILabel!
    override func awakeFromNib() {
        Utility.UpdateUILanguage(multiLingualViews)
    }
}
