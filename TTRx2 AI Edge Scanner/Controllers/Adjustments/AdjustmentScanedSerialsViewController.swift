//
//  AdjustmentScanedSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 03/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class AdjustmentScanedSerialsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    var serialList = Array<Adjustments>()
    
    @IBOutlet weak var serialListTable: UITableView!
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        self.serialListTable.reloadData()
        fetchScannedSerials()
    }
    //MARK: - End
    
    //MARK: - Private Method
    func fetchScannedSerials(){
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false")
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                serialList = serial_obj
                serialListTable.reloadData()
            }
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func removeSerialFromDB(obj:Adjustments){
        PersistenceService.context.delete(obj)
        PersistenceService.saveContext()
    }
    
    func prepareSerialsForRemove(barcodes:[String]){
        
        var sCount = 0
        var fCount = 0
        
        for barcode in barcodes{
            do{
                let predicate = NSPredicate(format:"barcode='\(barcode)'")
                let adjustment_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
                print("Existing Adjuments Fetched for Removed")
                
                if !adjustment_obj.isEmpty{
                    
                    for obj in adjustment_obj{
                        self.removeSerialFromDB(obj: obj)
                        let index = (serialList as NSArray).index(of: obj) as Int
                        if index <= serialList.count{
                          serialList.remove(at: index)
                          sCount+=1
                        }
                    }
                }else{
                    fCount+=1
                }
                
            }catch let error {
                fCount+=1
                print(error.localizedDescription)
                
            }
        }
        DispatchQueue.main.async{
            self.serialListTable.reloadData()
            if Int(sCount)>0{
                Utility.showPopup(Title: Success_Title, Message: "\(Int(sCount)>1 ?"\(sCount) Serials" : "\(sCount) Serial") successfully removed" , InViewC: self)
            }
//            Utility.showPopup(Title: Success_Title, Message: "\(Int(sCount)>1 ?"\(sCount) Serials" : "\(sCount) Serial") successfully removed\n\(Int(fCount)>1 ?"\(fCount) Serials" : "\(fCount) Serial") failed to removed" , InViewC: self)

        }
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to remove this serial?".localized()
        controller.delegate = self
        controller.isIndexRequired = true
        controller.indexNumber = sender.tag
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func removeMultipleButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
        if(defaults.bool(forKey: "IsMultiScan")){
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
            controller.isForMultiRemove = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
            controller.isForMultiRemove = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    //MARK: - End
    
    //MARK: - Tableview Delegate and Datasource
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serialList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickingSerialListTableViewCell") as! PickingSerialListTableViewCell
        
        let obj = serialList[indexPath.row]
        
        cell.serialLabel.text = obj.serial ?? ""
        
        cell.gtin14Label.text = obj.gtin ?? ""
        
        cell.ndcLabel.text = obj.identifier_value ?? ""
        
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        cell.expirationDateLabel.text = ""
        let exDate = obj.expiration_date ?? ""
        if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: exDate){
            cell.expirationDateLabel.text = formattedDate
        }
        
        cell.deleteButton.tag = indexPath.row
        
        return cell
    }
    //MARK: - End
}

extension AdjustmentScanedSerialsViewController : ScanViewControllerDelegate{
    func didScanCodeForRemoveMultiple(willBeRemovedSerials: [String]) {
        print(willBeRemovedSerials as [String])
        DispatchQueue.main.async{
            
        }
        self.prepareSerialsForRemove(barcodes: willBeRemovedSerials)
    }
}
extension AdjustmentScanedSerialsViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForRemoveMultiple(willBeRemovedSerials: [String]) {
        print(willBeRemovedSerials as [String])
        DispatchQueue.main.async{
            
        }
        self.prepareSerialsForRemove(barcodes: willBeRemovedSerials)
    }
}
//MARK: - ConfirmationViewDelegate
extension AdjustmentScanedSerialsViewController : ConfirmationViewDelegate{
    func doneButtonPressed() {
    }
    func doneButtonPressedWithIndex(index: Int) {
        let obj = serialList[index]
        self.removeSerialFromDB(obj: obj)
        serialList.remove(at: index)
        self.serialListTable.reloadData()
    }
    
    func cancelConfirmation() {
        self.serialListTable.reloadData()
    }
}
