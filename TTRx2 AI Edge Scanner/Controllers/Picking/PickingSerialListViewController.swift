//
//  PickingSerialListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 20/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PickingSerialListViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    var serialList = Array<[String:Any]>()
    var allScannedSerials = Array<String>()
    var scannedCodeArr = Array<String>()
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
    func callApiForRemoveMultipleSerials(willBeRemovedSerials: [String]){
        self.allScannedSerials.append(contentsOf: willBeRemovedSerials)
        self.allScannedSerials = Array(Set(self.allScannedSerials))
        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        //        let arrayRemainingLetters = allSerials.filter {
        //            !first3.contains($0)
        //        }
        if first.count > 0 {
            self.salesOrderByPicking(serials: first.joined(separator: "\\n"))
            self.showSpinner(onView: self.view)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self) //,,,sb-lang2
            return
        }
    }
    func salesOrderByPicking(serials : String){
        if !serials.isEmpty{
            var requestDict = [String:Any]()
            requestDict["type"] = "sales_order_by_picking"
            requestDict["serials_list"] = serials
            requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id")
            requestDict["action"] = "REMOVE"
            
            Utility.POSTServiceCall(type: "SalesOrderByPickingMultipleGS1", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "", isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    if isDone! {
                        let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                        print(responseArray as NSArray)
                        if responseArray.count > 0{
                            if let serialDetailsArray = responseArray as? [[String : Any]]{
                                var sCount = 0
                                var fCount = 0
                                
                                for serialDetails in serialDetailsArray {
                                    if let result = serialDetails["is_ok"] as? Bool{
                                        if result {
                                            let filteredArray = self.serialList.filter { $0["serial_number"] as? String == serialDetails["serial_number"] as? String}
                                            print(filteredArray)
                                            if filteredArray.isEmpty {
                                                fCount+=1
                                            } else {
                                                sCount+=1
                                                let mutableSerialList = (self.serialList as NSArray).mutableCopy() as? NSMutableArray
                                                mutableSerialList?.removeObjects(in:filteredArray)
                                                self.serialList = mutableSerialList as? [[String : Any]] ?? [[String : Any]]()
                                            }
                                        }else{
                                            fCount+=1
                                        }
                                    }else{
                                        fCount+=1
                                    }
                                }
                                Utility.saveObjectTodefaults(key: "VerifiedSalesOrderByPickingArray", dataObject: self.serialList)
                                if Int(sCount)>0 {
                                    //,,,sb-lang2
//                                    Utility.showPopup(Title: Success_Title, Message: "\(Int(sCount)>1 ?"\(sCount) Serials" : "\(sCount) Serial") successfully removed" , InViewC: self)
                                    
                                    Utility.showPopup(Title: Success_Title, Message: "\(Int(sCount)>1 ?"\(sCount) " + "Serials".localized() : "\(sCount) " + "Serial".localized()) " + "successfully removed".localized() , InViewC: self)
                                    //,,,sb-lang2
                                }else if Int(fCount)>0 && Int(sCount)<=0{
                                    Utility.showPopup(Title:"", Message: "Please check the product that you scan for remove are already deleted or exist in the picking items.".localized(), InViewC: self)//,,,sb-lang2

                                }//\n\(Int(fCount)>1 ?"\(fCount) Serials" : "\(fCount) Serial") failed to removed
                                self.serialListTable.reloadData()
                            }
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)//,,,sb-lang2
                        }
                    }else{
                        if responseData != nil{
                            let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                            let errorMsg = responseDict["message"] as! String
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                    }
                    self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
                    
                    let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
                    //        let arrayRemainingLetters = allSerials.filter {
                    //            !first3.contains($0)
                    //        }
                    if first.count > 0 {
                        self.salesOrderByPicking(serials: first.joined(separator: "\\n"))
                    }else{
                        self.removeSpinner()
                    }
                }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
    
    func salesOrderByPickingSingle(serialDetails : [String : Any]){
        if let serial = serialDetails["serial_number"] as? String{
            self.showSpinner(onView: self.view)
            var requestDict = [String:Any]()
            requestDict["type"] = "sales_order_by_picking"
            requestDict["serial"] = serial
            requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id")
            requestDict["action"] = "REMOVE"
            var type = ""
            if let product_uuid = serialDetails["product_uuid"] as? String{
                if product_uuid.isEmpty{
                    type = "SalesOrderByPickingAggregationSerial"
                }else{
                    type = "SalesOrderByPickingGS1"
                    requestDict["product_uuid"] = product_uuid
                }
            }
            
            Utility.POSTServiceCall(type: type, serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "", isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                        print(responseDict as NSDictionary)
                        if (responseDict["action"] as? String) != nil  {
                            if let s_No = responseDict["serial_number"] as? String{
                                if(s_No == serial){
                                    if(self.serialList as NSArray).contains(serialDetails){
                                        let mutableSerialList = (self.serialList as NSArray).mutableCopy() as? NSMutableArray
                                        mutableSerialList?.remove(serialDetails)
                                        self.serialList = mutableSerialList as? [[String : Any]] ?? [[String : Any]]()
                                        Utility.saveObjectTodefaults(key: "VerifiedSalesOrderByPickingArray", dataObject: self.serialList)
                                        Utility.showPopup(Title: Success_Title, Message: "Serial successfully deleted.".localized() , InViewC: self) //,,,sb-lang2
                                    }
                                    self.serialListTable.reloadData()
                                }
                            }
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self) //,,,sb-lang2
                        }
                    }else{
                        if responseData != nil{
                            let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                            let errorMsg = responseDict["message"] as! String
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                    }
                    self.serialListTable.reloadData()
                }
            }
            
        }else{
            DispatchQueue.main.async{
                Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self) //,,,sb-lang2
                return
            }
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to remove this serial?".localized() //,,,sb-lang2
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
        return serialList.count    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickingSerialListTableViewCell") as! PickingSerialListTableViewCell
        
        let dataDict:NSDictionary = serialList[indexPath.row] as NSDictionary
        
        var dataStr = ""
        
        if let name = dataDict["serial_number"] as? String{
            dataStr = name
        }
        cell.serialLabel.text = dataStr
        
        dataStr = ""
        
        if let str = dataDict["gtin14"] as? String{
            dataStr = str
        }
        
        cell.gtin14Label.text = dataStr
        
        if let str = dataDict["product_ndc"] as? String{
            dataStr = str
        }
        
        cell.ndcLabel.text = dataStr
        
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        cell.expirationDateLabel.text = ""
        if let exDate = dataDict["expiration_date"] as? String{
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: exDate){
                cell.expirationDateLabel.text = formattedDate
                
            }
        }
        
        cell.deleteButton.tag = indexPath.row
        
        return cell
        
    }
    //MARK: - End
    
    
}
class PickingSerialListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var ndcLabel: UILabel!
    @IBOutlet weak var gtin14Label: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet var multiLingualViews: [UIView]!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
