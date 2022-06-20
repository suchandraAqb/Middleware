//
//  SFSerialDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 06/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

let SerialStatus = ["INBOUND_SHIPMENT_NOT_ACCEPTED" : "IN Shipment Not Accepted","IN_INVENTORY" : "In Inventory","DESTRUCTED" : "Destructed","DISPENSED" : "Dispensed","IN_QUARANTINE" : "In Quarantine","NOT_IN_INVENTORY" : "Not In Inventory","TRANSFORMED" : "Transformed","LOCKED" : "Locked", "INBOUND_SHIPMENT_NOT_RECEIVED" : "Inbound Shipment Not Received"]//,,,sb10

let EventStatus = ["INBOUND_SHIPMENT_DATA_RECEIVED" : "Inbound Shipment Data Received","INBOUND_SHIPMENT_ACCEPTED" : "Inbound Shipment Accepted","INBOUND_SHIPMENT_DECLINED" : "Inbound Shipment Declined","QUARANTINE" : "Item placed in Quarantine","UNQUARANTINE" : "Item removed from Quarantine","TRANSFER" : "Internal Item Transfer","DESTRUCTION" : "Item Destroyed","DISPENSED" : "Item Dispensed","TRANSFORMED" : "Item Transformed","SALES_ORDER_SHIPPED" : "Item Shipped for a sales order (Outbound)","RETURN_RECEIVED" : "Item Received for a Return.","AGGREGATION" : "Item aggregated to a container","DISAGGREGATION" : "Item disaggregated from a container"]

class SFSerialDetailsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var toggleButton1: UIButton!
    @IBOutlet weak var toggleButton2: UIButton!
    @IBOutlet weak var toggle1BorderView: UIView!
    @IBOutlet weak var toggle2BorderView: UIView!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventListTable: UITableView!
    
    
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var itemTypeButton: UIButton!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var lotNoLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mfgLabel: UILabel!
    @IBOutlet weak var expDateLabel: UILabel!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var storageNameLabel: UILabel!
    @IBOutlet weak var shelfNameLabel: UILabel!
    @IBOutlet weak var businessStepLabel: UILabel!
    @IBOutlet weak var dispositionLabel: UILabel!
    
    var eventLogList = [[String:Any]]()
    var serialDetails = [String:Any]()
    var isSelected1stView = true
    var serial = ""
    var simple_serial = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        eventView.roundTopCorners(cornerRadious: 40)
        detailsContainerView.setRoundCorner(cornerRadious: 10)
        setup_view()
        getSerialDetails()
    }
    //MARK:- End
    
    
    //MARK:- Custom Method
    func setup_view(){
        serialLabel.text = simple_serial
        if isSelected1stView {
            toggleButton1.isUserInteractionEnabled = false
            toggleButton2.isUserInteractionEnabled = true
            toggleButton1.setTitleColor(UIColor.white, for: .normal)
            toggle1BorderView.isHidden = false
            toggleButton2.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle2BorderView.isHidden = true
            eventView.isHidden = true
        }else{
            toggleButton1.isUserInteractionEnabled = true
            toggleButton2.isUserInteractionEnabled = false
            toggleButton1.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle1BorderView.isHidden = true
            toggleButton2.setTitleColor(UIColor.white, for: .normal)
            toggle2BorderView.isHidden = false
            eventView.isHidden = false
            
        }
        
    }
    func getSerialDetails(){
        let str = serial.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let appendStr = "serial_detail?serial_type=GS1_SERIAL&serial=\(str ?? "")"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "SerialFinder", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let responseDict = responseData as? [String:Any]{
                        self.serialDetails = responseDict
                        self.populateSerialDetails()
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
    
    func populateSerialDetails(){
        
        var dataStr = ""
        
        if let txt = serialDetails["type"] as? String,txt == "CONTAINER"{
            dataStr = "Container"
            itemTypeButton.setImage(UIImage(named: "serial_container.png"), for: .normal)
        }else{
            itemTypeButton.setImage(UIImage(named: "overlay_product.png"), for: .normal)
            if let txt = serialDetails["product_name"] as? String{
                dataStr = txt
            }
        }
        itemNameLabel.text = dataStr
        
        dataStr = ""
        if let txt = serialDetails["lot_number"] as? String{
            dataStr = txt
        }
        lotNoLabel.text = dataStr
        
        dataStr = ""
        if let txt = serialDetails["inventory_status"] as? String{
            dataStr = SerialStatus[txt] ?? ""
        }
        statusLabel.text = dataStr
        
        dataStr = ""
        if let txt = serialDetails["production_date"] as? String{
            dataStr = txt
        }
        mfgLabel.text = dataStr
        
        dataStr = ""
        if let txt = serialDetails["expiration_date"] as? String{
            dataStr = txt
        }
        expDateLabel.text = dataStr
        
        dataStr = ""
        if let txt = serialDetails["location_name"] as? String{
            dataStr = txt
        }
        locationNameLabel.text = dataStr.capitalized
        
        dataStr = ""
        if let txt = serialDetails["storage_area_name"] as? String{
            dataStr = txt
        }
        storageNameLabel.text = dataStr.capitalized
        
        dataStr = ""
        if let txt = serialDetails["storage_shelf_name"] as? String{
            dataStr = txt
        }
        shelfNameLabel.text = dataStr.capitalized
        
        dataStr = ""
        if let txt = serialDetails["business_step_name"] as? String{
            dataStr = txt
        }
        businessStepLabel.text = dataStr.capitalized
        
        dataStr = ""
        if let txt = serialDetails["disposition_name"] as? String{
            dataStr = txt.capitalized
        }
        dispositionLabel.text = dataStr
        
        if let events = serialDetails["events_list"] as? [[String:Any]]{
            eventLogList = events
            eventListTable.reloadData()
        }
        
        
    }
    
    func populateEventDateandTime(date:String?,time:String?)->NSAttributedString{
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        let timeString = NSMutableAttributedString(string:time ?? "", attributes: custAttributes)
        
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let dateStr = NSAttributedString(string: "\n" + (date ?? ""), attributes: custTypeAttributes)
        timeString.append(dateStr)
        
        return timeString
        
    }
    //MARK:- End
    
    
    @IBAction func toggleButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            toggleButton1.isUserInteractionEnabled = false
            toggleButton2.isUserInteractionEnabled = true
            toggleButton1.setTitleColor(UIColor.white, for: .normal)
            toggle1BorderView.isHidden = false
            toggleButton2.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle2BorderView.isHidden = true
            eventView.isHidden = true
        }else{
            toggleButton1.isUserInteractionEnabled = true
            toggleButton2.isUserInteractionEnabled = false
            toggleButton1.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle1BorderView.isHidden = true
            toggleButton2.setTitleColor(UIColor.white, for: .normal)
            toggle2BorderView.isHidden = false
            eventView.isHidden = false
        }
        
    }
    
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
       let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        return view
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventLogList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventLogCell") as! EventLogCell
        
        
        let dataDict = eventLogList[indexPath.row]
        
        var dataStr = ""
        
        if let txt = dataDict["timestamp"] as? String{
            let timeStr = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: stdTimeFormat, dateStr: txt)
            
            let dateStr = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MM-dd-yyyy", dateStr: txt)
            
            cell.eventTimeLabel.attributedText = populateEventDateandTime(date: dateStr, time: timeStr)
        }else{
            cell.eventTimeLabel.text = dataStr
        }
        
        
        
        dataStr = ""
        
        if let txt = dataDict["event_code"] as? String{
            dataStr = txt
            if let str = EventStatus[txt]{
               dataStr = str
            }
        }
        
        cell.eventButton.setTitle(dataStr.capitalized, for: .normal)
        cell.eventButton.setRoundCorner(cornerRadious: 5)
        
        
        
        if indexPath.row + 1 == eventLogList.count {
            cell.bottomView.isHidden = true
        }else{
            cell.bottomView.isHidden = false
        }
        
        
        return cell
        
        
        
        
    }
    
    //MARK: - End
    
    
    
    
}

class EventLogCell: UITableViewCell {
    
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

