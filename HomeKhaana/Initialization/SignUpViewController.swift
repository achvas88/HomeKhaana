//
//  SignUpViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/10/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class SignUpViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{ //}, FBSDKLoginButtonDelegate  {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    //@IBOutlet weak var btnFacebookView: FBSDKLoginButton!
    @IBOutlet weak var btnFacebook: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Action Handlers ----------------------------------------------
    @IBAction func kitchenUser(_ sender: Any) {
        self.txtEmail.text = "ach.k@gmail.com"
        self.txtPassword.text = "achyuth12"
    }
    
    @IBAction func btnRegisterClicked(_ sender: Any) {
        self.btnSignUpOrLogIn(isSignUp: true)
    }
    
    @IBAction func btnLogInClicked(_ sender: Any) {
        self.btnSignUpOrLogIn(isSignUp: false)
    }
    
    @IBAction func btnForgotPasswordClicked(_ sender: Any) {
        let email = txtEmail.text!
    
        if email == ""
        {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
        else
        {
            Auth.auth().sendPasswordReset(withEmail: email, completion:
            {
                (error) in
            
                var title = ""
                var message = ""
                
                if error != nil
                {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                }
                else
                {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.txtEmail.text = ""
                }
                
                self.showError(message: message,title: title)
            })
        }
    }
    
    // Google Sign In ----------------------------------------------
    @IBAction func btnGoogleClicked(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate=self
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential)
        {
            (user, error) in
            if (error == nil)
            {
                self.navigateToLoadUserScreen()
            }
            else
            {
                self.showError(message: error!.localizedDescription)
            }
        }
    }
    
    // Facebook Sign In --------------------------------------------------
    @IBAction func btnFacebookClicked(_ sender: Any)
    {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self, handler: {
                result, error in
                if error != nil
                {
                    self.showError(message: error!.localizedDescription)
                }
                else if result?.isCancelled == true
                {
                    //do nothing
                }
                else
                {
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signInAndRetrieveData(with: credential, completion: {
                            (user, error) in
                            if (error != nil)
                            {
                                self.showError(message: error!.localizedDescription)
                            }
                            else
                            {
                                self.navigateToLoadUserScreen()
                            }
                    })
                }
            })
    }
    
    // Supporting Functions ----------------------------------------------
    func btnSignUpOrLogIn(isSignUp: Bool)
    {
        let email = txtEmail.text!
        let password = txtPassword.text!
        
        if (email == "" || password == "")
        {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
        else
        {
            if(isSignUp)
            {
                Auth.auth().createUser(withEmail: email, password: password)
                {
                    (result, error) in
                    if (error == nil)
                    {
                        self.navigateToLoadUserScreen()
                    }
                    else
                    {
                        self.showError(message: error!.localizedDescription)
                    }
                }
            }
            else
            {
                Auth.auth().signIn(withEmail: email, password: password)
                {
                    (result, error) in
                    if (error == nil)
                    {
                        self.navigateToLoadUserScreen()
                    }
                    else
                    {
                        self.showError(message: error!.localizedDescription)
                    }
                }
            }
        }
    }
    
    func navigateToLoadUserScreen()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoadUser")
        self.present(vc!, animated: true, completion: nil)
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
