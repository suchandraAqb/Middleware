//
//  ARSFProductNotFoundListViewController1.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Nova on 27/01/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sb10

import UIKit

class ARSFProductNotFoundListViewController1: BaseViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var exportLabel: UILabel!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    
    @IBOutlet weak var productAddedView : UIView!
    @IBOutlet weak var productAddedSubView : UIView!
    @IBOutlet weak var gtin14Label : UILabel!
    @IBOutlet weak var lotLabel : UILabel!
    @IBOutlet weak var serialLabel : UILabel!
    @IBOutlet weak var expirationDateLabel : UILabel!
    @IBOutlet weak var productNameTextFiled : UITextField!
    @IBOutlet weak var updateButton : UIButton!
    
    @IBOutlet weak var gtinStackView: UIStackView!
    @IBOutlet weak var lotNumberStackView: UIStackView!
    @IBOutlet weak var serialNumberStackView: UIStackView!
    @IBOutlet weak var expirationDateStackView: UIStackView!
    @IBOutlet weak var productNameStackView: UIStackView!
    @IBOutlet weak var productNameTitleLabel: UILabel!
    
    var notFoundSerials = Array<Dictionary<String,Any>>()
    var allNotFound = false
    
    var sectionMainTag = 0
    var product_gtin14Array = [String]()
    var productArray = [] as NSMutableArray
    var expandSectionArray = [] as NSMutableArray
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view, typically from a nib.
        let headerNib = UINib.init(nibName: "ProductNotFoundHeaderView", bundle: Bundle.main)
        listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "ProductNotFoundHeaderView")
        
        sectionView.roundTopCorners(cornerRadious: 40)
        setup_view()
        
        updateButton.setRoundCorner(cornerRadious: updateButton.frame.height/2.0)
        productAddedSubView.setRoundCorner(cornerRadious: 20)
        createInputAccessoryView()
        productNameTextFiled.inputAccessoryView = inputAccView
        
        if (notFoundSerials.count > 0) {
            self.exportLabel.alpha = 1
            self.exportButton.alpha = 1
            self.exportButton.isUserInteractionEnabled = true
        }else {
            self.exportLabel.alpha = 0.5
            self.exportButton.alpha = 0.5
            self.exportButton.isUserInteractionEnabled = false
        }
        
        if let product_gtin14 = (notFoundSerials as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_gtin14") as? [String] {
            product_gtin14Array = product_gtin14
//            print(product_gtin14Array as Any)
            
            for product_gtin14 in product_gtin14Array {
                let products = getInvidualProductList(product_gtin14: product_gtin14)
                if (products.count > 0) {
                    productArray.add(products)
                }
            }
        }
