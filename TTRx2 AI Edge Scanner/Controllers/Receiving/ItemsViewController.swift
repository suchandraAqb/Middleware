//
//  ItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 24/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ItemsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var itemsButton: UIButton!
    
    var itemsList:Array<Any>?
    var shipmentId:String?
    var isfromSetLot:Bool!
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
    }
    //MARK: - End
    
    @IBAction func lotBreakdownButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)        
            if let dataDict:NSDictionary = self.itemsList?[sender.tag] as? NSDictionary{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingLotBreakDownVC") as! ReceivingLotBreakDownVC
            controller.productDict = dataDict
            controller.isfromSetLot = isfromSetLot
            self.navigationController?.pushViewController(controller, animated: false)
          
        }
    }
    
    @IBAction func viewSerialButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

        if let dataDict:NSDictionary = itemsList?[sender.tag] as? NSDictionary{
            if let uuid = dataDict["uuid"] as? String{
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialsView") as! SerialsViewController
                controller.shipmentId = shipmentId
                controller.itemUuid = uuid
                self.navigationController?.pushViewController(controller, animated: false)
                
            }
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return itemsList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        //cell.viewLotBreakDownButton.isHidden = true
        
        let dataDict:NSDictionary = itemsList?[indexPath.section] as! NSDictionary
        var dataStr:String = ""
        
        if let name = dataDict["name"]  as? String{
            dataStr = name
        }
        cell.productNameLabel.text = dataStr
        
        dataStr = ""
        
        if let quantity = dataDict["quantity"]  as? Int{
            dataStr = "\(quantity)"
        }
        
        cell.quantityLabel.text = dataStr
        
        dataStr = ""
        if let uuid = dataDict["uuid"]  as? String{
            dataStr = uuid
        }
        
        cell.udidValueLabel.text = dataStr
        
        dataStr = ""
        if let ndc = dataDict["ndc"]  as? String{
            dataStr = ndc
        }
        
        cell.ndcValueLabel.text = dataStr
        
        dataStr = ""
        
        if let sku = dataDict["sku"]  as? String{
            dataStr = sku
        }
        
        if let is_having_serial = dataDict["is_having_serial"] as? Bool{
            
            cell.viewSerialButton.isHidden = !is_having_serial
        }
        
        if let lots = dataDict["lots"] as? [[String:Any]],!lots.isEmpty{
            cell.lotQtyView.isHidden = true
            
            if let _ = lots.first(where: {$0["lot_number"] as? String == ""}){
                isfromSetLot = true
                cell.viewLotBreakDownButton.setTitle("Set Lot", for: .normal)
            }else{
                isfromSetLot = false
                cell.viewLotBreakDownButton.setTitle("View Lot Break Down", for: .normal)
            }
//            var i = 0
//            for lot in lots{
//                let view = LotDetailsView.instanceFromNib() as! LotDetailsView
//
//                if i == 0 {
//                    view.lotNoHeaderLabel.isHidden = false
//                    view.lotQuantityHeaderLabel.isHidden = false
//                }else{
//                    view.lotNoHeaderLabel.isHidden = true
//                    view.lotQuantityHeaderLabel.isHidden = true
//                }
//
//
//                if let lot_number = lot["lot_number"] as? String{
//                    view.lotNoLabel.text = lot_number
//                }
//
//                if let qty = lot["quantity"] as? Int{
//                    view.lotQuantity.text = "\(qty)"
//                }
//
//                cell.lotQtyStackView.addArrangedSubview(view)
//                i+=1
//            }
            
        }else{
            cell.lotQtyView.isHidden = true
        }
        
        
        cell.skuValueLabel.text = dataStr
        cell.viewSerialButton.tag = indexPath.section
        cell.viewLotBreakDownButton.tag = indexPath.section
        return cell
        
    }
    //MARK: - End
}
