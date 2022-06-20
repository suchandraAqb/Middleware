//
//  ReceivingLotSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 07/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReceivingLotSearchViewController: BaseViewController,SingleSelectDropdownDelegate,DatePickerViewDelegate {
    
    @IBOutlet weak var tradingPartnerLabel: UILabel!
    @IBOutlet weak var poTextField: UITextField!
    @IBOutlet weak var iOTextField: UITextField!
    @IBOutlet weak var oNTextField: UITextField!
    @IBOutlet weak var rNTextField: UITextField!
    @IBOutlet weak var shipDateLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var searchButton: UIButton!
    var tradingPartners:Array<Any>?
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        getTradingPartnersList()
        //createInputAccessoryView()
        createInputAccessoryViewAddedScan()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    
    
    
    //MARK: - Private Method
    
    
    func getTradingPartnersList(){
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetTradingPartners", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let dataArray = responseDict["data"] as? Array<Any> {
                        let sortedResults = (dataArray as NSArray).sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as! [[String:AnyObject]]
                        self.tradingPartners = sortedResults
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
    //MARK: - IBAction
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.tag == 1{
            if tradingPartners == nil {
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = tradingPartners as! Array<[String:Any]>
            controller.type = "Trading Partners"
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var tpName = ""
        if let str = tradingPartnerLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            tpName = str
        }
        
        var poStr = ""
        if let str = poTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            poStr = str
        }
        
        var shipDateStr = ""
        if let str = shipDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            shipDateStr = str
        }
        
        var deliveyDate = ""
        if let str = deliveryDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            deliveyDate = str
        }
        
        var order = ""
        if let str = oNTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            order = str
        }
        
        var invoice = ""
        if let str = iOTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            invoice = str
        }
        
        var release = ""
        if let str = rNTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            release = str
        }
        
        var appendStr = "?delivery_status=everything_but_confirmed&"
        
        if !tpName.isEmpty{
            appendStr = appendStr + "trading_partner_name=\(tpName)&"
        }
        
        if !order.isEmpty{
            appendStr = appendStr + "transaction_order_number=\(order)&"
        }
        
        if !invoice.isEmpty{
            appendStr = appendStr + "transaction_invoice_number=\(invoice)&"
        }
        
        if !release.isEmpty{
            appendStr = appendStr + "transaction_release_number=\(release)&"
        }
        
        if !poStr.isEmpty{
            appendStr = appendStr + "transaction_po_number=\(poStr)&"
        }
        
        if !shipDateStr.isEmpty{
            appendStr = appendStr + "ship_date=\(shipDateStr)&"
        }
        
        if !deliveyDate.isEmpty{
            appendStr = appendStr + "delivery_date=\(deliveyDate)&"
        }
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentsListView") as! ShipmentsListViewController
        controller.appendStr = escapedString
        controller.isfromSearchmanually = true
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    //MARK: - End
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    //MARK: - End
    //MARK: - SingleSelectDropdownDelegate
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil{
            
            if sender?.tag == 1{
                if let name = data["name"] as? String{
                    tradingPartnerLabel.text = name
                    tradingPartnerLabel.accessibilityHint = name
                }
            }
        }
    }
    //MARK: - End
    
    //MARK: - DatePickerViewDelegate
    func dateSelectedWithSender(selectedDate: Date, sender: UIButton?) {
        if sender != nil{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            
            
            if sender?.tag == 2 {
                shipDateLabel.text = dateStr
                shipDateLabel.accessibilityHint = dateStrForApi
            }else{
                deliveryDateLabel.text = dateStr
                deliveryDateLabel.accessibilityHint = dateStrForApi
            }
            
        }
    }
    //MARK: - End
}
extension ReceivingLotSearchViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
    }
}
