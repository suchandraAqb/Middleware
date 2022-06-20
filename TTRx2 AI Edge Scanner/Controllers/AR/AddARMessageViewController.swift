//
//  AddARMessageViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 13/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol AddARMessageViewControllerDelegate: class {
    @objc optional func didSaveNewMessage(messageDict:[String:Any])
}
class AddARMessageViewController: BaseViewController,HSBColorPickerDelegate, UITextViewDelegate {
    weak var delegate: AddARMessageViewControllerDelegate?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var colorPickerView: HSBColorPicker!
    var selectedColor:UIColor = UIColor.clear

    override func viewDidLoad() {
        super.viewDidLoad()
        createInputAccessoryView()
        setupUI()
        colorPickerView.delegate = self
    }
    //MARK: - Custom Method
    func setupUI(){
        titleTextField.delegate = self
        messageTextField.delegate = self
        messageTextField.inputAccessoryView = inputAccView

    }
    //MARK: - End
    //MARK: - IBAction
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
        }
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        guard let title = titleTextField.text,!title.isEmpty else{
            Utility.showPopup(Title:"Warning!".localized(), Message: "Title can't be blank.".localized(), InViewC: self)
            return
        }
        guard let message = messageTextField.text,!message.isEmpty else{
            Utility.showPopup(Title:"Warning!".localized(), Message: "Message can't be blank.".localized(), InViewC: self)
            return
        }
        if selectedColor == UIColor.clear {
            Utility.showPopup(Title:"Warning!".localized(), Message: "Please choose your color.".localized(), InViewC: self)
            return
        }
        self.dismiss(animated: true) {
            var dict = [String: Any]()
            dict["title"] = title
            dict["body"] = message
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: self.selectedColor, requiringSecureCoding: false)
                dict["color"] = data
                self.delegate?.didSaveNewMessage?(messageDict: dict)
            } catch let error {
                print("error color key data not saved \(error.localizedDescription)")
            }

            
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
    //MARK: - textView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
         textView.inputAccessoryView = inputAccView
    }
    //MARK: - HSBColorPickerDelegate
    func HSBColorColorPickerTouched(sender: HSBColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        print("%@",color);
        selectedColor = color
        containerView.layer.borderColor = color.cgColor
        containerView.layer.borderWidth = 5
    }
    //MARK: - End

}
