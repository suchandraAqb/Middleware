//
//  AdjustmentAddLotBasedViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 03/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CloudKit

@objc protocol DPLotBasedUpdatedViewDelegate: class {
    @objc optional func didLotAdded(data:NSDictionary)
    @objc optional func didSelectStaff(data:NSDictionary)
}

class DPLotBasedUpdatedViewController:BaseViewController,UITableViewDataSource, UITableViewDelegate,SingleSelectDropdownDelegate,DPProductLotStorageDelegate
{
    weak var delegate: DPLotBasedUpdatedViewDelegate?
    
    @IBOutlet weak var lotlistTable: UITableView!
    @IBOutlet weak var lotAutoSearchView: UIView!
    @IBOutlet weak var lotAutoSearchSectionView: UIView!
    @IBOutlet weak var lotSearchTextFieldView: UIView!
    @IBOutlet weak var lotSearchContainer: UIView!
    @IBOutlet weak var lotSearchTextField: UITextField!
    @IBOutlet weak var headerButton:UIButton!
 

    var products:Array<Any>?
    var lots:Array<Any>?
    var masterLots:Array<Any>?
    var masterStaffArr:Array<Any>?
    var selectedProductIndex = -1
    var selectedSearchType = 0
    var selectedProductDict:NSDictionary?
    var selectedLot = [String:Any]()
    var staffarr:Array<Any>?
    var isStaffList:Bool = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lotAutoSearchSectionView.roundTopCorners(cornerRadious: 40)
        lotSearchContainer.setRoundCorner(cornerRadious: 10)
        lotSearchTextFieldView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        lotSearchTextField.addLeftViewPadding(padding: 12.0)
        lotSearchTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        createInputAccessoryView()
        lotSearchTextField.inputAccessoryView = inputAccView
        if isStaffList{
            masterStaffArr = staffarr
            headerButton.setTitle("Participant Details".localized(), for: .normal)
            lotSearchTextField.placeholder = "Filter By Participant name".localized()
        }else{
            masterLots = lots
            headerButton.setTitle("Product Lots".localized(), for: .normal)
            lotSearchTextField.placeholder = "Filter by Lot Number".localized()

        }
     }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func crossButtonPressed(_ sender:UIButton){
        self.dismiss(animated: true)
    }
    //MARK: - End
    
    //MARK: - Private Method
  
    func autoCompleteLotWithStr(searchStr:String?){
        
        var predicate:NSPredicate?
        if !isStaffList{
            predicate = NSPredicate(format: "lot_number CONTAINS[c] '\(searchStr ?? "")'")
        
            if let masterArr = masterLots as NSArray? {
                let filteredArray = masterArr.filtered(using: predicate!) as NSArray
            
             if filteredArray.count>0{
                lots = (filteredArray as! Array<Any>)
            }else{
                lots = []
                if searchStr == ""{
                    lots = masterLots
                }
              }
            }
        }else{
            predicate = NSPredicate(format: "full_name CONTAINS[c] '\(searchStr ?? "")'")
        
            if let masterArr = masterStaffArr as NSArray? {
                let filteredArray = masterArr.filtered(using: predicate!) as NSArray
            
             if filteredArray.count>0{
                staffarr = (filteredArray as! Array<Any>)
            }else{
                staffarr = []
                if searchStr == ""{
                    staffarr = masterStaffArr
                }
              }
            }
        }
            lotlistTable.reloadData()
        }
            
    
    
    //MARK: - End
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
      
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
      
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
       textField.resignFirstResponder()
       return true
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        if sender == lotSearchTextField{
            self.autoCompleteLotWithStr(searchStr: lotSearchTextField.text)
        }
    }
    
    //MARK: - End
    //MARK: - Tableview Delegate and Datasource
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        doneTyping()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
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
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 5))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        if isStaffList{
            return staffarr?.count ?? 0
        }else{
            return lots?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell") as! ProductListCell
        cell.bgView.layer.cornerRadius = 10
        cell.bgView.layer.masksToBounds = true
        cell.bgView.clipsToBounds = true

        
        if !isStaffList{
            cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "E3F1F7")

            cell.firstView.isHidden = false
            cell.secondView.isHidden = false
            cell.thirdView.isHidden = false
            cell.firstLabel.text = "Lot Number:".localized()
            cell.secondLabel.text = "Available Qty:".localized()
            cell.thirdLabel.text = "Expiration Date:".localized()
            
            let dataDict:NSDictionary = lots?[indexPath.section] as! NSDictionary
            var dataStr:String = ""
            if let name = dataDict["lot_number"] as? String{
                dataStr = name
            }
            
            cell.productNameLabel.text = dataStr
            
            var str = ""
            if let items = dataDict["total_available_quantity"] as? NSString {
                str = "\(items.intValue)"
            }
            
            cell.quantityLabel.text = str
        
            dataStr = ""
            if let expirationDate = dataDict["lot_expiration"] as? String{
                dataStr = expirationDate
            }
            cell.expirationDateLabel.text = dataStr
        }else{
            cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "E3F1F7")

            cell.firstView.isHidden = false
            cell.secondView.isHidden = false
            cell.thirdView.isHidden = true
            cell.firstLabel.text = "Participant Name:".localized()
            cell.secondLabel.text = "Email:".localized()
            
            
            let dataDict:NSDictionary = staffarr?[indexPath.section] as! NSDictionary
            var dataStr = ""
            if let name = dataDict["full_name"] as? String{
                dataStr = name
            }
            cell.productNameLabel.text = dataStr
            
            dataStr = ""
            if let name = dataDict["email"] as? String{
                dataStr = name
            }
            cell.quantityLabel.text = dataStr

        }
        
       return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isStaffList{
            let data:NSDictionary = lots?[indexPath.section] as! NSDictionary
            selectedLot = data as! [String : Any]
        
            self.dismiss(animated: true) {
                self.delegate?.didLotAdded!(data: self.selectedLot as NSDictionary)
            }
        }else{
            let data:NSDictionary = staffarr?[indexPath.section] as! NSDictionary
            let selectedStaff = data as! [String : Any]
        
            self.dismiss(animated: true) {
                self.delegate?.didSelectStaff?(data: selectedStaff as NSDictionary)
            }
        }
    }
    //MARK: - End

}
