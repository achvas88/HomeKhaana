//
//  UserPreferencesViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/18/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import Firebase
import GooglePlacePicker

class UserPreferencesViewController: UIViewController,GMSPlacePickerViewControllerDelegate {
    
    @IBOutlet weak var tglVegetarian: UISwitch!
    @IBOutlet weak var btnAddAddress: CustomUIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user:User = User.sharedInstance!
        self.tglVegetarian.isOn = user.isVegetarian
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLooksGoodClicked(_ sender: Any) {
        User.sharedInstance!.isVegetarian = tglVegetarian.isOn
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAddAddressClicked(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        self.btnAddAddress.setTitle(place.name, for: .normal)
        print("Place name \(place.name)")
        print("Place address \(String(describing: place.formattedAddress))")
        print("Place attributions \(String(describing:place.attributions))")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
