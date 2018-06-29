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
import FBSDKLoginKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var btnPreferences: CustomUIButton!
    @IBOutlet weak var btnPayment: CustomUIButton!
    @IBOutlet weak var btnHelp: CustomUIButton!
    @IBOutlet weak var btnFAQ: CustomUIButton!
    @IBOutlet weak var btnLogout: CustomUIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        if let user = Auth.auth().currentUser
        {
            let name = user.displayName
            self.lblTitle.text = name
        }
        
        self.setupButtons()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons()
    {
        self.btnPreferences.setImage(UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.btnPayment.setImage(UIImage(named: "credit-card")?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.btnHelp.setImage(UIImage(named: "Help")?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.btnFAQ.setImage(UIImage(named: "FAQ")?.withRenderingMode(.alwaysOriginal), for: .normal)
        let logoutBgColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        self.btnLogout.backgroundColor = logoutBgColor
    }
    
    @IBAction func btnLogOutClicked(_ sender: Any) {
        
        if Auth.auth().currentUser != nil
        {
            do
            {
                try Auth.auth().signOut()
                
                GIDSignIn.sharedInstance().signOut()
                
                let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                present(vc, animated: true, completion: nil)
                
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        }
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