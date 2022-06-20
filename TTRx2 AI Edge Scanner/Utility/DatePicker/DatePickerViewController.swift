//
//  DatePickerViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 09/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  DatePickerViewDelegate: class {
    func dateSelectedWithSender(selectedDate:Date,sender:UIButton?)
    
}
class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker:UIDatePicker!
    @IBOutlet weak var sectionView:UIView!
    var selectedDate:Date?
    var sender:UIButton?
    weak var delegate: DatePickerViewDelegate?
    var isTimePicker:Bool?
    var minimumDate:Date?//,,,sb10

    
    //MARK: View Life Cycle
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        if isTimePicker != nil && isTimePicker!{
            datePicker.datePickerMode = .time
        }
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            
        }
        if minimumDate != nil {
            datePicker.minimumDate = minimumDate
        }//,,,sb10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BaseViewController.transparentBlackEffect(On: self.view)
    }
    
    //MARK: End
    
    //MARK: IBAction
    
    @IBAction func cancelButtonPressed(_ sender: UIButton){
        self.view.backgroundColor = .clear
       self.dismiss(animated: true) {
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton){
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
            self.delegate?.dateSelectedWithSender(selectedDate: self.datePicker.date, sender: self.sender)
        }
    }
    //MARK: End
    

    

}
