//
//  AddAttachmentViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 26/03/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import MobileCoreServices

@objc protocol AddAttachmentViewDelegate: AnyObject {
    func attachmentAdd(attachmentDict:[String:Any]?)
}

class AddAttachmentViewController: BaseViewController{
    
    weak var delegate: AddAttachmentViewDelegate?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var otherTextView: UIView!
    @IBOutlet weak var referanceView: UIView!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var fileView: UIView!
    @IBOutlet weak var privateView: UIView!
    @IBOutlet weak var notesSubView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var fileSelectionView: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    @IBOutlet weak var otherTextField: UITextField!
    @IBOutlet weak var referenceTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextView!
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet weak var isprivateButton: UIButton!
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    enum VideoSource {
        case photoLibrary
        case camera
    }
    
    var type = ""
    var imagePicker = UIImagePickerController()
    
    var fileName = ""
    var fileMimeType = ""
    var filePath = ""
    var isprivate = ""
    var fileType = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_initialview()
        
        let btn = UIButton()
        btn.tag = 1
        typeButtonPressed(btn)
        
        isprivateButton.isSelected = true
        isprivate = "true"
    }
    
    func setup_initialview(){
        
        DispatchQueue.main.async {
            Utility.populateMandatoryFieldsMark(self.mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 17.0,color:Utility.hexStringToUIColor(hex: "719898"))
            
            self.sectionView.roundTopCorners(cornerRadious: 40)
            self.mainView.setRoundCorner(cornerRadious: 10)
            self.typeView.setRoundCorner(cornerRadious: 10)
            self.referanceView.setRoundCorner(cornerRadious: 10)
            self.noteView.setRoundCorner(cornerRadious: 10)
            self.privateView.setRoundCorner(cornerRadious: 10)
            self.fileView.setRoundCorner(cornerRadious: 10)
            self.fileSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
            self.notesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
            self.otherTextField.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
            self.referenceTextField.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
            self.saveButton.setRoundCorner(cornerRadious: self.saveButton.frame.height / 2.0)
            self.createInputAccessoryView()
            self.referenceTextField.inputAccessoryView = self.inputAccView
            self.noteTextField.inputAccessoryView = self.inputAccView
            self.otherTextField.inputAccessoryView = self.inputAccView
        }
    }
    
    //MARK: - IBAction
    @IBAction func privateButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            isprivate = "false"
        }else{
            sender.isSelected = true
            isprivate = "true"
        }
    }
    
    @IBAction func typeButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            if sender.isSelected {
                return
            }
            for btn in self.typeButtons {
                
                if btn.tag == sender.tag {
                    btn.isSelected = true
                }else{
                    btn.isSelected = false
                }
                
                self.otherTextView.isHidden = true
                
                if btn.isSelected && btn.tag == 1{
                    self.type = "PRODUCT_PACKAGING"
                }else if btn.isSelected && btn.tag == 2{
                    self.type = "DOCUMENTATION"
                }else if btn.isSelected && btn.tag == 3{
                    self.type = "OTHER"
                    self.otherTextView.isHidden = false
                }
            }
        }
    }
    
    
    @IBAction func addFileButtonPressed(_ sender: UIButton) {
        
        let popUpAlert = UIAlertController(title: "File".localized(), message: "", preferredStyle: .actionSheet)
        
        let picture = UIAlertAction(title: "Take Picture".localized(), style: .default, handler:  { (UIAlertAction) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return
            }
            self.selectImageFrom(.camera)
        })
        
        let video = UIAlertAction(title: "Video Capture".localized(), style: .default, handler:  { (UIAlertAction) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return
            }
            self.selectVideoFrom(.camera)
        })
        
        let file = UIAlertAction(title: "Choose File".localized(), style: .default, handler:  { (UIAlertAction) in
            self.chooseFile(sender: sender)
        })
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:  { (UIAlertAction) in
            
        })
        
        popUpAlert.addAction(picture)
        popUpAlert.addAction(video)
        popUpAlert.addAction(file)
        popUpAlert.addAction(cancel)
        
        if let popoverController = popUpAlert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
