//
//  BaseViewController.swift
//  DrKure
//
//  Created by Rupbani Mukherjee on 21/10/19.
//  Copyright © 2019 development_test. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController,UITextFieldDelegate
{
    @IBOutlet weak var mainScroll: UIScrollView!
    var vSpinner : UIView?
    var inputAccView : UIView?
    var toolBar : UIToolbar?
    var defaultDB = UserDefaults.standard
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet var multiLingualViews: [UIView]!
    var textFieldTobeField : UITextField!
    var textViewTobeField :UITextView!
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    /////////////////////////////////
    //MARK: - End
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
        
        toolBar = UIToolbar.init(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 40.0))
        toolBar?.barStyle = UIBarStyle.black
        toolBar!.isTranslucent = true
        let btnDone = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneTyping))
        toolBar?.setItems([btnDone], animated: true)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.addTransition(transitionType: .fade, duration: 0.3)
    }
    override func viewWillDisappear(_ animated: Bool) {
        doneTyping()
    }
    
    @IBAction func backAction(sender:UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backActionWithoutAnimation(sender:UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func backActionPopToRoot(sender:UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Quantity Update Popup -
    public func quantityUpdater(view: UIView, isHidden: Bool){
        if isHidden{
            UIView.animate(withDuration: 0.3, animations: {view.alpha = 0},
                           completion: {(value: Bool) in
                            
                           })
        }else{
            UIView.animate(withDuration: 0.3, animations: {view.alpha = 1},
                           completion: {(value: Bool) in
                            
                           })
        }
    }
    
    //MARK: - Remove Observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - End
    
    //MARK: - Adjust Keyboard
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        if mainScroll == nil {
            return
        }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            mainScroll.contentInset = .zero
        } else {
            mainScroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        mainScroll.scrollIndicatorInsets = mainScroll.contentInset
    }
    //MARK: - End
}

//MARK: - Defined Methods keyboard ups/Down
extension BaseViewController{
    
    func animateViewMoving (up:Bool, moveValue :CGFloat)
    {
        let movementDuration:TimeInterval = 0.5
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    //MARK: - Defined Methods For Input Accessory view[Done]
    
    func createInputAccessoryView()
    {
        inputAccView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 40.0))
        inputAccView?.backgroundColor = UIColor.init(red: 198/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        let btnDone: UIButton = UIButton(type: .custom)
        btnDone.frame = CGRect(x: (UIScreen.main.bounds.size.width - 80.0), y: 0.0, width: 80.0, height: 40.0)
        btnDone.setTitle("Done".localized(), for: UIControl.State())
        btnDone.setTitleColor(UIColor.black, for: UIControl.State())
        btnDone.addTarget(self, action: #selector(doneTyping), for: .touchUpInside)
        inputAccView!.addSubview(btnDone)
        
        
        
        let btnCancel: UIButton = UIButton(type: .custom)
        btnCancel.frame = CGRect(x: 0, y: 0.0, width: 80.0, height: 40.0)//(UIScreen.main.bounds.size.width - 300.0)
        btnCancel.setTitle("Cancel".localized(), for: UIControl.State())
        btnCancel.setTitleColor(UIColor.black, for: UIControl.State())
        btnCancel.addTarget(self, action: #selector(cancelTyping), for: .touchUpInside)
        inputAccView!.addSubview(btnCancel)
        
    }
    func createInputAccessoryViewAddedScan()
    {
        inputAccView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 40.0))
        inputAccView?.backgroundColor = UIColor.init(red: 198/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        let btnDone: UIButton = UIButton(type: .custom)
        btnDone.frame = CGRect(x: (UIScreen.main.bounds.size.width - 80.0), y: 0.0, width: 80.0, height: 40.0)
        btnDone.setTitle("Done".localized(), for: UIControl.State())
        btnDone.setTitleColor(UIColor.black, for: UIControl.State())
        btnDone.addTarget(self, action: #selector(doneTyping), for: .touchUpInside)
        inputAccView!.addSubview(btnDone)
        
        let btnScan: UIButton = UIButton(type: .custom)
        btnScan.frame = CGRect(x: UIScreen.main.bounds.size.width/2-40, y: 0, width: 80.0, height: 40.0)//(UIScreen.main.bounds.size.width - 300.0)
        btnScan.setTitle("Scan".localized(), for: UIControl.State())
        btnScan.setTitleColor(UIColor.black, for: UIControl.State())
        btnScan.addTarget(self, action: #selector(scanning), for: .touchUpInside)
        inputAccView!.addSubview(btnScan)
        
        let btnCancel: UIButton = UIButton(type: .custom)
        btnCancel.frame = CGRect(x: 0, y: 0.0, width: 80.0, height: 40.0)//(UIScreen.main.bounds.size.width - 300.0)
        btnCancel.setTitle("Cancel".localized(), for: UIControl.State())
        btnCancel.setTitleColor(UIColor.black, for: UIControl.State())
        btnCancel.addTarget(self, action: #selector(cancelTyping), for: .touchUpInside)
        inputAccView!.addSubview(btnCancel)
        
    }
    @objc func doneTyping()
    {
        self.view.endEditing(true)
    }
    @objc func cancelTyping()
    {
        self.view.endEditing(true)
    }
    @objc func scanning(){
        Utility.openSacnDetails(controller: self)
    }
 
    //MARK: - Implement Loader -    
    func showSpinner(onView : UIView) {
        self.removeSpinner()
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        spinnerView.tag = 100
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async{
            //For removing all view previously added to 'onView'
            for view in onView.subviews{
                let viewWithTag = view.tag
                if viewWithTag == 100 {
                    view.removeFromSuperview()
                }
            }
            
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
            
            UIView.animate(withDuration: 0.3, animations: {self.vSpinner?.alpha = 1},
                           completion: {(value: Bool) in
                            self.vSpinner = spinnerView
                           })
            
        }
    }
    
    func removeSpinner() {
        DispatchQueue.main.async{
            //,,,sbm1
            /*
            UIView.animate(withDuration: 0.2, animations: {self.vSpinner?.alpha = 0.0},
                                       completion: {(value: Bool) in
                                        self.vSpinner?.removeFromSuperview()
                                        self.vSpinner = nil
                                       })
            */
            
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
            //,,,sbm1
        }
    }
    //MARK: - End -
    ///////////////////////////////////////////////
    
    //MARK: Hide keyboard by touching anywhere
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(BaseViewController.doneTyping))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //Mark: ViewShadow
    func dropShadow(viewDrop:UIView!)
    {
        viewDrop.layer.masksToBounds = false
        viewDrop.layer.shadowColor = UIColor.gray.cgColor
        viewDrop.layer.shadowOpacity = 0.2
        viewDrop.layer.shadowOffset = CGSize(width: 0, height:0)
        viewDrop.layer.shadowRadius = 10
        viewDrop.layer.cornerRadius = 10
    }
}

extension UIView {

  func dropShadow(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: -1, height: 1)
    layer.shadowRadius = 1

    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }

  func dropShadowAround(color: UIColor, opacity: Float = 1, offSet: CGSize, radius: CGFloat = 3, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius

    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}
extension BaseViewController: UIPopoverPresentationControllerDelegate{
    public func showPopover(ofViewController popoverViewController: UIViewController, originView: UIView, presentationStyle: UIModalPresentationStyle, transitionStyle: UIModalTransitionStyle) {
        popoverViewController.modalPresentationStyle = presentationStyle
        popoverViewController.modalTransitionStyle = transitionStyle
        if let popoverController = popoverViewController.popoverPresentationController {
            popoverController.delegate = self
            popoverController.sourceView = originView
            popoverController.sourceRect = originView.bounds
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.any
        }
        self.present(popoverViewController, animated: true)
    }
    
    internal func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle{
        return .none
    }
}
extension BaseViewController{
    class func transparentBlackEffect(On view: UIView){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5){
                view.backgroundColor = UIColor(white: 0, alpha: 0.5)
            }
        }
    }
}
