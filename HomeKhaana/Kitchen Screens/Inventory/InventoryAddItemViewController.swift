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
    
    let imagePicker = UIImagePickerController()
    
    var menuItems:[ChoiceGroup]?
    var imageChanged: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
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
        
        //do not use the following statement because we still want to get groups that ahve only vegetarian options. This should not really be a problem, but if the kitchen user acceidentally has "isVegetarian" set, which doesnt make sense, then the following commented line will be problematic. Hence it is safer to directly manipulate the menuItems in the DataManager.
        //menuItems = DataManager.getChoiceGroups(kitchenId: User.sharedInstance!.id)
        self.menuItems = DataManager.menuItems[User.sharedInstance!.id] //for kitchens, user id = kitchen id
    }
    
    @IBAction func autoPopulate(_ sender: Any) {
        self.txtTitle.text = "Biryani"
        self.txtGroup.text = "Lunch"
        self.txtCost.text = "7.59"
        self.txtDescription.text = "This non-vegetarian thali is a perfect mid-day meal. The ingredients are carefully chosen in each of these items and is cooked home-style!"
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
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgItem.contentMode = .scaleAspectFill
            imgItem.image = pickedImage
            self.imageChanged = true
        }
        
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
        
        if(self.txtDescription.text == nil || self.txtDescription.text! == "")
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
        
        let choiceID: String = UUID().uuidString
        let newChoice: Choice = Choice(id: choiceID, title: self.txtTitle.text!, description: self.txtDescription.text!, cost: costValue, isVegetarian: tglVegetarian.isOn, hasImage: false, items: self.txtItemContents.text ?? "", kitchenId: User.sharedInstance!.id)
        newChoice.image = self.imgItem.image
        
        self.addChoiceToGroup(newChoice: newChoice)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func addChoiceToGroup(newChoice: Choice)
    {
        //menuItems
        let choiceGroupTitle:String = self.txtGroup.text ?? "Other"
        let choiceGroup:ChoiceGroup? = DataManager.getChoiceGroup(kitchenId: User.sharedInstance!.id, groupTitle: choiceGroupTitle)
        
        if(choiceGroup == nil)
        {
            DataManager.createChoiceGroup(kitchenId: User.sharedInstance!.id, displayTitle: choiceGroupTitle, choices: [newChoice])
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
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
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