//        print ("productArray.....",productArray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        productAddedView.isHidden = true
    }
    //MARK:- End
    
    //MARK: - Private
    func setup_view(){
        createInputAccessoryView()
    }
    
    func getInvidualProductList(product_gtin14:String)->[[String:Any]]{
        var filterList = [[String:Any]]()
        
        let predicate = NSPredicate(format: "product_gtin14 = '\(product_gtin14)'")
        
        filterList = (notFoundSerials as NSArray).filtered(using: predicate) as! [[String : Any]]
        
        return filterList
    }
        
    func shareCSV() {
        var csvString = "\("Product name".localized()), \("Product UUID".localized()), \("Simple serial".localized()), \("GS1 serial".localized()), \("Product gtin14".localized()), \("Lot number".localized()), \("Status".localized()), \("Expiration date".localized()) \n"
        
        for i in 0..<productArray.count {
            let products:[[String:Any]] = productArray[i] as! [[String : Any]]
            
            for j in 0..<products.count {
                 let dataDict = products[j]

                 var product_nameStr = ""
                 if let product_name = dataDict["product_name"] as? String {
                     product_nameStr = product_nameStr.appending(product_name)
                     product_nameStr = product_nameStr.appending(",")
                 }else {
                    product_nameStr = product_nameStr.appending(",")
                 }
                
                 var product_uuidStr = ""
                 if let product_uuid = dataDict["product_uuid"] as? String {
                     product_uuidStr = product_uuidStr.appending(product_uuid)
                     product_uuidStr = product_uuidStr.appending(",")
                 }else {
                    product_uuidStr = product_uuidStr.appending(",")
                 }
                
                 var simple_serialStr = ""
                 if let simple_serial = dataDict["simple_serial"] as? String {
                     simple_serialStr = simple_serialStr.appending(simple_serial)
                     simple_serialStr = simple_serialStr.appending(",")
                 }else {
                    simple_serialStr = simple_serialStr.appending(",")
                 }
                
                 var gs1_serialStr = ""
                 if let gs1_serial = dataDict["gs1_serial"] as? String {
                     gs1_serialStr = gs1_serialStr.appending(gs1_serial)
                     gs1_serialStr = gs1_serialStr.appending(",")
                 }else {
                    gs1_serialStr = gs1_serialStr.appending(",")
                 }
                
                 var product_gtin14Str = ""
                 if let product_gtin14 = dataDict["product_gtin14"] as? String {
                     product_gtin14Str = product_gtin14Str.appending(product_gtin14)
                     product_gtin14Str = product_gtin14Str.appending(",")
                 }else {
                    product_gtin14Str = product_gtin14Str.appending(",")
                 }
                
                 var lot_numberStr = ""
                 if let lot_number = dataDict["lot_number"] as? String {
                     lot_numberStr = lot_numberStr.appending(lot_number)
                     lot_numberStr = lot_numberStr.appending(",")
                 }else {
                    lot_numberStr = lot_numberStr.appending(",")
                 }
                
                 var statusStr = ""
                 if let status = dataDict["status"] as? String {
                     statusStr = statusStr.appending(status)
                     statusStr = statusStr.appending(",")
                 }else {
                    statusStr = statusStr.appending(",")
                 }
                
                 var expiration_dateStr = ""
                 if let expiration_date = dataDict["expiration_date"] as? String {
                     if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss-HH:mm", outputFormat: "yyyy-MM-dd", dateStr: expiration_date) {

                         expiration_dateStr = expiration_dateStr.appending(formattedDate)
                     }
                 }

                 csvString = csvString.appending (product_nameStr)
                 csvString = csvString.appending (product_uuidStr)
                 csvString = csvString.appending (simple_serialStr)
                 csvString = csvString.appending (gs1_serialStr)
                 csvString = csvString.appending (product_gtin14Str)
                 csvString = csvString.appending (lot_numberStr)
                 csvString = csvString.appending (statusStr)
                 csvString = csvString.appending (expiration_dateStr)
                 csvString = csvString.appending ("\n")
            }
        }