//            popoverController.permittedArrowDirections = []
        }
        
        self.present(popUpAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        var tempattachmentDict = [String:Any]()
        
        var note = ""
        if let txt = noteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            note = txt
        }
        
        var reference = ""
        if let txt = referenceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            reference = txt
        }
        
        var otherText = ""
        if let txt = otherTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            otherText = txt
        }
        
        var fileName = ""
        if let txt = fileNameLabel.accessibilityHint , !txt.isEmpty {
            fileName = txt
        }
        
        var isvalidate = true
        
        if type == "" {
            Utility.showPopup(Title: App_Title, Message: "Please select Document Type".localized(), InViewC: self)
            isvalidate = false
        }
        
        if reference == "" {
            Utility.showPopup(Title: App_Title, Message: "Please enter Reference".localized(), InViewC: self)
            isvalidate = false
        }
        
        if fileName == "" {
            Utility.showPopup(Title: App_Title, Message: "Please select File".localized(), InViewC: self)
            isvalidate = false
        }
        
        if type == "OTHER" && otherText == "" {
            Utility.showPopup(Title: App_Title, Message: "Please enter Other Text".localized(), InViewC: self)
            isvalidate = false
        }
        
        tempattachmentDict["reference"] = reference
        tempattachmentDict["type"] = type
        tempattachmentDict["type_other"] = otherText
        tempattachmentDict["notes"] = note
        tempattachmentDict["is_private"] = isprivate
        
        
        
        tempattachmentDict["fileName"] = fileName
        tempattachmentDict["fileMimeType"] = fileMimeType
        tempattachmentDict["filePath"] = filePath
        tempattachmentDict["fileType"] = fileType
        
        if isvalidate {
            self.delegate?.attachmentAdd(attachmentDict: tempattachmentDict)
            self.navigationController?.popViewController(animated: true)
        }
        
        
        
    }
    
    //MARK: - End
    
    //MARK: - Private Method
    func chooseFile(sender:UIButton){
        let popUpAlert = UIAlertController(title: "Choose File".localized(), message: "", preferredStyle: .actionSheet)
        
        let picture = UIAlertAction(title: "Picture".localized(), style: .default, handler:  { (UIAlertAction) in
            self.selectImageFrom(.photoLibrary)
        })
        let video = UIAlertAction(title: "Video".localized(), style: .default, handler:  { (UIAlertAction) in
            self.selectVideoFrom(.photoLibrary)
        })
        
        let document = UIAlertAction(title: "Document".localized(), style: .default, handler:  { (UIAlertAction) in
            self.selectDocument()
        })
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:  { (UIAlertAction) in
            
        })
        
        popUpAlert.addAction(picture)
        popUpAlert.addAction(video)
        popUpAlert.addAction(document)
        popUpAlert.addAction(cancel)
        
        if let popoverController = popUpAlert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
//            popoverController.permittedArrowDirections = []
        }
        
        
        self.present(popUpAlert, animated: true, completion: nil)
    }
    
    //MARK: - End
}
extension AddAttachmentViewController: UITextViewDelegate{
    
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
    
    //MARK: - End
}
extension AddAttachmentViewController: UIImagePickerControllerDelegate{
    
    func selectImageFrom(_ source: ImageSource){
        
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        switch source {
        case .camera:
            self.imagePicker.sourceType = .camera
        case .photoLibrary:
            self.imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func selectVideoFrom(_ source: VideoSource){
        
        self.imagePicker =  UIImagePickerController()
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        
        switch source {
        case .camera:
            self.imagePicker.sourceType = .camera
        case .photoLibrary:
            self.imagePicker.sourceType = .photoLibrary
        }
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.allowsEditing = false
        imagePicker.videoQuality = UIImagePickerController.QualityType.type640x480
        imagePicker.videoMaximumDuration = 300;
        present(imagePicker, animated: true, completion: nil)
    }
    //MARK: - Add image to Library
    private func saveImage(imageName: String, image: UIImage) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        
        do {
            try data.write(to: fileURL)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                
                if  let imageUrl = self.loadImageFromDiskWith(fileName: "Adjustment.jpg") {
                    
                    if let tmpFileName = imageUrl.lastPathComponent {
                        
                        let tmpFileNameArray = tmpFileName.components(separatedBy: ".")
                        
                        let mimeType = Utility.getMimeType(fileExtention: tmpFileNameArray[1])
                        
                        self.fileName = tmpFileName
                        self.fileMimeType = mimeType
                        self.filePath = imageUrl.absoluteString!
                        self.fileType = "Picture"
                        
                        self.fileNameLabel.text = tmpFileName
                        self.fileNameLabel.accessibilityHint = tmpFileName
                        self.fileNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                    }
                }
            }
            
        } catch let error {
            print("error saving file with error", error)
        }
        
    }
    //MARK: - Fetch image from Library
    private func loadImageFromDiskWith(fileName: String) -> NSURL? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            _ = UIImage(contentsOfFile: imageUrl.path)
            
