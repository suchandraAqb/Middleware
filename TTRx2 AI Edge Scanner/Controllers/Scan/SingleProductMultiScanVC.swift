//
//  SingleProductMultiScanVC.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 23/12/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import ScanditBarcodeCapture
import UIKit

class SingleProductMultiScanVC: BaseViewController{
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var tblProduct: UITableView!
    //    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    //    @IBOutlet weak var btnAdd: UIButton!
    //    @IBOutlet weak var viewAdd: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    //    @IBOutlet var btnCounter: [UIButton]!
    private var productCount = 0
    deinit {
        self.tblProduct.removeObserver(self, forKeyPath: "contentSize")
    }
    //MARK: - VC Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblProduct.delegate = self
        self.tblProduct.dataSource = self
        self.tblProduct.separatorStyle = .none
        self.addDetailsView()
        self.setupStartScreen()
        self.tblProduct.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        //self.viewAdd.dropShadowAround(color: .lightGray, offSet: CGSize(width: 0, height: 1))
    }
    
    private func setupStartScreen(){
        //self.heightTableView.constant = 120
        self.btnConfirm.isHidden = true
        self.btnClear.isHidden = true
        //self.lblProductCount.text = productCount > 0 ? "\(productCount)" : ""
        self.lblHeader.text = "Looking for barcodes..."
        //        self.productView.isHidden = true
    }
    private func setupAfterAddScreen(){
        self.btnConfirm.isHidden = false
        self.btnClear.isHidden = false
        self.tblProduct.reloadSections([0], with: .automatic)
        self.lblHeader.text = productCount > 1 ? "\(productCount) items" : "\(productCount) item"
    }
    private func addDetailsView(){
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.detailsView.frame = frame
        self.detailsContainerView.roundTopCorners(cornerRadious: 20)
        self.view.addSubview(self.detailsView)
    }
}
//MARK: - BUTTONS -
extension SingleProductMultiScanVC: ConfirmationViewDelegate{
    @IBAction func productCounter(_ sender: UIButton){
        if !sender.isSelected{
            if sender.tag == 0 {
                print("Minus")
                productCount > 0 ? (productCount -= 1) : ()
                if productCount == 0 {
                    self.setupAfterAddScreen()
                    self.setupStartScreen()
                }else{
                    self.setupAfterAddScreen()
                }
            }else{
                print("Plus")
                productCount += 1
                self.setupAfterAddScreen()
            }
        }
    }
    
    @IBAction func addProduct(_ sender: UIButton){
        if self.productCount == 0{
            self.productCount = 1
            self.setupAfterAddScreen()
        }else{
            //self.tblProduct.reloadSections([0], with: .automatic)
        }
    }
    
    @IBAction func clearProduct(_ sender: UIButton){
        self.productCount = 0
        self.tblProduct.reloadSections([0], with: .automatic)
        self.setupStartScreen()
    }
    
    @IBAction func back(_ sender: UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure want to cancel scanning?".localized()
        controller.delegate = self
        controller.isCancelConfirmation = false
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    func doneButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}
extension SingleProductMultiScanVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productCount == 0 ? 0 : 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.selectionStyle = .none
        cell.lblProductCount.text = "\(productCount)"
        return cell
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView {
            if obj == self.tblProduct && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    if self.productCount == 1{
                        self.heightTableView.constant = newSize.height
                        self.tblProduct.invalidateIntrinsicContentSize()
                        UIView.animate(withDuration: 0.3, animations: {
                            self.tblProduct.layoutIfNeeded()
                        })
                    }
                }
            }
        }
    }
}


