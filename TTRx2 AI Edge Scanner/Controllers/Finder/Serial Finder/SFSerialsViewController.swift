//
//  SFSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 06/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class SFSerialsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate  {
    
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var serialsButton: UIButton!
    var serialsList:Array<Any>?
    var verifiedSerialsList = [[String:Any]]()
    var productUuid:String?
    var lot:String?
    var isAllProduct = false
    var uniquesItems = [String]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        let headerNib = UINib.init(nibName: "SectionHeaderView", bundle: Bundle.main)
        listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
        
        if isAllProduct{
            let products = getInvidualProductList(uuid: productUuid ?? "")
            if let unique = (products as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String]{
                uniquesItems = unique
            }
            
        }else{
            uniquesItems = [lot ?? ""]
        }
        
        listTable.reloadData()
        
        
    }
    //MARK: - End
    
    //MARK: - Private Method
    func getInvidualProductList(uuid:String)->[[String:Any]]{
        var filterList = [[String:Any]]()
        let predicate = NSPredicate(format: "product_uuid = '\(uuid)'")
        filterList = (verifiedSerialsList as NSArray).filtered(using: predicate) as! [[String : Any]]
        return filterList
    }
    
    func getInvidualProductLotList(uuid:String,lot:String)->[[String:Any]]{
        var filterList = [[String:Any]]()
        let predicate = NSPredicate(format: "product_uuid = '\(uuid)' and lot_number='\(lot)'")
        filterList = (verifiedSerialsList as NSArray).filtered(using: predicate) as! [[String : Any]]
        return filterList
    }
    
    func populateProductandStatus(product:String?,status:String?)->NSAttributedString{
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15.0)!]
        let productString = NSMutableAttributedString(string:product ?? "", attributes: custAttributes)
        
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 11.0)!]
        
        let statusStr = NSAttributedString(string: "\n" + (status ?? ""), attributes: custTypeAttributes)
        productString.append(statusStr)
        
        return productString
        
    }
    
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as! SectionHeaderView
        
        headerView.lotNoLabel.text = uniquesItems[section]
        headerView.quantityLabel.text = "\(getInvidualProductLotList(uuid: productUuid ?? "", lot: uniquesItems[section]).count)"
        
        let serials = getInvidualProductLotList(uuid: productUuid ?? "", lot: uniquesItems[section])
        if serials.count > 0 {
        
            let dataDict = serials.first
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let exDate = dataDict?["expiration_date"] as? String{
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: exDate){
                    headerView.expirationDateLabel.text = "Expiration Date".localized() + ": \(formattedDate)"
                   
                }
            }
        }
        
        
        
        headerView.layer.cornerRadius = 10
        headerView.clipsToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return uniquesItems.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (getInvidualProductLotList(uuid: productUuid ?? "", lot: uniquesItems[section])).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        let serials = getInvidualProductLotList(uuid: productUuid ?? "", lot: uniquesItems[indexPath.section])
        
        if serials.count > 0 {
            
            let dataDict = serials[indexPath.row]
            if let txt = dataDict["simple_serial"] as? String,let status = dataDict["status"] as? String {
                cell.productNameLabel.attributedText = populateProductandStatus(product: txt, status:SFStatus[status])
            }else{
                cell.productNameLabel.text = ""
            }
            
            if indexPath.row + 1 == serials.count {
                cell.layer.cornerRadius = 10
                cell.clipsToBounds = true
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }else{
                cell.layer.cornerRadius = 0
                cell.clipsToBounds = false
            }
            
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let serials = getInvidualProductLotList(uuid: productUuid ?? "", lot: uniquesItems[indexPath.section])
        
        if serials.count > 0 {
            let dataDict = serials[indexPath.row]
            if let gs1Serial = dataDict["gs1_serial"] as? String{
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SFSerialDetailsView") as! SFSerialDetailsViewController
                controller.serial = gs1Serial
                if let serial = dataDict["simple_serial"] as? String {
                    controller.simple_serial = serial
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    //MARK: - End
    
    
    
    
}
