//
//  PurchaseOrderVC.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 13/05/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData


public var current_shipment_po : String?

class PurchaseOrderVC: BaseViewController {
    
    @IBOutlet weak var step5View: UIView!
    @IBOutlet weak var step4BarViewContainer: UIView!
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var addPOButton: UIButton!
    
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step4Button: UIButton!
    @IBOutlet weak var step5Button: UIButton!
    
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step3BarView: UIView!
    @IBOutlet weak var step4BarView: UIView!
    
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    @IBOutlet weak var step5Label: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    var isFiveStep:Bool!
    
    var shipmentId:String?
    public var responseDict: NSDictionary?
    public var itemsList: [[String: Any]] = []
    public var ship_lines_item: [[String: Any]] = []
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shipmentId = defaults.string(forKey: "shipmentId")
        
        self.sectionView.roundTopCorners(cornerRadious: 40)
        addPOButton.setRoundCorner(cornerRadious: addPOButton.frame.size.height/2.0)
        
        isFiveStep = defaults.bool(forKey: "isFiveStep")
        if !isFiveStep{
            step4Label.text = "Confirm Receiving"
            step5View.isHidden = true
            step4BarViewContainer.isHidden = true
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let shipmentData = defaults.object(forKey: ttrShipmentDetails){
                do{
                    let shipmentDict:NSDictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(shipmentData as! Data) as! NSDictionary
                    //populateShipmentDetails(shipmentDict: shipmentDict)
                    
                    if let transactions = shipmentDict["transactions"] as? [[String: Any]]{
                        self.itemsList = transactions
                        current_shipment_po = self.itemsList.first?["po_number"] as? String
                    }
                    
                    if let items = shipmentDict["ship_lines_item"] as? [[String: Any]]{
                        self.ship_lines_item = items
                    }
                    
                    DispatchQueue.main.async {
                        self.tblList.reloadData()
                    }
                    
                }catch{
                    print("Shipment Data Not Found")
                }
            }
            
            
            //            if let responseData = self.responseDict{
            //
            //                if let transactions = responseData["transactions"] as? [[String: Any]]{
            //                    self.itemsList = transactions
            //                }
            //                if let ship_lines_item = responseData["ship_lines_item"] as? [[String: Any]]{
            //                    self.ship_lines_item = ship_lines_item
            //                }
            //
            //            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setup_stepview()
        self.fetchFromLocalDB()
        self.checkForUnallocation()
    }
    
    func checkForUnallocation(){
        
        let responseItem = ship_lines_item
        
        if let _ = responseItem.firstIndex(where: {$0["unallocated_quantity"] as? Int ?? 0 > 0}){
            
            if self.localTableData?.count != 0{
                
                if let _ = localTableData?.firstIndex(where: {$0.unalloc_quantity > $0.alloc_quantity}){
                    
                    self.warningLabel.text = "There are some un-allocated item(s) present in the shipment. Please allocate them to purchase orders before receiving the shipment"
                    
                }else{
                    self.warningLabel.text = ""
                    
                }
                
            }else{
                self.warningLabel.text = "There are some un-allocated item(s) present in the shipment. Please allocate them to purchase orders before receiving the shipment"
            }
            
        }else{
            
            self.warningLabel.text = ""
        }
    }
    
