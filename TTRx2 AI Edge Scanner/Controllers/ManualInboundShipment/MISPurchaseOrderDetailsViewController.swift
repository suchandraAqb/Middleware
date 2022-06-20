//
//  MISPurchaseOrderDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 17/03/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISPurchaseOrderDetailsViewController: BaseViewController{
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet weak var shipmentTypeButton: UIButton!
    @IBOutlet weak var udidValueLabel: UILabel!
    @IBOutlet weak var tpValueLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var cOrderIdValueLabel: UILabel!
    @IBOutlet weak var invoiceValueLabel: UILabel!
    @IBOutlet weak var orderValueLabel: UILabel!
    @IBOutlet weak var releaseValueLabel: UILabel!
    @IBOutlet weak var referenceNbrLabel: UILabel!
    @IBOutlet weak var poLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var SBNickNameValueLabel: UILabel!
    @IBOutlet weak var SBAddressValueLabel: UILabel!
    @IBOutlet weak var SFNickNameValueLabel: UILabel!
    @IBOutlet weak var SFAddressValueLabel: UILabel!
    
    @IBOutlet weak var BBNickNameValueLabel: UILabel!
    @IBOutlet weak var BBAddressValueLabel: UILabel!
    @IBOutlet weak var STNickNameValueLabel: UILabel!
    @IBOutlet weak var STAddressValueLabel: UILabel!
    
    var purchaseOrderDetailsDict:NSDictionary?
    var itemsArray:Array<Any>?

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
        
        viewItemsButton.setRoundCorner(cornerRadious: viewItemsButton.frame.size.height/2.0)
        
        populateDetails(dataDict: purchaseOrderDetailsDict)
        
    }
    //MARK:- End
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - End
    
    func getAddressStr(addressDict:[String:Any])->String{
        var addressStr = ""
            
        if let line1 = addressDict["line1"] as? String{
            addressStr = addressStr + line1 + ", "
        }
        
        if let line2 = addressDict["line2"] as? String{
            addressStr = addressStr + line2 + "\n"
        }
        
        if let line3 = addressDict["line3"] as? String{
            addressStr = addressStr + line3 + "\n\n"
        }
        
        if let city = addressDict["city"] as? String{
            addressStr = addressStr + city + ", "
        }
        
        if let state_name = addressDict["state_name"] as? String{
            addressStr = addressStr + state_name + ", "
        }
        
        if let country_name = addressDict["country_name"] as? String{
            addressStr = addressStr + country_name
        }
        
        if let phone = addressDict["phone"] as? String{
            addressStr = addressStr + "\n" + phone
        }
        
        return addressStr
    }
    
    
    
    func populateDetails(dataDict:NSDictionary?){
        
        
        if dataDict != nil{
            
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            
            if let items:Array<Any> = dataDict!["line_items"] as? Array<Any>{
                itemsArray = items
            }
            
            var dataStr = ""
            if let txt = dataDict?["uuid"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            udidValueLabel.text = dataStr
            
            
            dataStr = ""
            if let txt = dataDict?["trading_partner_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            tpValueLabel.text = dataStr
            
            if let shipDate:String = dataDict!["transaction_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                    orderDateLabel.text = formattedDate
                }
            }
            
            dataStr = ""
            if let txt = dataDict?["custom_id"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cOrderIdValueLabel.text = dataStr
            
            dataStr = ""
            if let txt = dataDict?["invoice_nbr"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            invoiceValueLabel.text = dataStr
            
            dataStr = ""
            if let txt = dataDict?["order_nbr"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            orderValueLabel.text = dataStr
            
            dataStr = ""
            if let txt = dataDict?["release_nbr"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            releaseValueLabel.text = dataStr
            
            dataStr = ""
            if let txt = dataDict?["internal_reference_number"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            referenceNbrLabel.text = dataStr
            
            dataStr = ""
            if let txt = dataDict?["po_nbr"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            poLabel.text = dataStr
            
            dataStr = ""
            if let txt = dataDict?["notes"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            notesLabel.text = dataStr
            
            
            
            if let sold_by = dataDict!["sold_by_address_custom"] as? [String:Any] {
                if let recipient_name:String = sold_by["recipient_name"] as? String{
                    SBNickNameValueLabel.text = recipient_name
                }
                let addressStr = self.getAddressStr(addressDict: sold_by)
                SBAddressValueLabel.text = addressStr
            }
            
            if let ship_from = dataDict!["ship_from_address_custom"] as? [String:Any] {
                if let recipient_name:String = ship_from["recipient_name"] as? String{
                    SFNickNameValueLabel.text = recipient_name
                }
                let addressStr = self.getAddressStr(addressDict: ship_from)
                SFAddressValueLabel.text = addressStr
            }
            
            if let bought_by = dataDict!["billing_address_custom"] as? [String:Any] {
                if let recipient_name:String = bought_by["recipient_name"] as? String{
                    BBNickNameValueLabel.text = recipient_name
                }
                let addressStr = self.getAddressStr(addressDict: bought_by)
                BBAddressValueLabel.text = addressStr
            }
            
            if let ship_to = dataDict!["ship_to_address_custom"] as? [String:Any] {
                if let recipient_name:String = ship_to["recipient_name"] as? String{
                    STNickNameValueLabel.text = recipient_name
                }
                let addressStr = self.getAddressStr(addressDict: ship_to)
                STAddressValueLabel.text = addressStr
            }
            
        }
        
    }
    
    //MARK: - IBAction
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        if itemsArray != nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISPurchaseOrderItemsView") as! MISPurchaseOrderItemsViewController
            controller.itemsList = itemsArray
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No items found.", InViewC: self)
        }
    }
    //MARK: - End
    

    

}
