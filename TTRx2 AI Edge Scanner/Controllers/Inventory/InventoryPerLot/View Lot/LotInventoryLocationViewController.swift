//
//  LotInventoryLocationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 28/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class LotInventoryLocationViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationFieldView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    
    @IBOutlet weak var listTable: UITableView!
    
    @IBOutlet var lotStackView: UIStackView!
    
    var productUuid = ""
    var lotNumber = ""
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var currentPage = 1
    var totalResult = 0
    var allLocations:NSDictionary?
    var allLocationList = [[String : Any]]()
    var locationUuid = ""
    
    var isForItemsInInventory = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        sectionView.roundTopCorners(cornerRadious: 40)
        locationView.setRoundCorner(cornerRadious: 10)

        locationFieldView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        getAllLocation()
        
        loadMoreFooterView()
        lotLabel.text = lotNumber
        locationLabel.text = "Global".localized()
        locationLabel.accessibilityHint = ""
        locationLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
        getStorageListWithQueryParam()
        
        if isForItemsInInventory {
            lotStackView.isHidden = true
        }

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Action
    
    @IBAction func viewButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotInventoryView") as! LotInventoryViewController
        let dataDict = itemsList[sender.tag]
        print(dataDict)
        if let uuid = dataDict["storage_area_uuid"] as? String{
            controller.storageAreaUuid = uuid
        }
        controller.productUuid = productUuid
        
        if isForItemsInInventory {
            controller.isForItemsInInventory = isForItemsInInventory
            if let lot = dataDict["lot"] as? String{
                controller.lotNumber = lot //"\(lot)"
            }
        }else{
            controller.lotNumber = lotNumber
        }
        controller.forStorageArea = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
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
//                self.didReceiveBarcodeLocationScan(codeDetails: ["scannedCodes":"b592af47-4319-4739-824b-9ca8d93d34cc"])

    }
    
    
        
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getStorageListWithQueryParam()
        
    }
    //MARK: - End
    
    
    //MARK: - Privae method
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
    
    func loadMoreFooterView() {
        loadMoreButton = UIButton(frame: CGRect(x: 0, y: -20, width: self.listTable.frame.width, height: 50))
        //UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.listTable.frame.width, height: 40)))
        loadMoreButton.titleLabel?.textAlignment = .center
        loadMoreButton.setTitleColor(#colorLiteral(red: 0.02745098039, green: 0.1294117647, blue: 0.2666666667, alpha: 1), for: .normal)
        loadMoreButton.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 16.0)
        loadMoreButton.setTitle("Load more".localized(), for: .normal)
        loadMoreButton.backgroundColor = .clear
        self.listTable.tableFooterView?.backgroundColor = .clear
        loadMoreButton.addTarget(self, action:#selector(loadMoreButtonPressed), for: .touchUpInside)
        self.listTable.tableFooterView = loadMoreButton
        
    }
    //MARK: - End
    
    
    //MARK: - Call API
    
    func getStorageListWithQueryParam() {
        let appendStr = "\(productUuid)/lots/storage_area?is_wrap_results_in_generic_search_object=true&location_uuid=\(locationUuid)&lot=\(lotNumber)&sort_by_asc=true&nb_per_page=10&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetProducts", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                        if let dataArray = responseDict["data"] as? [[String: Any]] {
                            self.itemsList += dataArray
                            self.listTable.reloadData()
                        }
                        self.loadMoreButton.isUserInteractionEnabled = true
                        if self.itemsList.count == self.totalResult {
                            self.loadMoreButton.isHidden = true
                        } else {
                            self.loadMoreButton.isHidden = false
                        }
                    }
                }else{
                    self.currentPage -= 1
                    self.loadMoreButton.isUserInteractionEnabled = true
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
                
                currentPage = 1
                itemsList = []
                listTable.reloadData()
                getStorageListWithQueryParam()
            }
        }
        
    }
    
    
    //MARK: - End

}


//MARK: - Tableview Delegate and Datasource
extension LotInventoryLocationViewController: UITableViewDelegate, UITableViewDataSource {


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }



    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "StorageListCell") as! StorageListCell

        cell.customView.setRoundCorner(cornerRadious: 10)
        cell.storageShelfView.isHidden = true
        
        let item = itemsList[indexPath.row]

        var dataStr = ""
        if let txt = item["storage_area_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.storageAreaLabel.text = dataStr

        dataStr = ""
        if let txt = item["storage_shelf_name"] as? String,!txt.isEmpty{
            dataStr = txt
            cell.storageShelfView.isHidden = false
        }
        cell.storageShelfLabel.text = dataStr

        dataStr = ""
        if let txt = item["get_total_available_items"] as? NSNumber{
            dataStr = "\(txt)"
        }
        cell.quantityLabel.text = dataStr
        
        cell.viewButton.tag = indexPath.row

        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class StorageListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
           
    @IBOutlet weak var storageAreaLabel: UILabel!
    
    @IBOutlet weak var storageShelfView: UIView!
    @IBOutlet weak var storageShelfLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var viewButton: UIButton!


    @IBOutlet var multiLingualViews: [UIView]!

    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }

}


//MARK: - Scan view delegate
extension LotInventoryLocationViewController:SingleScanViewControllerDelegate{
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

//MARK: - End
