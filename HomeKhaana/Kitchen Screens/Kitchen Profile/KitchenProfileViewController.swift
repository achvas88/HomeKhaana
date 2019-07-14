//
//  KitchenProfileViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 12/9/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class KitchenProfileViewController: UIViewController {

    @IBOutlet weak var imgKitchen: UIImageView!
    @IBOutlet weak var txtKitchenName: UILabel!
    @IBOutlet weak var swhOnline: UISwitch!
    @IBOutlet weak var stkKitchenRating: UIStackView!
    @IBOutlet weak var lblKitchenRating: UILabel!
    
    var kitchen: Kitchen?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadKitchen()
    }
    
    func reloadKitchen()
    {
        kitchen = DataManager.kitchens[User.sharedInstance!.id]
        
        if(kitchen == nil)
        {
            fatalError("kitchen is not present. This can't be true!")
        }
        self.imgKitchen.image = kitchen!.image
        self.txtKitchenName.text = kitchen!.name
        self.swhOnline.isOn = kitchen!.isOnline
        if(kitchen!.ratingCount > 0)
        {
            self.lblKitchenRating.text = "\(kitchen!.rating)"
            self.stkKitchenRating.isHidden = false
        }
        else
        {
            self.stkKitchenRating.isHidden = true
        }
    }
        
    @IBAction func logoutClicked(_ sender: Any) {
        User.Logout(vcHost: self)
    }

    @IBAction func swhOnlineToggled(_ sender: Any) {
        kitchen!.isOnline = self.swhOnline.isOn
        if(!self.swhOnline.isOn)
        {
            let alertController = UIAlertController(title: "Reminder", message: "You still need to complete ongoing orders.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
