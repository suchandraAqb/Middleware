//
//  PickingLotBasedViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 22/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}
@objc protocol PickingLotBasedViewDelegate: class{
    @objc optional func didAddedLotBasedProduct()
}

class PickingLotBasedViewController: BaseViewController,AddPickingLotBasedDelegate,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    var itemsList:Array<Any>?
    var uniqueProductsArray:Array<Any>?
    
    @IBOutlet weak var dataContainer: UIView!
    @IBOutlet weak var addMoreButton: UIButton!
    
    @IBOutlet weak var quantityUpdateView: UIView!
    @IBOutlet weak var quantityUpdateContainer: UIView!
    @IBOutlet weak var quantityUpdateTextField: UITextField!
    @IBOutlet weak var quantityUpdateButton: UIButton!
    @IBOutlet weak var scanDisclaimerLabel: UILabel!
    var isFromScan:Bool?
    var scanLotbasedArray:Array<Any>?
    weak var delegate : PickingLotBasedViewDelegate?

    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let headerNib = UINib.init(nibName: "PickingLotbasedListHeader", bundle: Bundle.main)
        listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "PickingLotbasedListHeader")
        
        let footerNib = UINib.init(nibName: "LotBasedFooterView", bundle: Bundle.main)
        listTable.register(footerNib, forHeaderFooterViewReuseIdentifier: "LotBasedFooterView")
        
        
        
        sectionView.roundTopCorners(cornerRadious: 40)
        dataContainer.roundTopCorners(cornerRadious: 40)
        quantityUpdateContainer.setRoundCorner(cornerRadious: 20)
        addMoreButton.setRoundCorner(cornerRadious: addMoreButton.frame.size.height/2.0)
        quantityUpdateButton.setRoundCorner(cornerRadious: quantityUpdateButton.frame.size.height/2.0)
        quantityUpdateTextField.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        createInputAccessoryView()
        quantityUpdateTextField.inputAccessoryView = inputAccView
        
        if isFromScan ?? false {
            scanDisclaimerLabel.text = "Some serials did not match exactly but quantity could be found with their Product/Lot combination.\nThose items are picked as Lot based".localized()
        }else{
            scanDisclaimerLabel.text = ""
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupList()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    
    //MARK: - Private method
    func setupList(){
        if let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any> {
            
            if scanLotbasedArray != nil {
                let exProd = exProducts as NSArray?
                let arr = NSMutableArray(array: exProd!)
                
                for data in scanLotbasedArray! {
                    
                    if let dict = data as? NSDictionary {
                        if let lot = dict["lot"] as? String {
                            let predicate = NSPredicate(format:"lot ='\(lot)'")
                            if let filterArray = exProd?.filtered(using: predicate){
                                if filterArray.count > 0 {
                                    let firstObj = filterArray.first as? NSDictionary ?? NSDictionary()
                                    let objectIdx = exProd?.index(of: firstObj)
                                    let modDict = NSMutableDictionary(dictionary: firstObj)
                                    let qty1 = dict["quantity"] as! Int
                                    let qty2 = modDict["quantity"] as! Int
                                    modDict["quantity"] = qty1 + qty2
                                    arr.replaceObject(at: objectIdx!, with: modDict)
                                    Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr)
                                }else{
                                    if scanLotbasedArray != nil {
                                        Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: scanLotbasedArray!)
                                        scanLotbasedArray = nil
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
                
                scanLotbasedArray = nil
                
            }
        }else{
            if scanLotbasedArray != nil {
                Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: scanLotbasedArray!)
                scanLotbasedArray = nil
            }
        }
        
        if let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any> {
            
            let arr = exProducts as NSArray?
            let uniqueArr = arr?.value(forKeyPath: "@distinctUnionOfObjects.product_uuid")
            //            let uniqueSet = NSSet(array: uniqueArr as! [Any])
            //            uniqueProductsArray =  uniqueSet.allObjects
            uniqueProductsArray = uniqueArr as? Array<Any>
            print(uniqueProductsArray?.first as Any)
            itemsList = exProducts
            dataContainer.isHidden = false
            listTable.reloadData()
        }else{
            uniqueProductsArray = nil
            itemsList = nil
            listTable.reloadData()
            dataContainer.isHidden = true
        }
    }
    func removeLot(data:NSDictionary , itemIdx:Int){
        
        var requestDict = [String:Any]()
        requestDict["type"] = "sales_order_by_picking"
        requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id") ?? ""
        requestDict["product_uuid"] = data["product_uuid"] ?? ""
        requestDict["lot_number"] = data["lot"] ?? ""
        requestDict["quantity"] = data["quantity"]
        requestDict["action"] = "REMOVE"
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "AddPickingLotBasedProduct", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "",isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let _ = responseDict["uuid"] as? String {
                        
                        self.itemsList?.remove(at: itemIdx)
                        
                        if let _ = self.itemsList, !self.itemsList!.isEmpty{
                            Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: self.itemsList!)
                        }else{
                            defaults.removeObject(forKey: "picking_lot_products")
                        }
                        
                        self.setupList()
                        Utility.showPopup(Title: Success_Title, Message: "Lot Removed..".localized() , InViewC: self)
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
    
    func addProduct(quantity:String, isAdd:Bool , totalQuantity:String,itemIdx:Int , product:NSDictionary){
        
        var requestDict = [String:Any]()
        requestDict["type"] = "sales_order_by_picking"
        requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id") ?? ""
        requestDict["product_uuid"] = product["product_uuid"] ?? ""
        requestDict["lot_number"] = product["lot"] ?? ""
        requestDict["quantity"] = quantity
        if isAdd{
            requestDict["action"] = "ADD"
        }else{
            requestDict["action"] = "REMOVE"
        }
        
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "AddPickingLotBasedProduct", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "",isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    let modDict = NSMutableDictionary(dictionary: responseDict)
                    if let _ = responseDict["uuid"] as? String {
                        modDict["quantity"] = (totalQuantity as NSString).intValue
                        
                        if self.itemsList != nil && itemIdx >= 0 {
                            let arr = NSMutableArray(array: self.itemsList!)
                            arr.replaceObject(at: itemIdx, with: modDict)
                            Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr)
                        }else if self.itemsList != nil {
                            let arr = NSMutableArray(array: self.itemsList!)
                            arr.add(modDict)
                            Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr)
                        }else{
                            let arr = NSMutableArray()
                            arr.add(modDict)
                            Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr)
                        }
                        
                        self.setupList()
                        //self.quantityUpdateView.isHidden = true
                        self.quantityUpdater(view: self.quantityUpdateView, isHidden: true)
                        
                        Utility.showPopup(Title: Success_Title, Message: "Lot Quantity Updated..".localized() , InViewC: self)
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
    
    @IBAction func quantityUpdateButtonPressed(_ sender: UIButton) {
        
        var quantity =   quantityUpdateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let totalQuantity =   quantityUpdateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if (quantity as NSString).intValue <= 0 {
            Utility.showPopup(Title: App_Title, Message: "Enter quantity more than 0".localized(), InViewC: self)
            return
        }
        
        
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            var isAdd = true
            
            let curQuantity = (quantity as NSString).intValue
            let prvQuan = dict["quantity"] as! Int32
            var newQuantity = 0
            if curQuantity > prvQuan {
                newQuantity = Int(curQuantity - prvQuan)
            }else{
                isAdd = false
                newQuantity = Int(prvQuan - curQuantity)
            }
            
            quantity = "\(newQuantity)"
            
            addProduct(quantity: quantity, isAdd: isAdd, totalQuantity: totalQuantity, itemIdx: sender.tag, product: dict)
        }
        
    }
    
    @IBAction func cancelQuantityUpdateButtonPressed(_ sender: UIButton) {
        //quantityUpdateView.isHidden = true
        self.quantityUpdater(view: self.quantityUpdateView, isHidden: true)
    }
    
    @IBAction func addProductButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddPickingLotBasedProductView") as! AddPickingLotBasedProductViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func doneButtonpressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            self.navigationController?.popViewController(animated: false)
        }else{
            delegate?.didAddedLotBasedProduct!()
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func crossButtonpressed(_ sender: UIButton) {
        
        let msg = "You are about to delete the resource.\nThis operation can’t be undone.\n\nProceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            if let dict = self.itemsList![sender.tag] as? NSDictionary {
                self.removeLot(data: dict, itemIdx: sender.tag)
            }
            
            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func lotQuantityButtonPressed(_ sender: UIButton) {
        
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            let prvQuan = dict["quantity"] as! Int32
            quantityUpdateTextField.text = "\(prvQuan)"
            quantityUpdateButton.tag = sender.tag
        }
        
        //quantityUpdateView.isHidden = false
        self.quantityUpdater(view: self.quantityUpdateView, isHidden: false)
    }
    
    //MARK: - End
    
    //MARK: - Tableview Delegate and Datasource
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat{
        return 123
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PickingLotbasedListHeader") as! PickingLotbasedListHeader
        
        if headerView.multiLingualViews != nil{
            Utility.UpdateUILanguage(headerView.multiLingualViews)
        }
        
        if let uuid = uniqueProductsArray?[section] as? String {
            headerView.uuidLabel.text = uuid
            let allList = itemsList as NSArray?
            let predicate = NSPredicate(format:"product_uuid ='\(uuid)'")
            if let filterArray = allList?.filtered(using: predicate){
                if filterArray.count > 0 {
                    let arr = filterArray as NSArray?
                    let narr = arr?.value(forKeyPath: "quantity") as? Array<Int>
                    let sum = narr?.sum()
                    print("Total Quantity: \(String(describing: sum!))")
                    
                    headerView.quantityLabel.text = "\(String(describing: sum!))"
                    
                    if let dataDict = filterArray.first as? NSDictionary {
                        
                        if let name = dataDict["product_name"]  as? String{
                            headerView.nameLabel.text = name
                        }
                        
                        if let txt = dataDict["gtin14"] as? String{
                            headerView.gtinLabel.text = txt
                        }
                    }
                }
            }
        }
        
        headerView.layer.cornerRadius = 10
        headerView.clipsToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        headerView.lotQuantityView.layer.cornerRadius = 10
        headerView.lotQuantityView.clipsToBounds = true
        headerView.lotQuantityView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LotBasedFooterView") as! LotBasedFooterView
        footerView.bgView.backgroundColor = UIColor.white
        footerView.bgView.layer.cornerRadius = 10
        footerView.bgView.clipsToBounds = true
        footerView.bgView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        return footerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return uniqueProductsArray?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let uuid = uniqueProductsArray?[section] as? String {
            let allList = itemsList as NSArray?
            let predicate = NSPredicate(format:"product_uuid ='\(uuid)'")
            if let filterArray = allList?.filtered(using: predicate){
                return filterArray.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LotProductListCell") as! LotProductListCell
        
        cell.dataView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 0)
        
        
        if let uuid = uniqueProductsArray?[indexPath.section] as? String {
            let allList = itemsList as NSArray?
            let predicate = NSPredicate(format:"product_uuid ='\(uuid)'")
            if let filterArray = allList?.filtered(using: predicate){
                if filterArray.count > 0 {
                    
                    if let dataDict = filterArray[indexPath.row] as? NSDictionary {
                        var dataStr:String = ""
                        
                        if let txt = dataDict["lot"] as? String{
                            dataStr = txt
                        }
                        cell.lotNoLabel.text = dataStr
                        
                        dataStr = ""
                        if let txt = dataDict["quantity"] as? Int{
                            dataStr = "\(txt)"
                        }
                        
                        cell.lotQuantityButton.setTitle(dataStr, for: .normal)
                        
                        
                        if filterArray.count == Int(indexPath.row + 1) {
                            cell.dataView.layer.cornerRadius = 10
                            cell.dataView.clipsToBounds = true
                            cell.dataView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                            
                        }else{
                            cell.dataView.layer.cornerRadius = 0
                            cell.dataView.clipsToBounds = true
                        }
                        
                        cell.lotQuantityButton.tag = allList?.index(of: dataDict) ?? 0
                        cell.crossButton.tag = allList?.index(of: dataDict) ?? 0
                        
                    }
                }
            }
        }
        
        cell.lotQuantityButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious:cell.lotQuantityButton.frame.size.height / 2.0)
        
        return cell
        
    }
    //MARK: - End
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - End
    
    //MARK: - AddPickingLotBasedDelegate
    func addedProduct(data: NSDictionary) {
        
    }
    //MARK: - End
}

class LotProductListCell: UITableViewCell
{
    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var lotNoLabel: UILabel!
    @IBOutlet weak var lotQuantityButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var storageButton: UIButton!
    @IBOutlet weak var storageView: UIView!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
        
    }
}
