//
//  DashboardViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 15/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData

class DashboardViewController: BaseViewController, ConfirmationViewDelegate/*, MWPuchaseOrderListViewControllerDelegate*/ {
    
    @IBOutlet weak var serialFinderView: UIView!
    @IBOutlet weak var receivingView: UIView!
    @IBOutlet weak var pickingView: UIView!
    @IBOutlet weak var returnsView: UIView!
    @IBOutlet weak var inventoryView: UIView!
    
    @IBOutlet weak var transferView: UIView!
    @IBOutlet weak var quarantineView: UIView!
    @IBOutlet weak var destructionView: UIView!
    @IBOutlet weak var dispenseView: UIView!
    @IBOutlet weak var manufacturerView: UIView!
    @IBOutlet weak var commissionSerialsView: UIView!
    
    @IBOutlet var missingStolenView: UIView!
    @IBOutlet var missingStolenLabel: UILabel!
    @IBOutlet weak var shipmentView: UIView!
    @IBOutlet weak var shipmentLabel: UILabel!
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var dashboardButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var inventoryLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var SFLabel: UILabel!
    
    
    @IBOutlet weak var receivingLabel: UILabel!
    @IBOutlet weak var pickingLabel: UILabel!
    @IBOutlet weak var returnsButtonLabel: UILabel!
    @IBOutlet weak var inventoryButtonLabel: UILabel!
    @IBOutlet weak var transferLabel: UILabel!
    @IBOutlet weak var quarantineLabel: UILabel!
    @IBOutlet weak var destructionLabel: UILabel!
    @IBOutlet weak var dispenseLabel: UILabel!
    @IBOutlet weak var manufactureLabel: UILabel!
    @IBOutlet weak var commissionSerialLabel: UILabel!
    
    @IBOutlet weak var receivingSelectionView: UIView!
    @IBOutlet weak var receivingSelectionSubView: UIView!
    @IBOutlet var myAccountView: UIView!
    @IBOutlet var myAccountLabel: UILabel!
    @IBOutlet var eventsView: UIView!
    @IBOutlet var eventsLabel: UILabel!
    
    @IBOutlet weak var sessioninfoButton:UIButton!

    static var repeatTimer:Timer?
    

    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    /////////////////////////////////////////////////////////////
    //MARK: - View Life Cycle -
    override func loadView() {
        super.loadView()
        serialFinderView.setRoundCorner(cornerRadious: 20.0)
        receivingView.setRoundCorner(cornerRadious: 20.0)
        pickingView.setRoundCorner(cornerRadious: 20.0)
        inventoryView.setRoundCorner(cornerRadious: 20.0)
        returnsView.setRoundCorner(cornerRadious: 20.0)
        transferView.setRoundCorner(cornerRadious: 20.0)
        quarantineView.setRoundCorner(cornerRadious: 20.0)
        destructionView.setRoundCorner(cornerRadious: 20.0)
        dispenseView.setRoundCorner(cornerRadious: 20.0)
        manufacturerView.setRoundCorner(cornerRadious: 20.0)
        commissionSerialsView.setRoundCorner(cornerRadious: 20.0)
        sectionView.roundTopCorners(cornerRadious: 40)
        //receivingSelectionSubView.roundTopCorners(cornerRadious: 40)
        shipmentView.setRoundCorner(cornerRadious: 20.0)
        myAccountView.setRoundCorner(cornerRadious: 20.0)
        missingStolenView.setRoundCorner(cornerRadious: 20.0)
        eventsView.setRoundCorner(cornerRadious: 20.0)
        sessioninfoButton.setRoundCorner(cornerRadious: sessioninfoButton.frame.size.height/2)
        
    

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view.
        //Added For Return Serial Verification
        let verificationModel = ReturnVerificationModel.ReturnVerificationObj
        if !verificationModel.isCheckingInprogress{
            verificationModel.checkForUpdate()
        }
        //End
        var domainName = ""
        if let domaintstr =  defaults.object(forKey: "domainname") as? String {
            domainName = domaintstr
        }
      //  let str = clientFriendlyName + "\n" + "Version - \((Bundle.main.shortVersion))"
        let str = domainName + "\n" + "Version - \("22.1")"
        versionLabel.text = str
   
        let userName = (defaults.value(forKey: "userName") ?? "") as! String
        nameLabel.text = "Hello, \(userName)"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUILanguage()
  
    }
    
