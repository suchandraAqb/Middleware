//
//  PPShipmentDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 11/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PPShipmentDetailsViewController: BaseViewController{
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet weak var shipmentTypeButton: UIButton!
    @IBOutlet weak var udidValueLabel: UILabel!
    @IBOutlet weak var tpValueLabel: UILabel!
    @IBOutlet weak var etaValueLabel: UILabel!
    @IBOutlet weak var poValueLabel: UILabel!
    @IBOutlet weak var poLabel:UILabel!
    @IBOutlet weak var shipDateValueLabel: UILabel!
    @IBOutlet weak var deliveryDateValueLabel: UILabel!
    @IBOutlet weak var cOrderIdValueLabel: UILabel!
    @IBOutlet weak var invoiceValueLabel: UILabel!
    @IBOutlet weak var orderValueLabel: UILabel!
    @IBOutlet weak var releaseValueLabel: UILabel!
    @IBOutlet weak var SFNickNameValueLabel: UILabel!
    @IBOutlet weak var SFAddressValueLabel: UILabel!
    @IBOutlet weak var STNickNameValueLabel: UILabel!
    @IBOutlet weak var STAddressValueLabel: UILabel!
    
    var type = ""  
    var shipmentId = ""
    var itemsArray:Array<Any>?

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        shipmentTypeButton.setTitle("\(type.capitalized) Shipment", for: .normal)
        
        viewItemsButton.setRoundCorner(cornerRadious: viewItemsButton.frame.size.height/2.0)
        getShipmentDetails()
        
    }
    //MARK:- End
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - End
    
    func getShipmentDetails(){
        
        self.showSpinner(onView: self.view)
        
        var appendStr = ""
        
        var apiName = ""
        if type.capitalized == "Inbound"{
            apiName = "ShipmentDetails"
            appendStr = "\(shipmentId)"

        }else{
            apiName = "ConfirmShipment"
            appendStr = "\(type.capitalized)/\(shipmentId)"
        }
        
          Utility.GETServiceCall(type: apiName, serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in //
                DispatchQueue.main.async{ [self] in
                  self.removeSpinner()
                  if isDone! {
                    
                    if let responseDict = responseData as? NSDictionary {
                        if type.capitalized == "Inbound"{
                            self.inboundpopulateDetails(dataDict: responseDict)
                        }else{
                            self.populateDetails(dataDict: responseDict)
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
    
    func inboundpopulateDetails(dataDict:NSDictionary?){
        
        
        if dataDict != nil{
            
            udidValueLabel.text = shipmentId
            
            if let items:Array<Any> = dataDict!["ship_lines_item"] as? Array<Any>{
                itemsArray = items
            }
            
            
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let shipDate:String = dataDict!["ship_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                    shipDateValueLabel.text = formattedDate
                }
            }
            
            if let ship_eta_date:String = dataDict!["ship_eta_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: ship_eta_date){
                    etaValueLabel.text = formattedDate
                }
            }
            
            if let ship_delivery_date:String = dataDict!["ship_delivery_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: ship_delivery_date){
                    deliveryDateValueLabel.text = formattedDate
                }
            }
            
            
            
            if let trading_partner:NSDictionary = dataDict!["trading_partner"] as? NSDictionary{
                
                if let name = trading_partner["name"]{
                    tpValueLabel.text = name as? String
                }
                
            }
            
            if let transactions:Array<Any> = dataDict!["transactions"] as? Array<Any>{
                
                if transactions.count>0{
                    let firstTransaction:NSDictionary = transactions.first as? NSDictionary ?? NSDictionary()
                    
                    poLabel.text = "PO#"
                    if let po:String = firstTransaction["po_number"] as? String{
                        poValueLabel.text = po
                    }
                    
                    if let custom_order_id:String = firstTransaction["custom_order_id"] as? String{
                        cOrderIdValueLabel.text = custom_order_id
                    }
                    
                    if let invoice_number:String = firstTransaction["invoice_number"] as? String{
                        invoiceValueLabel.text = invoice_number
                    }
                    
                    if let order_number:String = firstTransaction["order_number"] as? String{
                        orderValueLabel.text = order_number
                    }
                    
                    if let release_number:String = firstTransaction["release_number"] as? String{
                        releaseValueLabel.text = release_number
                    }
                    
               }
                
            }
            
            if let ship_from:NSDictionary = dataDict!["ship_from_location"] as? NSDictionary {
                
                if let recipient_name:String = ship_from["recipient_name"] as? String{
                    SFNickNameValueLabel.text = recipient_name
                }
                
                var addressStr:String = ""
                
                if let line1:String = ship_from["line1"] as? String{
                    addressStr = addressStr + line1 + ", "
                }
                
                
                
                if let line2:String = ship_from["line2"] as? String{
                    addressStr = addressStr + line2 + "\n"
                }
                
                if let line3:String = ship_from["line3"] as? String{
                    addressStr = addressStr + line3 + "\n\n"
                }
                
                if let city:String = ship_from["city"] as? String{
                    addressStr = addressStr + city + ", "
                }
                
                if let state_name:String = ship_from["state_name"] as? String{
                    addressStr = addressStr + state_name + ", "
                }
                
                if let country_name:String = ship_from["country_name"] as? String{
                    addressStr = addressStr + country_name
                }
                
                if let phone:String = ship_from["phone"] as? String{
                    addressStr =  addressStr + "\n" + phone
                }
                
                SFAddressValueLabel.text = addressStr
                
            }
            
            if let ship_to:NSDictionary = dataDict!["ship_to_location"] as? NSDictionary {
                
                if let recipient_name:String = ship_to["recipient_name"] as? String{
                    STNickNameValueLabel.text = recipient_name
                }
                
                var addressStr:String = ""
                
                if let line1:String = ship_to["line1"] as? String{
                    addressStr = addressStr + line1 + ", "
                }
                
                if let line2:String = ship_to["line2"] as? String{
                    addressStr = addressStr + line2 + "\n"
                }
                
                if let line3:String = ship_to["line3"] as? String{
                    addressStr = addressStr + line3 + "\n\n"
                }
                
                if let city:String = ship_to["city"] as? String{
                    addressStr = addressStr + city + ", "
                }
                
                if let state_name:String = ship_to["state_name"] as? String{
                    addressStr = addressStr + state_name + ", "
                }
                
                if let country_name:String = ship_to["country_name"] as? String{
                    addressStr = addressStr + country_name
                }
                
                if let phone:String = ship_to["phone"] as? String{
                    addressStr = addressStr + "\n" + phone
                }
                
                STAddressValueLabel.text = addressStr
                
             }
            
        }
        
    }
    func populateDetails(dataDict:NSDictionary?){
        
        
        if dataDict != nil{
            
            udidValueLabel.text = shipmentId
            
            if let items:Array<Any> = dataDict!["ShipmentLineItem"] as? Array<Any>{
                itemsArray = items
            }
            
            
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let shipDate:String = dataDict!["shipment_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                    shipDateValueLabel.text = formattedDate
                }
            }
            
            if let ship_eta_date:String = dataDict!["estimated_delivery_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: ship_eta_date){
                    etaValueLabel.text = formattedDate
                }
            }
            
            if let ship_delivery_date:String = dataDict!["delivery_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: ship_delivery_date){
                    deliveryDateValueLabel.text = formattedDate
                }
            }
            
            
            
            if let trading_partner:NSDictionary = dataDict!["trading_partner"] as? NSDictionary{
                
                if let name = trading_partner["name"]{
                    tpValueLabel.text = name as? String
                }
                
            }
            
            if let transactions:Array<Any> = dataDict!["transactions"] as? Array<Any>{
                
                if transactions.count>0{
                    let firstTransaction:NSDictionary = transactions.first as? NSDictionary ?? NSDictionary()
                    
                    poLabel.text = "SO#"
                    
                    if let po:String = firstTransaction["po_number"] as? String{
                        poValueLabel.text = po
                    }
                    
                    if let custom_order_id:String = firstTransaction["custom_order_id"] as? String{
                        cOrderIdValueLabel.text = custom_order_id
                    }
                    
                    if let invoice_number:String = firstTransaction["invoice_number"] as? String{
                        invoiceValueLabel.text = invoice_number
                    }
                    
                    if let order_number:String = firstTransaction["order_number"] as? String{
                        orderValueLabel.text = order_number
                    }
                    
                    if let release_number:String = firstTransaction["release_number"] as? String{
                        releaseValueLabel.text = release_number
                    }
                    
               }
                
            }
            
            if let ship_from:NSDictionary = dataDict!["ship_from"] as? NSDictionary {
                
                if let recipient_name:String = ship_from["recipient_name"] as? String{
                    SFNickNameValueLabel.text = recipient_name
                }
                
                var addressStr:String = ""
                
                if let line1:String = ship_from["line1"] as? String{
                    addressStr = addressStr + line1 + ", "
                }
                
                
                
                if let line2:String = ship_from["line2"] as? String{
                    addressStr = addressStr + line2 + "\n"
                }
                
                if let line3:String = ship_from["line3"] as? String{
                    addressStr = addressStr + line3 + "\n\n"
                }
                
                if let city:String = ship_from["city"] as? String{
                    addressStr = addressStr + city + ", "
                }
                
                if let state_name:String = ship_from["state_name"] as? String{
                    addressStr = addressStr + state_name + ", "
                }
                
                if let country_name:String = ship_from["country_name"] as? String{
                    addressStr = addressStr + country_name
                }
                
                if let phone:String = ship_from["phone"] as? String{
                    addressStr =  addressStr + "\n" + phone
                }
                
                SFAddressValueLabel.text = addressStr
                
            }
            
            if let ship_to:NSDictionary = dataDict!["shipping_address"] as? NSDictionary {
                
                if let recipient_name:String = ship_to["recipient_name"] as? String{
                    STNickNameValueLabel.text = recipient_name
                }
                
                var addressStr:String = ""
                
                if let line1:String = ship_to["line1"] as? String{
                    addressStr = addressStr + line1 + ", "
                }
                
                if let line2:String = ship_to["line2"] as? String{
                    addressStr = addressStr + line2 + "\n"
                }
                
                if let line3:String = ship_to["line3"] as? String{
                    addressStr = addressStr + line3 + "\n\n"
                }
                
                if let city:String = ship_to["city"] as? String{
                    addressStr = addressStr + city + ", "
                }
                
                if let state_name:String = ship_to["state_name"] as? String{
                    addressStr = addressStr + state_name + ", "
                }
                
                if let country_name:String = ship_to["country_name"] as? String{
                    addressStr = addressStr + country_name
                }
                
                if let phone:String = ship_to["phone"] as? String{
                    addressStr = addressStr + "\n" + phone
                }
                
                STAddressValueLabel.text = addressStr
                
             }
            
        }
        
    }
    //MARK: - IBAction
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
       if itemsArray != nil {
            
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PPShipmentItemsView") as! PPShipmentItemsViewController
            controller.itemsList = itemsArray
            controller.shipmentId = shipmentId
            controller.type = type
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No items found.", InViewC: self)
        }
       
    }
    //MARK: - End
    

    

}
