//
//  SFScannedListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 04/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

let SFStatus = ["IN_INVENTORY" : "In Inventory","DESTRUCTED" : "Destructed","DISPENSED" : "Dispensed","IN_QUARANTINE" : "In Quarantine","SHIPPED_TO_CLIENT" : "Shipped To Client","NOT_RECEIVED" : "Not Received","NOT_FOUND" : "Not Found","LOT_FOUND" : "Lot Found"]

class SFScannedListViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var toggleButton1: UIButton!
    @IBOutlet weak var toggleButton2: UIButton!
    @IBOutlet weak var toggle1BorderView: UIView!
    @IBOutlet weak var toggle2BorderView: UIView!
    
    
    @IBOutlet weak var productViewcontainer: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var productListTable: UITableView!
    @IBOutlet weak var searchViewHeightConstant:NSLayoutConstraint!
    
    var isSelected1stView = true
    
    var allScannedSerials = Array<String>()
    var verifiedSerials = Array<Dictionary<String,Any>>()
    var allproducts:NSDictionary?
    var uniquesProducts = [String]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let headerNib = UINib.init(nibName: "ProductHeaderView", bundle: Bundle.main)
        productListTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "ProductHeaderView")
        scanButtonPressed(UIButton())
        sectionView.roundTopCorners(cornerRadious: 40)
        productViewcontainer.roundTopCorners(cornerRadious: 40)
        setup_view()
        
    }
    //MARK:- End
    
    //MARK: - Private
    func setup_view(){
        allproducts = UserInfosModel.getAllProducts()
        searchView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        searchTextField.addLeftViewPadding(padding: 12.0)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        createInputAccessoryView()
        searchTextField.inputAccessoryView = inputAccView
        
        if isSelected1stView {
            toggleButton1.isUserInteractionEnabled = false
            toggleButton2.isUserInteractionEnabled = true
            toggleButton1.setTitleColor(UIColor.white, for: .normal)
            toggle1BorderView.isHidden = false
            toggleButton2.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle2BorderView.isHidden = true
            productViewcontainer.isHidden = true
        }else{
            toggleButton1.isUserInteractionEnabled = true
            toggleButton2.isUserInteractionEnabled = false
            toggleButton1.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle1BorderView.isHidden = true
            toggleButton2.setTitleColor(UIColor.white, for: .normal)
            toggle2BorderView.isHidden = false
            productViewcontainer.isHidden = false
            
        }
        self.searchViewShowHide()
    }
    
    func prepareSerialsForAPI(scannedCode: [String]){
        self.allScannedSerials.append(contentsOf: scannedCode)
        self.allScannedSerials = Array(Set(self.allScannedSerials))
        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSerialFinder)
        
        if first.count > 0 {
            self.validateSerials(serials: first.joined(separator: ","))
            self.showSpinner(onView: self.view)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self)
            return
        }
    }
    
    func validateSerials(serials : String){
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?serial_type=GS1_BARCODE&serials=\(str ?? "")&result_type=ON_SCREEN"
            Utility.GETServiceCall(type: "SerialFinder", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    if isDone! {
                        if let responseDict = responseData as? NSDictionary? {
                            if let responseArray = responseDict!["results"] as? NSArray{
                                if responseArray.count > 0{
                                    if let serialDetailsArray = responseArray as? [[String : Any]]{
                                        
                                        for serialDetails in serialDetailsArray {
                                            if !(self.verifiedSerials as NSArray).contains(serialDetails){
                                                self.verifiedSerials.append(serialDetails)
                                            }
                                        }
                                        print(self.verifiedSerials as NSArray)
                                    }
                                }else{
                                    //Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later." , InViewC: self)
                                }
                            }
                        }
                        self.listTable.reloadData()
                        self.searchViewShowHide()
                        self.autoCompleteWithStr(searchStr: "")
                    }else{
                        if responseData != nil{
                            let responseDict: NSDictionary = responseData as! NSDictionary
                            let errorMsg = responseDict["message"] as! String
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                    }
                    self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.components(separatedBy: ",").count))
                    let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSerialFinder)
                    if first.count > 0 {
                        self.validateSerials(serials: first.joined(separator: ","))
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
    func searchViewShowHide(){
        if verifiedSerials.isEmpty {
            searchViewHeightConstant.constant = 0
            searchView.isHidden = true
        }else{
            searchViewHeightConstant.constant = 50
            searchView.isHidden = false
        }
    }
    func populateProductandStatus(product:String?,status:String?)->NSAttributedString{
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15.0)!]
        let productString = NSMutableAttributedString(string:product ?? "", attributes: custAttributes)
        
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let statusStr = NSAttributedString(string: "\n" + (status ?? ""), attributes: custTypeAttributes)
        productString.append(statusStr)
        
        return productString
        
    }
    
    func getInvidualProductList(uuid:String)->[[String:Any]]{
        var filterList = [[String:Any]]()
        
        let predicate = NSPredicate(format: "product_uuid = '\(uuid)'")
        
        filterList = (verifiedSerials as NSArray).filtered(using: predicate) as! [[String : Any]]
        
        
        return filterList
    }
    
    func getInvidualProductLotList(uuid:String,lot:String)->[[String:Any]]{
        var filterList = [[String:Any]]()
        
        let predicate = NSPredicate(format: "product_uuid = '\(uuid)' and lot_number='\(lot)'")
        
        filterList = (verifiedSerials as NSArray).filtered(using: predicate) as! [[String : Any]]
        
        
        return filterList
    }
    
    func populateProducView(){
        if verifiedSerials.count>0{
            let predicate = NSPredicate(format: "product_uuid != '' and status != 'NOT_FOUND' and status != 'LOT_FOUND'")
            let filterArr = (verifiedSerials as NSArray).filtered(using: predicate)
            if filterArr.count > 0{
                if let unique = (filterArr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? [String]{
                    uniquesProducts = unique
                    print(uniquesProducts as Any)
                    
                }
                
            }
        }
        productListTable.reloadData()
        self.searchViewShowHide()

    }
    
    func autoCompleteWithStr(searchStr:String?){
        
        
        if searchStr != nil,searchStr!.isEmpty {
            searchTextField.text = searchStr
            populateProducView()
            return
        }
        
        var predicate:NSPredicate?
        predicate = NSPredicate(format: "product_name CONTAINS[c] '\(searchStr ?? "")'")
        
        if let masterArr = verifiedSerials as NSArray?{
            
            let masterDictArr = verifiedSerials
            var filteredArray = NSArray()
            
            if searchStr?.count == 1 {
                
                filteredArray = masterDictArr.filter({ return ($0["product_name"] as? String ?? "").first?.lowercased().contains((searchStr?.first ?? Character("")).lowercased()) ?? false}) as NSArray
                
            }else{
                filteredArray = masterArr.filtered(using: predicate!) as NSArray
            }
            
            if filteredArray.count>0{
                if let unique = filteredArray.value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? [String]{
                    uniquesProducts = unique
                }
                
            }else{
                uniquesProducts = []
            }
            productListTable.reloadData()
            self.searchViewShowHide()

        }
    }
    
    @objc func productSerialButtonPressed(sender:UIButton){
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SFSerialsView") as! SFSerialsViewController
        controller.productUuid = uniquesProducts[sender.tag]
        controller.isAllProduct = true
        controller.verifiedSerialsList = verifiedSerials
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK:- End
    //MARK: - IBAction
    @IBAction func lotSerialButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SFSerialsView") as! SFSerialsViewController
        controller.productUuid = uniquesProducts[sender.tag]
        controller.lot = sender.accessibilityHint
        controller.verifiedSerialsList = verifiedSerials
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func toggleButtonPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            toggleButton1.isUserInteractionEnabled = false
            toggleButton2.isUserInteractionEnabled = true
            toggleButton1.setTitleColor(UIColor.white, for: .normal)
            toggle1BorderView.isHidden = false
            toggleButton2.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle2BorderView.isHidden = true
            productViewcontainer.isHidden = true
        }else{
            toggleButton1.isUserInteractionEnabled = true
            toggleButton2.isUserInteractionEnabled = false
            toggleButton1.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle1BorderView.isHidden = true
            toggleButton2.setTitleColor(UIColor.white, for: .normal)
            toggle2BorderView.isHidden = false
            productViewcontainer.isHidden = false
        }
    }
    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SFSerialScanView") as! SFSerialScanViewController
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK:- End
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == listTable {
            return UITableView.automaticDimension
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == listTable {
            return UITableView.automaticDimension
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == listTable {
            return 1
        }else{
            return UITableView.automaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if tableView == listTable {
            return 1
        }else{
            return 40
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == listTable{
            let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
            view.backgroundColor = UIColor.clear
            
            return view
            
        }else{
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProductHeaderView") as! ProductHeaderView
            let products = getInvidualProductList(uuid: uniquesProducts[section])
            
            if products.count>0{
                let firstObj = products.first
                if let name = firstObj!["product_name"] as? String{
                    headerView.productNameLabel.text = name
                }
            }
            
            headerView.quantityLabel.text = "\(getInvidualProductList(uuid: uniquesProducts[section]).count)"
            headerView.serialButton.tag = section
            headerView.serialButton.addTarget(self, action:#selector(productSerialButtonPressed), for: .touchUpInside)
            
            headerView.layer.cornerRadius = 10
            headerView.clipsToBounds = true
            headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            return headerView
        }
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 5))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        if tableView == listTable {
            return verifiedSerials.count
        }else{
            return uniquesProducts.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == listTable{
            return 1
        }else{
            let product_uuid = uniquesProducts[section]
            let products = getInvidualProductList(uuid: product_uuid)
            if let unique = (products as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String]{
                
                return unique.count
                
                
            }else{
                return 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView == listTable {
            
            let dataDict = verifiedSerials[indexPath.section]
            
            if let product_uuid = dataDict["product_uuid"] as? String , !product_uuid.isEmpty,let status = dataDict["status"] as? String,!status.isEmpty, (status != "NOT_FOUND" && status != "LOT_FOUND"){ // Valid Product
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SFProductCell") as! SFProductCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                cell.clipsToBounds = true
                
                cell.itemTypeButton.setImage(UIImage(named: "overlay_product.png"), for: .normal)
                cell.arrowButton.isHidden = false
                var dataStr = ""
                
                if let simple_serial = dataDict["simple_serial"] as? String {
                    dataStr = simple_serial
                }
                cell.serialLabel.text = dataStr
                
                dataStr = ""
                if let lot_number = dataDict["lot_number"] as? String {
                    dataStr = lot_number
                }
                
                cell.lotLabel.text = dataStr
                
                dataStr = ""
                if let expiration_date = dataDict["expiration_date"] as? String {
                    dataStr = expiration_date
                }
                cell.expirationDateLabel.text = dataStr
                
                
                
                dataStr = ""
                if let product_uuid = dataDict["product_uuid"] as? String{
                    dataStr = product_uuid
                    
                    if allproducts != nil{
                        if let dict = allproducts![product_uuid] as? NSDictionary {
                            if let gtin14 = dict["gtin14"] as? String{
                                dataStr = gtin14
                            }
                        }
                    }
                }
                cell.gtinLabel.text = dataStr
                
                if let gs1Serial = dataDict["gs1_serial"] as? String,let status = dataDict["status"] as? String{
                    
                    cell.itemNameAndTypeLabel.attributedText = populateProductandStatus(product: gs1Serial, status:SFStatus[status])
                    
                }else{
                    cell.itemNameAndTypeLabel.text = ""
                }
                return cell
                
                
            }else if let product_uuid = dataDict["product_uuid"] as? String , product_uuid.isEmpty,let status = dataDict["status"] as? String,!status.isEmpty, (status != "NOT_FOUND" && status != "LOT_FOUND"){ // Container
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SFOtherCell") as! SFOtherCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                cell.clipsToBounds = true
                
                cell.itemTypeButton.setImage(UIImage(named: "serial_container.png"), for: .normal)
                cell.frontArrowButton.isHidden = false
                
                if let gs1Serial = dataDict["gs1_serial"] as? String,let status = dataDict["status"] as? String{
                    cell.itemNameAndTypeLabel.attributedText = populateProductandStatus(product: gs1Serial, status:SFStatus[status])
                }else{
                    cell.itemNameAndTypeLabel.text = ""
                }
                return cell
            }else if let status = dataDict["status"] as? String,!status.isEmpty, status == "LOT_FOUND"{ // Lot product
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SFOtherCell") as! SFOtherCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                cell.clipsToBounds = true
                
                cell.itemTypeButton.setImage(UIImage(named: "overlay_product.png"), for: .normal)
                cell.frontArrowButton.isHidden = true
                
                if let gs1Serial = dataDict["simple_serial"] as? String{
                    
                    cell.itemNameAndTypeLabel.attributedText = populateProductandStatus(product: gs1Serial, status:"The serial is lotbased and the serial finder is not compatible with lot based data")
                    
                }else{
                    cell.itemNameAndTypeLabel.text = ""
                }
                
                return cell
                
            }
            else{ // Error
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SFProductCell") as! SFProductCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                cell.clipsToBounds = true
                cell.itemTypeButton.setImage(UIImage(named: "serial_error.png"), for: .normal)
                cell.arrowButton.isHidden = true
                var dataStr = ""
                if let simple_serial = dataDict["simple_serial"] as? String {
                    dataStr = simple_serial
                }
                cell.serialLabel.text = dataStr
                dataStr = ""
                if let lot_number = dataDict["lot_number"] as? String {
                    dataStr = lot_number
                }
                cell.lotLabel.text = dataStr
                dataStr = ""
                if let expiration_date = dataDict["expiration_date"] as? String {
                    if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss-HH:mm", outputFormat: "yyyy-MM-dd", dateStr: expiration_date){
                        dataStr = formattedDate
                    }
                }
                cell.expirationDateLabel.text = dataStr
                dataStr = ""
                if let product_gtin14 = dataDict["product_gtin14"] as? String{
                    dataStr = product_gtin14
                }
                cell.gtinLabel.text = dataStr
                if let gs1Serial = dataDict["simple_serial"] as? String,let status = dataDict["status"] as? String{
                    cell.itemNameAndTypeLabel.attributedText = populateProductandStatus(product: gs1Serial, status:SFStatus[status])
                }else{
                    cell.itemNameAndTypeLabel.text = ""
                }
                return cell
                
                
                /*
                let cell = tableView.dequeueReusableCell(withIdentifier: "SFOtherCell") as! SFOtherCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                cell.clipsToBounds = true
                
                cell.itemTypeButton.setImage(UIImage(named: "serial_error.png"), for: .normal)
                cell.frontArrowButton.isHidden = true
                
                if let simple_serial = dataDict["simple_serial"] as? String,let status = dataDict["status"] as? String {
                    cell.itemNameAndTypeLabel.attributedText = populateProductandStatus(product: simple_serial, status:SFStatus[status])
                }else{
                    cell.itemNameAndTypeLabel.text = ""
                }
                return cell
                 */
            }
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SFProductLotCell") as! SFProductLotCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.clipsToBounds = true
            let product_uuid = uniquesProducts[indexPath.section]
            let products = getInvidualProductList(uuid: product_uuid)
            if let unique = (products as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String]{
                
                let currentLot = unique[indexPath.row]
                
                cell.lotNameLabel.text = currentLot
                cell.quantityLabel.text = "\(getInvidualProductLotList(uuid: product_uuid, lot: currentLot).count)"
                cell.serialButton.tag = indexPath.section
                cell.serialButton.accessibilityHint = currentLot
                
                
                if indexPath.row + 1 == unique.count {
                    cell.layer.cornerRadius = 10
                    cell.clipsToBounds = true
                    cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }else{
                    cell.layer.cornerRadius = 0
                    cell.clipsToBounds = false
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == listTable{
            let dataDict = verifiedSerials[indexPath.section]
            if let gs1Serial = dataDict["gs1_serial"] as? String,!gs1Serial.isEmpty,let status = dataDict["status"] as? String,!status.isEmpty, (status != "NOT_FOUND" && status != "LOT_FOUND"){
                //let storyboard = UIStoryboard(name: "Finder", bundle: nil)
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SFSerialDetailsView") as! SFSerialDetailsViewController
                controller.serial = gs1Serial
                if let serial = dataDict["simple_serial"] as? String {
                    controller.simple_serial = serial
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
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
    
    @objc func textFieldDidChange(sender: UITextField) {
        //        if selectedCustomerIndex > -1 {
        //            selectedCustomerIndex = -1
        //        }
        autoCompleteWithStr(searchStr: sender.text!)
    }
    
    //MARK: - End
}

extension SFScannedListViewController:SFSerialScanViewDelegate{
    func didClickOnCamera() {
        DispatchQueue.main.async{
            if(defaults.bool(forKey: "IsMultiScan")){
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                controller.isForReceivingSerialVerificationScan = true
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }else{
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
                controller.isForReceivingSerialVerificationScan = true
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func didCancelScanSelection() {
        if verifiedSerials.isEmpty {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}

extension SFScannedListViewController : ScanViewControllerDelegate{
    func didScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
            self.prepareSerialsForAPI(scannedCode: scannedCode)
            print("Scanned Barcodes")
        }
    }
}

extension SFScannedListViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
            //["010083491310500821133413571022612\u{1D}172312011058BA5jj9","010083491310500821133413571022612\u{1D}172312011058BA533A"]
            self.prepareSerialsForAPI(scannedCode: scannedCode)
            print("Scanned Barcodes")
        }
    }
}

class SFProductCell: UITableViewCell {
    
    @IBOutlet weak var itemTypeButton: UIButton!
    @IBOutlet weak var itemNameAndTypeLabel: UILabel!
    @IBOutlet weak var gtinLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
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

class SFOtherCell: UITableViewCell {
    
    @IBOutlet weak var itemTypeButton: UIButton!
    @IBOutlet weak var itemNameAndTypeLabel: UILabel!
    @IBOutlet weak var frontArrowButton: UIButton!
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

class SFProductLotCell: UITableViewCell {
    
    @IBOutlet weak var serialButton: UIButton!
    @IBOutlet weak var lotNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
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
