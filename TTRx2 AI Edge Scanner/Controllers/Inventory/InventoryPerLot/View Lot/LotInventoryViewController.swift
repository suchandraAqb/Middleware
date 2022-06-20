//
//  LotInventoryViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 29/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class LotInventoryViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationFieldView: UIView!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var stockView: UIView!
    @IBOutlet weak var availableView: UIView!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var itemsNotAvailableLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var allocatedLabel: UILabel!
    @IBOutlet weak var quarantineLabel: UILabel!
    @IBOutlet weak var lockedLabel: UILabel!
    @IBOutlet weak var toBeReceivedLabel: UILabel!
    @IBOutlet weak var totalItemsNotAvailableLabel: UILabel!
    
    //chayan
    @IBOutlet var viewLotsButton: UIButton!
    
    
    var productUuid = ""
    var lotNumber = ""
    var itemsList: [[String: Any]] = []
    var allLocationList = [[String : Any]]()
    var allLocations:NSDictionary?
    var locationUuid = ""
    var storageAreaUuid = ""
    var forStorageArea = false
    var isForItemsInInventory = false
    
    //chayan
    var isShowViewLotButton = false
    
    var itemsInInventoryDetailsDict = [String:Any]()
    
    var appendStr = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        
        locationView.setRoundCorner(cornerRadious: 10)
        locationFieldView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        stockView.setRoundCorner(cornerRadious: 10)
        availableView.setRoundCorner(cornerRadious: 10)
        detailsView.setRoundCorner(cornerRadious: 10)
        
        getAllLocation()
        
        locationLabel.text = "Global".localized()
        locationLabel.accessibilityHint = ""
        locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
        
        locationView.isHidden = false
        
        
        if isForItemsInInventory{
            if forStorageArea {
                backButton.setTitle("Lot In Storage Area".localized(), for: .normal)
                locationView.isHidden = true
            }else{
                backButton.setTitle("Product Inventory Details".localized(), for: .normal)
                locationView.isHidden = false
            }
        }else{
            if forStorageArea {
                backButton.setTitle("Lot in Storage Area".localized(), for: .normal)
                locationView.isHidden = true
            }
        }
        
        
        //chayan
        if isShowViewLotButton {
            viewLotsButton.isHidden=false
        }else{
            viewLotsButton.isHidden=true
        }
        
        
        
        
        getListWithQueryParam()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    //MARK: - Private method
    func getAllLocation (){
        allLocations = UserInfosModel.getLocations()
        let globDict = ["name" : "Global".localized(), "value" : ""]
        allLocationList.append(globDict)
        for (key, val) in allLocations! {
            if let valDict = val as? [String: Any] {
                if let txt = valDict["name"] as? String,!txt.isEmpty{
                    let globDict = ["name" : txt, "value" : key as! String]
                    allLocationList.append(globDict)
                }
            }
        }
    }
    
    func PopulateDetails(){
        
        if isForItemsInInventory , !forStorageArea{
            if !self.itemsInInventoryDetailsDict.isEmpty {
                print(self.itemsInInventoryDetailsDict)
                if let txt = self.itemsInInventoryDetailsDict["qty_in_stock"] as? NSNumber{
                    stockLabel.text="\(txt)"
                }
                if let txt = self.itemsInInventoryDetailsDict["get_total_unavailable_items"] as? NSNumber{
                    itemsNotAvailableLabel.text="\(txt)"
                }
                if let txt = self.itemsInInventoryDetailsDict["get_total_available_items"] as? NSNumber{
                    availableLabel.text="\(txt)"
                }
                if let txt = self.itemsInInventoryDetailsDict["get_qty_allocated"] as? NSNumber{
                    allocatedLabel.text="\(txt)"
                }
                if let txt = self.itemsInInventoryDetailsDict["get_qty_quarantined"] as? NSNumber{
                    quarantineLabel.text="\(txt)"
                }
                if let txt = self.itemsInInventoryDetailsDict["get_qty_locked"] as? NSNumber{
                    lockedLabel.text="\(txt)"
                }
                if let txt = self.itemsInInventoryDetailsDict["get_qty_to_be_received"] as? NSNumber{
                    toBeReceivedLabel.text="\(txt)"
                }
                if let txt = self.itemsInInventoryDetailsDict["get_total_unavailable_items"] as? NSNumber{
                    totalItemsNotAvailableLabel.text="\(txt)"
                }
            } else {
                stockLabel.text = "0"
                itemsNotAvailableLabel.text = "0"
                availableLabel.text = "0"
                allocatedLabel.text = "0"
                quarantineLabel.text = "0"
                lockedLabel.text = "0"
                toBeReceivedLabel.text = "0"
                totalItemsNotAvailableLabel.text = "0"
            }
        }else{
            if !self.itemsList.isEmpty && self.itemsList.count > 0 {
                let dataDict = self.itemsList[0]
                print(dataDict)
                if let txt = dataDict["qty_in_stock"] as? NSNumber{
                    stockLabel.text="\(txt)"
                }
                if let txt = dataDict["get_total_unavailable_items"] as? NSNumber{
                    itemsNotAvailableLabel.text="\(txt)"
                }
                if let txt = dataDict["get_total_available_items"] as? NSNumber{
                    availableLabel.text="\(txt)"
                }
                if let txt = dataDict["get_qty_allocated"] as? NSNumber{
                    allocatedLabel.text="\(txt)"
                }
                if let txt = dataDict["get_qty_quarantined"] as? NSNumber{
                    quarantineLabel.text="\(txt)"
                }
                if let txt = dataDict["get_qty_locked"] as? NSNumber{
                    lockedLabel.text="\(txt)"
                }
                if let txt = dataDict["get_qty_to_be_received"] as? NSNumber{
                    toBeReceivedLabel.text="\(txt)"
                }
                if let txt = dataDict["get_total_unavailable_items"] as? NSNumber{
                    totalItemsNotAvailableLabel.text="\(txt)"
                }
                
                /*
                if let txt = (self.itemsList as NSArray).value(forKeyPath: "@sum.qty_in_stock")  as? NSNumber{
                    stockLabel.text = "\(txt.intValue)"
                }
                if let txt = (self.itemsList as NSArray).value(forKeyPath: "@sum.get_total_unavailable_items")  as? NSNumber{
                    itemsNotAvailableLabel.text = "\(txt.intValue)"
                }
                if let txt = (self.itemsList as NSArray).value(forKeyPath: "@sum.get_total_available_items")  as? NSNumber{
                    availableLabel.text = "\(txt.intValue)"
                }
                if let txt = (self.itemsList as NSArray).value(forKeyPath: "@sum.get_qty_allocated")  as? NSNumber{
                    allocatedLabel.text = "\(txt.intValue)"
                }
                if let txt = (self.itemsList as NSArray).value(forKeyPath: "@sum.get_qty_quarantined")  as? NSNumber{
                    quarantineLabel.text = "\(txt.intValue)"
                }
                if let txt = (self.itemsList as NSArray).value(forKeyPath: "@sum.get_qty_locked")  as? NSNumber{
                    lockedLabel.text = "\(txt.intValue)"
                }
                if let txt = (self.itemsList as NSArray).value(forKeyPath: "@sum.get_qty_to_be_received")  as? NSNumber{
                    toBeReceivedLabel.text = "\(txt.intValue)"
                }
                if let txt = (self.itemsList as NSArray).value(forKeyPath: "@sum.get_total_unavailable_items")  as? NSNumber{
                    totalItemsNotAvailableLabel.text = "\(txt.intValue)"
                }
                */
 
 
 
            } else {
                stockLabel.text = "0"
                itemsNotAvailableLabel.text = "0"
                availableLabel.text = "0"
                allocatedLabel.text = "0"
                quarantineLabel.text = "0"
                lockedLabel.text = "0"
                toBeReceivedLabel.text = "0"
                totalItemsNotAvailableLabel.text = "0"
            }
        }
        
        
        
    }
    //MARK: - End
    
    //MARK: - Action
    
    @IBAction func locationSelectButtonPressed(_ sender: UIButton) {
        doneTyping()
        
         if allLocationList.count == 0 {
             return
         }
         
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
         controller.isDataWithDict = false
         controller.nameKeyName = "name"
         controller.listItems = allLocationList
         controller.type = "Locations".localized()
         controller.delegate = self
         controller.sender = sender
         controller.modalPresentationStyle = .custom
             
         self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func locationScanButtonPressed(_ sender: UIButton) {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
                controller.delegate = self
                controller.isForLocationSelection=true
                self.navigationController?.pushViewController(controller, animated: true)
                
                /*
                     "b592af47-4319-4739-824b-9ca8d93d34cc"
                     "6d72602d-6843-4adc-aedb-5d147d84ffa5"
                     "c02d4563-1a29-4df9-b7f9-311eca2a9868"
                     "166411fc-9cc4-42e3-836e-56a11c87a5f7"
                     "823d8e69-5842-4ec8-b281-a6ab4838a298"
                 */
//                self.didReceiveBarcodeLocationScan(codeDetails: ["scannedCodes":"823d8e69-5842-4ec8-b281-a6ab4838a298"])

    }

    
    
    @IBAction func viewLotsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsInInventoryLotListView") as! ItemsInInventoryLotListViewController
        controller.productUuid = productUuid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    //MARK: - End
    
    //MARK: - Call API
    
    func getListWithQueryParam() {
        
        if isForItemsInInventory {
            if forStorageArea {
                appendStr = "\(productUuid)/lots/storage_area?is_wrap_results_in_generic_search_object=true&storage_area_uuid=\(storageAreaUuid)&lot=\(lotNumber)&is_convert_lowest_sealable_unit=false&_=\(Date().currentTimeMillis())"
            }else{
                appendStr = "\(productUuid)/inventory?location_uuid=\(locationUuid)&is_convert_lowest_sealable_unit=false&_=\(Date().currentTimeMillis())"
            }
        }else{
            if forStorageArea {
                appendStr = "\(productUuid)/lots/storage_area?is_wrap_results_in_generic_search_object=true&storage_area_uuid=\(storageAreaUuid)&lot=\(lotNumber)&sort_by_asc=true&nb_per_page=1000&page=1&_=\(Date().currentTimeMillis())"
            }else{
                appendStr = "\(productUuid)/lots?is_wrap_results_in_generic_search_object=true&location_uuid=\(locationUuid)&lot=\(lotNumber)&sort_by_asc=true&nb_per_page=1000&page=1&_=\(Date().currentTimeMillis())"
            }
        }
        
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetProducts", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if self.isForItemsInInventory , !self.forStorageArea {
                            self.itemsInInventoryDetailsDict = responseDict
                            self.PopulateDetails()
                        }else{
                            if let dataArray = responseDict["data"] as? [[String: Any]] {
                                self.itemsList += dataArray
                                self.PopulateDetails()
                            }
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
        
    //MARK: End
    
    

    //MARK: - SingleSelectDropdownDelegate
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if let name = data["name"] as? String , let valuestr = data["value"] as? String {
            if valuestr != locationUuid {
                locationLabel.text = name
                locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                
                locationLabel.accessibilityHint = valuestr
                locationUuid = valuestr
                
                itemsList = []
                getListWithQueryParam()
            }
        }
    }
    
    //MARK: - End

}

//MARK: - Scan view delegate
extension LotInventoryViewController:SingleScanViewControllerDelegate{
    func didReceiveBarcodeLocationScan(codeDetails:[String:Any]){
        let locationCode = codeDetails["scannedCodes"] as! String
        print(locationCode)
        let predicate = NSPredicate(format:"value='\(locationCode)'")
        let filterArray = (allLocationList as NSArray).filtered(using: predicate)
        if filterArray.count>0 {
            let dict=filterArray[0]
            let btn=UIButton()
            self.selecteditem(data: dict as! NSDictionary,sender:btn)
        }else{
            Utility.showPopup(Title: "Error!", Message: "Selected location is not available.".localized() , InViewC: self)
        }
    }
}
