//
//  FinderViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 04/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class FinderViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,ARSFCardViewControllerDelegate { //,,,sb11-3
    
    @IBOutlet var roundedView:[UIView]!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var listTable: UITableView!
    
    //,,,sb9
    @IBOutlet weak var lastUsedARFilterLabel: UILabel!
    @IBOutlet weak var noDataFoundLabel: UILabel!//,,,sb11

//    var loadMoreButton = UIButton()//,,,sb11-6
    var itemsList: [[String: Any]] = []
    var currentPage = 1
    var totalResult = 0
    //,,,sb9
    var selectedDetailsDict = [String:Any]()//,,,sb11-10
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        for view in roundedView{
            view.setRoundCorner(cornerRadious: 10)
        }
        //,,,temp sb11
        //,,,sb9
        /*
        filterButton.isHidden = true
        startButton.isHidden = false
        lastUsedARFilterLabel.isHidden = true
        listTable.isHidden = true
        */
        
        filterButton.isHidden = false
        startButton.isHidden = false
        lastUsedARFilterLabel.isHidden = false
        listTable.isHidden = false
        //,,,sb9
        //,,,temp sb11
        
        self.setUpView()
       
        //,,,temp sb11
        //,,,sb9
//        loadMoreFooterView()//,,,sb11-6
//        last_used_filters_WebserviceCall(callType: "firstLoad")//,,,sb11-1
        //,,,sb9
        //,,,temp sb11
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.noDataFoundLabel.isHidden = true
        self.itemsList = []
        listTable.reloadData()
        last_used_filters_WebserviceCall(callType: "firstLoad")
    }//,,,temp sb11 //,,,sb11-1
    //MARK:- End
    
    //MARK:- IBAction
    @IBAction func viewDownloadableListButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ARExportProductDownloadableFilesController") as! ARExportProductDownloadableFilesController
        self.navigationController?.pushViewController(controller, animated: true)
    }//,,,sb8
    
    @IBAction func SerialFinderButtonPressed(_ sender: UIButton) {
        //,,,sb3
        if (sender == startButton) {
            self.didClickOnCamera()
        }
        else {
            //,,,sb8
//            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SFScannedListView") as! SFScannedListViewController
//             self.navigationController?.pushViewController(controller, animated: true)
            //,,,sb8
        }
        //,,,sb3
    }
    
    @IBAction func PPButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PPListViewController") as! PPListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        //,,,sb11-3
        let itemDetailsDict = itemsList[sender.tag]
        let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ARSFCardView") as! ARSFCardViewController
        controller.delegate = self
        controller.itemDetailsDict = itemDetailsDict
        controller.filterType = "LastUsedFilter"
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
        //,,,sb11-3
    }
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ARSFFilterView") as! ARSFFilterViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /*
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        last_used_filters_WebserviceCall(callType: "loadMore")
    }//,,,sb9
    *///,,,sb11-6
    //MARK:- End
    
    //MARK:- Private function
    func setUpView(){
        let custAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),//,,,sb1
        NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 15.0)!]
        let attString = NSMutableAttributedString(string: "Start".localized() + "\n", attributes: custAttributes)//,,,sb8
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor:  Utility.hexStringToUIColor(hex: "072144"),//,,,sb1
        NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 12.0)!]
        
        let typeStr = NSAttributedString(string: "With no filters".localized(), attributes: custTypeAttributes)//,,,sb8
        attString.append(typeStr)
        
        startButton.setAttributedTitle(attString, for: .normal)
        
        
        let custAttributes1: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),//,,,sb1,
        NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 13.0)!]
        let attString1 = NSMutableAttributedString(string: "Look With".localized() + "\n", attributes: custAttributes1)
        
        let custTypeAttributes2: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),//,,,sb1,
        NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 13.0)!]
        
        let typeStr1 = NSAttributedString(string: "Filters".localized(), attributes: custTypeAttributes2)
        attString1.append(typeStr1)
        
        filterButton.setAttributedTitle(attString1, for: .normal)
        //filterButton.isHidden = true
        listTable.reloadData()

    }
    
    func didClickOnCamera() {
        DispatchQueue.main.async{
            defaults.setValue(true, forKey: "IsMultiScan")
            if(defaults.bool(forKey: "IsMultiScan")){
                let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
                let controller = storyboard.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                controller.isOnlySerialFinederAR = true
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
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
    
    /*
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
    *///,,,sb11-6
    
    //MARK: - Webservice Call
    func last_used_filters_WebserviceCall(callType:String) {
        //,,,sb11-6
//        let url = "?nb_per_page=10&sort_by_asc=false&sort_by=created_on&page=\(currentPage)&filter_name="
        
        let str = "SERIAL_FINDER".addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        
        //,,,sb11-6
//        let url = "?filter_module=\(str ?? "")&nb_per_page=100&sort_by_asc=false&sort_by=created_on&page=\(currentPage)&filter_name=&description="
//        let url = "?filter_module=\(str ?? "")&nb_per_page=10&sort_by_asc=false&sort_by=created_on&page=\(currentPage)&filter_name=&description="
        let url = "?filter_module=\(str ?? "")&nb_per_page=10&sort_by_asc=false&sort_by=last_update&page=\(currentPage)&filter_name=&description="//,,,sb11-9
        //,,,sb11-6

        
        self.showSpinner(onView: self.view)//,,,sb11-6
        Utility.GETServiceCall(type: "ar_viewer", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        self.totalResult = (responseDict["nb_total_results"] as? Int) ?? 0
                        if let dataArray = responseDict["data"] as? [[String: Any]] {
                            self.itemsList += dataArray
//                            print ("self.itemsList....",self.itemsList.count)
                            self.listTable.reloadData()
                        }
                        
                        /*
                        self.loadMoreButton.isUserInteractionEnabled = true
                        if self.itemsList.count == self.totalResult {
                            self.loadMoreButton.isHidden = true
                        } else {
                            self.loadMoreButton.isHidden = false
                        }*///,,,sb11-6
                        
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
                    if let path = Bundle.main.path(forResource: "last_used_filters", ofType: "json") {
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
                    /*
                     self.loadMoreButton.isUserInteractionEnabled = true
                     self.loadMoreButton.isHidden = true//,,,sb11-1
                     *///,,,sb11-6
                    
                    self.noDataFoundLabel.isHidden = false//,,,sb11-1
                    self.listTable.reloadData()//,,,sb11-6
                    
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
                        let msg = "Last used AR filter deleted successfully".localized()//,,,sb11-11
                        Utility.showPopupWithAction(Title: Success_Title, Message: msg, InViewC: self, action:{
                            self.itemsList = []
                            self.last_used_filters_WebserviceCall(callType: "firstLoad")
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
            let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARSFCreateNewFilterView") as! ARSFCreateNewFilterViewController
            controller.mode = "edit"
            controller.detailsDict = detailsDict!
            self.navigationController?.pushViewController(controller, animated: true)
        }else if buttonName == "delete" {
            Utility.showPopupWithAction(Title: Warning, Message: "Do you want to delete last used AR filter?".localized(), InViewC: self, isCancel: true, action:{//,,,sb11-11
                if let uuid = detailsDict!["uuid"] as? String {
                    self.ar_viewer_delete_WebserviceCall(uuid: uuid)
                }
            })
        }else if buttonName == "duplicate" {
            let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARSFCreateNewFilterView") as! ARSFCreateNewFilterViewController
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
        
        //,,,sb11-10
        if itemsList.count > 5 {
            return 5
        }else {
            return itemsList.count
        }
        //,,,sb11-10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FinderViewTableViewCell") as! FinderViewTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        //,,,sb9
        let item = itemsList[indexPath.row]
        var dataStr = ""
        if let txt = item["filter_name"] as? String,!txt.isEmpty {
            dataStr = txt
        }
        cell.titleLabel.text = dataStr
        //,,,sb9
        
        cell.leftView.layer.cornerRadius = 10
        cell.rightView.layer.cornerRadius = 10
        cell.actionButton.tag=indexPath.row
        
        
//        cell.rightView.isHidden = true//,,,sb11-6
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
        }
    }
    //MARK:- End
}
extension FinderViewController : ScanViewControllerDelegate{
    func didScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
            let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARSFProductFoundListView") as! ARSFProductFoundListViewController
            
            //,,,temp sb0
            controller.scancode = scannedCode
            
            /*
            //for test server
            let staticScannedCode = ["010083491310500821203812477973667\u{1D}17240208100C99E164",
                                     "010083491310500821203812473404877\u{1D}17240208100C99E164"]//valid serial
            //for pre-test server
            let staticScannedCode = ["010083491310500821115416525167894\u{1D}17230604105A515DFD",
                                     "010083491331240621115416527155005\u{1D}1723060410EECEECCC",
                                     "010083491310500821115416529302118\u{1D}17230604105A515DFD",
                                     "010083491310500821115416525167894\u{1D}17230604105A515DFD",
                                     "010083491310500821115416527449546\u{1D}17230604105A515DFD",
                                     "010083491310500821121310435457135\u{1D}17230802100E6381B8",
                                     "010083491310500821115416524293419\u{1D}17230604105A515DFD"]//valid serial

            let staticScannedCode = ["010083491310500821115416524293419\u{1D}17230604105A515DFD",
                                      "010136912062719121127617012384330\u{1D}1723100410BB3F3B93",
                                      "010083491310500821133413571022612\u{1D}172312011058BA5jj9"
                                     ]//valid serial, not found
             
            let staticScannedCode = ["010136912062719121127617012384330\u{1D}1723100410BB3F3B93",
                                      "010083491310500821133413571022612\u{1D}172312011058BA5jj9"
                                     ]//not found
            
            let staticScannedCode = ["01008349131050081723110110EA8180EC"
                                    ]//lot found //,,,sb9
            
            let staticScannedCode = ["01008349131050081723110110EA8180EC",
                                     "010136912062719121127617012384330\u{1D}1723100410BB3F3B93"
                                    ]//lot found, not found //,,,sb9
            
            controller.scancode = staticScannedCode
            */
            //,,,temp sb0
            
            self.navigationController?.pushViewController(controller, animated: false)
//            print("Scanned Barcodes") //,,,sb11-12
        }
    }
    func didLotBasedTriggerScanDetailsForLotBased(arr : NSArray){
     }
    func didScanCodeFromAR(scannedCode scannedcode : [String]) {
        let controller = self.navigationController?.visibleViewController
        if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
            self.navigationController?.popViewController(animated: false)
            DispatchQueue.main.async {
            self.didScanCodeForReceiveSerialVerification(scannedCode: Array(scannedcode))
          }
        }
     }
    
    func didScanCodeForReceiveSerialVerificationAndCodeDetails(scannedCode:[String], codeDetailsArray:[[String : Any]]) {
        DispatchQueue.main.async{
            let storyboard = UIStoryboard.init(name: "AugmentedReality", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARSFProductFoundListView") as! ARSFProductFoundListViewController
            
            controller.scancode = scannedCode
            controller.controllerName = "FinderViewController"
            controller.lookWithFilterSearchArray = codeDetailsArray
            controller.selectedDetailsDict = self.selectedDetailsDict//,,,sb11-10
            
            self.navigationController?.pushViewController(controller, animated: false)
//            print("Scanned Barcodes") //,,,sb11-12
        }
    }//,,,sb11-3
    
    func backToScanViewController() {
    }//,,,sb11-3
}

class FinderViewTableViewCell:UITableViewCell{
    @IBOutlet var leftView: UIView!
    @IBOutlet var rightView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