            return imageUrl as NSURL
            
        }
        
        return nil
    }
    //MARK: - Add video to Library
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        
        let tmpFileName = URL(fileURLWithPath: videoPath).lastPathComponent //videoPath.pathExtension
        
        let tmpFileNameArray = tmpFileName.components(separatedBy: ".")
        
        let mimeType = Utility.getMimeType(fileExtention: tmpFileNameArray[1])
        
        self.fileName = tmpFileName
        self.fileMimeType = mimeType
        self.filePath = videoPath
        self.fileType = "Video"
        
        self.fileNameLabel.text = tmpFileName
        self.fileNameLabel.accessibilityHint = tmpFileName
        self.fileNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
        
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        var Size = Float()
        var data = Data()
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
           mediaType == (kUTTypeMovie as String),
           let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
           UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
        {
            
            //            data = try! Data.init(contentsOf: url)
            //            Size = Float(Double(data.count)/1024/1024)
            //            print("Video size-------::",Size)
            
            
            //else{
            // Handle a movie capture
            let backView = UIView(frame: view.bounds)
            backView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            let progressView = UIProgressView(progressViewStyle: .bar)
            progressView.center = view.center
            progressView.setProgress(0.5, animated: true)
            progressView.trackTintColor = UIColor.lightGray
            progressView.tintColor = UIColor.blue
            
            view.addSubview(backView)
            backView.addSubview(progressView)
            
            guard let uncompressedData = try? Data(contentsOf: url) else {
                return
            }
            
            print("File size before compression: \(Double(uncompressedData.count / 1048576)) mb")
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
            
            Utility.compressVideo(inputURL: url,
                                  outputURL: compressedURL) { exportSession in
                guard let session = exportSession else {
                    return
                }
                
                switch session.status {
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .completed:
                    
                    DispatchQueue.main.async {
                        progressView.progress = 1.0
                        backView.removeFromSuperview()
                    }
                    
                    guard let compressedData = try? Data(contentsOf: compressedURL) else {
                        return
                    }
                    
                    print("File size after compression: \(Double(compressedData.count / 1048576)) mb")
                    Size = Float(Double(compressedData.count/1048576))
                    
                    if Size>VideoUploadLimit {
                        DispatchQueue.main.async {
                            Utility.showPopup(Title: App_Title, Message: "The file you try to upload is too large. The limit is \(Int(VideoUploadLimit)) MB".localized(), InViewC: self)
                            return
                        }
                    }else{
                        UISaveVideoAtPathToSavedPhotosAlbum(
                            compressedURL.absoluteString,
                            self,
                            #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
                            nil)
                    }
                    
                case .failed:
                    break
                case .cancelled:
                    break
                @unknown default:
                    fatalError()
                }
            }
        }else{
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, info[UIImagePickerController.InfoKey.imageURL] as? NSURL == nil{
                
                saveImage(imageName: "Adjustment.jpg", image: image)
                
            }else{
                if  let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? NSURL {
                    
                    print((imageUrl as URL).fileSizeString)
                    print((imageUrl as URL).fileSize)
                    
                    data = try! Data.init(contentsOf: imageUrl as URL)
                    Size = Float(Double(data.count)/1024/1024)
                    print("Image size-------::",Size)
                    if Size>FileUploadLimit {
                        self.dismiss(animated: true) {
                            Utility.showPopup(Title: App_Title, Message: "The file you try to upload is too large. The limit is \(Int(FileUploadLimit)) MB".localized(), InViewC: self)
                            return;
                        }
                    }else{
                        if let tmpFileName = imageUrl.lastPathComponent {
                            
                            let tmpFileNameArray = tmpFileName.components(separatedBy: ".")
                            
                            let mimeType = Utility.getMimeType(fileExtention: tmpFileNameArray[1])
                            
                            self.fileName = tmpFileName
                            self.fileMimeType = mimeType
                            self.filePath = imageUrl.absoluteString!
                            self.fileType = "Picture"
                            
                            self.fileNameLabel.text = tmpFileName
                            self.fileNameLabel.accessibilityHint = tmpFileName
                            self.fileNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                        }
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension AddAttachmentViewController: UIDocumentPickerDelegate,UINavigationControllerDelegate{
    
    func selectDocument(){
        print("select document")
        clickFunction()
    }
    
    func clickFunction(){
        
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
        
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        var Size = Float()
        var data = Data()
        
        print("import result : \(myURL)")
        
        data = try! Data.init(contentsOf: myURL)
        Size = Float(Double(data.count)/1024/1024)
        
        print("File size-------::",Size)
        if Size>FileUploadLimit {
            Utility.showPopup(Title: App_Title, Message: "The file you try to upload is too large. The limit is \(Int(FileUploadLimit)) MB".localized(), InViewC: self)
            return
        }else{
            let tmpFileName = myURL.lastPathComponent
            let tmpFileNameArray = tmpFileName.components(separatedBy: ".")
            let mimeType = Utility.getMimeType(fileExtention: tmpFileNameArray[1])
            
            self.fileName = tmpFileName
            self.fileMimeType = mimeType
            self.filePath = myURL.absoluteString
            self.fileType = "Document"
            
            self.fileNameLabel.text = tmpFileName
            self.fileNameLabel.accessibilityHint = tmpFileName
            self.fileNameLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
        }
    }
    
    public func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
}
