//
//  ARSFFilterSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 06/05/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sb11-6

import UIKit

@objc protocol  ARSFFilterSearchViewControllerDelegate: class {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class ARSFFilterSearchViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!

    @IBOutlet weak var filterNameView: UIView!
    @IBOutlet weak var filterNameTextField: UITextField!

    @IBOutlet weak var shortDescriptionView: UIView!
    @IBOutlet weak var shortDescriptionTextField: UITextField!
    
    weak var delegate: ARSFFilterSearchViewControllerDelegate?
    var searchDict = [String:Any]()

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        setupUI()
        createInputAccessoryView()
        populateSearchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    
    //MARK: - Custom Method
    func setupUI(){
        filterNameTextField.delegate = self
        shortDescriptionTextField.delegate = self
    }
    
    func populateSearchData(){
        if !searchDict.isEmpty {
            if let txt = searchDict["filter_name"] as? String,!txt.isEmpty{
                filterNameTextField.text = txt
            }
            
            if let txt = searchDict["description"] as? String,!txt.isEmpty{
                shortDescriptionTextField.text = txt
            }
            
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        var fileNameStr = ""
        if let str = filterNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            fileNameStr = str
        }
        
        var descriptionStr = ""
        if let str = shortDescriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            descriptionStr = str
        }
        
        
        var appendStr = ""
        if !fileNameStr.isEmpty {
            appendStr = appendStr + "filter_name=\(fileNameStr)&"
            searchDict["filter_name"] = fileNameStr
        }else {
            searchDict["filter_name"] = ""
        }
        
        if !descriptionStr.isEmpty {
            appendStr = appendStr + "description=\(descriptionStr)&"
            searchDict["description"] = descriptionStr
        }else {
            searchDict["description"] = ""
        }
        
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        doneTyping()
        searchDict = [String:Any]()
        filterNameTextField.text = ""
        shortDescriptionTextField.text = ""
        
        self.delegate?.clearSearch()
        self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
    }
    //MARK: - End
    
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
      
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }
    //MARK: - End
}
//MARK: - End
