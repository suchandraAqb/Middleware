//
//  ProductLotListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 29/01/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ProductLotListViewController: BaseViewController {
    
    @IBOutlet weak var addLotButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    
    var itemsList:Array<Any>?
    var productDict:NSDictionary?
    var remainingquantity:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        addLotButton.setRoundCorner(cornerRadious: addLotButton.frame.size.height/2.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupList()
        
        refreshRemainingquantity()
    }
    
    //MARK: - Action
    
    
    @IBAction func addLotButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ProductEditView") as! ProductEditViewController
        controller.isAdd = true
        controller.productDict = productDict
        controller.remainingquantity = remainingquantity
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ProductEditView") as! ProductEditViewController
        controller.productDict = productDict
        controller.remainingquantity = remainingquantity
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            controller.lotDict = dict
        }
        controller.isAdd = false     
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let msg = "You are about to delete the resource.".localized() + "\n" + "This operation can’t be undone.".localized() + "\n\n" + "Proceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            if let dict = self.itemsList![sender.tag] as? NSDictionary {
                self.removeLot(data: dict)
            }
            
            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - End
    
    //MARK: - End
    func refreshRemainingquantity(){
        if let misitem_id = productDict?["id"] as? Int,  let totalQuantity = productDict?["quantity"] as? Int {
            do{
                let predicate = NSPredicate(format:"misitem_id='\(misitem_id)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                    if let avalableQuantity = (arr as NSArray).value(forKeyPath: "@sum.quantity")  as? NSNumber{
                        remainingquantity = totalQuantity - Int(truncating: avalableQuantity)
                    }else{
                        remainingquantity = totalQuantity
                    }
                }else {
                    remainingquantity = totalQuantity
                }
            }catch let error{
                remainingquantity = totalQuantity
                print(error.localizedDescription)
            }
        }
    }
    
    func removeLot(data:NSDictionary){
        if let id = data["id"] {
            do{
                let predicate = NSPredicate(format:"id='\(id)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))                
                if !serial_obj.isEmpty{
                    if let obj = serial_obj.first {
                        PersistenceService.context.delete(obj)
                        PersistenceService.saveContext()
                    }                    
                }
                
                setupList()
                refreshRemainingquantity()
            }catch let error{
                print(error.localizedDescription)
            }
        }
        
    }
    
    func setupList(){
        if let misitem_id = productDict?["id"] as? Int16 {
            do{
                let predicate = NSPredicate(format:"misitem_id='\(misitem_id)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                
                
                if !serial_obj.isEmpty{
                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                    itemsList = arr
                    listTable.reloadData()
                }else{
                    itemsList = nil
                    listTable.reloadData()
                }
            }catch let error{
                print(error.localizedDescription)
                itemsList = nil
                listTable.reloadData()
                
            }
        }
        
    }
    
    //MARK: - End
    
    
}


//MARK: - Tableview Delegate and Datasource
extension ProductLotListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "MISProductLotCell") as! MISProductLotCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        if let dict = self.itemsList![indexPath.row] as? NSDictionary {
            
            var dataStr = ""
            if let txt = dict["sdi"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.referenceLabel?.text = dataStr
            
            dataStr = ""
            if let txt = dict["lot_number"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.lotLabel.text = dataStr
            
            dataStr = ""
            if let txt = dict["quantity"] as? NSNumber{
                dataStr = "\(txt)"
            }
            cell.quantityLabel.text = dataStr
            
            dataStr = ""
            if let txt = dict["expiration_date"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.expirationDateLabel.text = dataStr          
            
        }
        
        cell.editButton?.tag = indexPath.row
        cell.deleteButton?.tag = indexPath.row
        
        return cell
    }
}
//MARK: - End



//MARK: - Tableview Cell
class MISProductLotCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    
    @IBOutlet weak var referenceLabel: UILabel?
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    
    @IBOutlet weak var btnEditLot: UIButton?
    @IBOutlet weak var btnEditExpDate: UIButton?
    
    @IBOutlet weak var editButton: UIButton?
    @IBOutlet weak var deleteButton: UIButton?
    
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        self.customView.setRoundCorner(cornerRadious: 10)
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End
