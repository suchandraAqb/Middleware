//
//  ARSFFilterViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 06/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFFilterViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,ARSFCardViewControllerDelegate,ARSFFilterSearchViewControllerDelegate { //,,,sb11-6

    @IBOutlet var createNewFilterButton: UIButton!
    @IBOutlet var listTable: UITableView!
    @IBOutlet weak var noDataFoundLabel: UILabel!//,,,sb11
    @IBOutlet weak var filterButton: UIButton!//,,,sb11-6
    
    //,,,sb9
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var currentPage = 1
    var totalResult = 0
    //,,,sb9
    
    var searchDict = [String:Any]()//,,,sb11-6
    var appendString = ""//,,,sb11-6
    var isSearch = false//,,,sb11-6
    var selectedDetailsDict = [String:Any]()//,,,sb11-10


    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        createNewFilterButton.setRoundCorner(cornerRadious: 15)
        listTable.reloadData()
        
        //,,,sb9
        loadMoreFooterView()
//        ar_viewer_WebserviceCall(callType: "firstLoad")//,,,sb11-1
        //,,,sb9
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //,,,sb11-6
        if !isSearch {
            self.noDataFoundLabel.isHidden = true
            currentPage = 1
            self.itemsList = []
            listTable.reloadData()
            ar_viewer_WebserviceCall(callType: "firstLoad")
        }
        else {
            isSearch = false
        }
        //,,,sb11-6
    }//,,,sb11-1
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func createNewFilterButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFCreateNewFilterView") as! ARSFCreateNewFilterViewController
        controller.mode = "create"//,,,sb11-3
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        //,,,sb11-3
        let itemDetailsDict = itemsList[sender.tag]
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFCardView") as! ARSFCardViewController
        controller.delegate = self
        controller.itemDetailsDict = itemDetailsDict
        controller.filterType = "ExistingPresetFilter"
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
        //,,,sb11-3
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        ar_viewer_WebserviceCall(callType: "loadMore")
    }//,,,sb9
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFFilterSearchViewController") as! ARSFFilterSearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }//,,,sb11-6
    //MARK:- End
    
    
    //MARK: - Privete Method
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
    }//,,,sb9
    
    func didClickOnCameraWithFilter(uuid:String) {
        DispatchQueue.main.async{
            defaults.setValue(true, forKey: "IsMultiScan")
            if(defaults.bool(forKey: "IsMultiScan")){
                let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
                let controller = storyboard.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                controller.isOnlySerialFinederAR = true
                controller.isLookWithFilterAR = true
                controller.delegate = self
                controller.mainUUID = uuid
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }//,,,sb11-3
    //MARK:- End
    
    //MARK: - Webservice Call
    func ar_viewer_WebserviceCall(callType:String) {
        let str = "SERIAL_FINDER".addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        
        //,,,sb11-6
//        let url = "?filter_module=\(str ?? "")&nb_per_page=100&sort_by_asc=false&sort_by=created_on&page=\(currentPage)&filter_name=&description="
//        let url = "?filter_module=\(str ?? "")&nb_per_page=100&sort_by_asc=false&sort_by=created_on&page=\(currentPage)&\(appendString)"
        let url = "?filter_module=\(str ?? "")&nb_per_page=100&sort_by_asc=false&sort_by=last_update&page=\(currentPage)&\(appendString)"//,,,sb11-9
        //,,,sb11-6

        
        
        self.showSpinner(onView: self.view)
        
        Utility.GETServiceCall(type: "ar_viewer", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                        if let dataArray = responseDict["data"] as? [[String: Any]] {
                            self.itemsList += dataArray
//                            print ("self.itemsList....",self.itemsList.count) //,,,sb11-12
                            self.listTable.reloadData()
                        }
                        self.loadMoreButton.isUserInteractionEnabled = true
                        if self.itemsList.count == self.totalResult {
                            self.loadMoreButton.isHidden = true
                        } else {
                            self.loadMoreButton.isHidden = false
                        }
                        
                        //,,,sb11-1
                        if self.itemsList.count > 0 {
                            self.noDataFoundLabel.isHidden = true
                        }else {
                            self.noDataFoundLabel.isHidden = false
                            self.listTable.reloadData()//,,,sb11-6
                        }
                        //,,,sb11-1
                    }
                    
                    /*
                    if let path = Bundle.main.path(forResource: "LookWithFilter", ofType: "json") {
                        do {
                              let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                              let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                              if let responseDict = jsonResult as? [String: Any] {
                                self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                                if let dataArray = responseDict["data"] as? [[String: Any]] {
                                    self.itemsList += dataArray
                                    print ("self.itemsList....",self.itemsList.count,self.itemsList)
                                    self.listTable.reloadData()
                                }
                                self.loadMoreButton.isUserInteractionEnabled = true
                                if self.itemsList.count == self.totalResult {
                                    self.loadMoreButton.isHidden = true
                                } else {
                                    self.loadMoreButton.isHidden = false
                                }
                            }
                          } catch {
                               print("JSON parsing Error")
                          }
                    }
                    */
                    
                }else {
                    self.currentPage -= 1
                    self.loadMoreButton.isUserInteractionEnabled = true
                    self.noDataFoundLabel.isHidden = false//,,,sb11-1
                    self.listTable.reloadData()//,,,sb11-6
                    self.loadMoreButton.isHidden = true//,,,sb11-1
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }

                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }//,,,sb9
    
    func ar_viewer_delete_WebserviceCall(uuid:String) {
        let appendStr = "/\(uuid)"
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "ar_viewer", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if (responseDict["uuid"] as? String) != nil {
                        let msg = "Existing preset AR filter deleted successfully".localized()//,,,sb11-11
                        Utility.showPopupWithAction(Title: Success_Title, Message: msg, InViewC: self, action:{
                            self.currentPage = 1
                            self.itemsList = []
                            self.ar_viewer_WebserviceCall(callType: "firstLoad")
                        })
                    }
                }
                else {
                    if responseData != nil {
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else  if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                        }
                    }else {
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
                
            }
        }
    }//,,,sb11-3
    //MARK: End
    
    //MARK:- ARSFCardViewControllerDelegate
    func didSelectButton(buttonName:String,detailsDict:[String:Any]?) {
        
        selectedDetailsDict = detailsDict! //,,,sb11-10
        
        if buttonName == "start" {
            if let uuid = detailsDict!["uuid"] as? String {
                self.didClickOnCameraWithFilter(uuid: uuid)
            }
        }else if buttonName == "edit" {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFCreateNewFilterView") as! ARSFCreateNewFilterViewController
            controller.mode = "edit"
            controller.detailsDict = detailsDict!
            self.navigationController?.pushViewController(controller, animated: true)
        }else if buttonName == "delete" {
            Utility.showPopupWithAction(Title: Warning, Message: "Do you want to delete existing preset filter?".localized(), InViewC: self, isCancel: true, action:{
                if let uuid = detailsDict!["uuid"] as? String {
                    self.ar_viewer_delete_WebserviceCall(uuid: uuid)
                }
            })
        }else if buttonName == "duplicate" {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFCreateNewFilterView") as! ARSFCreateNewFilterViewController
            controller.mode = "duplicate"
            controller.detailsDict = detailsDict!
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }//,,,sb11-3
    //MARK:- End
    
    //MARK: - Table view datasourse & delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList.count//,,,sb9
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFFilterCell") as! ARSFFilterCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        //,,,sb9
//        cell.titleLabel.text="Products who are about to expire"
//        cell.descriptionLabel.text="Find only the products who will expire in 90 days or less, from today."
        
        let item = itemsList[indexPath.row]
        var dataStr = ""
        if let txt = item["filter_name"] as? String,!txt.isEmpty {
            dataStr = txt
        }
        cell.titleLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["description"] as? String,!txt.isEmpty {
            dataStr = txt
        }
        cell.descriptionLabel.text = dataStr
        //,,,sb9
        
        cell.leftView.layer.cornerRadius = 10
        cell.rightView.layer.cornerRadius = 10
        cell.actionButton.tag=indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            
        }
    }
    //MARK:- End
    
    //MARK: - Search View Delegate
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?) {
        isSearch = true
        
        filterButton.isSelected = false
        if searchDict != nil{
            self.searchDict = searchDict!
            if !self.searchDict.isEmpty {
                filterButton.isSelected = true
            }
        }

        self.appendString = appendstr
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        self.ar_viewer_WebserviceCall(callType: "firstLoad")
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
    }
    //MARK: End
}

extension ARSFFilterViewController : ScanViewControllerDelegate {
    func didScanCodeForReceiveSerialVerificationAndCodeDetails(scannedCode:[String], codeDetailsArray:[[String : Any]]) {
        DispatchQueue.main.async{
            let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARSFProductFoundListView") as! ARSFProductFoundListViewController
            
            controller.scancode = scannedCode
            controller.controllerName = "ARSFFilterViewController"
            controller.lookWithFilterSearchArray = codeDetailsArray
            controller.selectedDetailsDict = self.selectedDetailsDict//,,,sb11-10
            
            self.navigationController?.pushViewController(controller, animated: false)
//            print("Scanned Barcodes")//,,,sb11-12
        }
    }
    
    func backToScanViewController() {
    }
}//,,,sb11-3

//MARK:  Table view cell class
class ARSFFilterCell:UITableViewCell{
    @IBOutlet var leftView: UIView!
    @IBOutlet var rightView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