    //MARK: - End
    
    //MARK: - Private function
    
    func removeDefaultsObject(){
        if (defaults.object(forKey: "ScanFailedItemsArray") != nil){
            defaults.removeObject(forKey: "ScanFailedItemsArray")
        }
        if (defaults.object(forKey: "AdjustmentVerifiedArray") != nil){
            defaults.removeObject(forKey: "AdjustmentVerifiedArray")
        }
        if (defaults.object(forKey: "SalesByPickingVerifiedArray") != nil){
            defaults.removeObject(forKey: "SalesByPickingVerifiedArray")
        }
        if (defaults.object(forKey: "FailedSalesOrderByPickingArray") != nil){
            defaults.removeObject(forKey: "FailedSalesOrderByPickingArray")
        }
        if (defaults.object(forKey: "InventoryVerifiedArray") != nil){
            defaults.removeObject(forKey: "InventoryVerifiedArray")
        }
        
        defaults.removeObject(forKey: "accesstoken")
        defaults.removeObject(forKey: "refreshtoken")
        defaults.removeObject(forKey: "domainname")
        defaults.removeObject(forKey: "configSet")
        defaults.removeObject(forKey: "sub")
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "password")
    }
    
    //MARK: - End
    
    ////////////////////////////////////////////////////////////
    //MARK: - TIMER FUNCTIONS
    func initializeTimer(userinfo:UserInfosModel){
        DashboardViewController.repeatTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { timer in
            print("All User Info Updated")
            userinfo.getAllUserInfos { (isDone:Bool?) in
                if let name = userinfo.userName {
                    self.nameLabel.text = name
                    defaults.set(name, forKey: "fullname")
                    self.nameLabel.isHidden = true
                }else{
                    self.nameLabel.isHidden = true
                }
            }
        }
    }
    
    func removeTimer(){
        if DashboardViewController.repeatTimer != nil {
            DashboardViewController.repeatTimer?.invalidate()
            DashboardViewController.repeatTimer = nil
        }
    }
    //MARK: - End
    ////////////////////////////////////////////////////////////
    //MARK: - LogOut
    func logoutWebServiceCall(){
        self.showSpinner(onView: self.view)
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"Logout")
        requestDict["sub"] = defaults.object(forKey: "sub")
        
        Utility.POSTServiceCall(type: "Logout", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                self.removeTimer()
                self.removeDefaultsObject()
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ThirdView") as! ThirdViewController
                self.navigationController?.pushViewController(controller, animated: false)
                //self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func updateUILanguage(){
        
        dashboardButton.setTitle("Dashboard".localized(), for: .normal)
       // logoutButton.setTitle("Logout".localized(), for: .normal)
        inventoryLabel.text = "Inventory".localized()
        inventoryButtonLabel.text = "Inventory".localized()
        transactionLabel.text = "Transaction".localized()
        SFLabel.text = "SerialFinder".localized()
        receivingLabel.text = "Receiving".localized()
        pickingLabel.text = "Picking".localized()
        SFLabel.text = "SerialFinder".localized()
        returnsButtonLabel.text = "Returns(VRS)".localized()
        transferLabel.text = "Transfer".localized()
        quarantineLabel.text = "Quarantine".localized()
        destructionLabel.text = "Destruction".localized()
        dispenseLabel.text = "Dispense".localized()
        manufactureLabel.text = "Manufacturer".localized()
        commissionSerialLabel.text = "CommSerials".localized()
        
        shipmentLabel.text = "Shipment".localized()
        missingStolenLabel.text = "Missing / Stolen".localized()

        myAccountLabel.text = "My Account".localized()
        eventsLabel.text = "Events".localized()
    }
    
    //MARK: - End
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        logoutWebServiceCall()
    }
    func staffMgtList(){
        self.showSpinner(onView: self.view)
        UserInfosModel.UserInfoShared.staffMgtGetApiCall { isDone, itemArr in
            self.removeSpinner()
        }
    }
    //MARK: - End -
}
////////////////////////////////////////////
//MARK: - API CALL -
extension DashboardViewController {
    //MARK: - Get Individual Product
    func getIndividualProduct(code : String){
        if !code.isEmpty{
            let  appendStr = "?gs1_barcode=\(code)&is_include_suggested_inbound_shipments=true&is_include_inbound_shipment_informations=true&perform_search_on=NOT_RECEIVED_INVENTORY_ONLY"//NOT_RECEIVED_INVENTORY_ONLY" //"?gs1_barcode=*0101369120751100211000007*1720112910LOTB00002&is_include_suggested_inbound_shipments=true&is_include_inbound_shipment_informations=true"
            
            self.showSpinner(onView: self.view)
            let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            Utility.GETServiceCall(type: "GetIndividualProduct", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: escapedString) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                        if responseArray.count > 0{
                            let responseDict: NSDictionary = responseArray.firstObject as? NSDictionary ?? NSDictionary()
                            if let inbound_shipment_information = responseDict["inbound_shipment_information"] as? [String : Any] {
                                if let is_received = inbound_shipment_information["is_received"] as? Bool{
                                    if is_received{
                                        Utility.showAlertWithPopAction(Title: App_Title, Message: "Shipment already received.", InViewC: self, isPop: true, isPopToRoot: true)
                                        return
                                    }else{
                                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentDetailsView") as! ShipmentDetailsViewController
                                        controller.shipmentId = inbound_shipment_information["inbound_shipment_uuid"] as? String
                                        controller.delegate = self
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                            }else{
                                if let suggested_inbound_shipments = responseDict["suggested_inbound_shipments"] as? [[String : Any]], !suggested_inbound_shipments.isEmpty {
                                    print(suggested_inbound_shipments)
                                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentsListView") as! ShipmentsListViewController
                                    controller.itemsList = suggested_inbound_shipments
                                    self.navigationController?.pushViewController(controller, animated: true)
                                }else{
                                    Utility.showPopup(Title: App_Title, Message: "Shipment not found or already received", InViewC: self)
                                }
                            }
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later." , InViewC: self)
                        }
                        print(Utility.json(from: [responseArray])!)
                        
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
    }
    //MARK: - End
    /////////////////////////////////////////////////////
    //MARK: - Post Return
    func searchShipmentForReturns(serial : String){
        self.showSpinner(onView: self.view)
        if !serial.isEmpty{
            var requestDict = [String:Any]()
            requestDict["source_type"] = "PRODUCT_SERIAL"
            requestDict["serial_type"] = "GS1_BARCODE"
            requestDict["value"] = serial
            
            
            Utility.POSTServiceCall(type: "SearchShipmentForReturns", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                        if let uuid = responseDict["uuid"] as? String{
                            let storyboard = UIStoryboard(name: "Return", bundle: .main)
                            let controller = storyboard.instantiateViewController(withIdentifier: "OutboundShipmentDetailsView") as! OutboundShipmentDetailsViewController
                            controller.returnUuid = uuid
                            
                            if let source_shipment = responseDict["source_shipment"] as? NSDictionary {
                                controller.outboundShipment = source_shipment
                            }
                            self.navigationController?.pushViewController(controller, animated: true)
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
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
}
//MARK: - End
/////////////////////////////////////////////////
//MARK: - DASHBOARD IBAction -
extension DashboardViewController {
    @IBAction func shipmentButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Shipments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ShipmentOptionView") as! ShipmentOptionViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func arButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ARMessageListViewController") as! ARMessageListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "LogoutMsg".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func SFButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "FinderView") as! FinderViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func ReceivingButtonPressed(_ sender: UIButton) {
        //,,,sbm1
        /*
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingSelectionViewController") as! ReceivingSelectionViewController
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
        */
        
        /*
        let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWERPListViewController") as! MWERPListViewController
        self.navigationController?.pushViewController(controller, animated: true)
        */
        
        
        
        
        
        //,,,sbm2
        var directSerialLineItemsListArray : [MWViewItemsModel] = []
        do{
            let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and product_flow_type='directSerialScanEntry' and is_edited=true")

            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                directSerialLineItemsListArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    directSerialLineItemsListArray.append(cdModel.convertCoreDataRequestsToMWViewItemsModel())
                })
            }
        }catch let error{
            print(error.localizedDescription)
            directSerialLineItemsListArray = []
        }
        //,,,sbm2
        
        //,,,sbm2
        var directLotLineItemsListArray : [MWViewItemsModel] = []
        do{
            let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and product_flow_type='directManualLotEntry' and is_edited=true")

            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                directLotLineItemsListArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    directLotLineItemsListArray.append(cdModel.convertCoreDataRequestsToMWViewItemsModel())
                })
            }
        }catch let error{
            print(error.localizedDescription)
            directLotLineItemsListArray = []
        }
        //,,,sbm2
        
        
        if directSerialLineItemsListArray.count > 0 {
            let lineItem = directSerialLineItemsListArray[0]
            let selectedPuchaseOrderDict = MWPuchaseOrderModel(erpUUID: lineItem.erpUUID,
                                                          erpName: lineItem.erpName,
                                                          uniqueID: lineItem.poUniqueID,
                                                          poNumber: lineItem.poNumber,
                                                          createdOn: "",
                                                          vendor: "",
                                                          location: "")

            let storyboard = UIStoryboard(name: "MWReceiving", bundle: Bundle.main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialListViewController") as! MWReceivingSerialListViewController
            controller.flowType = "directSerialScan"
            controller.selectedPuchaseOrderDict = selectedPuchaseOrderDict
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if directLotLineItemsListArray.count > 0 {
            let lineItem = directLotLineItemsListArray[0]
            let selectedPuchaseOrderDict = MWPuchaseOrderModel(erpUUID: lineItem.erpUUID,
                                                          erpName: lineItem.erpName,
                                                          uniqueID: lineItem.poUniqueID,
                                                          poNumber: lineItem.poNumber,
                                                          createdOn: "",
                                                          vendor: "",
                                                          location: "")
            
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingManuallyViewController") as! MWReceivingManuallyViewController
            controller.flowType = "directManualLot"
            controller.selectedPuchaseOrderDict = selectedPuchaseOrderDict
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else {
            //        let dict = erpListArray[indexPath.section]
                    let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
                    let controller = storyboard.instantiateViewController(withIdentifier: "MWPuchaseOrderListViewController") as! MWPuchaseOrderListViewController
            //        controller.delegate = self
            //        controller.erpDict = dict
                    self.navigationController?.pushViewController(controller, animated: true)
        }
        //,,,sbm1
    }
    @IBAction func PickingButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Picking", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "PickingOptionsView") as! PickingOptionsViewController
        controller.modalPresentationStyle = .custom
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func InventoryButtonPressed(_ sender: UIButton) {
        //let msg = "Please confirm your scanning option."
        let storyboard = UIStoryboard.init(name: "Inventory", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "InventoryHomeView") as! InventoryHomeViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
        /*  let confirmAlert = UIAlertController(title: "".localized(), message: "", preferredStyle: .actionSheet)
         let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
         let singleAction = UIAlertAction(title: "Single Scan".localized(), style: .default, handler: { (UIAlertAction) in
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
         controller.isForInventory = true
         self.navigationController?.pushViewController(controller, animated: true)
         })
         
         let multiAction = UIAlertAction(title: "Multi Scan".localized(), style: .default, handler: { (UIAlertAction) in
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
         controller.isForInventory = true
         controller.delegate = self
         self.navigationController?.pushViewController(controller, animated: true)
         })
         
         confirmAlert.addAction(cancelAction)
         confirmAlert.addAction(singleAction)
         confirmAlert.addAction(multiAction)
         self.navigationController?.present(confirmAlert, animated: true, completion: nil)*/
        
    }
    @IBAction func ReturnsButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Return", bundle: .main)
        do{
            let return_obj = try PersistenceService.context.fetch(Return.activeFetchRequest)
            if !return_obj.isEmpty{
                //print(return_obj.first!.uuid!)
                print("Active Return Existt")
                let controller = storyboard.instantiateViewController(withIdentifier: "ReturnGeneralInfoView") as! ReturnGeneralInfoViewController
                self.navigationController?.pushViewController(controller, animated: true)
            }else{
                let controller = storyboard.instantiateViewController(withIdentifier: "ReturnProductTypeSelectionVC") as! ReturnProductTypeSelectionVC
                controller.modalPresentationStyle = .custom
                controller.selectedProduct = {
                    isLotbased in
                    if isLotbased{
                        print("LotBased")
                        let controller = storyboard.instantiateViewController(withIdentifier: "ReturnProductListVC") as! ReturnProductListVC
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }else{
                        print("SerialBased")
                        let controller = storyboard.instantiateViewController(withIdentifier: "ReturnShipmentSelectionView") as! ReturnShipmentSelectionViewController
                        controller.delegate = self
                        controller.modalPresentationStyle = .custom
                        self.present(controller, animated: true, completion: nil)
                    }
                }
                self.present(controller, animated: true, completion: nil)
            }
        }catch let error{
            print(error.localizedDescription)
            let controller = storyboard.instantiateViewController(withIdentifier: "ReturnProductTypeSelectionVC") as! ReturnProductTypeSelectionVC
            controller.modalPresentationStyle = .custom
            controller.selectedProduct = {
                isLotbased in
                if isLotbased{
                    print("LotBased")
                    let controller = storyboard.instantiateViewController(withIdentifier: "ReturnProductListVC") as! ReturnProductListVC
                    self.navigationController?.pushViewController(controller, animated: true)
                    
                }else{
                    print("SerialBased")
                    let controller = storyboard.instantiateViewController(withIdentifier: "ReturnShipmentSelectionView") as! ReturnShipmentSelectionViewController
                    controller.delegate = self
                    controller.modalPresentationStyle = .custom
                    self.present(controller, animated: true, completion: nil)
                }
            }
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func transferButtonPressed(_ sender: UIButton) {
//            let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
//            let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentScanView") as! AdjustmentScanViewController
//            controller.adjustmentType = Adjustments_Types.Transfer.rawValue
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentGeneralView") as! AdjustmentGeneralViewController
        controller.adjustmentType = Adjustments_Types.Transfer.rawValue
        self.navigationController?.pushViewController(controller, animated: true)

    }
    @IBAction func quarantineButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "QuarantineOptionView") as! QuarantineOptionViewController
        controller.modalPresentationStyle = .custom
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
    }
    @IBAction func destructionButtonPressed(_ sender: UIButton) {
//        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
//        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentScanView") as! AdjustmentScanViewController
//        controller.adjustmentType = Adjustments_Types.Destruction.rawValue
//        self.navigationController?.pushViewController(controller, animated: true)
        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentGeneralView") as! AdjustmentGeneralViewController
        controller.adjustmentType = Adjustments_Types.Destruction.rawValue
        self.navigationController?.pushViewController(controller, animated: true)
//
    }
    @IBAction func dispenseButtonPressed(_ sender: UIButton) {
//        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
//        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentScanView") as! AdjustmentScanViewController
//        controller.adjustmentType = Adjustments_Types.Dispense.rawValue
//        self.navigationController?.pushViewController(controller, animated: true)
        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentGeneralView") as! AdjustmentGeneralViewController
        controller.adjustmentType = Adjustments_Types.Dispense.rawValue
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func missingStolenButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentGeneralView") as! AdjustmentGeneralViewController
        controller.adjustmentType = Adjustments_Types.MissingStolen.rawValue
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func manufacturerButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Manufacturer", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ManufacturerProductListView") as! ManufacturerProductListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func commissionSerialsButtonPressed(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.init(name: "CommisionsSerials", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "LotsCommissionListView") as! LotsCommissionListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func myAccountButtonPressed(_ sender: UIButton){
        let storyboard = UIStoryboard.init(name: "MyAccount", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MyAccountOption") as! MyAccountOptionViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func eventsButtonPressed(_ sender: UIButton){
        let storyboard = UIStoryboard.init(name: "Shipments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "EventsOptionView") as! EventsOptionViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func sessionInfoPressed(_ sender:UIButton){
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "SessionInfoView") as! SessionInfoViewController
        storyboard.modalTransitionStyle = .flipHorizontal
        self.present(storyboard, animated: true, completion: nil)
    }
   
    
    
    
    /*
     @IBAction func closeReceivingSelectionView(_ sender: UIButton) {
     UIView.transition(with: receivingSelectionView, duration: 0.4,
     options: .curveEaseInOut,
     animations: {
     self.receivingSelectionView.isHidden = true
     })
     }
     
     @IBAction func startReceivingScanButtonPressed(_ sender: Any){
     closeReceivingSelectionView(UIButton())
     let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
     controller.isForEndPointURLScan = false
     controller.delegate = self
     self.navigationController?.pushViewController(controller, animated: true)
     }
     
     
     @IBAction func searchManuallyButtonPressed(_ sender: UIButton) {
     closeReceivingSelectionView(UIButton())
     let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingLotSearchView") as! ReceivingLotSearchViewController
     self.navigationController?.pushViewController(controller, animated: true)
     
     }
     */
    
    
}
//MARK: - End -
/////////////////////////////////////////
//MARK: - PROTOCOL EXTENSIONS -
extension DashboardViewController : ScanViewControllerDelegate{
    func didScanCodeForReceive(codeDetails: [String : Any]) {
        print(codeDetails["scannedCode"] as Any)
        self.getIndividualProduct(code: codeDetails["scannedCode"] as! String)
    }
    func didScanCodeForReturnShipmentSearch(codeDetails: [String : Any]) {
        print(codeDetails["scannedCode"] as Any)
        self.searchShipmentForReturns(serial:codeDetails["scannedCode"] as! String)
    }
}
extension DashboardViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForReceive(codeDetails: [String : Any]){
        print(codeDetails["scannedCode"] as Any)
        self.getIndividualProduct(code: codeDetails["scannedCode"] as! String)
    }
    func didSingleScanCodeForReturnShipmentSearch(codeDetails: [String : Any]) {
        print(codeDetails["scannedCode"] as Any)
        self.searchShipmentForReturns(serial:codeDetails["scannedCode"] as! String)
    }
}
extension DashboardViewController : ShipmentDetailsViewControllerDelegate{
    func willScanAgain() {
        if(defaults.bool(forKey: "IsMultiScan")){
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
extension DashboardViewController : ReceivingSelectionViewControllerDelegate {
    func didClickOnCamera(){
        if(defaults.bool(forKey: "IsMultiScan")){
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func didClickOnTrigger(){
        let storyBoard = UIStoryboard.init(name: "Scanner", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "SingleProductMultiScanVC") as! SingleProductMultiScanVC
        //controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didClickOnManualEntry(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingLotSearchView") as! ReceivingLotSearchViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didClickOnManualInboundShipment(){
        
        let storyboard = UIStoryboard.init(name: "ManualInbound", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MISInitialView") as! MISInitialViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
}

extension DashboardViewController : ReturnShipmentSelectionViewControllerDelegate {
    func returnDidClickOnCamera(){
        if(defaults.bool(forKey: "IsMultiScan")){
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
            controller.delegate = self
            controller.isReturnShipmentSearch = true
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
            controller.delegate = self
            controller.isReturnShipmentSearch = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func didClickOnSearchByRMA(){
        
    }
}

extension DashboardViewController : QuarantineOptionViewControllerDelegete {
    
    func didClickOnitemInQuarantineButton() {
        //UnQuarantineSearchViewController
        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "UnQuarantineSearchView") as! UnQuarantineSearchViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didClickOnQuarantineButton() {
//        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
//        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentScanView") as! AdjustmentScanViewController
//        controller.adjustmentType = Adjustments_Types.Quarantine.rawValue
//        self.navigationController?.pushViewController(controller, animated: true)
        
        
        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustmentGeneralView") as! AdjustmentGeneralViewController
        controller.adjustmentType = Adjustments_Types.Quarantine.rawValue
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension DashboardViewController :PickingOptionsViewDelegete  {
    func didClickOnSOByPickingButton() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SelectCustomerView") as! SelectCustomerViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didClickOnPickingBySOButton() {
        let storyboard = UIStoryboard.init(name: "Picking", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "PickingSearchView") as! PickingSearchViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
}
//MARK: - END -
