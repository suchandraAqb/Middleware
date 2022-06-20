//
//  ARSFProductFoundListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 13/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFProductFoundListViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var exportLabel: UILabel!//,,,sb7
    @IBOutlet weak var exportButton : UIButton!//,,,sb3
    @IBOutlet weak var productNotFoundView: UIView!//,,,sb10
    @IBOutlet weak var productNotFoundButton: UIButton!//,,,sb7
    
    
    var allScannedSerials = Array<String>()
    var allMainSerials = Array<Dictionary<String,Any>>()//,,,sb6
    var verifiedSerials = Array<Dictionary<String,Any>>()
    var notFoundSerials = Array<Dictionary<String,Any>>()//,,,sb7
    var lotFoundSerials = Array<Dictionary<String,Any>>()//,,,sb7
    var scancode : [String] = []
    var uniquesProducts = [String]()
    var product_detailsArr = Array<Dictionary<String,Any>>()
    
    var lookWithFilterSearchArray = [[String : Any]]()//,,,sb11-2
    var controllerName = ""//,,,sb11-2
    var selectedDetailsDict = [String:Any]()//,,,sb11-10
    

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
//        print("selectedDetailsDict.....",selectedDetailsDict)//,,,sb11-10 //,,,sb11-12
        
        if controllerName == "ARSFCreateNewFilterViewController" ||
           controllerName == "ARSFFilterViewController" ||
           controllerName == "FinderViewController" {
            
            self.getFilterArrayFromLookWithFilters()
        }//,,,sb11-2 //,,,sb11-3
        else {
            self.prepareSerialsForAPI(scannedCode: scancode)
            self.listTable.isHidden = true
            
            //,,,sb7
            self.exportLabel.alpha = 0.5
            self.exportButton.alpha = 0.5
            self.exportButton.isUserInteractionEnabled = false
            productNotFoundView.isHidden = true
            //,,,sb7
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func backButtonPressed(sender:UIButton) {
        //,,,sb11-10
        /*
        if controllerName == "ARSFCreateNewFilterViewController" {
            guard let controllers = self.navigationController?.viewControllers else { return }
            
            var isPopView = true
            for  controller in controllers {
                if controller.isKind(of: ARSFCreateNewFilterViewController.self){
                    isPopView = false
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
            if isPopView {
                navigationController?.popViewController(animated: true)
            }
        }
        else if controllerName == "ARSFFilterViewController" {
            guard let controllers = self.navigationController?.viewControllers else { return }
            var isPopView = true
            for  controller in controllers {
                if controller.isKind(of: ARSFFilterViewController.self){
                    isPopView = false
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
            if isPopView {
                navigationController?.popViewController(animated: true)
            }
        }//,,,sb11-3
        else {
            navigationController?.popViewController(animated: true)
        }*/
        
        navigationController?.popViewController(animated: true)
        //,,,sb11-10
    }//,,,sb11-2
    
    
    @IBAction func productNotFoundButtonPressed(_ sender: UIButton) {
        self.navigateProductNotFoundListViewController(navigationType: "popViewController")//,,,sb9
    }//,,,sb7
    
    func navigateProductNotFoundListViewController(navigationType: String){
        let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
        
//        let controller = storyboard.instantiateViewController(withIdentifier: "ARSFProductNotFoundListViewController") as! ARSFProductNotFoundListViewController
        let controller = storyboard.instantiateViewController(withIdentifier: "ARSFProductNotFoundListViewController1") as! ARSFProductNotFoundListViewController1
        
        controller.notFoundSerials = notFoundSerials
        
        if (navigationType == "popToViewController") {
            controller.allNotFound = true
        }else {
            controller.allNotFound = false
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }//,,,sb9
    
    @IBAction func deleteButtonPressed(_ sender:UIButton){
        //,,,sb3
        /*
        let msg = "You are about to delete the product with lots and serials?".localized()
        
        let confirmAlert = UIAlertController(title: "Confrimation".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            if self.uniquesProducts.count > 0 {
                self.uniquesProducts.remove(at:sender.tag)
                if self.uniquesProducts.isEmpty {
                    self.exportButton.alpha = 0.5
                    self.exportButton.isUserInteractionEnabled = false
                }else{
                    self.exportButton.alpha = 1
                    self.exportButton.isUserInteractionEnabled = true
                }
                self.listTable.reloadData()
            }
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        */
        
        let msg = "You are about to delete the product with lots and serials?".localized()
        
        let confirmAlert = UIAlertController(title: "Confrimation".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes".localized(), style: .default) { (UIAlertAction) in
            if self.uniquesProducts.count > 0 {
                self.uniquesProducts.remove(at:sender.tag)
                if self.uniquesProducts.isEmpty {
                    self.exportLabel.alpha = 0.5
                    self.exportButton.alpha = 0.5
                    self.exportButton.isUserInteractionEnabled = false
                }else{
                    self.exportLabel.alpha = 1
                    self.exportButton.alpha = 1
                    self.exportButton.isUserInteractionEnabled = true
                }
                self.listTable.reloadData()
            }
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        //,,,sb3
       
    }
    @IBAction func exportButtonPressed(_ sender:UIButton){
        self.prepareExportData()
//        print ("self.lookWithFilterSearchArray.....",self.lookWithFilterSearchArray) //,,,sb11-12
//        print ("self.selectedDetailsDict.....",self.selectedDetailsDict)//,,,sb11-10 //,,,sb11-12

        DispatchQueue.main.async {
            let storyboard = UIStoryboard.init(name:"AugmentedReality",bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARExportProductFirstView") as! ARExportProductFirstViewController
            controller.productDetailsArr = self.product_detailsArr
            controller.selectedDetailsDict = self.selectedDetailsDict//,,,sb11-10
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    //MARK:- End
    
    
    //MARK: - Privete Method
    func prepareSerialsForAPI(scannedCode: [String]){
        self.allScannedSerials.append(contentsOf: scannedCode)
        self.allScannedSerials = Array(Set(self.allScannedSerials))
        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSerialFinder)
//        print ("first.count...1",first.count)
        
        if first.count > 0 {
            self.validateSerials(serials: first.joined(separator: ","))
            self.showSpinner(onView: self.view)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self)
            return
        }
    }
    
    
    func getFilterArrayFromLookWithFilters() {
                
        for serialDetails in lookWithFilterSearchArray {
            if !(self.allMainSerials as NSArray).contains(serialDetails){
                self.allMainSerials.append(serialDetails)
            }
        }
        
        if self.allMainSerials.count>0 {
            let predicate = NSPredicate(format: "product_uuid != '' and status != 'NOT_FOUND' and status != 'LOT_FOUND'")
            let filterArr = (self.allMainSerials as NSArray).filtered(using: predicate)
            for filterDict in filterArr {
                if !(self.verifiedSerials as NSArray).contains(filterDict){
                    self.verifiedSerials.append(filterDict as! Dictionary<String,Any>)
                }
            }

            //,,,sb7
            let notFoundPredicate = NSPredicate(format: "status == 'NOT_FOUND'")
            let notFoundFilterArr = (self.allMainSerials as NSArray).filtered(using: notFoundPredicate)
            for notFoundFilterDict in notFoundFilterArr {
                if !(self.notFoundSerials as NSArray).contains(notFoundFilterDict){
                    self.notFoundSerials.append(notFoundFilterDict as! Dictionary<String,Any>)
                }
            }

            let lotFoundPredicate = NSPredicate(format: "status == 'LOT_FOUND'")
            let lotFoundFilterArr = (self.allMainSerials as NSArray).filtered(using: lotFoundPredicate)
            for lotFoundFilterDict in lotFoundFilterArr {
                if !(self.lotFoundSerials as NSArray).contains(lotFoundFilterDict){
                    self.lotFoundSerials.append(lotFoundFilterDict as! Dictionary<String,Any>)
                }
            }
            //,,,sb7
        }
        //,,,sb6
        
        //,,,sb10
        self.listTable.reloadData()
        self.populateProducView()
        //,,,sb10
        
        self.removeSpinner()
        if self.uniquesProducts.count > 0 {
           self.listTable.isHidden = false
        }
    }//,,,sb11-2
    
    func validateSerials(serials : String){
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?serial_type=GS1_BARCODE&serials=\(str ?? "")&result_type=ON_SCREEN"
            Utility.GETServiceCall(type: "SerialFinder", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    if isDone! {
                        if let responseDict = responseData as? NSDictionary? {
                            if let responseArray = responseDict!["results"] as? NSArray{
                                if responseArray.count > 0 {

                                    if let serialDetailsArray = responseArray as? [[String : Any]]{
                                        
                                        //,,,sb6
                                        /*
                                        for serialDetails in serialDetailsArray {
                                            if !(self.verifiedSerials as NSArray).contains(serialDetails){
                                                self.verifiedSerials.append(serialDetails)
                                            }
                                        }
                                        print("self.verifiedSerials...>>",self.verifiedSerials as NSArray)
                                        */
                                        
                                        for serialDetails in serialDetailsArray {
                                            if !(self.allMainSerials as NSArray).contains(serialDetails){
                                                self.allMainSerials.append(serialDetails)
                                            }
                                        }
//                                        print("self.allMainSerials...>> count",self.allMainSerials as NSArray,self.allMainSerials.count)
                                        
                                        if self.allMainSerials.count>0 {
                                            let predicate = NSPredicate(format: "product_uuid != '' and status != 'NOT_FOUND' and status != 'LOT_FOUND'")
                                            let filterArr = (self.allMainSerials as NSArray).filtered(using: predicate)
                                            for filterDict in filterArr {
                                                if !(self.verifiedSerials as NSArray).contains(filterDict){
                                                    self.verifiedSerials.append(filterDict as! Dictionary<String,Any>)
                                                }
                                            }
//                                            print("self.verifiedSerials...>> count",self.verifiedSerials as NSArray,self.verifiedSerials.count)

                                            //,,,sb7
                                            let notFoundPredicate = NSPredicate(format: "status == 'NOT_FOUND'")
                                            let notFoundFilterArr = (self.allMainSerials as NSArray).filtered(using: notFoundPredicate)
                                            for notFoundFilterDict in notFoundFilterArr {
                                                if !(self.notFoundSerials as NSArray).contains(notFoundFilterDict){
                                                    self.notFoundSerials.append(notFoundFilterDict as! Dictionary<String,Any>)
                                                }
                                            }
//                                            print("self.notFoundSerials...>> count",self.notFoundSerials as NSArray,self.notFoundSerials.count)

                                            let lotFoundPredicate = NSPredicate(format: "status == 'LOT_FOUND'")
                                            let lotFoundFilterArr = (self.allMainSerials as NSArray).filtered(using: lotFoundPredicate)
                                            for lotFoundFilterDict in lotFoundFilterArr {
                                                if !(self.lotFoundSerials as NSArray).contains(lotFoundFilterDict){
                                                    self.lotFoundSerials.append(lotFoundFilterDict as! Dictionary<String,Any>)
                                                }
                                            }
//                                            print("self.lotFoundSerials...>> count",self.lotFoundSerials as NSArray,self.lotFoundSerials.count)
                                            //,,,sb7
                                        }
                                        //,,,sb6
                                    }
                                }else{
                                    //Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later." , InViewC: self)
                                }
                            }
                        }
                        
                        /*
                        self.listTable.reloadData()
                        self.populateProducView()
                        *///,,,sb10
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
//                    print ("first.count...2",first.count)
                    if first.count > 0 {
                        self.validateSerials(serials: first.joined(separator: ","))
                    }else{
                        
                        //,,,sb10
                        self.listTable.reloadData()
                        self.populateProducView()
                        //,,,sb10
                        
                        self.removeSpinner()
                        if self.uniquesProducts.count > 0 {
                           self.listTable.isHidden = false
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
  
    func populateProducView() {
        
        if verifiedSerials.count>0 {
//            print ("verifiedSerials count.......",verifiedSerials.count)//,,,sb11-12
            
            let predicate = NSPredicate(format: "product_uuid != '' and status != 'NOT_FOUND' and status != 'LOT_FOUND'")
            let filterArr = (verifiedSerials as NSArray).filtered(using: predicate)
            if filterArr.count > 0 {
                if let unique = (filterArr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? [String]{
                    uniquesProducts = unique
//                    print(uniquesProducts as Any)
                }
            }
            
            //,,,sb7
//            else{
//                Utility.showPopup(Title: App_Title, Message: "Products are either Not found or Non-serialized".localized(), InViewC: self)
//            }
            
            self.exportLabel.alpha = 1
            self.exportButton.alpha = 1
            self.exportButton.isUserInteractionEnabled = true
            
            if (notFoundSerials.count > 0) {
                productNotFoundView.isHidden = false
            }else {
                productNotFoundView.isHidden = true
            }
            
            if (lotFoundSerials.count > 0) {
                Utility.showPopup(Title: App_Title, Message: "Lot based data found in scanned result but serial finder is not compatible with lot based data.".localized(), InViewC: self)
            }
            //,,,sb7
        }
        else {
            self.exportLabel.alpha = 0.5
            self.exportButton.alpha = 0.5
            self.exportButton.isUserInteractionEnabled = false
            
            productNotFoundView.isHidden = true
            if (notFoundSerials.count > 0) {
                productNotFoundView.isHidden = false
            }
            
            if (allMainSerials.count > 0) {
                if (notFoundSerials.count == allMainSerials.count) {
                    self.navigateProductNotFoundListViewController(navigationType: "popToViewController")//,,,sb9
                }
                else {
                    if (lotFoundSerials.count == allMainSerials.count) {
                        Utility.showPopupWithAction(Title: App_Title, Message: "Lot based data found in scanned result but serial finder is not compatible with lot based data.".localized(), InViewC: self, action:{
                            self.navigationController?.popViewController(animated: false)
                        })
                    }
                    else {
                        if (notFoundSerials.count > 0) {
                            Utility.showPopupWithAction(Title: App_Title, Message: "Products are either Not found or Non-serialized".localized(), InViewC: self, action:{
                                
    //                            self.navigateProductNotFoundListViewController(navigationType: "popToViewController")
                            })//,,,sb9
                        }
                        else {
                            Utility.showPopupWithAction(Title: App_Title, Message: "Products are either Not found or Non-serialized".localized(), InViewC: self, action:{
                                self.navigationController?.popViewController(animated: false)
                            })
                        }
                    }
                }
            }
            else {
                Utility.showPopupWithAction(Title: App_Title, Message: "No Product Found".localized(), InViewC: self, action:{
                    self.navigationController?.popViewController(animated: false)
                })
            }
        }//,,,sb7

            
        listTable.reloadData()
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
    func prepareExportData() {
        //,,,sb3
        /*
        for uuid in uniquesProducts{
            
            var lotDict = [String:Any]()
            var uniqueArr = NSArray()
            var uniqueSerialArr = NSArray()
            var lotDetailsArray = Array<Dictionary<String,Any>>()
            var productDetailsDict = [String:Any]()
            var uniqueBarcodeArray = NSArray()
            
            let product = self.getInvidualProductList(uuid: uuid as String)
            if let unique = (product as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String]{
                uniqueArr = unique as NSArray
            }
            for lotNumeber in uniqueArr{
                lotDict["lot_no"] = lotNumeber
            
                let filterArray = self.getInvidualProductLotList(uuid: uuid as String, lot: lotNumeber as! String)
                    if let unique = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.simple_serial") as? [String]{
                        uniqueSerialArr = unique as NSArray
                }
                if let unique = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.gs1_serial") as? [String]{
                    uniqueBarcodeArray = unique as NSArray
                }
                lotDict["barcodes"] = uniqueBarcodeArray
                lotDict["serials"] = uniqueSerialArr
                lotDetailsArray.append(lotDict)
            }
            productDetailsDict["product_uuid"] = uuid
            productDetailsDict["lot_details"] = lotDetailsArray
            product_detailsArr.append(productDetailsDict)
        }*/
        
        product_detailsArr = []
        for uuid in uniquesProducts {
            var lotDict = [String:Any]()
            var uniqueArr = NSArray()
            var lotDetailsArray = Array<Dictionary<String,Any>>()
            var productDetailsDict = [String:Any]()
            
            let product = self.getInvidualProductList(uuid: uuid as String)
            if let unique = (product as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String]{
                uniqueArr = unique as NSArray
            }
            
            for lotNumeber in uniqueArr {
                let filterArray = self.getInvidualProductLotList(uuid: uuid as String, lot: lotNumeber as! String)
                var serialArray = Array<Dictionary<String,Any>>()
                for lotDict in filterArray {
                    let simple_serial = lotDict["simple_serial"]  as? String
                    let gs1_serial = lotDict["gs1_serial"]  as? String
                    let serial_format = "PRODUCT_SIMPLE_SERIAL"
                    
                    var serialDict = [String:Any]()
                    serialDict["serial"] = simple_serial
                    serialDict["serial_format"] = serial_format
                    serialDict["barcode"] = gs1_serial
                    serialArray.append(serialDict)
                }
                lotDict["serials"] = serialArray
                lotDict["lot_no"] = lotNumeber
                lotDetailsArray.append(lotDict)
            }
            productDetailsDict["product_uuid"] = uuid
            productDetailsDict["lot_details"] = lotDetailsArray
            product_detailsArr.append(productDetailsDict)
        }
        //,,,sb3
    }
    
    //MARK:- End
    
    
    //MARK: - Webservice Call
    
    //MARK:- End
    
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !uniquesProducts.isEmpty {
            return uniquesProducts.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SFProductFoundCell") as! SFProductFoundCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.deleteButton.tag = indexPath.row
        let isdeleteShow = defaults.object(forKey: "collect_result") as! Bool
        if isdeleteShow {
            cell.deleteButton.isHidden = false
        }else{
            cell.deleteButton.isHidden = true
        }
        
        if !uniquesProducts.isEmpty {

            let product_uuid = uniquesProducts[indexPath.row]
            let products = getInvidualProductList(uuid: product_uuid)
            if products.count>0 {
                if let unique = (products as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String] {
                    let dict = products.first! as NSDictionary
                    cell.productName.text = dict["product_name"]  as? String
                    var str = ""
                    var str1 = ""
                    //,,,sb3
                    if unique.count>1 {
                        str = "lots".localized()
                        str1 = "Units found in".localized()
                    }else {
                        str = "lot".localized()
                        str1 = "Unit found in".localized()
                    }
                    let newStr = "\(products.count)" + " \(str1) \(unique.count) \(str)"
                    //,,,sb3
                    cell.lotdetails.text = newStr
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard.init(name:"AugmentedReality",bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARSFProductFoundDetailsView") as! ARSFProductFoundDetailsViewController
            let product_uuid = self.uniquesProducts[indexPath.row] as NSString
            controller.product_uuid = product_uuid
            controller.product = self.getInvidualProductList(uuid: product_uuid as String)
            controller.selectedDetailsDict = self.selectedDetailsDict//,,,sb11-10
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
class SFProductFoundCell: UITableViewCell {
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var lotdetails: UILabel!
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var deleteButton : UIButton!
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
