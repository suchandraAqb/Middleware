//
//  ItemsTableViewCell.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 27/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var udidLabel: UILabel!
    @IBOutlet weak var udidValueLabel: UILabel!
    
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var skuValueLabel: UILabel!
    
    @IBOutlet weak var ndcLabel: UILabel!
    @IBOutlet weak var ndcValueLabel: UILabel!
    
    @IBOutlet weak var upcLabel: UILabel!
    @IBOutlet weak var upcValueLabel: UILabel!
    
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var lotValueLabel: UILabel!
    
     @IBOutlet weak var deleteButton: UIButton!
     @IBOutlet weak var statusButton: UIButton!
    
    @IBOutlet weak var viewSerialButton: UIButton!
    @IBOutlet weak var viewLotBreakDownButton: UIButton!
    
    @IBOutlet weak var qtyToPickedLabel: UILabel!
    @IBOutlet weak var qtyPickedLabel: UILabel!
    
    @IBOutlet weak var qtyView: UIView!
    @IBOutlet weak var productUuidView: UIView!
    
    @IBOutlet weak var gtin14Label: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    
    @IBOutlet weak var lotQtyHeaderView: UIView!
    @IBOutlet weak var lotQtyView: UIView!
    @IBOutlet weak var lotQtyStackView: UIStackView!
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var storageArealLabel : UILabel!
    @IBOutlet var shelfLabel:UILabel!
    @IBOutlet var lotDetails : UIButton!
    @IBOutlet var lotdetailsBorderView:UIView!
    @IBOutlet var failedReasonText : UILabel!
    @IBOutlet var serialNumberText : UILabel!
    @IBOutlet var lotNumberText : UILabel!
    @IBOutlet var expirationView: UIView!
    @IBOutlet var checkUncheckButton:UIButton!
    @IBOutlet weak var pickItemsButton: UIButton!
    @IBOutlet weak var editButton:UIButton!

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
