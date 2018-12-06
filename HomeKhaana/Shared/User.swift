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
import FirebaseFunctions

final class User{
    
    static var sharedInstance:User? = nil   //singleton
    static var isUserInitialized: Bool = false
    static var userJustCreated: Bool = false
    
    //member variables
    var name:String
    var isVegetarian: Bool
    var id: String
    var email: String
    var customerID:String
    var paymentSources: [PaymentSource]?
    var chargeID: UInt
    var defaultPaymentSourceID:String?
    var originalDefaultPaymentSourceID:String?
    var defaultPaymentSource:PaymentSource?
    var defaultAddress:String
    var isUserImageLoaded: Bool
    var paymentSourcesToDeleteOnQuit:[PaymentSource]?
    var isKitchen: Bool
    
    
    static var dictionary: [String: Any] {
        return [
            "name": User.sharedInstance!.name,
            "isVegetarian": User.sharedInstance!.isVegetarian,
            "id": User.sharedInstance!.id,
            "email": User.sharedInstance!.email,
            "chargeID": User.sharedInstance!.chargeID,
            "customerID": User.sharedInstance!.customerID,
            "defaultAddress": User.sharedInstance!.defaultAddress,
            "isKitchen": User.sharedInstance!.isKitchen
        ]
    }
    
    //designated constructors
    public init(name:String, isVegetarian:Bool, id:String, email:String, customerID:String, chargeID:UInt, defaultAddress: String, isKitchen: Bool)
    {
        self.name = name
        self.isVegetarian = isVegetarian
        self.id = id
        self.email = email
        self.customerID = customerID
        self.chargeID = chargeID          // these will also be set later on.
        self.defaultAddress = defaultAddress
        self.isUserImageLoaded = false
        self.paymentSourcesToDeleteOnQuit = []
        self.isKitchen = isKitchen
        User.isUserInitialized = true
    }
    
    //convenience constructors
    public convenience init?(dictionary: NSDictionary, id: String)
    {
        guard let name = dictionary["name"] as? String,
              let isVegetarian = dictionary["isVegetarian"] as? Bool,
              let email = dictionary["email"] as? String,
              let chargeID = dictionary["chargeID"] as? UInt,
              let customerID = dictionary["customerID"] as? String
        else { return nil}
        
        let defaultAddress = dictionary["defaultAddress"] as? String
        let isKitchen = dictionary["isKitchen"] as? Bool
        
        self.init(name: name, isVegetarian: isVegetarian, id: id, email: email, customerID:customerID, chargeID: chargeID, defaultAddress: (defaultAddress ?? ""), isKitchen: isKitchen ?? false)
    }
    
    //intializes User data from the database
    public static func initialize(completion: @escaping () -> ())
    {
        LoaderController.sharedInstance.updateTitle(title: "Loading User Details")
        let db: DatabaseReference! = Database.database().reference()
        if let user = Auth.auth().currentUser
        {
            // we are using email address as the document id
            let uid = user.uid
            
            if(uid == "") {
                return
            }
            
            //First load the User.
            let dispatchGroupUser = DispatchGroup()
            dispatchGroupUser.enter()
            db.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                if(value == nil){
                    //new user! yayy!!
                    User.sharedInstance = User(name: user.displayName ?? user.email!, isVegetarian: false, id: uid, email: user.email!, customerID: "", chargeID: 1, defaultAddress: "", isKitchen: false)
                    
                    //write back to the database
                    db.child("Users").child(uid).setValue(User.dictionary, withCompletionBlock: { (err:Error?, ref:DatabaseReference) in
                        if let err = err {
                            fatalError("Error creating new user: \(err)")
                        } else {
                            User.userJustCreated = true
                            LoaderController.sharedInstance.updateTitle(title: "User Successfully Initialized")
                        }
                    })
                }
                else {
                    let user = User(dictionary: value!, id: uid)
                    User.sharedInstance = user
                }
                //semaphore.signal()
                dispatchGroupUser.leave()
            });
            
