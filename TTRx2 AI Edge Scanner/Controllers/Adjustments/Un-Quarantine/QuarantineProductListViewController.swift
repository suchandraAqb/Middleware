//
//  QuarantineProductListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 15/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class QuarantineProductListViewController: BaseViewController {

    @IBOutlet weak var listTable: UITableView!
    var adjustmentLineItemsArray: [[String: Any]] = []
    var adjustment_uuid = ""
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        getAdjectmentDetails()
    }
    //MARK: - End

    
    
    //MARK: - Action
    @IBAction func serialButtonPressed(_ sender: UIButton) {
        let adjustmentLineItem = adjustmentLineItemsArray[sender.tag]
        if let structure = adjustmentLineItem["structure"] as? [[String: Any]] {
            
            if structure.count > 1 {
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineSerialListView") as! UnQuarantineSerialListViewController
                controller.structure = structure
                self.navigationController?.pushViewController(controller, animated: false)
            }
            
        }
        
        
    }
    //MARK: - End
    //MARK: - Webservice Call
    func getAdjectmentDetails() {
        let appendStr = adjustment_uuid
        ///adjustments/{adjustment_uuid}/
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetQuarantineList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        print("Adjustmentitems: \(responseDict)")
                        
                        if let adjustmentLineItems = responseDict["adjustmentLineItem"] as? [[String:Any]] {
                            self.adjustmentLineItemsArray = adjustmentLineItems
                            self.listTable.reloadData()
                        }
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
    
    //MARK: - End
    

}

//MARK: - Tableview Delegate and Datasource
extension QuarantineProductListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return adjustmentLineItemsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        configureCell(at: indexPath)
    }
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "UnQuarantineItemCell") as! UnQuarantineItemCell
        cell.customView.setRoundCorner(cornerRadious: 20)
        cell.serialButton.tag = indexPath.row
        
        let adjustmentLineItem = adjustmentLineItemsArray[indexPath.row]
        if let products = adjustmentLineItem["product"] as? [[String: Any]], let firstPro = products.first {
            let udid = (firstPro["uuid"] as? String) ?? ""
            let predicate = NSPredicate(format: "uuid == '\(udid)'")
            if let allProducts = AllProductsModel.getAllProducts() {
                let filterArray = (allProducts as NSArray).filtered(using: predicate)
                if filterArray.count > 0 {
                    let firstObject =  (filterArray.first as? [String: Any]) ?? [:]
                    print("firstObject", firstObject)
                    let ndc_text = (firstObject["identifier_us_ndc"] as? String) ?? ""
                    cell.ndcLabel.text = ndc_text
                } else {
                    cell.ndcLabel.text = ""
                }
            } else {
                cell.ndcLabel.text = ""
            }
            cell.productNamelabel.text = (firstPro["product_name"] as? String) ?? ""
            cell.skuLabel.text = (firstPro["sku"] as? String) ?? ""
            let type = (adjustmentLineItem["type"] as? String) ?? ""
            cell.serialView.isHidden = false
            var typeStr = ""
            if type == "LOT_BASED"{
                typeStr = "Lot Based Item(s)".localized()
                cell.serialView.isHidden = true
            } else if type == "SIMPLE_SERIAL_BASED" {
                typeStr = "Item".localized()
            }else if type == "GS1_SERIAL_BASED" {
                if let structure = adjustmentLineItem["structure"] as? [[String: Any]] {
                    if structure.count > 0 {
                        typeStr = "Aggregation".localized()
                    }
                }
                
            }else{
                typeStr = "Item".localized()
            }
            cell.typeLabel.text = typeStr
            
        }
        if let structure = adjustmentLineItem["structure"] as? [[String: Any]] {
            let fisrtStructure = structure.first ?? [:]
            if structure.count > 1 {
                cell.serialButton.isUserInteractionEnabled = true
                cell.serialButton.setTitle("View Serials".localized(), for: .normal)
                cell.serialButton.setTitleColor(#colorLiteral(red: 0, green: 0.6862745098, blue: 0.937254902, alpha: 1), for: .normal)
            }else{
                cell.serialButton.isUserInteractionEnabled = false
                cell.serialButton.setTitleColor(#colorLiteral(red: 0.02745098039, green: 0.1294117647, blue: 0.2666666667, alpha: 1), for: .normal)
                cell.serialButton.setTitle((fisrtStructure["serial"] as? String) ?? "", for: .normal)
            }
        }
        
        if let quantity = adjustmentLineItem["quantity"] as? Int {
            cell.quantityLabel.text = "\(quantity)"
        }
        
        return cell
    }
}
//MARK: - End
