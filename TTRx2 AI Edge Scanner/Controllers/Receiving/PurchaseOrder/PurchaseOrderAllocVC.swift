//
//  PurchaseOrderAllocVC.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 19/05/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData
class PurchaseOrderAllocVC: BaseViewController, ConfirmationViewDelegate {
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblPO: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCustoOrderNo: UILabel!
    
    public var ship_lines_item: [[String: Any]] = []
    public var line_items: [[String: Any]] = []
    
    public var dictPo: [String: Any]?
    public var localTableData : Array<ReceiveLineItem>? = nil
    
    public var editSessionData : [[String: Any]] = []
    private var isEdittingOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        
        if let po = dictPo{
            
            self.lblPO.text = po["po_number"] as? String
            self.lblDate.text = po["date"] as? String
            self.lblCustoOrderNo.text = po["order_number"] as? String
            self.line_items = po["line_items"] as? [[String: Any]] ?? [[String: Any]]()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchFromLocalDB()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        
    }
    //MARK: - Private Methods
    private func fetchFromLocalDB(){
        do {
            
            let fetchRequest = NSFetchRequest<ReceiveLineItem>(entityName: "ReceiveLineItem")
            
            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
            
            self.localTableData = serial_obj.filter({$0.po_no == self.dictPo?["po_number"] as? String ?? ""})
            
            if self.localTableData?.count == 0 {
                
                for i in 0..<ship_lines_item.count{
                    
                    var data = Int()
                    
                    if let quantity = self.ship_lines_item[i]["unallocated_quantity"] as? Int{
                        
                        data = quantity
                        
                    }
                    
                    let numberFormatter = NumberFormatter()
                    numberFormatter.locale = Locale(identifier: "en_US")
                    
                    let update_qty = (numberFormatter.number(from: self.line_items[i]["quantity"] as? String ?? ""))?.intValue ?? 0
                    
                    self.ship_lines_item[i].updateValue(update_qty, forKey: "quantity")
                    
                    self.ship_lines_item[i].updateValue(update_qty, forKey: "allocated_quantity")

                    let update_uuid = self.line_items[i]["uuid"] as? String ?? ""
                    
                    self.ship_lines_item[i].updateValue(update_uuid, forKey: "shipment_line_item_uuid")
                }
                self.editSessionData = self.ship_lines_item
                
            }else{
                
                self.editSessionData = []
                self.localTableData?.forEach({ item in
                    
                    let dictValues = ["unallocated_quantity": Int(item.unalloc_quantity),
                                      "name": item.productName ?? "",
                                      "ndc": item.ndc ?? "",
                                      "gtin14": item.gtin14 ?? "",
                                      "quantity": Int(item.quantity),
                                      "allocated_quantity":Int(item.alloc_quantity),
                                      "shipment_line_item_uuid": item.shipment_line_item_uuid ?? ""] as [String : Any]
                    self.editSessionData.append(dictValues)
                })
            }
            
            self.tblList.reloadData()
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func updateLineItem(index: Int, qty: Int){
        
        isEdittingOn = true
        
        if self.localTableData?.count == 0{
            
            let unalloc_qty = self.ship_lines_item[index]["unallocated_quantity"] as? Int ?? 0
            let alloc_qty = self.ship_lines_item[index]["allocated_quantity"] as? Int ?? 0
            let total_qty = self.ship_lines_item[index]["quantity"] as? Int ?? 0
            
//            if qty <= total_qty{
                
                if qty == unalloc_qty{
                    
                    self.editSessionData[index].updateValue(qty, forKey: "allocated_quantity")
                    //self.editSessionData[index].updateValue(0, forKey: "unallocated_quantity")
                    
                }else if qty < unalloc_qty{
                    
                    self.editSessionData[index].updateValue(qty, forKey: "allocated_quantity")
                    
                    //let updt_unalloc = unalloc_qty - qty
                    
                    //self.editSessionData[index].updateValue(updt_unalloc, forKey: "unallocated_quantity")
                    
                }else{
                    
//                    if qty == total_qty {
//
//                        if unalloc_qty != 0{
//
//                            let updated_unalloc = total_qty - qty
//                            self.editSessionData[index].updateValue(qty, forKey: "allocated_quantity")
//                            self.editSessionData[index].updateValue(updated_unalloc, forKey: "unallocated_quantity")
//
//                        }else{
//
//                        }
//                    }
                }
//            }
            
        }else{
            
            let unalloc_qty = Int(self.localTableData?[index].unalloc_quantity ?? 0)
            let alloc_qty = Int(self.localTableData?[index].alloc_quantity ?? 0)
            let total_qty = Int(self.localTableData?[index].quantity ?? 0)
            
            //            if qty <= total_qty{
            
            if qty == unalloc_qty{
                
                if unalloc_qty == 0{
                    
                    self.editSessionData[index].updateValue(0, forKey: "allocated_quantity")
                    //self.editSessionData[index].updateValue(alloc_qty, forKey: "unallocated_quantity")
                }else{
                    self.editSessionData[index].updateValue(qty, forKey: "allocated_quantity")
                    //self.editSessionData[index].updateValue(0, forKey: "unallocated_quantity")
                }
                
                
            }else if qty < unalloc_qty{
                
                self.editSessionData[index].updateValue(qty, forKey: "allocated_quantity")
                
//                let updt_unalloc = unalloc_qty - qty
//                self.editSessionData[index].updateValue(updt_unalloc, forKey: "unallocated_quantity")
            }else{
                
                //                    if qty == total_qty {
                //
                //                        if unalloc_qty != 0{
                //
                //                            let updated_unalloc = total_qty - qty
                //                            self.editSessionData[index].updateValue(qty, forKey: "allocated_quantity")
                //                            self.editSessionData[index].updateValue(updated_unalloc, forKey: "unallocated_quantity")
                //
                //                        }else{
                //
                //                        }
                //                    }
            }
            //            }
        }
        self.tblList.reloadData()
    }
    
    //MARK: - ConfirmationViewDelegate
    @objc func doneButtonPressed() {
        
    }
    
    func cancelConfirmation() {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
    @IBAction func backPressed(_ sender: UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to cancel editing".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func updateProductCount(_ sender: UIButton){
        
        let popUpAlert = UIAlertController(title: "", message: "Update quantity".localized(), preferredStyle: .alert)
        var addedTextField = UITextField()
        popUpAlert.addTextField { (textField : UITextField!) -> Void in
            
            addedTextField = textField
            
            if self.isEdittingOn{
                
                textField.text = (self.editSessionData[sender.tag]["allocated_quantity"] as? Int ?? 0).description
                
            }else{
                
                if self.localTableData?.count == 0{
                    textField.text = (self.ship_lines_item[sender.tag]["allocated_quantity"] as? Int ?? 0).description
                }else{
                    textField.text = (Int(self.localTableData?[sender.tag].alloc_quantity ?? 0)).description
                }
            }
            
            textField.keyboardType = .numberPad
        }
        
        let okAction = UIAlertAction(title: "Update".localized(), style: .cancel, handler: { _ in
    
            self.updateLineItem(index: sender.tag, qty: Int(addedTextField.text!) ?? 0)
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: nil)
        
        popUpAlert.addAction(okAction)
        popUpAlert.addAction(cancelAction)
        
        self.present(popUpAlert, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        if isEdittingOn{
            
            for item in self.editSessionData{
                
                let line_item_id = item["shipment_line_item_uuid"] as? String ?? ""
                let name = item["name"] as? String ?? ""
                let ndc = item["ndc"] as? String ?? ""
                let qty = item["quantity"] as? Int ?? 0
                let alloc_qty = item["allocated_quantity"] as? Int ?? 0
                let unalloc_qty = item["unallocated_quantity"] as? Int ?? 0
                let gtin = item["gtin14"] as? String ?? ""
                
                let params = updateLocalParams(line_item_id: line_item_id, ndc: ndc, quantity: qty, alloc_quantity: alloc_qty, unallocQty: unalloc_qty, gtin: gtin, name: name)
                
                self.updateLocalDB(with: params, po_no: self.dictPo?["po_number"] as? String ?? "")
                
//                if current_shipment_po != self.dictPo?["po_number"] as? String ?? ""{
//
//                    self.updateLocalDB(with: params, po_no: current_shipment_po ?? "")
//
//                }else{
//
//                    self.updateLocalDB(with: params, po_no: self.dictPo?["po_number"] as? String ?? "")
//                }
            }
            self.isEdittingOn = false
            
        }else{
            
            if self.localTableData?.count == 0{
                
                for item in self.ship_lines_item{
                    
                    let line_item_id = item["shipment_line_item_uuid"] as? String ?? ""
                    let name = item["name"] as? String ?? ""
                    let ndc = item["ndc"] as? String ?? ""
                    let qty = item["quantity"] as? Int ?? 0
                    let alloc_qty = item["allocated_quantity"] as? Int ?? 0
                    let unalloc_qty = item["unallocated_quantity"] as? Int ?? 0
                    let gtin = item["gtin14"] as? String ?? ""
                    
                    let params = updateLocalParams(line_item_id: line_item_id, ndc: ndc, quantity: qty, alloc_quantity: alloc_qty, unallocQty: unalloc_qty, gtin: gtin, name: name)
                    
                    
                    self.updateLocalDB(with: params, po_no: self.dictPo?["po_number"] as? String ?? "")
                    
//                    if current_shipment_po != self.dictPo?["po_number"] as? String ?? ""{
//
//                        self.updateLocalDB(with: params, po_no: current_shipment_po ?? "")
//
//                    }else{
//
//                        self.updateLocalDB(with: params, po_no: self.dictPo?["po_number"] as? String ?? "")
//                    }
                }
            }else{
                
                self.localTableData?.forEach({ item in
                    
                    let line_item_id = item.shipment_line_item_uuid ?? ""
                    let name = item.productName ?? ""
                    let ndc = item.ndc ?? ""
                    let qty = item.quantity
                    let alloc_qty = item.alloc_quantity
                    let unalloc_qty = item.unalloc_quantity
                    let gtin = item.gtin14 ?? ""
                    
                    let params = updateLocalParams(line_item_id: line_item_id, ndc: ndc, quantity: Int(qty), alloc_quantity: Int(alloc_qty), unallocQty: Int(unalloc_qty), gtin: gtin, name: name)
                    
                    self.updateLocalDB(with: params, po_no: self.dictPo?["po_number"] as? String ?? "")
                })
            }
        }
    }
    
    //MARK: - UPDATE DATABASE
    
    private struct updateLocalParams{
        var line_item_id: String
        var ndc: String
        var quantity: Int
        var alloc_quantity: Int
        var unallocQty: Int
        var gtin: String
        var name: String
    }
    
    private func updateLocalDB(with params: updateLocalParams, po_no: String){
        
        let predicatePO = NSPredicate(format:"po_no='\(po_no)'")
        let predicateUUID = NSPredicate(format:"shipment_line_item_uuid='\(params.line_item_id)'")
        
        do{
            let serial_obj = try PersistenceService.context.fetch(ReceivingLineItem.fetchRequestWithPredicate(predicate: predicateUUID))
            
            if serial_obj.isEmpty{
                
                let obj = ReceiveLineItem(context: PersistenceService.context)
                
                obj.productName = params.name
                obj.ndc = params.ndc
                obj.quantity = Int16(params.quantity)
                obj.alloc_quantity = Int16(params.alloc_quantity)
                obj.unalloc_quantity = Int16(params.unallocQty)
                obj.gtin14 = params.gtin
                obj.shipment_line_item_uuid = params.line_item_id
                obj.po_no = po_no
                obj.date = self.dictPo?["date"] as? String ?? ""
                
                PersistenceService.saveContext()
                
                Utility.showAlertWithPopAction(Title: Success_Title, Message: "Changes has been saved and will be applied on completion of receiving.".localized(), InViewC: self, isPop: true, isPopToRoot: false)
            }else{
       
                if let obj = serial_obj.first {
                    
                    obj.quantity = Int16(params.quantity)
                    obj.alloc_quantity = Int16(params.alloc_quantity)
                    obj.unalloc_quantity = Int16(params.unallocQty)
                    
                    PersistenceService.saveContext()
                    
                    Utility.showAlertWithPopAction(Title: Success_Title, Message: "Changes has been saved and will be applied on completion of receiving.".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
    }
}
extension PurchaseOrderAllocVC: UITableViewDelegate, UITableViewDataSource{
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
        return isEdittingOn ? (self.editSessionData.count) : (self.localTableData?.count ?? 0 == 0 ? self.ship_lines_item.count : self.localTableData?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllocatationCell", for: indexPath) as! AllocatationCell
        
        if isEdittingOn{
            
            let dataDict = editSessionData[indexPath.section] as NSDictionary
            
            var dataStr:String = ""
            
            if let name = dataDict["name"]  as? String{
                dataStr = name
            }
            
            cell.productNameLabel.text = dataStr
            
            dataStr = ""
            if let ndc = dataDict["ndc"]  as? String{
                dataStr = ndc
            }
            
            cell.ndcValueLabel.text = dataStr
            
            dataStr = ""
            if let gtin = dataDict["gtin14"]  as? String{
                dataStr = gtin
            }
            
            cell.gtin14Label.text = dataStr
            
            dataStr = ""
            if let quantity = dataDict["quantity"]  as? Int{
                dataStr = "\(quantity)"
            }
            cell.poQtyLabel.text = dataStr
            
            dataStr = ""
            if let quantity = dataDict["unallocated_quantity"] as? Int{
                dataStr = "\(quantity)"
            }
            cell.unAllocatedQty.text = dataStr
            
            dataStr = ""
            if let quantity = dataDict["allocated_quantity"] as? Int{
                dataStr = "\(quantity)"
            }
            
            cell.allocatedQty.setTitle(dataStr, for: .normal)
            
        }else{
            if self.localTableData?.count == 0{
                
                let dataDict = ship_lines_item[indexPath.section] as NSDictionary
                
                var dataStr:String = ""
                
                if let name = dataDict["name"]  as? String{
                    dataStr = name
                }
                
                cell.productNameLabel.text = dataStr
                
                dataStr = ""
                if let ndc = dataDict["ndc"]  as? String{
                    dataStr = ndc
                }
                
                cell.ndcValueLabel.text = dataStr
                
                dataStr = ""
                if let gtin = dataDict["gtin14"]  as? String{
                    dataStr = gtin
                }
                
                cell.gtin14Label.text = dataStr
                
                dataStr = ""
                if let quantity = dataDict["quantity"]  as? Int{
                    dataStr = "\(quantity)"
                }
                cell.poQtyLabel.text = dataStr
                
                dataStr = ""
                if let quantity = dataDict["unallocated_quantity"] as? Int{
                    dataStr = "\(quantity)"
                }
                cell.unAllocatedQty.text = dataStr
                
                dataStr = ""
                if let quantity = dataDict["allocated_quantity"] as? Int{
                    dataStr = "\(quantity)"
                }
                
                cell.allocatedQty.setTitle(dataStr, for: .normal)
                
            }else{
                let dataDict = self.localTableData?[indexPath.section]
                
                var dataStr:String = ""
                
                if let name = dataDict?.productName{
                    dataStr = name
                }
                
                cell.productNameLabel.text = dataStr
                
                dataStr = ""
                if let ndc = dataDict?.ndc{
                    dataStr = ndc
                }
                
                cell.ndcValueLabel.text = dataStr
                
                dataStr = ""
                if let gtin = dataDict?.gtin14{
                    dataStr = gtin
                }
                
                cell.gtin14Label.text = dataStr
                
                dataStr = ""
                if let quantity = dataDict?.quantity{
                    dataStr = "\(quantity)"
                }
                cell.poQtyLabel.text = dataStr
                
                dataStr = ""
                if let quantity = dataDict?.unalloc_quantity{
                    dataStr = "\(quantity)"
                }
                cell.unAllocatedQty.text = dataStr
                
                dataStr = ""
                if let quantity = dataDict?.alloc_quantity{
                    dataStr = "\(quantity)"
                }
                cell.allocatedQty.setTitle(dataStr, for: .normal)
                
            }
        }
                
        cell.btnAllocated.tag = indexPath.section
        
        return cell
        
    }
}
class AllocatationCell: UITableViewCell{
    
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet weak var btnAllocated: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var gtin14Label: UILabel!
    @IBOutlet weak var ndcValueLabel: UILabel!
    @IBOutlet weak var poQtyLabel: UILabel!
    @IBOutlet weak var unAllocatedQty: UILabel!
    @IBOutlet weak var allocatedQty: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.btnAllocated.layer.cornerRadius = 10
        self.btnAllocated.layer.borderWidth = 0.5
        self.btnAllocated.layer.borderColor = UIColor(red: 184/255, green: 203/255, blue: 203/255, alpha: 1.0).cgColor
    }
}
