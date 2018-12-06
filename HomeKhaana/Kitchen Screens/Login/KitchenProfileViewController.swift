//
//  KitchenProfileViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 12/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class KitchenProfileViewController: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtImage: UITextField!
    @IBOutlet weak var txtFoodType: UITextField!
    
    var currentKitchen:Kitchen?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentKitchen = DataManager.kitchens[User.sharedInstance!.id]
        
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        if(identifier == "kitchenHome")
        {
            if(self.txtName.text == nil || self.txtName.text! == "")
            {
                self.showError(message: "Please enter your kitchen's name")
                return false
            }
            
            if(self.txtAddress.text == nil || self.txtAddress.text! == "")
            {
                self.showError(message: "Please enter your kitchen's address")
                return false
            }
            
            if(self.txtImage.text == nil || self.txtImage.text! == "")
            {
                self.showError(message: "Please upload a display image for your kitchen")
                return false
            }
            
            if(self.txtFoodType.text == nil || self.txtFoodType.text! == "")
            {
                self.showError(message: "Please enter the type of food your kitchen offers")
                return false
            }
        }
        
        //we are good to go here as all values are set. let us update the kitchen's values right away or create the kitchen if need be.
        if (currentKitchen == nil)
        {
            currentKitchen = Kitchen(id: User.sharedInstance!.id, name: self.txtName.text!, rating: -1, timeForFood: "15 mins", address: self.txtAddress.text!, type: self.txtFoodType.text!, ratingCount: 0, imgName: self.txtImage.text!, offersVegetarian: false)
        }
        else
        {
            currentKitchen!.name = self.txtName.text!
            currentKitchen!.address = self.txtAddress.text!
            currentKitchen!.imgName = self.txtImage.text!
            currentKitchen!.type = self.txtFoodType.text!
        }
        
        DataManager.kitchens[User.sharedInstance!.id] = currentKitchen
        
        return true
    }

    func showError(message: String, title: String = "Error")
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
