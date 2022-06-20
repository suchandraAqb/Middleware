//
//  ViewLotViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 23/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ViewLotViewController: BaseViewController {
    
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lotNumberLabel: UILabel!
    @IBOutlet weak var ndcLabel: UILabel!
    @IBOutlet weak var productionDateLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var sellByDateLabel: UILabel!
    @IBOutlet weak var bestByDateLabel: UILabel!
    
    @IBOutlet weak var inboundShipmentButton: UIButton!
    @IBOutlet weak var outboundShipmentButton: UIButton!
    
    var lotDetailsDict = [String:Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.setRoundCorner(cornerRadious: 10)
        
        inboundShipmentButton.setRoundCorner(cornerRadious: inboundShipmentButton.frame.size.height/2.0)
        outboundShipmentButton.setRoundCorner(cornerRadious: outboundShipmentButton.frame.size.height/2.0)
        populateLotDetails()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Action
    
    @IBAction func viewInventoryButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotInventoryView") as! LotInventoryViewController
        if let txt = lotDetailsDict["product_uuid"] as? String,!txt.isEmpty{
            controller.productUuid = txt
        }
        if let txt = lotDetailsDict["lot_number"] as? String,!txt.isEmpty{
            controller.lotNumber = txt
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewInventoryLocationButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotInventoryLocationView") as! LotInventoryLocationViewController
        if let txt = lotDetailsDict["product_uuid"] as? String,!txt.isEmpty{
            controller.productUuid = txt
        }
        if let txt = lotDetailsDict["lot_number"] as? String,!txt.isEmpty{
            controller.lotNumber = txt
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func inboundShipmentButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentListView") as! ShipmentListViewController
        if let txt = lotDetailsDict["product_uuid"] as? String,!txt.isEmpty{
            controller.productUuid = txt
        }
        if let txt = lotDetailsDict["lot_number"] as? String,!txt.isEmpty{
            controller.lotNumber = txt
        }
        controller.shipmentType = "Inbound"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func outboundShipmentButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentListView") as! ShipmentListViewController
        if let txt = lotDetailsDict["product_uuid"] as? String,!txt.isEmpty{
            controller.productUuid = txt
        }
        if let txt = lotDetailsDict["lot_number"] as? String,!txt.isEmpty{
            controller.lotNumber = txt
        }
        controller.shipmentType = "Outbound"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
   
    //MARK: End
    
    //MARK Privae method
    func populateLotDetails() {
        if !lotDetailsDict.isEmpty {
            var dataStr = ""
            if let txt = lotDetailsDict["product_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            titleLabel.text = dataStr

            dataStr = ""
            if let txt = lotDetailsDict["lot_number"] as? String,!txt.isEmpty{
                if lotDetailsDict["lot_type"]as? String == "SERIAL_BASED"{
                    dataStr = "SB: \(txt)"
                }else{
                    dataStr = "LB: \(txt)"
                }
            }
            lotNumberLabel.text = dataStr
            
            dataStr = ""
            if let txt = lotDetailsDict["product_ndc"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            ndcLabel.text = dataStr
            
            
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            dataStr = ""
            if let txt = lotDetailsDict["lot_production_date"] as? String,!txt.isEmpty{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: txt){
                    dataStr = formattedDate
                }
            }
            productionDateLabel.text = dataStr

            dataStr = ""
            if let txt = lotDetailsDict["lot_expiration"] as? String,!txt.isEmpty{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: txt){
                    dataStr = formattedDate
                }
            }
            expirationDateLabel.text = dataStr

            dataStr = ""
            if let txt = lotDetailsDict["lot_sell_by"] as? String,!txt.isEmpty{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: txt){
                    dataStr = formattedDate
                }
            }
            sellByDateLabel.text = dataStr

            dataStr = ""
            if let txt = lotDetailsDict["lot_best_by"] as? String,!txt.isEmpty{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: txt){
                    dataStr = formattedDate
                }
            }
            bestByDateLabel.text = dataStr
        }
    }
    //MARK: - End

}