extension PickingSerialListViewController : ScanViewControllerDelegate{
    func didScanCodeForRemoveMultiple(willBeRemovedSerials: [String]) {
//        print(willBeRemovedSerials as [String])
//        print(scannedCodeArr)
//        var willRemoveArr = Array<String>()
//
//        for str in willBeRemovedSerials{
//            if scannedCodeArr.contains(str){
//                willRemoveArr.append(str)
//            }
//        }
//        if !(willRemoveArr.count>0){
//            Utility.showPopup(Title:"", Message: "Please scan all those product that added in picking items.", InViewC: self)
//        }
        DispatchQueue.main.async{
            self.callApiForRemoveMultipleSerials(willBeRemovedSerials: willBeRemovedSerials)
        }
    }
}
extension PickingSerialListViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForRemoveMultiple(willBeRemovedSerials: [String]) {
        print(willBeRemovedSerials as [String])
        DispatchQueue.main.async{
            self.callApiForRemoveMultipleSerials(willBeRemovedSerials: willBeRemovedSerials)
        }
    }
}
//MARK: - ConfirmationViewDelegate
extension PickingSerialListViewController : ConfirmationViewDelegate{
    func doneButtonPressed() {
    }
    func doneButtonPressedWithIndex(index: Int) {
        let serialDetails = serialList[index]
        self.salesOrderByPickingSingle(serialDetails:serialDetails)
    }
    func cancelConfirmation() {
        self.serialListTable.reloadData()
    }
}
