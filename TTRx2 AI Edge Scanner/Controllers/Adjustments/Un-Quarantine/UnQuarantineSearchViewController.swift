//
//  UnQuarantineSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by rupshikha anand on 02/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class UnQuarantineSearchViewController: BaseViewController, DatePickerViewDelegate {
    
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var referenceTextField: UITextField!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    //MARK: - End
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    //MARK: - End
    
    //MARK: Private method
    func setUI() {
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
    }
    //MARK: End
    
    //MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
        controller.delegate = self
        controller.sender = sender
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func searchButtonPressed(_ sender: UIButton){
        doneTyping()
        
        var uuidStr = ""
        if let str = uuidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            uuidStr = str
        }
        
        var dateStr = ""
        if let str = dateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            dateStr = str
        }
        
        var productName = ""
        if let str = productNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            productName = str
        }
        
        var reference = ""
        if let str = referenceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            reference = str
        }
        
        var reason = ""
        if let str = reasonTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            reason = str
        }
        
        var appendStr = "?type=QUARANTINE&nb_per_page=100&"
        //removed is_voided=false"
        
        
        if !uuidStr.isEmpty{
            appendStr = appendStr + "adjustment_uuid=\(uuidStr)&"
            //product_uuid replaced
        }
        
        if !dateStr.isEmpty{
            appendStr = appendStr + "date=\(dateStr)&"
        }
        
        if !productName.isEmpty{
            appendStr = appendStr + "product_name=\(productName)&"
        }
        
        if !reference.isEmpty{
            appendStr = appendStr + "reference_num=\(reference)&"
        }
        
        if !reason.isEmpty{
            appendStr = appendStr + "reason=\(reason)&"
        }
        
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "QuarantineListView") as! QuarantineListViewController
            controller.appendStr = escapedString
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    //MARK: - End
    
    //MARK: - DatePickerViewDelegate
    func dateSelectedWithSender(selectedDate: Date, sender: UIButton?) {
        if sender != nil{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            
            dateLabel.text = dateStr
            dateLabel.accessibilityHint = dateStrForApi
            
        }
    }
    //MARK: - End
    
    
    
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    //MARK: - End
    
}
//MARK: - End







