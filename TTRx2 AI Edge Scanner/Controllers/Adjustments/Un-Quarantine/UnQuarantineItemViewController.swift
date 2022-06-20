//
//  UnQuarantineItemViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by rupshikha anand on 02/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class UnQuarantineItemViewController: BaseViewController {
    //GET=​/adjustments​/{adjustment_uuid}​
    //UUID_ITEM
    weak var delegate: QuarantineOptionViewControllerDelegete?
    weak var delegates: ConfirmationViewDelegate?
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var selectAllButton: UIButton!
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    
    
    
    var adjustmentLineItemsArray: [[String: Any]] = []
    var isSelect:Bool = false
    var isCellCheckBoxSelect:Bool = false
    var selectedRow: [[String: Any]] = []
    //MARK: - End
    var attachmentList = [[String:Any]]()

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        if let items = Utility.getObjectFromDefauls(key: "adjustmentLineItems") as? [[String:Any]]{
            adjustmentLineItemsArray = items
            
            if let sitems = Utility.getObjectFromDefauls(key: "selectedItems") as? [[String:Any]]{
                
                selectedRow = sitems
                if self.selectedRow.count == self.adjustmentLineItemsArray.count {
                   self.selectAllButton.isSelected = true
                } else {
                   self.selectAllButton.isSelected = false
                }
                
            }else{
                selectedRow = items
                self.selectAllButton.isSelected = true
                
            }
            listTable.reloadData()
        }
        
    }
    //MARK: - End
    
    //MARK: - Action
    func initialSetUp(){
        sectionView.roundTopCorners(cornerRadious: 40)
        
        
    }
    //MARK: - End
    
    //MARK: - Action
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func selectAllButtonPressed(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.selectedRow = adjustmentLineItemsArray
        } else {
            self.selectedRow.removeAll()
        }
        self.listTable.reloadData()
        
    }
    
    @IBAction func checkButtonPressed(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        
        let obj = adjustmentLineItemsArray[sender.tag]
        
        if (self.selectedRow as NSArray).contains(obj) {
            let index = (self.selectedRow as NSArray).index(of: obj)
            self.selectedRow.remove(at: index)
        } else {
            self.selectedRow.append(obj)
        }
        if self.selectedRow.count == self.adjustmentLineItemsArray.count {
            self.selectAllButton.isSelected = true
        } else {
            self.selectAllButton.isSelected = false
        }
        
        listTable.reloadData()
    }
    
    @IBAction func serialButtonPressed(_ sender: UIButton) {
        let adjustmentLineItem = adjustmentLineItemsArray[sender.tag]
        if let structure = adjustmentLineItem["structure"] as? [[String: Any]] {
            
            if structure.count > 1 {
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineSerialListView") as! UnQuarantineSerialListViewController
                controller.structure = structure
                self.navigationController?.pushViewController(controller, animated: false)
            }
            
        }
        
        
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        if selectedRow.count == 0{
            Utility.showPopup(Title: App_Title, Message: "Please select item(s) to Un-Quarantine.".localized(), InViewC: self)
            return
        }
        
        Utility.saveObjectTodefaults(key: "selectedItems", dataObject: selectedRow)
        
        
        defaults.set(true, forKey: "un_quaran_2ndStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineConfirmView") as! UnQuarantineConfirmViewController
        controller.attachmentList = attachmentList
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: UnQuarantineGeneralViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineGeneralView") as! UnQuarantineGeneralViewController
            self.navigationController?.pushViewController(controller, animated: true)
            
        }else if sender.tag == 3 {
            nextButtonPressed(UIButton())
        }
        
        
        
    }
    //MARK: - End
    
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "un_quaran_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "un_quaran_2ndStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        if isFirstStepCompleted && isSecondStepCompleted{
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.isUserInteractionEnabled = true
            
            
        }else if isFirstStepCompleted {
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
        }
        
    }
    
    
    //MARK: End
    
}

//MARK: - Tableview Delegate and Datasource
extension UnQuarantineItemViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return adjustmentLineItemsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        configureCell(at: indexPath)
    }
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "UnQuarantineItemCell") as! UnQuarantineItemCell
        cell.customView.setRoundCorner(cornerRadious: 20)
        cell.checkButton.tag =  indexPath.row
        cell.serialButton.tag = indexPath.row
        
        let adjustmentLineItem = adjustmentLineItemsArray[indexPath.row]
        if let products = adjustmentLineItem["product"] as? [[String: Any]], let firstPro = products.first {
            let udid = (firstPro["uuid"] as? String) ?? ""
            let predicate = NSPredicate(format: "uuid == '\(udid)'")
            if let allProducts = AllProductsModel.getAllProducts() {
                let filterArray = (allProducts as NSArray).filtered(using: predicate)
                if filterArray.count > 0 {
                    let firstObject =  (filterArray.first as? [String: Any]) ?? [:]
                    print("firstObject", firstObject)
                    let ndc_text = (firstObject["identifier_us_ndc"] as? String) ?? ""
                    cell.ndcLabel.text = ndc_text
                } else {
                    cell.ndcLabel.text = ""
                }
            } else {
                cell.ndcLabel.text = ""
            }
            cell.productNamelabel.text = (firstPro["product_name"] as? String) ?? ""
            cell.skuLabel.text = (firstPro["sku"] as? String) ?? ""
            let type = (adjustmentLineItem["type"] as? String) ?? ""
            var typeStr = ""
            cell.serialView.isHidden = false
            if type == "LOT_BASED"{
                typeStr = "Lot Based Item(s)".localized()
                cell.serialView.isHidden = true
            } else if type == "SIMPLE_SERIAL_BASED" {
                typeStr = "Item".localized()
            }else if type == "GS1_SERIAL_BASED" {
                if let structure = adjustmentLineItem["structure"] as? [[String: Any]] {
                    if structure.count > 0 {
                        typeStr = "Aggregation".localized()
                    }
                }
                
            }else{
                typeStr = "Item".localized()
            }
            cell.typeLabel.text = typeStr
            
        }
        if let structure = adjustmentLineItem["structure"] as? [[String: Any]] {
            let fisrtStructure = structure.first ?? [:]
            if structure.count > 1 {
                cell.serialButton.isUserInteractionEnabled = true
                cell.serialButton.setTitle("View Serials".localized(), for: .normal)
                cell.serialButton.setTitleColor(#colorLiteral(red: 0, green: 0.6862745098, blue: 0.937254902, alpha: 1), for: .normal)
            }else{
                cell.serialButton.isUserInteractionEnabled = false
                cell.serialButton.setTitleColor(#colorLiteral(red: 0.02745098039, green: 0.1294117647, blue: 0.2666666667, alpha: 1), for: .normal)
                cell.serialButton.setTitle((fisrtStructure["serial"] as? String) ?? "", for: .normal)
            }
        }
        
        if let quantity = adjustmentLineItem["quantity"] as? Int {
            cell.quantityLabel.text = "\(quantity)"
        }
        
        
        if self.selectAllButton.isSelected {
            cell.checkButton.isSelected = true
        } else {
            if (self.selectedRow as NSArray).contains(adjustmentLineItem) {
                cell.checkButton.isSelected = true
            } else {
                cell.checkButton.isSelected = false
            }
        }
        return cell
    }
}
//MARK: - End

//MARK: - Tableview Cell
class UnQuarantineItemCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var serialButton: UIButton!
    @IBOutlet weak var productNamelabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var ndcLabel: UILabel!
    @IBOutlet weak var serialView: UIView!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End
