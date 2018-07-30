//
//  User.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/17/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

final class User{
    
    static var sharedInstance:User? = nil   //singleton
    static var isUserInitialized: Bool = false
    
    //member variables
    var name:String
    var isVegetarian: Bool
    var id: String
    var email: String
    var customerID:String
    var paymentSources: [PaymentSource]
    var chargeID: UInt
    
    static var dictionary: [String: Any] {
        return [
            "name": User.sharedInstance!.name,
            "isVegetarian": User.sharedInstance!.isVegetarian,
            "id": User.sharedInstance!.id,
            "email": User.sharedInstance!.email,
            "customerID": User.sharedInstance!.customerID,
        ]
    }
    
    //designated constructors
    public init(name:String, isVegetarian:Bool, id:String, email:String, customerID:String)
    {
        self.name = name
        self.isVegetarian = isVegetarian
        self.id = id
        self.email = email
        self.customerID = customerID
        self.paymentSources = []   // these will be set later on.
        self.chargeID = 0          // these will also be set later on.
        User.isUserInitialized = true
    }
    
    //convenience constructors
    public convenience init?(dictionary: NSDictionary, id: String)
    {
        guard let name = dictionary["name"] as? String,
              let isVegetarian = dictionary["isVegetarian"] as? Bool,
              let email = dictionary["email"] as? String,
              let customerID = dictionary["customerID"] as? String
        else { return nil}
        
        self.init(name: name, isVegetarian: isVegetarian, id: id, email: email, customerID:customerID)
    }
    
    //intializes User data from the database
    public static func initialize()
    {
        if let user = Auth.auth().currentUser
        {
            // we are using email address as the document id
            let uid = user.uid
            
            if(uid == "") {
                fatalError("User id is empty")
            }
            
            db.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                if(value == nil){
                    //new user! yayy!!
                    User.sharedInstance = User(name: user.displayName!, isVegetarian: false, id: uid, email: user.email!, customerID: "")
                    
                    //write back to the database
                    db.child("Users").child(uid).setValue(User.dictionary, withCompletionBlock: { (err:Error?, ref:DatabaseReference) in
                        if let err = err {
                            fatalError("Error creating new user: \(err)")
                        } else {
                            print("New user created!")
                        }
                    })
                }
                else {
                    let user = User(dictionary: value!, id: uid)
                    User.sharedInstance = user
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    //writes back User data to the database
    public static func WriteToDatabase()
    {
        if User.isUserInitialized
        {
            let id=User.sharedInstance!.id
            db.child("Users/\(id)/isVegetarian").setValue(User.sharedInstance!.isVegetarian){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Error uploading user data: \(error).")
                } else {
                    print("User updated successfully!")
                }
            }
        }
    }
}
