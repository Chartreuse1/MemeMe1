//
//  ViewController.swift
//
//  Created by Tony on 2018-11-27.
//  Copyright © 2018 TT. All rights reserved.
//

import UIKit

//defining a structure to store meme definition
struct Meme {
    var topText = ""
    var bottomText = ""
    var originalImage : UIImage?
    var memedImage : UIImage?
}

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    ///////////////////////////////////////////////////////
    // class variables below
    ///////////////////////////////////////////////////////
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    var activeTextField:UITextField! //to identify which text field is being edited

    ///////////////////////////////////////////////////////
    // class constants below
    ///////////////////////////////////////////////////////
    
    let imagePicker = UIImagePickerController()
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -2.0]
    let topTextFieldDefaultText = "TOP"
    let bottomTextFieldDefaultText = "BOTTOM"
    let topTextFieldTag = 1001 //id for top text field
    let bottomTextFieldTag = 1002 //id for bottom text field

    ///////////////////////////////////////////////////////
    // class methods below
    ///////////////////////////////////////////////////////
    
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
        textField.resignFirstResponder() //dismiss keyboard
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
        
        let memedImage = generateMemedImage()
        
        let avc = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //save the meme only if user did not cancel out of the activity view controller
        avc.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed) {
                print("saving meme")
                self.saveMeme(memedImage)
            }
        }
        
        //show the stock activity view controller
        present(avc, animated: true)
    }
    
    func saveMeme(_ image : UIImage) {
        // store the meme in a Meme structure
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: image)
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
    
    //return UI elements to the default starting state
    //this function can be called multiple times with no issues
    func resetScreen() {
        setAttributedText(textField: topTextField, text: topTextFieldDefaultText)
        setAttributedText(textField: bottomTextField, text: bottomTextFieldDefaultText)
        imageView.image = nil
        actionButton.isEnabled = false
    }
    
    //launch image picker and instruct it to pick image from the specified source (e.g. photo album, camera, etc)
    func launchImagePicker(_ sourceType : UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        present(imagePicker, animated:true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //identify which text field was touched
        activeTextField = textField
        
        //clear out the text field only if the text within is the default text
        if textField.tag == topTextFieldTag && textField.text?.uppercased() == topTextFieldDefaultText {
            textField.text = ""
        }
        //clear out the text field only if the text within is the default text
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
        //disable camera button if the device does not have a camera
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
                //move the view up only when the bottom text field is touched
                view.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        //return view to default vertical position after keyboard is dismissed
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    



}

