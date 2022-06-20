//
//  ContainerListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 17/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ContainerListViewController: BaseViewController,ContainerSearchViewDelegate,ContainerDetailsViewDelegate {
        
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var searchDict = [String:Any]()
    
    //MARK: - End
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        getContainerListWithQueryParam()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if (defaults.object(forKey: "InventoryVerifiedArray") != nil){
            defaults.removeObject(forKey: "InventoryVerifiedArray")
        }
        if (defaults.object(forKey: "ScanFailedItemsArray") != nil){
            defaults.removeObject(forKey: "ScanFailedItemsArray")
        }
    }
    //MARK: - End
    
    //MARK: - Action
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerSearchViewController") as! ContainerSearchViewController
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerDetailsViewController") as! ContainerDetailsViewController
        
        if let txt = self.itemsList[sender.tag]["serial"] as? String,!txt.isEmpty{
            controller.serialNumber = txt
        }        
        controller.delegate = self
        controller.fromList = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerEditView") as! ContainerEditViewController
        if let txt = self.itemsList[sender.tag]["serial"] as? String,!txt.isEmpty{
            controller.serialNumber = txt
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getContainerListWithQueryParam()
        
    }
    
    //MARK: - End
    
    //MARK Privae method
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
    
    
    
    func getContainerListWithQueryParam() {
        let url = "?nb_per_page=10&\(appendStr)&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ContainersSearch", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
    //MARK: - Search View Delegate
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?) {
        
        filterButton.isSelected = false
        if searchDict != nil{
            self.searchDict = searchDict!
        }
        
        self.appendStr = appendstr
        if !self.appendStr.isEmpty {
            filterButton.isSelected = true
        }
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getContainerListWithQueryParam()
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        self.appendStr = ""
        filterButton.isSelected = false
        
    }
    //MARK: End
    
    //MARK: - Details View Delegate
    func doneDelete() {
       currentPage = 1
       itemsList = []
       listTable.reloadData()
       getContainerListWithQueryParam()
    }
    //MARK: End
}

//MARK: - Tableview Delegate and Datasource
extension ContainerListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "ContainerListCell") as! ContainerListCell
        
        
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["container_uuid"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.uuidLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["gs1_id"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.gs1idLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["serial"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.serialLabel.text = dataStr
                
        cell.editButton.tag = indexPath.row
        cell.viewButton.tag = indexPath.row
        cell.customView.layoutIfNeeded()
        
        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class ContainerListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    
    
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var gs1idLabel: UILabel!
    
   
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        self.customView.setRoundCorner(cornerRadious: 10)
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End


