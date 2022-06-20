//
//  PickingListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 22/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

enum Pickings_Types:String {
    case TO_DO = "picking_to_do_and_partial_picking"
    case INPROGRESS = "pinking_in_progress"
    case ALL = ""
    
}

class PickingListViewController: BaseViewController {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet var typeButtons: [UIButton]!
    var loadMoreButton = UIButton()
    var itemsList: [[String: Any]] = []
    var appendStr = ""
    var currentPage = 1
    var totalResult = 0
    var quaranTineAdjustmentList: [[String: Any]] = []
    var disPatchGroup = DispatchGroup()
    var searchType = Pickings_Types.ALL.rawValue
    
    //MARK: - End
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()
        let btn = UIButton()
        btn.tag = 1
        typeButtonPressed(btn)
        
        
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
           // print("itemsList: \(self.itemsList)")
           // print("quaranTineAdjustmentList: \(self.quaranTineAdjustmentList)")
            self.listTable.reloadData()
        }
    }
    
    //MARK: - End
    
    //MARK: - Action
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func pickTheListButtonPressed(_ sender: UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Do you want to proceed?".localized()
        controller.delegate = self
        controller.isIndexRequired = true
        controller.indexNumber = sender.tag
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsPressed(_ sender: UIButton) {
        
        let dict = itemsList[sender.tag]
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingSOItemsView") as! PickingSOItemsViewController
        controller.shipmentId = dict["uuid"] as? String ?? ""
        controller.isFromViewItems = true
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func typeButtonPressed(_ sender: UIButton) {
        
        if sender.isSelected {
            return
        }
        
        for btn in typeButtons {
            
            if btn.tag == sender.tag {
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
            
            if btn.isSelected && btn.tag == 1{
                searchType = Pickings_Types.TO_DO.rawValue
            }else if btn.isSelected && btn.tag == 2{
                searchType = Pickings_Types.INPROGRESS.rawValue
            }else if btn.isSelected && btn.tag == 3{
                searchType = Pickings_Types.ALL.rawValue
            }
        }
        
        currentPage = 1
        itemsList = []
        listTable.reloadData()
        getPickingListWithQueryParam()
        
    }
    @IBAction func reassignParticipentButtonPressed(_ sender:UIButton){
        let dict = itemsList[sender.tag]
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ParticipentReassignView") as!ParticipentReassignViewController
        storyboard.pickingDict = dict as NSDictionary
        storyboard.delegate = self
        storyboard.modalTransitionStyle = .flipHorizontal
        self.present(storyboard, animated: true, completion: nil)
    }
    
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        getPickingListWithQueryParam()
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
    func getPickingListWithQueryParam() {
        
        let url = appendStr + "status=\(searchType)&nb_per_page=10&sort_by_asc=false&page=\(currentPage)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "ShipmentPickings", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
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
    
    //MARK: End
}

//MARK: - Tableview Delegate and Datasource
extension PickingListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = listTable.dequeueReusableCell(withIdentifier: "PickingListCell") as! PickingListCell
        
        cell.pickThisList.tag = indexPath.row
        cell.customView.setRoundCorner(cornerRadious: 20)
        cell.pickThisList.setRoundCorner(cornerRadious: cell.pickThisList.frame.size.height / 2.0)
        cell.viewItemsButton.tag = indexPath.row
        cell.viewItemsButton.setRoundCorner(cornerRadious: cell.viewItemsButton.frame.size.height / 2.0)
        let item = itemsList[indexPath.row]
        
        var dataStr = ""
        if let txt = item["trading_partner_name"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.tpLabel.text = dataStr
        
        var participentName = ""
        if let txt = item["participant_name"] as? String, !txt.isEmpty {
            participentName = txt
            
        }
        
        dataStr = ""
        if let txt = item["status"] as? String,!txt.isEmpty{
            dataStr = txt
            
            if txt == "TO_PICK" || txt == "PICKING_PARTIAL"{
                if txt == "TO_PICK"{
                    dataStr = "To Do".localized()
                }else{
                    dataStr = "Partial Picking".localized()
                }
                cell.pickTheListButtonView.isHidden = false
                cell.pickThisList.setTitle("PICK THIS LIST".localized(), for: .normal)
                cell.participentReassignButton.isHidden = true

            }else if txt == "PICKING_IN_PROGRESS"{
                if !participentName.isEmpty {
                    dataStr = "In Progress\n" + "(" + (participentName) + ")".localized()
                }else{
                    dataStr = "In Progress".localized()
                }
                cell.pickTheListButtonView.isHidden = false
                cell.pickThisList.setTitle("CONTINUE".localized(), for: .normal)
                cell.participentReassignButton.isHidden = false
                    
            }else{
                cell.pickTheListButtonView.isHidden = true
                cell.participentReassignButton.isHidden = true

            }
            
        }else{
            cell.pickTheListButtonView.isHidden = true
            cell.participentReassignButton.isHidden = true

        }
        cell.statusLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["created_on"] as? String,!txt.isEmpty{
            dataStr = txt
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withSpaceBetweenDateAndTime,.withFractionalSeconds,.withTimeZone]
            print(formatter.date(from: dataStr) as Any)
            
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd HH:mm:ss.SSSSSSZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: dataStr){
                dataStr = formattedDate
            }
        }
        cell.dateLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["products_count_to_ship"] as? Int{
            dataStr = "\(txt)"
        }
        cell.productCountLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["items_count_to_ship"] as? Int{
            dataStr = "\(txt)"
        }
        cell.itemsCountLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["po_number"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.poLabel.text = dataStr
        
        dataStr = ""
        if let txt = item["order_number"] as? String, !txt.isEmpty{
            dataStr = txt
        }
        cell.orderLabel.text = dataStr
        
        if let txt = item["invoice_nbr"] as? String, !txt.isEmpty{
            dataStr = txt
        }
        cell.invoiceLabel.text = dataStr
        
        
        cell.viewItemsButton.tag = indexPath.row
        cell.pickThisList.tag = indexPath.row
        cell.participentReassignButton.tag = indexPath.row
        return cell
    }
}

//MARK: - End

//MARK: - Tableview Cell
class PickingListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var tpLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var poLabel: UILabel!
    @IBOutlet weak var pickThisList: UIButton!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet weak var pickTheListButtonView: UIView!
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var participentName:UILabel!
    @IBOutlet var orderLabel:UILabel!
    @IBOutlet var invoiceLabel:UILabel!
    @IBOutlet var participentReassignButton:UIButton!

    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End

//MARK: - ConfirmationViewDelegate
extension PickingListViewController: ConfirmationViewDelegate {
    
    func doneButtonPressed() {
        print("done")
    }
    
    func doneButtonPressedWithIndex(index: Int) {
        let dict = itemsList[index]
        var istodo = false
        if let txt = dict["status"] as? String,!txt.isEmpty{
            if txt == "TO_PICK" || txt == "PICKING_PARTIAL"{
                istodo = true
            }
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingDetailsView") as! PickingDetailsViewController
        controller.shipmentId = dict["uuid"] as? String ?? ""
        controller.isTodo = istodo
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    func cancelConfirmation() {
        print("cancle")
    }
}
extension PickingListViewController:participentReassignDelegate{
    func didReassigned() {
        let button = UIButton()
        button.tag = 2
        typeButtonPressed(button)
    }
}
//MARK: - End
