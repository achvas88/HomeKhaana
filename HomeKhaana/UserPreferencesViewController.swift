//
//  UserPreferencesViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/18/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class UserPreferencesViewController: UIViewController {

    @IBOutlet weak var tglVegetarian: UISwitch!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let user = Auth.auth().currentUser
        {
            // we are using email address as the document id
            let email = user.email!
            
            if(email == "") {
                fatalError("User email is empty")
            }
            
            
            let docRef = db.collection("Users").document(email)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    if let user = User(dictionary: document.data()!) {
                        print("userID:" + user.id)
                        print("userEmail:" + user.emailAddress)
                        print("isVegetarian:" + String(user.isVegetarian))
                        self.tglVegetarian.isOn = user.isVegetarian
                    } else {
                        fatalError("Unable to initialize type \(User.self) with dictionary \(String(describing: document.data()))")
                    }
                    
                    //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    //print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLooksGoodClicked(_ sender: Any) {
        
        if let user = Auth.auth().currentUser
        {
            // we are using email address as the document id
            let email = user.email!
            if(email == "") {
                fatalError("User email is empty")
            }
            let docRef = db.collection("Users").document(email)
            docRef.setData([
                "isVegetarian": tglVegetarian.isOn,
                "emailAddress": email,
                "name": user.displayName ?? "Username"
            ],merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
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
