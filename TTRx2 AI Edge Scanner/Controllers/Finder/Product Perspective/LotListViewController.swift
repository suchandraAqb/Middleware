//
//  LotListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Dhiman on 25/10/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class LotListViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var lotlistTableView : UITableView!
    var lotArr = NSArray()
    var type = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK : - Tableview delegate & datasource

    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return lotArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        cell.lotdetailsBorderView.layer.cornerRadius = 10
        cell.lotdetailsBorderView.layer.masksToBounds = true
        cell.lotdetailsBorderView.clipsToBounds = true
        
        let lotDict = lotArr[indexPath.row] as! NSDictionary
        
        if type.capitalized == "Inbound"{
            if lotDict["lot_number"] is NSNull{
                cell.lotValueLabel.text = ""
            }else{
                cell.lotValueLabel.text = "Lot number : \(lotDict["lot_number"] ?? "")"
            }
        }else{
            if lotDict["lot_number"] is NSNull{
                cell.lotValueLabel.text = ""
            }else{
                cell.lotValueLabel.text = "Lot number : \(lotDict["number"] ?? "")"
            }
        }
        if lotDict["expiration_date"] is NSNull{
            cell.expirationDateLabel.text = "Expiration Date : "
        }else{
            cell.expirationDateLabel.text = "Expiration Date : \(lotDict["expiration_date"] ?? "")"
        }
        let str = lotDict["quantity"] as? NSString
        if str == nil {
            cell.quantityLabel.text = "Quantity : \(lotDict["quantity"] ?? "")"
        }else{
            let quantityvalue = (lotDict["quantity"] as! NSString).integerValue
            cell.quantityLabel.text = "Quantity : \(quantityvalue)"
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
