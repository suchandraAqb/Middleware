//
//  ReceivingLotBreakDownVC.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 24/03/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData

class SippingLineItemDataModel{
    
    public var is_having_serial: Bool?
    public var maxQuantity: Int?
    public var name: String?
    public var shipment_line_item_uuid: String?
    public var uuid: String?
    public var lots: Array<LotDataModel>?
    
    init(is_having_serial: Bool?, maxQuantity: Int?, name: String?, shipment_line_item_uuid: String?, uuid: String?, lots: Array<LotDataModel>?) {
        
        self.is_having_serial = is_having_serial
        self.maxQuantity = maxQuantity
        self.name = name
        self.shipment_line_item_uuid = shipment_line_item_uuid
        self.uuid = uuid
        self.lots = lots
    }
}
class LotDataModel{
    
    public var quantity: Int?
    public var lot_number: String?
    public var expiration_date: String?
    public var production_date: String?
    public var best_by_date: String?
    public var sell_by_date: String?
    
    
    init(quantity: Int?, lot_number: String?, expiration_date: String?, production_date: String?, best_by_date: String?, sell_by_date: String?) {
        
        self.quantity = quantity
        self.lot_number = lot_number
        self.expiration_date = expiration_date
        self.production_date = production_date
        self.best_by_date = best_by_date
        self.sell_by_date = sell_by_date
    }
}

class ReceivingLotBreakDownVC: BaseViewController {
    
    @IBOutlet weak var addLotButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var heightConsAddLot: NSLayoutConstraint!
    @IBOutlet weak var btnHeader: UIButton!
    
    public var arrLotListData : Array<LotDataModel>?{
        didSet{
            ////50
            if isfromSetLot {
                self.heightConsAddLot.constant = 50
            }else{
                self.heightConsAddLot.constant = self.arrLotListData?.count ?? 0 == 0 ? 0 : 0
            }
            self.listTable.reloadData()
        }
    }
    
    public var shippingLineItemData : SippingLineItemDataModel?
    public var localTableData : Array<ReceiveLotEdit>?{
        didSet{
            self.listTable.reloadData()
        }
    }
    
