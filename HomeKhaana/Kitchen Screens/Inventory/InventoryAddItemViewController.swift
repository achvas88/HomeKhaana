//
//  InventoryAddItemViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 12/9/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class InventoryAddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate, UITextFieldDelegate {

    
    // This constraint ties an element at zero points from the bottom layout guide
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtGroup: UITextField!
    @IBOutlet weak var txtItemContents: UITextField!
    @IBOutlet weak var tglVegetarian: UISwitch!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblRemainingChars: UILabel!
    @IBOutlet weak var lblScreenHdr: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    var imageChanged: Bool = false
    var choice:Choice?
    var choiceGroupTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        self.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        
        //setup the description textview to make it look like the other textfields
        txtDescription.layer.cornerRadius = 5
        txtDescription.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        txtDescription.layer.borderWidth = 0.5
        txtDescription.clipsToBounds = true
        txtDescription.text = "Please enter the item description here"
        txtDescription.textColor = UIColor.lightGray
        txtDescription.delegate = self
        
        txtCost.delegate = self
        
        self.lblScreenHdr.text = "ADD ITEM"
        
        if(choice != nil)
        {
            setupFields()
        }
    }
    
    private func setupFields()
    {
        self.txtTitle.text! = choice!.displayTitle
        self.txtGroup.text! = choiceGroupTitle!
        self.txtGroup.isEnabled = false
        self.txtDescription.text! = choice!.description
        self.txtDescription.textColor = UIColor.black
        self.txtCost.text! = String(choice!.cost)
        tglVegetarian.isOn = choice!.isVegetarian
        self.txtItemContents.text = choice!.items
        self.imgItem.image = choice!.image
        self.lblScreenHdr.text = "EDIT ITEM"
        self.btnAdd.setTitle("Save", for: .normal)
        self.imageChanged = true
    }
    
    @IBAction func autoPopulate(_ sender: Any) {
        self.txtTitle.text = "Biryani"
        self.txtGroup.text = "Lunch"
        self.txtCost.text = "7.59"
        self.txtDescription.text = "This non-vegetarian thali is a perfect mid-day meal. The ingredients are carefully chosen in each of these items and is cooked home-style!"
        self.txtDescription.textColor = UIColor.black
        self.txtItemContents.text = "4 Chapathis, Rice, Aloo Mutter, Chicken Tikka Masala, Dal Tadka"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == txtCost)
        {
            if(textField.text == nil || textField.text! == "")
            {
                return
            }
            
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            textField.text = formatter.string(from: NSNumber(value: Float(textField.text!) ?? 0))
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please enter the item description here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let descChrCount = textView.text.count
        self.lblRemainingChars.text = "Minimum Required Characters: " + String(max(0, 100 - descChrCount))
    }
    
    @IBAction func pickImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("image selected");
        guard let pickedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)");
        }
        
        imgItem.contentMode = .scaleAspectFill
        imgItem.image = pickedImage
        self.imageChanged = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addClicked(_ sender: Any) {
        
        if(self.txtTitle.text == nil || self.txtTitle.text! == "")
        {
            self.showError(message: "Enter title for item")
            return
        }
        
        if(self.txtDescription.text == nil || self.txtDescription.text! == "" || self.txtDescription.text! == "Please enter the item description here")
        {
            self.showError(message: "Enter description for item")
            return
        }
        
        let descChrCount = txtDescription.text.count
        if (descChrCount < 100)
        {
            self.showError(message: "The description should be at least 100 characters long")
            return
        }
        
        if(!self.imageChanged || self.imgItem.image == nil)
        {
            self.showError(message: "Please choose an image for the item")
            return
        }
        
        if(self.txtCost.text == nil || self.txtCost.text! == "" )
        {
            self.showError(message: "Enter cost of item")
            return
        }
        
        let costValue:Float = Float(self.txtCost.text!) ?? 0
        if(costValue <= 0 )
        {
            self.showError(message: "Enter a valid cost")
            return
        }
        
        if(choice == nil)
        {
            let choiceID: String = UUID().uuidString
            let newChoice: Choice = Choice(id: choiceID, title: self.txtTitle.text!, description: self.txtDescription.text!, cost: costValue, isVegetarian: tglVegetarian.isOn, hasImage: false, items: self.txtItemContents.text ?? "", kitchenId: User.sharedInstance!.id, order: 0)
            newChoice.image = self.imgItem.image
            
            self.addChoiceToGroup(newChoice: newChoice)
        }
        else
        {
            choice!.displayTitle = self.txtTitle.text!
            choice!.description = self.txtDescription.text!
            choice!.cost = costValue
            choice!.isVegetarian = tglVegetarian.isOn
            choice!.items = self.txtItemContents.text ?? ""
            choice!.image = self.imgItem.image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func addChoiceToGroup(newChoice: Choice)
    {
        let choiceGroupTitle:String = self.txtGroup.text ?? "Other"
        let choiceGroup:ChoiceGroup? = ChoiceGroup.getChoiceGroup(kitchenId: User.sharedInstance!.id, groupTitle: choiceGroupTitle)
        
        if(choiceGroup == nil)
        {
            ChoiceGroup.createChoiceGroup(kitchenId: User.sharedInstance!.id, displayTitle: choiceGroupTitle, choices: [newChoice])
        }
        else
        {
            choiceGroup!.addChoice(choice: newChoice)
        }
    }
    
    func showError(message: String, title: String = "Error")
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}
