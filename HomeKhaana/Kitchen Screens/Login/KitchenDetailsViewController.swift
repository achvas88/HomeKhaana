//
//  KitchenProfileViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 12/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
//import GooglePlaces
//import GooglePlacePicker
import CoreLocation
import MapKit

class KitchenDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtFoodType: UITextField!
    @IBOutlet weak var imgKitchen: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var imageChanged: Bool = false
    
    var currentKitchen:Kitchen?
    
    
    // This constraint ties an element at zero points from the bottom layout guide
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
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
                self.keyboardHeightLayoutConstraint?.constant = 20.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 20.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        self.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        
        currentKitchen = DataManager.kitchens[User.sharedInstance!.id]
        // load values if already exists
        if(currentKitchen != nil)
        {
            self.txtName!.text = currentKitchen!.name
            self.txtAddress!.text = currentKitchen!.address
            self.imgKitchen!.image = currentKitchen!.image
            self.txtFoodType!.text = currentKitchen!.type
        }
        self.imageChanged = false
    }
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func pickImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgKitchen.contentMode = .scaleAspectFill
            imgKitchen.image = pickedImage
            
            self.imageChanged = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        
        if(self.txtName.text == nil || self.txtName.text! == "")
        {
            self.showError(message: "Please enter your kitchen's name")
            return
        }
        
        if(self.txtAddress.text == nil || self.txtAddress.text! == "")
        {
            self.showError(message: "Please enter your kitchen's address")
            return
        }
        
        if(self.txtFoodType.text == nil || self.txtFoodType.text! == "")
        {
            self.showError(message: "Please enter the type of food your kitchen offers")
            return
        }
        
        if(currentKitchen == nil && self.imageChanged == false)
        {
            self.showError(message: "Please choose an image for your kitchen")
            return
        }
        
        //the following should never happen as there isnt a way to clear out an image once it is set. keeping it here just to make sure we never leave out of here without an image set for the current kitchen
        if(currentKitchen != nil && currentKitchen!.hasImage == false)
        {
            self.showError(message: "Please choose an image for your kitchen")
            return
        }
        
        var vcToPresent:String = ""
        //we are good to go here as all values are set. let us update the kitchen's values right away or create the kitchen if need be.
        if (currentKitchen == nil)
        {
            currentKitchen = Kitchen(id: User.sharedInstance!.id, name: self.txtName.text!, rating: -1, timeForFood: "15 mins", address: self.txtAddress.text!, type: self.txtFoodType.text!, ratingCount: 0, hasImage: true, offersVegetarian: false)
            vcToPresent = "KitchenHome"
        }
        else
        {
            currentKitchen!.name = self.txtName.text!
            currentKitchen!.address = self.txtAddress.text!
            currentKitchen!.type = self.txtFoodType.text!
        }
        
        currentKitchen!.hasImage = true
        // if image was previously changed before this visit to this screen, then hold on to that value.
        currentKitchen!.imageChanged = currentKitchen!.imageChanged || self.imageChanged
        if(self.imageChanged)
        {
            currentKitchen!.image = imgKitchen.image
        }
        
        DataManager.kitchens[User.sharedInstance!.id] = currentKitchen
        
        //navigate to the right place
        if(vcToPresent == "")   //coming from Kitchen Details, simply go back/
        {
            self.dismiss(animated: true, completion: nil)
        }
        else    //initializing Kitchen. So go to KitchenHome
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: vcToPresent)
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    func showError(message: String, title: String = "Error")
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
