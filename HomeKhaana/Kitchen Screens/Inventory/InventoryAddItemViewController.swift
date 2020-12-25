//
//  InventoryAddItemViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 12/9/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class InventoryAddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate, UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    
    // This constraint ties an element at zero points from the bottom layout guide
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtGroup: UITextField!
    @IBOutlet weak var txtItemContents: UITextField!
    @IBOutlet weak var tglVegetarian: UISwitch!
    @IBOutlet weak var tglNeedNotice: UISwitch!
    @IBOutlet weak var tglFeatured: UISwitch!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblRemainingChars: UILabel!
    @IBOutlet weak var lblScreenHdr: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var pckGroup: UIPickerView!
    @IBOutlet weak var stpNoticeDays: UIStepper!
    @IBOutlet weak var lblNoticeDays: UILabel!
    @IBOutlet weak var stkNoticePeriod: UIStackView!
    
    let imagePicker = UIImagePickerController()
    
    var imageChanged: Bool = false
    var choice:Choice?
    var choiceGroupTitle: String?
    var pickerGroupData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPicker()
        
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
        txtDescription.delegate = self
        self.stkNoticePeriod.isHidden = true
        txtCost.delegate = self
        
        self.lblScreenHdr.text = "ADD ITEM"
        
        if(choice != nil)
        {
            setupFields()
        }
    }
    
    @IBAction func noticeDaysChanged(_ sender: UIStepper)
    {
        self.lblNoticeDays.text = Int(sender.value).description
    }
    
    private func setupPicker()
    {
        self.pckGroup.delegate = self
        self.pckGroup.dataSource = self
        
        pickerGroupData.append("--- New Group ---")
        let menuItems:[ChoiceGroup]? = DataManager.menuItems[User.sharedInstance!.id]
        if(menuItems != nil)
        {
            for choiceGroup in menuItems!
            {
                if(choiceGroup.displayTitle != "")
                {
                    pickerGroupData.append(choiceGroup.displayTitle)
                }
            }
        }
        self.pckGroup.selectRow(0, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerGroupData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.pickerGroupData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(row == 0)
        {
            self.txtGroup.isEnabled = true
        }
        else
        {
            self.txtGroup.isEnabled = false
            self.txtGroup.text = self.pickerGroupData[row]
        }
    }
    
    private func setupFields()
    {
        self.txtTitle.text! = choice!.displayTitle
        self.txtGroup.text! = choiceGroupTitle!
        self.txtGroup.isEnabled = false
        self.pckGroup.isHidden = true
        self.txtDescription.text! = choice!.description
        self.txtCost.text! = String(choice!.cost)
        tglVegetarian.isOn = choice!.isVegetarian
        self.txtItemContents.text = choice!.items
        self.imgItem.image = choice!.image
        self.lblScreenHdr.text = "EDIT ITEM"
        self.btnAdd.setTitle("Save", for: .normal)
        self.imageChanged = true
        tglFeatured.isOn = choice!.isFeatured
        tglNeedNotice.isOn = choice!.needsAdvanceNotice
        showHideNoticePeriod()
        if(tglNeedNotice.isOn)
        {
            let noticeDays = choice!.noticeDays ?? 0
            self.lblNoticeDays.text! = noticeDays.description
        }
    }
    
    private func showHideNoticePeriod()
    {
        stkNoticePeriod.isHidden = !tglNeedNotice.isOn
    }
    
    @IBAction func tglAdvancedNoticeChanged(_ sender: Any) {
        showHideNoticePeriod()
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
        if textView.text == "Please enter the item description here" {
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please enter the item description here"
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
            let newChoice: Choice = Choice(id: choiceID, title: self.txtTitle.text!, description: self.txtDescription.text!, cost: costValue, isVegetarian: tglVegetarian.isOn, hasImage: false, items: self.txtItemContents.text ?? "", kitchenId: User.sharedInstance!.id, order: 0, isFeatured: tglFeatured.isOn, needsAdvanceNotice: tglNeedNotice.isOn, noticeDays: Int(lblNoticeDays.text!) ?? 0)
            newChoice.image = self.imgItem.image
            
            self.addChoiceToGroup(newChoice: newChoice)
        }
        else
        {
            choice!.displayTitle = self.txtTitle.text!
            choice!.description = self.txtDescription.text!
            choice!.cost = costValue
            choice!.isVegetarian = tglVegetarian.isOn
            choice!.isFeatured = tglFeatured.isOn
            choice!.needsAdvanceNotice = tglNeedNotice.isOn
            if(tglNeedNotice.isOn)
            {
                choice!.noticeDays = Int(lblNoticeDays.text!) ?? 1 //here it is one because at the very least, if advanced notice is needed it should be for one day
            }
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
