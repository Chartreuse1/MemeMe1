//
//  ViewController.swift
//  Test01
//
//  Created by Tony Tong on 2018-11-27.
//  Copyright © 2018 TT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    var activeTextField:UITextField!
    let imagePicker = UIImagePickerController()
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -2.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configTextField(topTextField)
        configTextField(bottomTextField)
        configUIImagePickerController()
        configCameraButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.attributedText =  NSAttributedString(string: textField.text!, attributes:memeTextAttributes)
        return true
    }
    
    @IBAction func albumButtonTouched(_ sender: Any) {
        launchImagePicker(UIImagePickerController.SourceType.photoLibrary)
    }
    
    @IBAction func cameraButtonTouched(_ sender: Any) {
        launchImagePicker(UIImagePickerController.SourceType.camera)
    }
    
    func launchImagePicker(_ sourceType : UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        present(imagePicker, animated:true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField.tag == 1001 && textField.text?.uppercased() == "TOP" {
            textField.text = ""
        }
        if textField.tag == 1002 && textField.text?.uppercased() == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func configTextField(_ textField:UITextField) {
        textField.attributedText = NSAttributedString(string: textField.text!, attributes:memeTextAttributes)
        textField.delegate = self
        textField.adjustsFontSizeToFitWidth = true
    }
    
    func configUIImagePickerController(){
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
    }
    
    func configCameraButton() {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }

    ////////
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if let tf = activeTextField {
            if tf.tag == 1002 {
                view.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    



}

