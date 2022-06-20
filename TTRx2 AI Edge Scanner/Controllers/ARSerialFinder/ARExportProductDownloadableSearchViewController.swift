//
//  ARExportProductDownloadableSearchViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 18/02/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sb10

import UIKit
@objc protocol  ARExportProductDownloadableSearchViewDelegate: AnyObject {
    func SearchButtonPressed(appendstr: String,searchDict:[String:Any]?)
    func clearSearch()
}

class ARExportProductDownloadableSearchViewController: BaseViewController,SingleSelectDropdownDelegate,DatePickerViewDelegate  {
    
    @IBOutlet weak var createdDateView: UIView!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    @IBOutlet weak var createdDateOnView: UIView!
    @IBOutlet weak var createdDateOnLabel: UILabel!
    
    @IBOutlet weak var createdDateToView: UIView!
    @IBOutlet weak var createdDateToLabel: UILabel!
    
    @IBOutlet weak var createdDateFromView: UIView!
    @IBOutlet weak var createdDateFromLabel: UILabel!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    weak var delegate: ARExportProductDownloadableSearchViewDelegate?
    var searchDict = [String:Any]()
    var clearSearch = ""

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        searchContainer.setRoundCorner(cornerRadious: 10.0)
        searchButton.setRoundCorner(cornerRadious: searchButton.frame.size.height / 2.0)
        
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
    
    //MARK: - Privete Method
    func populateSearchData(){
        createdDateOnView.isHidden = true
        createdDateToView.isHidden = true
        createdDateFromView.isHidden = true
        
        if !searchDict.isEmpty {
            if let txt = searchDict["createdDate"] as? String,!txt.isEmpty{
                createdDateLabel.text = txt
                createdDateLabel.accessibilityHint = searchDict["createdDateForApi"] as? String
                createdDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            if let txt = searchDict["createdDateOn"] as? String,!txt.isEmpty{
                createdDateOnLabel.text = txt
                createdDateOnLabel.accessibilityHint = searchDict["createdDateOnForApi"] as? String
                createdDateOnLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                createdDateOnView.isHidden = false
            }
            if let txt = searchDict["createdDateFrom"] as? String,!txt.isEmpty{
                createdDateFromLabel.text = txt
                createdDateFromLabel.accessibilityHint = searchDict["createdDateFromForApi"] as? String
                createdDateFromLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                createdDateFromView.isHidden = false
            }
            if let txt = searchDict["createdDateTo"] as? String,!txt.isEmpty{
                createdDateToLabel.text = txt
                createdDateToLabel.accessibilityHint = searchDict["createdDateToForApi"] as? String
                createdDateToLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                createdDateToView.isHidden = false
            }
        }
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if (clearSearch == "clear") {
            self.delegate?.clearSearch()
            self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        clearSearch = ""
        
        doneTyping()
        
        if sender.tag == 1 {
            let createdDateList = [["name" : "On".localized() , "value" : "on"],["name" : "Before".localized() , "value" : "before"],["name" : "Range".localized() , "value" : "range"],["name" : "After".localized() , "value" : "after"]]
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = createdDateList
            controller.type = "Select Date Filter".localized()//,,,sb10
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
        else if sender.tag == 2 {
            //ON
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
        else if sender.tag == 4 {
            //After, From
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
        else if sender.tag == 3 {
            //Before, To
            var createdDateStr = ""
            if let str = createdDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
                createdDateStr = str
            }
            var createdDateFromStr = ""
            if (createdDateStr == "range") {
                if let str = createdDateFromLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
                    createdDateFromStr = str
                }
            }
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "DatePickerView") as! DatePickerViewController
            controller.delegate = self
            controller.sender = sender
                if (createdDateFromStr != "") {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.date(from:createdDateFromStr)!
                    controller.minimumDate = date
                }
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        clearSearch = ""
        
        doneTyping()
        
        var createdDateStr = ""
        if let str = createdDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            createdDateStr = str
        }
        var createdDateOnStr = ""
        if let str = createdDateOnLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            createdDateOnStr = str
        }
        var createdDateFromStr = ""
        if let str = createdDateFromLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            createdDateFromStr = str
        }
        var createdDateToStr = ""
        if let str = createdDateToLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
            createdDateToStr = str
        }
        
        
        if (createdDateStr == "on") {
            createdDateToStr = ""
            createdDateFromStr = ""
        }else if (createdDateStr == "after") { //from
            createdDateOnStr = ""
            createdDateToStr = ""
        }else if (createdDateStr == "before") { //to
            createdDateOnStr = ""
            createdDateFromStr = ""
        }

        var appendStr = ""
        if !createdDateStr.isEmpty{
            searchDict["createdDateForApi"] = createdDateStr
            searchDict["createdDate"] = createdDateLabel.text
        }else{
            searchDict["createdDateForApi"] = ""
            searchDict["createdDate"] = ""
        }
        
        if !createdDateOnStr.isEmpty{
            appendStr = appendStr + "created_date_on=\(createdDateOnStr)&"
            searchDict["createdDateOnForApi"] = createdDateOnStr
            searchDict["createdDateOn"] = createdDateOnLabel.text
        }else{
            searchDict["createdDateOnForApi"] = ""
            searchDict["createdDateOn"] = ""
        }
        
