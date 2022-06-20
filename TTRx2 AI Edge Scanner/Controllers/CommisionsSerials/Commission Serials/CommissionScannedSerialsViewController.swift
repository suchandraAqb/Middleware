//
//  CommissionScannedSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 21/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  CommissionScannedSerialsViewDelegate: class {
    
    @objc optional func didReceiveUpdatedSerials(serials:[String])
   

}

class CommissionScannedSerialsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    var allScannedSerials = Array<String>()
    weak var delegate: CommissionScannedSerialsViewDelegate?
    @IBOutlet weak var serialListTable: UITableView!
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        self.serialListTable .reloadData()
    }
    //MARK: - End
    
    //MARK: - Private Method
    
    
    //MARK: - End
    
    
    //MARK: - IBAction
    
    @IBAction func backWithSerialsButtonPressed(_ sender: UIButton) {
        self.delegate?.didReceiveUpdatedSerials?(serials: self.allScannedSerials)
        self.navigationController?.popViewController(animated: true)
    }
    
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
        return allScannedSerials.count    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickingSerialListTableViewCell") as! PickingSerialListTableViewCell
        
        
        let serial = allScannedSerials[indexPath.row]
        var expiration = ""
        var gtin = ""
        var idValue = ""
        
        let details = UtilityScanning(with:serial).decoded_info
        if details.count > 0 {
            
            if(details.keys.contains("00")){
                
            }else{
                if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                    if !allproducts.isEmpty  {
                        if(details.keys.contains("01")){
                            if let gtin14 = details["01"]?["value"] as? String{
                                gtin = gtin14
                                let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14 }
                                print(filteredArray as Any)
                                if filteredArray.count > 0 {
                                    idValue =  (filteredArray.first?["identifier_us_ndc"] as? String) ?? ""
                                }
                            }
                        }
                    }
                }
            }
            
            
            if(details.keys.contains("17")){
                if let exd = details["17"]?["value"] as? String{
                    expiration = exd
                }
            }
            
            
        }
        
        cell.serialLabel.text = serial
        cell.gtin14Label.text = gtin
        cell.ndcLabel.text = idValue
        cell.expirationDateLabel.text = expiration
        if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MM-dd-yyyy", dateStr: expiration){
            cell.expirationDateLabel.text = formattedDate
            
        }
        
        
        cell.deleteButton.tag = indexPath.row
        
        return cell
        
    }
    //MARK: - End
    
    
}

extension CommissionScannedSerialsViewController : ScanViewControllerDelegate{
    func didScanCodeForRemoveMultiple(willBeRemovedSerials: [String]) {
        print(willBeRemovedSerials as [String])
        for serial in willBeRemovedSerials{
            if (allScannedSerials.contains(serial)){
                let idx = (self.allScannedSerials as NSArray).index(of: serial)
                self.allScannedSerials.remove(at: idx)
            }
        }
        self.serialListTable.reloadData()
        
    }
}
extension CommissionScannedSerialsViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForRemoveMultiple(willBeRemovedSerials: [String]) {
        print(willBeRemovedSerials as [String])
        
        for serial in willBeRemovedSerials{
            let idx = (self.allScannedSerials as NSArray).index(of: serial)
            self.allScannedSerials.remove(at: idx)
        }
        self.serialListTable.reloadData()
        
    }
}
//MARK: - ConfirmationViewDelegate
extension CommissionScannedSerialsViewController : ConfirmationViewDelegate{
    func doneButtonPressed() {
    }
    func doneButtonPressedWithIndex(index: Int) {
        allScannedSerials.remove(at: index)
        self.serialListTable.reloadData()
        
    }
    func cancelConfirmation() {
        self.serialListTable.reloadData()
    }
}