            //next load payments
            dispatchGroupUser.notify(queue: DispatchQueue.main) {
                if(User.userJustCreated != true && User.sharedInstance!.isKitchen != true)
                {
                    loadPayments(completion: completion)
                }
                else
                {
                    User.sharedInstance!.paymentSources = []
                    allDone(completion: completion)
                }
            }
        }
    }
    
    public static func loadPayments(completion: @escaping () -> ())
    {
        print("Finished Loading User Details")
        LoaderController.sharedInstance.updateTitle(title: "Loading User Payments")
        
        //obtain payment sources
        let dispatchGroupPaymentSources = DispatchGroup()
        dispatchGroupPaymentSources.enter()
        let paymentSourcesRef = db.child("PaymentSources/\(Auth.auth().currentUser!.uid)")
        paymentSourcesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            User.sharedInstance!.paymentSources = []
            
            for card in snapshot.children {
                if let snapshot = card as? DataSnapshot,
                    let paymentSource = PaymentSource(snapshot: snapshot)
                {
                    User.sharedInstance!.paymentSources!.append(paymentSource)
                }
            }
            dispatchGroupPaymentSources.leave()
            
        })
        //next obtain default payment source
        //dispatchGroupPaymentSources.notify(queue: DispatchQueue.main, execute: loadDefaultPayment(completion: completion))
        dispatchGroupPaymentSources.notify(queue: DispatchQueue.main) {
            loadDefaultPayment(completion: completion)
        }
    }
    
    public static func loadDefaultPayment(completion: @escaping () -> ())
    {
        print("Finished Loading User Payments")
        LoaderController.sharedInstance.updateTitle(title: "Loading User Defaults")
        
        if (User.sharedInstance!.paymentSources?.count == 0)
        {
            allDone(completion: completion)
            return //nothing to do. return.
        }
        
        //obtain default payment source
        let dispatchGroupDefaultPayment = DispatchGroup()
        dispatchGroupDefaultPayment.enter()
        functions.httpsCallable("getDefaultPaymentSource").call() { (result, error) in
            if let error = error as NSError? {
                //function errored out
                fatalError(error.localizedDescription)
            }
            if let defaultPaymentSourceID = (result?.data as? [String: Any])?["defaultSourceID"] as? String {
                User.sharedInstance!.defaultPaymentSourceID = defaultPaymentSourceID
                User.sharedInstance!.originalDefaultPaymentSourceID = defaultPaymentSourceID
                for source in User.sharedInstance!.paymentSources!
                {
                    if(source.id == defaultPaymentSourceID)
                    {
                        User.sharedInstance!.defaultPaymentSource = source
                        break
                    }
                }
            }
           dispatchGroupDefaultPayment.leave()
        }
        dispatchGroupDefaultPayment.notify(queue: DispatchQueue.main) {
            allDone(completion: completion)
        }
    }
    
    public static func allDone(completion: @escaping () -> ())
    {
        print("Finished Loading User Default Payments")
        LoaderController.sharedInstance.updateTitle(title: "Finished Loading")
        completion();
    }
    
    public static func updateDefaultPayment()
    {
        if(User.sharedInstance!.defaultPaymentSource == nil) { return; }
        
        if (User.sharedInstance!.defaultPaymentSource!.id != User.sharedInstance!.originalDefaultPaymentSourceID)
        {
            //update default payment source
            functions.httpsCallable("updateDefaultPaymentSource").call(["updatedDefaultSourceID": User.sharedInstance!.defaultPaymentSource!.id]) { (result, error) in
            }
        }
    }
    
    public static func markPaymentSourceForDeletion(paymentSource:PaymentSource)
    {
        User.sharedInstance!.paymentSourcesToDeleteOnQuit!.append(paymentSource)
    }
    
    public static func paymentIsMarkedForDeletion(paymentSource:PaymentSource)->Bool
    {
        if(User.sharedInstance!.paymentSourcesToDeleteOnQuit == nil) { return false }
        if(User.sharedInstance!.paymentSourcesToDeleteOnQuit!.count == 0) { return false }
        for source in User.sharedInstance!.paymentSourcesToDeleteOnQuit!
        {
            if(source.id == paymentSource.id) { return true }
        }
        return false
    }
    
    private static func deleteSourcesMarkedForDeletion()
    {
        for paymentSource in User.sharedInstance!.paymentSourcesToDeleteOnQuit!
        {
            deletePaymentSource(paymentSource: paymentSource)
        }
    }
    
    public static func deletePaymentSource(paymentSource:PaymentSource)
    {
        if (User.isUserInitialized)
        {
            let id = User.sharedInstance!.id
            
            Database.database().reference().child("PaymentSources/\(id)").child(paymentSource.tokenID).setValue(nil){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Error deleting payment source: \(error).")
                } else {
                    print("Removed Payment!")
                }
            }
        }
    }
    
    public static func getPaymentSourceForID(id:String) -> PaymentSource?
    {
        if(User.sharedInstance!.paymentSources == nil)
        {
            return nil
        }
        for paymentSource in User.sharedInstance!.paymentSources!
        {
            if(paymentSource.id == id)
            {
                return paymentSource
            }
        }
        return nil
    }
    
    //writes back User data to the database
    public static func WriteToDatabase()
    {
        if (User.isUserInitialized)
        {
            if(User.sharedInstance!.isKitchen != true)
            {
                // update the user object
                let id=User.sharedInstance!.id
                db.child("Users/\(id)").setValue(User.dictionary){
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        fatalError("Error uploading user data: \(error).")
                    } else {
                        print("User updated successfully!")
                    }
                }
                
                //delete sources marked for deletion
                deleteSourcesMarkedForDeletion()
                
                //update the default payment source.
                updateDefaultPayment()
            }
            else
            {
                // update the user object
                let id=User.sharedInstance!.id
                let currentKitchen:Kitchen? = DataManager.kitchens[id]
                
                if(currentKitchen != nil)
                {
                    db.child("Kitchens/\(id)").setValue(currentKitchen!.dictionary){
                        (error:Error?, ref:DatabaseReference) in
                        if let error = error {
                            fatalError("Error uploading kitchen data: \(error).")
                        } else {
                            print("Kitchen updated successfully!")
                        }
                    }
                }
            }
        }
    }
}