        if !createdDateFromStr.isEmpty{
            appendStr = appendStr + "created_date_from=\(createdDateFromStr)&"
            searchDict["createdDateFromForApi"] = createdDateFromStr
            searchDict["createdDateFrom"] = createdDateFromLabel.text
        }else{
            searchDict["createdDateFromForApi"] = ""
            searchDict["createdDateFrom"] = ""
        }
        
        if !createdDateToStr.isEmpty{
            appendStr = appendStr + "created_date_to=\(createdDateToStr)&"
            searchDict["createdDateToForApi"] = createdDateToStr
            searchDict["createdDateTo"] = createdDateToLabel.text
        }else{
            searchDict["createdDateToForApi"] = ""
            searchDict["createdDateTo"] = ""
        }
                
        let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.delegate?.SearchButtonPressed(appendstr: escapedString,searchDict: self.searchDict)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        clearSearch = "clear"
        
        doneTyping()
        searchDict = [String:Any]()
        
        createdDateLabel.text = "Select Date Filter".localized()
        createdDateLabel.accessibilityHint = ""
        createdDateLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
         
        createdDateOnLabel.text = "Select Date".localized()
        createdDateOnLabel.accessibilityHint = ""
        createdDateOnLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        createdDateOnView.isHidden = true
                
        createdDateFromLabel.text = "Select Date".localized()
        createdDateFromLabel.accessibilityHint = ""
        createdDateFromLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        createdDateFromView.isHidden = true
        
        createdDateToLabel.text = "Select Date".localized()
        createdDateToLabel.accessibilityHint = ""
        createdDateToLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
        createdDateToView.isHidden = true
        
        /*
        self.delegate?.clearSearch()
        self.delegate?.SearchButtonPressed(appendstr: "",searchDict: self.searchDict)
        */
    }
    //MARK: - End
    
    //MARK: - SingleSelectDropdownDelegate
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil {
            if sender?.tag==1 {
                if let name = data["name"] as? String {
                    let value = data["value"] as? String
                    createdDateLabel.text = name
                    createdDateLabel.accessibilityHint = value
                    createdDateLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                    
                    if (value == "on") {
                        createdDateFromLabel.text = "Select Date".localized()
                        createdDateFromLabel.accessibilityHint = ""
                        createdDateFromLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateFromView.isHidden = true
                        
                        createdDateToLabel.text = "Select Date".localized()
                        createdDateToLabel.accessibilityHint = ""
                        createdDateToLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateToView.isHidden = true
                        
                        createdDateOnLabel.text = "Select Date".localized()
                        createdDateOnLabel.accessibilityHint = ""
                        createdDateOnLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateOnView.isHidden = false
                        
                    }else if (value == "after") { //from
                        createdDateOnLabel.text = "Select Date".localized()
                        createdDateOnLabel.accessibilityHint = ""
                        createdDateOnLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateOnView.isHidden = true
                        
                        createdDateToLabel.text = "Select Date".localized()
                        createdDateToLabel.accessibilityHint = ""
                        createdDateToLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateToView.isHidden = true
                        
                        createdDateFromLabel.text = "Select Date".localized()
                        createdDateFromLabel.accessibilityHint = ""
                        createdDateFromLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateFromView.isHidden = false
                        
                    }else if (value == "before") { //to
                        createdDateOnLabel.text = "Select Date".localized()
                        createdDateOnLabel.accessibilityHint = ""
                        createdDateOnLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateOnView.isHidden = true
                        
                        createdDateFromLabel.text = "Select Date".localized()
                        createdDateFromLabel.accessibilityHint = ""
                        createdDateFromLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateFromView.isHidden = true

                        createdDateToLabel.text = "Select Date".localized()
                        createdDateToLabel.accessibilityHint = ""
                        createdDateToLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateToView.isHidden = false
                        
                    }
                    else if (value == "range") {
                        createdDateOnLabel.text = "Select Date".localized()
                        createdDateOnLabel.accessibilityHint = ""
                        createdDateOnLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateOnView.isHidden = true
                        
                        createdDateFromLabel.text = "From Date".localized()
                        createdDateFromLabel.accessibilityHint = ""
                        createdDateFromLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateFromView.isHidden = false

                        createdDateToLabel.text = "To Date".localized()
                        createdDateToLabel.accessibilityHint = ""
                        createdDateToLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                        createdDateToView.isHidden = false
                    }
                }
            }
        }
    }
    //MARK: - End
    
    //MARK: - DatePickerViewDelegate
    func dateSelectedWithSender(selectedDate: Date, sender: UIButton?) {
        if sender != nil {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let dateStr = formatter.string(from: selectedDate)
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStrForApi = formatter.string(from: selectedDate)
            
            if sender?.tag == 2 {
                createdDateOnLabel.text = dateStr
                createdDateOnLabel.accessibilityHint = dateStrForApi
                createdDateOnLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
            if sender?.tag == 4 {
                createdDateFromLabel.text = dateStr
                createdDateFromLabel.accessibilityHint = dateStrForApi
                createdDateFromLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                                
                var createdDateStr = ""
                if let str = createdDateLabel.accessibilityHint?.trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty{
                    createdDateStr = str
                }
                if (createdDateStr == "range") {
                    createdDateToLabel.text = "To Date".localized()
                    createdDateToLabel.accessibilityHint = ""
                    createdDateToLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                }
            }
            if sender?.tag == 3 {
                createdDateToLabel.text = dateStr
                createdDateToLabel.accessibilityHint = dateStrForApi
                createdDateToLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
            }
        }
    }
    //MARK: - End
}
