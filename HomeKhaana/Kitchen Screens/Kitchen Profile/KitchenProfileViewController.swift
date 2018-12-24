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
    }
        
    @IBAction func logoutClicked(_ sender: Any) {
        User.Logout(vcHost: self)
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
