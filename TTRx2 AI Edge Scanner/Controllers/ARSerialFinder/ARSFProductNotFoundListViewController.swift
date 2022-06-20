//
//  ARSFProductNotFoundListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Nova on 27/01/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sb8

import UIKit

class ARSFProductNotFoundListViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
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
    
    //,,,sb10
    @IBOutlet weak var gtinStackView: UIStackView!
    @IBOutlet weak var lotNumberStackView: UIStackView!
    @IBOutlet weak var serialNumberStackView: UIStackView!
    @IBOutlet weak var expirationDateStackView: UIStackView!
    @IBOutlet weak var productNameStackView: UIStackView!
    @IBOutlet weak var productNameTitleLabel: UILabel!
    @IBOutlet weak var editAllButton: UIButton!
    //,,,sb10
    
    var isSelected1stView = true
    var notFoundSerials = Array<Dictionary<String,Any>>()
    var allNotFound = false
    var selectedButtonTag = 0//,,,sb10
    var editAll = ""//,,,sb10

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    func populateNameProductAndStatus(product_name:String?,product:String?,status:String?)->NSAttributedString {
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15.0)!]
        
        let productNameString = NSMutableAttributedString(string:product_name ?? "", attributes: custAttributes)
        
        let productString = NSMutableAttributedString(string:"\n" + (product ?? ""), attributes: custAttributes)
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.0)!]
        
        let statusStr = NSAttributedString(string: "\n" + (status ?? ""), attributes: custTypeAttributes)
        
        productNameString.append(productString)
        productNameString.append(statusStr)
        
        return productNameString
    }
    //MARK:- End
    
    //MARK: - IBAction
    func shareCSV() {
        var csvString = "\("Product name".localized()), \("Product UUID".localized()), \("Simple serial".localized()), \("GS1 serial".localized()), \("Product gtin14".localized()), \("Lot number".localized()), \("Status".localized()), \("Expiration date".localized()) \n"
       for serial in notFoundSerials {
        //            csvString = csvString.appending("\(String(describing: serial))\n")

            var product_nameStr = ""
            if let product_name = serial["product_name"] as? String {
                product_nameStr = product_nameStr.appending(product_name)
                product_nameStr = product_nameStr.appending(",")
            }
            var product_uuidStr = ""
            if let product_uuid = serial["product_uuid"] as? String {
                product_uuidStr = product_uuidStr.appending(product_uuid)
                product_uuidStr = product_uuidStr.appending(",")
            }
            var simple_serialStr = ""
            if let simple_serial = serial["simple_serial"] as? String {
                simple_serialStr = simple_serialStr.appending(simple_serial)
                simple_serialStr = simple_serialStr.appending(",")
            }
            var gs1_serialStr = ""
            if let gs1_serial = serial["gs1_serial"] as? String {
                gs1_serialStr = gs1_serialStr.appending(gs1_serial)
                gs1_serialStr = gs1_serialStr.appending(",")
            }
            var product_gtin14Str = ""
            if let product_gtin14 = serial["product_gtin14"] as? String {
                product_gtin14Str = product_gtin14Str.appending(product_gtin14)
                product_gtin14Str = product_gtin14Str.appending(",")
            }
            var lot_numberStr = ""
            if let lot_number = serial["lot_number"] as? String {
                lot_numberStr = lot_numberStr.appending(lot_number)
                lot_numberStr = lot_numberStr.appending(",")
            }
            var statusStr = ""
            if let status = serial["status"] as? String {
                statusStr = statusStr.appending(status)
                statusStr = statusStr.appending(",")
            }
            var expiration_dateStr = ""
            if let expiration_date = serial["expiration_date"] as? String {
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
    }//,,,sb10
    
    @IBAction func exportButtonPressed(_ sender:UIButton){
        
        let notFoundPredicate = NSPredicate(format: "product_name == ''")
        let notFoundFilterArr = (self.notFoundSerials as NSArray).filtered(using: notFoundPredicate)
        if (notFoundFilterArr.count > 0) {
            Utility.showPopup(Title: App_Title, Message: "Please enter all product names.".localized(), InViewC: self)
        }
        else {
            self.shareCSV()
        }
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

        if let str = productNameTextFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines),str.isEmpty {
            Utility.showPopup(Title: "", Message: "Enter the product name".localized(), InViewC: self)
        }else {
            if (editAll == "All") {
                let propertyName = productNameTextFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                
                for i in 0..<notFoundSerials.count {
                    var dataDict = notFoundSerials[i]
                    dataDict["product_name"] = propertyName
                    notFoundSerials[i] = dataDict
                }
                            
                listTable.reloadData()
                productAddedView.isHidden = true
            }//,,,sb10
            else {
                let propertyName = productNameTextFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                var dataDict = notFoundSerials[selectedButtonTag]
                dataDict["product_name"] = propertyName
                notFoundSerials[selectedButtonTag] = dataDict
                            
                listTable.reloadData()
                productAddedView.isHidden = true
            }
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        productNameTextFiled.resignFirstResponder()
        self.view.bringSubviewToFront(productAddedView)
        
        
        if (sender == editAllButton) {
            editAll = "All"
            
            productAddedView.isHidden = false
            productNameTextFiled.text = ""
                    
            serialNumberStackView.isHidden = true
            lotNumberStackView.isHidden = true
            expirationDateStackView.isHidden = true
            gtinStackView.isHidden = true
            
            let dataDict = notFoundSerials[sender.tag]
            var dataStr = ""
            if let product_name = dataDict["product_name"] as? String {
                dataStr = product_name
            }
            productNameTextFiled.text = dataStr
            productNameTitleLabel.text = "ENTER ALL PRODUCT NAMES :".localized()
        }//,,,sb10
        else {
            editAll = ""
            selectedButtonTag = sender.tag
            
            productAddedView.isHidden = false
            productNameTextFiled.text = ""
            
            //,,,sb10
            serialNumberStackView.isHidden = false
            lotNumberStackView.isHidden = false
            expirationDateStackView.isHidden = false
            gtinStackView.isHidden = false
            //,,,sb10

            let dataDict = notFoundSerials[sender.tag]

            var dataStr = ""
            if let simple_serial = dataDict["simple_serial"] as? String {
                dataStr = simple_serial
            }
            serialLabel.text = dataStr

            dataStr = ""
            if let lot_number = dataDict["lot_number"] as? String {
                dataStr = lot_number
            }
            lotLabel.text = dataStr

            dataStr = ""
            if let expiration_date = dataDict["expiration_date"] as? String {
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss-HH:mm", outputFormat: "yyyy-MM-dd", dateStr: expiration_date){
                    dataStr = formattedDate
                }
            }
            expirationDateLabel.text = dataStr

            dataStr = ""
            if let product_gtin14 = dataDict["product_gtin14"] as? String {
                dataStr = product_gtin14
            }
            gtin14Label.text = dataStr
            
            dataStr = ""
            if let product_name = dataDict["product_name"] as? String {
                dataStr = product_name
            }
            productNameTextFiled.text = dataStr
            productNameTitleLabel.text = "ENTER PRODUCT NAME :".localized()//,,,sb10
        }
    }
    //MARK:- End
    
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 5))
        view.backgroundColor = UIColor.clear
        return view
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return notFoundSerials.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataDict = notFoundSerials[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFProductNotFoundListCell") as! ARSFProductNotFoundListCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.itemTypeButton.setImage(UIImage(named: "serial_error.png"), for: .normal)
        cell.arrowButton.isHidden = true
        cell.editButton.isHidden = false
        cell.editButton.tag = indexPath.section
        
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
        if let gs1Serial = dataDict["simple_serial"] as? String, let status = dataDict["status"] as? String {
            let product_name = dataDict["product_name"] as? String
            cell.itemNameAndTypeLabel.attributedText = populateNameProductAndStatus(product_name: product_name,  product: gs1Serial, status:((SFStatus[status] ?? "")?.localized()))//,,,sb10
        }else {
            cell.itemNameAndTypeLabel.text = ""
        }
        return cell
    }
    //MARK: - End
    
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

class ARSFProductNotFoundListCell: UITableViewCell {
    
    @IBOutlet weak var itemTypeButton: UIButton!
    @IBOutlet weak var itemNameAndTypeLabel: UILabel!
    @IBOutlet weak var gtinLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
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
