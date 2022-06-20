//
//  ReturnProductListVC.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 02/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
var lotBasedProductUUID = String()
class ReturnProductListVC: BaseViewController {
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var disPatchGroup = DispatchGroup()
    var searchDict = [String:Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        self.listTable.delegate = self
        self.listTable.dataSource = self
        loadMoreFooterView()
        self.getProductListWithQueryParam()
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
            // print("itemsList: \(self.itemsList)")
            self.listTable.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    //MARK Privae method
    func loadMoreFooterView() {
        loadMoreButton = UIButton(frame: CGRect(x: 0, y: -20, width: self.listTable.frame.width, height: 50))
        //UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.listTable.frame.width, height: 40)))
        loadMoreButton.titleLabel?.textAlignment = .center
        loadMoreButton.setTitleColor(#colorLiteral(red: 0.02745098039, green: 0.1294117647, blue: 0.2666666667, alpha: 1), for: .normal)
        loadMoreButton.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 16.0)
        loadMoreButton.setTitle("Load more", for: .normal)
        loadMoreButton.backgroundColor = .clear
        self.listTable.tableFooterView?.backgroundColor = .clear
        loadMoreButton.addTarget(self, action:#selector(loadMoreButtonPressed), for: .touchUpInside)
        self.listTable.tableFooterView = loadMoreButton
        
    }
    //MARK: - End
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getProductListWithQueryParam()
    }
    
    @IBAction func filterbuttonpressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Return", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "ReturnProductSearchVC") as! ReturnProductSearchVC
        controller.delegate = self
        controller.searchDict = self.searchDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func productTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Return", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ReturnShipmentList") as! ReturnShipmentList
        let item = itemsList[sender.tag]
        controller.product_uuid = item["uuid"] as? String ?? ""
        self.defaultDB.set(item["uuid"] as? String ?? "", forKey: "lotProductUUID")
        controller.productName = item["name"] as? String ?? ""
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getProductListWithQueryParam() {
        
        let url = "?nb_per_page=10&\(appendStr)&sort_by_asc=false&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        DispatchQueue.main.async {
            self.showSpinner(onView: self.view)
        }
        
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "GetProducts", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.disPatchGroup.leave()
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
}

extension ReturnProductListVC: SearchViewDelegate{
    
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?) {
        
        filterButton.isSelected = false
        if searchDict != nil{
            self.searchDict = searchDict!
            if !self.searchDict.isEmpty {
                filterButton.isSelected = true
            }
        }
        
        self.appendStr = appendstr
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        DispatchQueue.global(qos: .userInteractive).async {
            self.getProductListWithQueryParam()
        }
    }
    
    func clearSearch() {
        searchDict = [String:Any]()
        filterButton.isSelected = false
    }
}

extension ReturnProductListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReturnProductCell", for: indexPath) as! ReturnProductCell
        
        cell.selectButton.tag = indexPath.row
        //let indexData = self.listDB?.data?[indexPath.row]
        let item = itemsList[indexPath.row]
        
        cell.lblProductName.text = item["name"] as? String
        cell.lblSku.text = item["sku"] as? String
        cell.lblNDC.text = item["identifier_us_ndc"] as? String
        cell.lblUPC.text = item["upc"] as? String
        cell.lblGTIN.text = item["gtin14"] as? String
        
        return cell
    }
}

class ReturnProductCell: UITableViewCell {
    
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var lblSku: UILabel!
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var lblNDC: UILabel!
    @IBOutlet var lblUPC: UILabel!
    @IBOutlet var lblGTIN: UILabel!
    @IBOutlet var selectButton: UIButton!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}