    //MARK: - Private Method
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "rec_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "rec_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "rec_3rdStep")
        let isFourthStepCompleted = defaults.bool(forKey: "rec_4thStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        step5Button.isUserInteractionEnabled = false
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted && isFourthStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            step5Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted{
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Button.isUserInteractionEnabled = true
        }
        
    }
    //MARK: - Fetch Data From Line Item DB
    public var localTableData : Array<ReceiveLineItem>?
    var localPOs = [[String: Any]](){
        didSet{
            self.tblList.reloadData()
        }
    }
    
    private func fetchFromLocalDB(){
        do {
            let fetchRequest = NSFetchRequest<ReceiveLineItem>(entityName: "ReceiveLineItem")
            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
            
            self.localTableData = serial_obj
            
            self.localTableData?.forEach({ item in
                
                let dict = ["po_number" : item.po_no ?? "",
                            "order_number": "",
                            "date": item.date ?? ""] as [String : Any]
                
                if localPOs.count>0{
                    
                    for l_item in localPOs{
                        
                        if item.po_no != l_item["po_number"] as? String ?? "" {
                            
                            localPOs.append(dict)
                            
                        }else{
                            
                        }
                    }
                }else{
                    localPOs.append(dict)
                }
            })
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: - IBAction
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        let responseItem = ship_lines_item
        
        var isLotBased : Bool = false
        for item  in ship_lines_item {
            if (item["is_having_serial"] != nil) {
                let is_having_serial = item["is_having_serial"] as! Bool
                if !is_having_serial {
                    isLotBased = true
                }
            }
        }
        
        if let _ = responseItem.firstIndex(where: {$0["unallocated_quantity"] as? Int ?? 0 > 0}){
            
            if self.localTableData?.count != 0{
                
                if let _ = localTableData?.firstIndex(where: {$0.unalloc_quantity > $0.alloc_quantity}){
                    
                    Utility.showPopup(Title: App_Title, Message: "Please allocate item(s) to purchase order" , InViewC: self)
                    
                }else{
                    
                    defaults.set(true, forKey: "rec_2ndStep")
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialVerificationView") as! SerialVerificationViewController
                    controller.shipmentId = self.shipmentId ?? ""
                    controller.isLotBased = isLotBased
                    controller.responseDict = responseDict
                    self.navigationController?.pushViewController(controller, animated: false)
                }
                
            }else{
                Utility.showPopup(Title: App_Title, Message: "Please allocate item(s) to purchase order" , InViewC: self)
            }
            
        }else{
            
            defaults.set(true, forKey: "rec_2ndStep")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialVerificationView") as! SerialVerificationViewController
            controller.shipmentId = self.shipmentId ?? ""
            controller.isLotBased = isLotBased
            controller.responseDict = responseDict
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderAllocVC") as! PurchaseOrderAllocVC
        controller.dictPo = self.itemsList[sender.tag]
        controller.ship_lines_item = self.ship_lines_item
        
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func addPO(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderListVC") as! PurchaseOrderListVC
        //let item = itemsList.first
        controller.shipmentId = self.shipmentId ?? ""
        controller.dictShipmentDetails = self.responseDict
        controller.dictPo = self.itemsList.first
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ShipmentDetailsViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentDetailsView") as! ShipmentDetailsViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
         }else if sender.tag == 3 {
            
            nextButtonPressed(UIButton())
            
        }else if sender.tag == 4 {
            
            if isFiveStep {
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "StorageSelectionView") as! StorageSelectionViewController
                self.navigationController?.pushViewController(controller, animated: false)
                
            }else{
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
                self.navigationController?.pushViewController(controller, animated: false)
            }
        }else if sender.tag == 5 {
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
    }
}
extension PurchaseOrderVC: UITableViewDelegate, UITableViewDataSource{
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return self.localPOs.count == 0 ? self.itemsList.count : self.localPOs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllocatedCell", for: indexPath) as! AllocatedCell
        
        cell.btnEdit.tag = indexPath.section
        
        if self.localPOs.count == 0 {
            
            let item = itemsList[indexPath.section]
            
            cell.lblPoNo.text = item["po_number"] as? String
            cell.lblCustOrderNo.text = item["order_number"] as? String
            cell.lblDate.text = item["date"] as? String
            
            let line_items = item["line_items"] as? [[String:Any]] ?? [[String:Any]]()
            
            cell.lblProductCount.text = "\(line_items.count)"
            
            var count = 0
            
            for ship_item in line_items{
                
                let numberFormatter = NumberFormatter()
                numberFormatter.locale = Locale(identifier: "en_US")
                
                let qty = (numberFormatter.number(from: ship_item["quantity"] as? String ?? ""))?.intValue ?? 0
                
                count += qty
                
            }
            cell.lblItemCount.text = "\(count)"
        }else{
            let item = localPOs[indexPath.section]
            
            cell.lblPoNo.text = item["po_number"] as? String
            cell.lblCustOrderNo.text = item["order_number"] as? String
            cell.lblDate.text = item["date"] as? String
        }
        return cell
    }
}
class AllocatedCell: UITableViewCell{
    
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var lblCustOrderNo: UILabel!
    @IBOutlet var lblPoNo: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblItemCount: UILabel!
    @IBOutlet var lblProductCount: UILabel!
    @IBOutlet var btnEdit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
}
class UnAllocatedCell: UITableViewCell{
    
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var lblItemCount: UILabel!
    @IBOutlet var lblProductCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
}
