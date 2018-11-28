//
//  ViewController.swift
//  Test01
//
//  Created by Tony Tong on 2018-11-27.
//  Copyright © 2018 TT. All rights reserved.
//

import UIKit

struct Meme {
    var topText = ""
    var bottomText = ""
    var originalImage : UIImage?
    var memedImage : UIImage?
}

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -2.0]
    let topTextFieldDefaultText = "TOP"
    let bottomTextFieldDefaultText = "BOTTOM"
    let topTextFieldTag = 1001
    let bottomTextFieldTag = 1002
    var activeTextField:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        //these tasks need only be executed (i.e. set up) once
        configTextField(topTextField)
        configTextField(bottomTextField)
        configUIImagePickerController()
        configCameraButton()
        
        //these tasks can be executed as needed
        resetScreen()
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
        setAttributedText(textField: textField, text: textField.text!)
        return true
    }
    
    @IBAction func albumButtonTouched(_ sender: Any) {
        launchImagePicker(UIImagePickerController.SourceType.photoLibrary)
    }
    
    @IBAction func cameraButtonTouched(_ sender: Any) {
        launchImagePicker(UIImagePickerController.SourceType.camera)
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        resetScreen()
    }
    
    @IBAction func actionButtonTouched(_ sender: Any) {
        let memeObj = Meme(
            topText: topTextField.text!,
            bottomText: bottomTextField.text!,
            originalImage: imageView.image,
            memedImage: generateMemedImage()
        )
        let avc = UIActivityViewController(activityItems: [memeObj.memedImage], applicationActivities: nil)
        present(avc, animated: true)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        showToolbars(false)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        showToolbars(true)
        
        return memedImage
    }
    
    func showToolbars(_ makeToolbarsVisible : Bool) {
        topToolbar.isHidden = !makeToolbarsVisible
        bottomToolbar.isHidden = !makeToolbarsVisible
    }
    
    func resetScreen() {
        setAttributedText(textField: topTextField, text: topTextFieldDefaultText)
        setAttributedText(textField: bottomTextField, text: bottomTextFieldDefaultText)
        imageView.image = nil
        actionButton.isEnabled = false
    }
    
    func launchImagePicker(_ sourceType : UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        present(imagePicker, animated:true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField.tag == topTextFieldTag && textField.text?.uppercased() == topTextFieldDefaultText {
            textField.text = ""
        }
        if textField.tag == bottomTextFieldTag && textField.text?.uppercased() == bottomTextFieldDefaultText {
            textField.text = ""
        }
    }
    
    func configTextField(_ textField:UITextField) {
        textField.delegate = self
        textField.adjustsFontSizeToFitWidth = true
    }
    
    func setAttributedText(textField:UITextField, text:String) {
        textField.attributedText = NSAttributedString(string: text, attributes:memeTextAttributes)
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
            actionButton.isEnabled = true //enable the share button only when there actually is an image
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
            if tf.tag == bottomTextFieldTag {
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

