//
//  HomeViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/10/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
//import FBSDKLoginKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var btnPreferences: CustomUIButton!
    @IBOutlet weak var btnPayment: CustomUIButton!
    @IBOutlet weak var btnFAQ: CustomUIButton!
    @IBOutlet weak var btnLogout: CustomUIButton!
    @IBOutlet weak var btnKitchenLogin: UIButton!
    @IBOutlet weak var stkUserRating: UIStackView!
    @IBOutlet weak var lblRating: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        self.navigationController?.isNavigationBarHidden = true
        
        if let user = Auth.auth().currentUser
        {
            let name = user.displayName
            self.lblTitle.text = name
        }
        
        if (User.sharedInstance!.ratingHandler.ratingCount > 0)
        {
            self.lblRating.text = String(User.sharedInstance!.ratingHandler.rating)
            self.stkUserRating.isHidden = false
        }
        else
        {
            self.stkUserRating.isHidden = true
        }
        
        self.imgUser.layer.borderWidth = 3
        self.imgUser.layer.masksToBounds = false
        self.imgUser.layer.borderColor = UIColor.white.cgColor
        self.imgUser.layer.cornerRadius = self.imgUser.frame.height/2
        self.imgUser.clipsToBounds = true
        
        self.setupButtons()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //load user image
        if (!User.sharedInstance!.isUserImageLoaded)
        {
            let user = Auth.auth().currentUser
            if let user = user {
                let pic = user.photoURL
                if(pic != nil)
                {
                    self.imgUser.downloadedFrom(url: pic!)
                    User.sharedInstance!.isUserImageLoaded = true
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons()
    {
        self.btnPreferences.setImage(UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnPayment.setImage(UIImage(named: "credit-card")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnFAQ.setImage(UIImage(named: "FAQ")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnKitchenLogin.setImage(UIImage(named: "chef")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if(User.sharedInstance!.isKitchen)
        {
            self.btnKitchenLogin.isHidden = true
        }
        if #available(iOS 13.0, *) {
            self.btnLogout.backgroundColor = UIColor.secondarySystemBackground
        } else {
            self.btnLogout.backgroundColor = UIColor.systemGray
        }
    }
    
    @IBAction func btnLogOutClicked(_ sender: Any) {
        User.Logout(vcHost: self)
    }

    @IBAction func loginAsKitchenClicked(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Confirmation",
                                                message: "This will cause your logged in email address to be marked permanently as a kitchen. This means you cannot place orders from this account again. Are you sure?",
                                                preferredStyle: .alert)
        var alertAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            
            let alertController2 = UIAlertController(title: "What happens now... ",
                                                    message: "You will be logged out now. When you log back in, you will launch into kitchen mode.",
                                                    preferredStyle: .alert)
            let alertAction2 = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                
                User.sharedInstance!.markingAsKitchen = true
                User.Logout(vcHost: self)
            })
            alertController2.addAction(alertAction2)
            self.present(alertController2, animated: true)
        })
        
        alertController.addAction(alertAction)
        alertAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if(segue.identifier == "showPayment")
        {
            let paymentSourcesVC: PaymentSourceTableViewController? = segue.destination as? PaymentSourceTableViewController
            paymentSourcesVC?.selectedPayment = User.sharedInstance!.defaultPaymentSource
            paymentSourcesVC?.mgmtMode = true;
        }*/
    }
    
    
}