//        print ("csvString......",csvString)
               
       let fileManager = FileManager.default
       do {
           let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
           let fileURL = path.appendingPathComponent("Notfounditems.csv")
           if FileManager.default.fileExists(atPath: fileURL.path) {
               try? FileManager.default.removeItem(at: fileURL)
           }
           try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
       } catch {
           print("error creating file")
       }

       let pathUrl = Utility.getDocumentsDirectory().appendingPathComponent("Notfounditems.csv")

       if FileManager.default.fileExists(atPath: pathUrl.path){
           //let documento = NSData(contentsOfFile: pathUrl.path)
           let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pathUrl], applicationActivities: nil)
        
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
                activityViewController.popoverPresentationController?.sourceView = self.exportButton
            }
            else {
                activityViewController.popoverPresentationController?.sourceView = self.view
            }
        
           self.present(activityViewController, animated: true, completion: nil)

           activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
               if completed {
                   activityViewController.dismiss(animated: true, completion: nil)
               }
           }
       }
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func exportButtonPressed(_ sender:UIButton){
        self.shareCSV()
    }
    
    @IBAction func backButtonPressed(sender:UIButton) {
        productNameTextFiled.resignFirstResponder()

        if allNotFound {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                if controller.isKind(of: FinderViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func closeAddProductViewButtonPressed(_ sender:UIButton){
        productNameTextFiled.resignFirstResponder()
        productAddedView.isHidden = true
    }
    
    @IBAction func updateButtonPressed(_ sender:UIButton){
        productNameTextFiled.resignFirstResponder()

        let propertyName = productNameTextFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var products:[[String:Any]] = productArray[sectionMainTag] as! [[String:Any]]
        for i in 0..<products.count {
            var dataDict = products[i]
            dataDict["product_name"] = propertyName
            products[i] = dataDict
        }
        productArray[sectionMainTag] = products
        
        listTable.reloadData()
        productAddedView.isHidden = true
    }
        
    @objc func editAllButtonPressed(sender:UIButton) {
        productNameTextFiled.resignFirstResponder()
        self.view.bringSubviewToFront(productAddedView)
        
        sectionMainTag = sender.tag
        
        productAddedView.isHidden = false
        productNameTextFiled.text = ""
                
        serialNumberStackView.isHidden = true
        lotNumberStackView.isHidden = true
        expirationDateStackView.isHidden = true
        gtinStackView.isHidden = false

        let products:[[String:Any]] = productArray[sender.tag] as! [[String:Any]]
        if (products.count > 0) {
            let dataDict = products[0]
            var dataStr = ""
            if let product_name = dataDict["product_name"] as? String {
                dataStr = product_name
                productNameTextFiled.text = dataStr
            }
            
            if let product_gtin14 = dataDict["product_gtin14"] as? String {
                dataStr = product_gtin14
                gtin14Label.text = dataStr
            }
        }
        
        productNameTitleLabel.text = "ENTER PRODUCT NAME :".localized()
    }
    //MARK:- End
        
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //MARK: - End
}

extension ARSFProductNotFoundListViewController1: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 92
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProductNotFoundHeaderView") as! ProductNotFoundHeaderView
        
        headerView.gtinTitleLabel.text = "GTIN".localized()
        headerView.productNameTitleLabel.text = "Product Name".localized()

        let products:[[String:Any]] = productArray[section] as! [[String:Any]]
        if (products.count > 0) {
            let dataDict = products[0]
            if let product_gtin14 = dataDict["product_gtin14"] as? String{
                headerView.gtinLabel.text = product_gtin14
            }else {
                headerView.gtinLabel.text = ""
            }
            
            if let product_name = dataDict["product_name"] as? String{
                headerView.productNameLabel.text = product_name
            }else {
                headerView.productNameLabel.text = ""
            }
        }
        
        headerView.serialButton.tag = section
        headerView.serialButton.addTarget(self, action:#selector(editAllButtonPressed), for: .touchUpInside)
        
        headerView.expandCollapseButton.tag = section
        headerView.expandCollapseButton.addTarget(self, action:#selector(expandCollapseButtonPressed), for: .touchUpInside)
        
        headerView.layer.cornerRadius = 10
        headerView.clipsToBounds = true
        
        if expandSectionArray.contains(section) {
            headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            headerView.expandCollapseButton.setImage(UIImage(named: "arrow-down.png"), for: .normal)
        }
        else {
            headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            headerView.expandCollapseButton.setImage(UIImage(named: "arrow-up.png"), for: .normal)
        }
        
        return headerView
    }
    
    @objc func expandCollapseButtonPressed(sender:UIButton){
        /*
        if expandSectionArray.contains(sender.tag) {
            expandSectionArray.remove(sender.tag)
        }
        else {
            expandSectionArray.add(sender.tag)
        }
        self.listTable.reloadSections([sender.tag], with: .fade)
        */
        
        if expandSectionArray.contains(sender.tag) {
            expandSectionArray.remove(sender.tag)
            self.listTable.reloadSections([sender.tag], with: .fade)
        }
        else {
            for i in 0..<expandSectionArray.count {
                let expandSection:Int = expandSectionArray[i] as! Int
                expandSectionArray.remove(expandSection)
                self.listTable.reloadSections([expandSection], with: .fade)
            }
            
            expandSectionArray.add(sender.tag)
            self.listTable.reloadSections([sender.tag], with: .fade)
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 8))
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return productArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if expandSectionArray.contains(section) {
            if let products = productArray[section] as? [[String:Any]] {
                return products.count
            }
            else {
                return 0
            }
        }
        else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFProductNotFoundListCell1") as! ARSFProductNotFoundListCell1
        let products:[[String:Any]] = productArray[indexPath.section] as! [[String:Any]]
        let dataDict = products[indexPath.row]
        
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
        if let status = dataDict["status"] as? String{
            dataStr = "\(SFStatus[status] ?? "")".localized()
        }
        cell.statusLabel.text = dataStr
        
        if (indexPath.row == products.count-1) {
            cell.bottomView.layer.cornerRadius = 10
            cell.bottomView.clipsToBounds = true
            cell.bottomView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        else {
            cell.bottomView.layer.cornerRadius = 0
        }
        return cell
    }
    //MARK: - End
}

class ARSFProductNotFoundListCell1: UITableViewCell {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet weak var bottomView: UIView!
    
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