    var productDict:NSDictionary?
    var remainingquantity:Int = 0
    public var isLotBased = false
    var totalQty:Int = 0
    var qtyAdded:Int = 0
    var isfromSetLot:Bool!
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        addLotButton.setRoundCorner(cornerRadious: addLotButton.frame.size.height/2.0)
        self.saveData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        totalQty = productDict!["quantity"] as! Int
        qtyAdded = 0
        self.fetchFromLocalDB()
    }
    //MARK: - Save Data To Array
    private func saveData(){
        if let dictData = productDict{
            
            if let lotItems = dictData["lots"] as? Array<NSDictionary>{
                
                for item in lotItems{
                    
                    var lotNumber = ""
                    var qty = 0
                    var expDate = ""
                    var prod_date = ""
                    var best_by_date = ""
                    var sell_by_date = ""
                    
                    if let txt = item["lot_number"] as? String,!txt.isEmpty{
                        lotNumber = txt
                    }
                    
                    if let txt = item["quantity"] as? NSNumber{
                        qty = txt.intValue
                    }
                    
                    if let txt = item["expiration_date"] as? String,!txt.isEmpty{
                        expDate = txt
                    }
                    
                    if let txt = item["best_by_date"] as? String,!txt.isEmpty{
                        best_by_date = txt
                    }
                    
                    if let txt = item["production_date"] as? String,!txt.isEmpty{
                        prod_date = txt
                    }
                    if let txt = item["sell_by_date"] as? String,!txt.isEmpty{
                        sell_by_date = txt
                    }
                    
                    if self.arrLotListData == nil{
                        self.arrLotListData = [LotDataModel(quantity: qty, lot_number: lotNumber, expiration_date: expDate, production_date: prod_date, best_by_date: best_by_date, sell_by_date: sell_by_date)]
                    }else{
                        self.arrLotListData?.append(LotDataModel(quantity: qty, lot_number: lotNumber, expiration_date: expDate, production_date: prod_date, best_by_date: best_by_date, sell_by_date: sell_by_date))
                    }
                    if isfromSetLot {
                        arrLotListData?.removeAll()
                    }
                }
            }
            
            var is_having_serial = Bool()
            var maxQuantity = Int()
            var name = String()
            var shipment_line_item_uuid = String()
            var uuid = String()
            
            if let txt = dictData["is_having_serial"] as? Bool{
                is_having_serial = txt
            }
            if let txt = dictData["quantity"] as? Int{
                maxQuantity = txt
            }
            if let txt = dictData["name"] as? String{
                name = txt
            }
            if let txt = dictData["shipment_line_item_uuid"] as? String{
                shipment_line_item_uuid = txt
            }
            if let txt = dictData["uuid"] as? String{
                uuid = txt
            }
            
            self.shippingLineItemData = SippingLineItemDataModel(is_having_serial: is_having_serial, maxQuantity: maxQuantity, name: name, shipment_line_item_uuid: shipment_line_item_uuid, uuid: uuid, lots: self.arrLotListData)
            
            
        }
    }
    
    //MARK: - Save Data For Lot Breakdown
    private func fetchFromLocalDB(){
        do {
            let fetchRequest = NSFetchRequest<ReceiveLotEdit>(entityName: "ReceiveLotEdit")
            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
            if !serial_obj.isEmpty {
                let arr = serial_obj as NSArray
                let str = (shippingLineItemData?.shipment_line_item_uuid)!
                let predicate = NSPredicate(format: "shipment_line_item_uuid = '\(str)'")
                let filterArr  = arr.filtered(using: predicate)
                if filterArr.count>0{
                    self.localTableData = filterArr as? Array<ReceiveLotEdit>
                    //.filter({$0.shipment_line_item_uuid == self.shippingLineItemData?.shipment_line_item_uuid})
                }else{
                    self.localTableData = []
                }
            }else{
                self.localTableData = serial_obj
            }
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    //MARK: - Action
    @IBAction func addLotButtonPressed(_ sender: UIButton) {
        if totalQty == qtyAdded && (remainingquantity<=0){
            Utility.showPopup(Title: App_Title, Message: "Sum of all lot's quantity can not be greater than prevoius quantity", InViewC: self)
            return
        }
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingEditLotVC") as! ReceivingEditLotVC

      //  if self.localTableData == nil{

           // let dictData = self.arrLotListData?[sender.tag]
            controller.isAdd = true
            controller.isLotBased = self.isLotBased
            controller.remainingquantity = totalQty - qtyAdded
            controller.shippingLineItemData = self.shippingLineItemData

        //}
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        if !isfromSetLot {
            return
        }
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingEditLotVC") as! ReceivingEditLotVC
        //controller.remainingquantity = remainingquantity
        
//        if let dicaData = self.arrLotListData?[sender.tag]{
//            
//            controller.editData = dicaData
//        }
        
        if !(self.localTableData?.isEmpty ?? false){
            if let dicaData = self.localTableData?[sender.tag]{
                controller.editLocalDBData = dicaData
            }
        }
        controller.isLotBased = self.isLotBased
        controller.isAdd = false
        controller.shippingLineItemData = self.shippingLineItemData
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let msg = "You are about to delete the resource.".localized() + "\n" + "This operation can’t be undone.".localized() + "\n\n" + "Proceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            //            if let dict = self.itemsList![sender.tag] as? NSDictionary {
            //                self.removeLot(data: dict)
            //            }
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }

}


//MARK: - Tableview Delegate and Datasource
extension ReceivingLotBreakDownVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.localTableData?.count ?? 0 == 0 ? self.arrLotListData?.count ?? 0 : self.localTableData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        
        let cell = listTable.dequeueReusableCell(withIdentifier: "MISProductLotCell") as! MISProductLotCell
        
        if self.localTableData?.count == 0{
            
            let dictData = self.arrLotListData?[indexPath.row]
            
            cell.lotLabel.text = dictData?.lot_number
            
            cell.quantityLabel.text = dictData?.quantity?.description
            
            cell.expirationDateLabel.text = dictData?.expiration_date
            
            cell.btnEditExpDate?.isHidden = dictData?.expiration_date == nil || dictData?.expiration_date == "" ? false : true
            
            cell.btnEditLot?.isHidden = dictData?.lot_number == nil || dictData?.lot_number == "" ? false : true
            
            cell.editButton?.tag = indexPath.row
            cell.deleteButton?.tag = indexPath.row
            
        }else{
            
            let dictData = self.localTableData?[indexPath.row]
           // let dictArrData = self.arrLotListData?[indexPath.row]
            
            cell.lotLabel.text = dictData?.lot_number
            
            
            cell.quantityLabel.text = dictData?.quantity.description
            qtyAdded = qtyAdded +  Int(dictData!.quantity) as Int
            cell.expirationDateLabel.text = dictData?.expiration_date
            
            
            cell.btnEditLot?.isHidden = false//dictArrData?.lot_number == nil || dictArrData?.lot_number == "" ? false : true
            cell.btnEditExpDate?.isHidden = false//dictArrData?.expiration_date == nil || dictArrData?.expiration_date == "" ? false : true
            
            cell.editButton?.tag = indexPath.row
            cell.deleteButton?.tag = indexPath.row
        }
        
        return cell
    }
}

