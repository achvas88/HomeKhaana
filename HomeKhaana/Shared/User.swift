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
import GoogleSignIn
//import FBSDKLoginKit
import MapKit

final class User: NSObject{
    
    static var sharedInstance:User? = nil   //singleton
    static var isUserInitialized: Bool = false
    static var userJustCreated: Bool = false
    static let locationManager = CLLocationManager()
    static var dispatchGroupLocation = DispatchGroup();
    static var loadingLocation: Bool = false
    
    //member variables
    var name:String
    var isVegetarian: Bool
    var id: String
    var email: String
    var customerID:String
    var paymentSources: [PaymentSource]?
    var defaultPaymentSourceID:String?
    var originalDefaultPaymentSourceID:String?
    var defaultPaymentSource:PaymentSource?
    var defaultAddress:String
    var isUserImageLoaded: Bool
    var paymentSourcesToDeleteOnQuit:[PaymentSource]?
    var isKitchen: Bool
    var latitude: Double
    var longitude: Double
    var userLocation: CLLocation
    var markingAsKitchen: Bool?
    var rating: Float
    var ratingThisSession: Int?
    var ratingCount: Int
    
    static var dictionary: [String: Any] {
        return [
            "name": User.sharedInstance!.name,
            "isVegetarian": User.sharedInstance!.isVegetarian,
            "id": User.sharedInstance!.id,
            "email": User.sharedInstance!.email,
//            "customerID": User.sharedInstance!.customerID,
            "defaultAddress": User.sharedInstance!.defaultAddress,
            "isKitchen": User.sharedInstance!.isKitchen,
            "latitude": User.sharedInstance!.latitude,
            "longitude": User.sharedInstance!.longitude,
            "rating": User.sharedInstance!.rating,
            "ratingCount": User.sharedInstance!.ratingCount
        ]
    }
    
    //designated constructors
    public init(name:String, isVegetarian:Bool, id:String, email:String, customerID:String, defaultAddress: String, isKitchen: Bool, latitude: Double, longitude: Double, rating: Float, ratingCount: Int)
    {
        self.name = name
        self.isVegetarian = isVegetarian
        self.id = id
        self.email = email
        self.customerID = customerID
        self.defaultAddress = defaultAddress
        self.isUserImageLoaded = false
        self.paymentSourcesToDeleteOnQuit = []
        self.isKitchen = isKitchen
        self.latitude = latitude
        self.longitude = longitude
        self.userLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        self.rating = rating
        self.ratingCount = ratingCount
        User.isUserInitialized = true
    }
    
    //convenience constructors
    public convenience init?(dictionary: NSDictionary, id: String)
    {
        guard let name = dictionary["name"] as? String,
              let isVegetarian = dictionary["isVegetarian"] as? Bool,
              let email = dictionary["email"] as? String,
              let customerID = dictionary["customerID"] as? String
        else { return nil }
        
        let defaultAddress = dictionary["defaultAddress"] as? String
        let isKitchen = dictionary["isKitchen"] as? Bool
        let latitude = dictionary["latitude"] as? Double
        let longitude = dictionary["longitude"] as? Double
        let rating = dictionary["rating"] as? Float
        let ratingCount = dictionary["ratingCount"] as? Int
            
        self.init(name: name, isVegetarian: isVegetarian, id: id, email: email, customerID:customerID, defaultAddress: (defaultAddress ?? ""), isKitchen: isKitchen ?? false, latitude: latitude ?? -1, longitude: longitude ?? -1, rating: rating ?? -1, ratingCount: ratingCount ?? 0)
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
                    User.sharedInstance = User(name: user.displayName ?? user.email!, isVegetarian: false, id: uid, email: user.email!, customerID: "", defaultAddress: "", isKitchen: false, latitude: -1, longitude: -1, rating: -1, ratingCount: 0)
                    
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
            /*dispatchGroupUser.notify(queue: DispatchQueue.main) {
                if(User.userJustCreated != true && User.sharedInstance!.isKitchen != true)
                {
                    loadPayments(completion: completion)
                }
                else
                {
                    User.sharedInstance!.paymentSources = []
                    allDone(completion: completion)
                }
            }*/
            
            dispatchGroupUser.notify(queue: DispatchQueue.main) {
                User.sharedInstance!.paymentSources = []
                if(User.sharedInstance!.isKitchen != true)
                {
                    loadUserLocation(completion: completion)
                }
                else
                {
                    allDone(completion: completion)
                }
            }
        }
    }
    
    public static func loadUserLocation(completion: @escaping () -> ())
    {
        LoaderController.sharedInstance.updateTitle(title: "Loading User Location")
        
        User.dispatchGroupLocation.enter()
        User.loadingLocation = true
        
        lookupUserLocation()
    
        User.dispatchGroupLocation.notify(queue: DispatchQueue.main) {
            User.loadingLocation = false
            allDone(completion: completion)
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
        print("Finished Loading")
        LoaderController.sharedInstance.updateTitle(title: "Finished Loading")
        completion();
    }

    
//     These will be used once credit card payment is available.
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
                if(User.sharedInstance!.markingAsKitchen ?? false)
                {
                    User.sharedInstance!.isKitchen = true
                }
                // update the user object
                let id=User.sharedInstance!.id
                let userRef = db.child("Users/\(id)")
                //hopperRef.updateChildrenAsync(hopperUpdates);
                
                userRef.updateChildValues(User.dictionary, withCompletionBlock: {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        fatalError("Error uploading user data: \(error).")
                    } else {
                        print("User updated successfully!")
                    }
                })
                
                //delete sources marked for deletion
                //deleteSourcesMarkedForDeletion()
                
                //update the default payment source.
                //updateDefaultPayment()
            }
            else
            {
                // update the user object
                let id=User.sharedInstance!.id
                let currentKitchen:Kitchen? = DataManager.kitchens[id]
                
                if(currentKitchen != nil)
                {
                    let kitchenRef = db.child("Kitchens/\(id)")
                    kitchenRef.updateChildValues(currentKitchen!.dictionary, withCompletionBlock: {
                        (error:Error?, ref:DatabaseReference) in
                        
                        if let error = error
                        {
                            // It reaches here in a very specific workflow. Convert to kitchen and then logout. but things work fine. So commenting this out. 
                            //fatalError("Error uploading kitchen data: \(error).")
                        }
                        else
                        {
                            print("Its done.")
                        }
                    })
                    
                    DataManager.saveMenuItems()
                }
            }
        }
    }
    
    public static func Logout(vcHost: UIViewController)
    {
        if Auth.auth().currentUser != nil
        {
            do
            {
                User.WriteToDatabase()
                
                try Auth.auth().signOut()
                
                GIDSignIn.sharedInstance().signOut()
                
                //let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                //loginManager.logOut()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                vcHost.present(vc, animated: true, completion: nil)
                
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        }
    }
    
    public static func lookupUserLocation() {
        // setup location manager
        User.locationManager.delegate = User.sharedInstance!
        User.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if(CLLocationManager.locationServicesEnabled())
        {
            locationManager.requestLocation()
        }
        else
        {
            if(User.loadingLocation)
            {
                User.dispatchGroupLocation.leave()
            }
        }
        // if you do not have access, let the user go through with this screen. The latitude longitude should have still been stored during user initialization.
    }
    
    // ratings related
    public func addRating(rating: Float)
    {
        if(self.rating == -1)
        {
            self.rating = rating
        }
        else
        {
            self.rating = limitToTwoDecimal(input: ((self.rating * Float(self.ratingCount) + rating)/Float(self.ratingCount + 1)))
        }
        
        self.ratingCount = self.ratingCount + 1
        self.ratingThisSession = Int(rating)
        
        //write it to the server
        writeRatingToServer()
    }
    
    public static func loadUserFromServer(userID: String,completion: @escaping (User?) -> Void)
    {
        db.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if(value == nil){
                completion(nil)
            }
            else {
                let userLoaded = User(dictionary: value!, id: userID)
                completion(userLoaded)
            }
        });
    }
    
    private func writeRatingToServer()
    {
        let userRef = db.child("Users/\(id)")
        userRef.child("rating").setValue(self.rating)
        userRef.child("ratingCount").setValue(self.ratingCount)
    }
    
    public func updateRating(oldRating: Float, newRating:Float)
    {
        if(oldRating == newRating)  //do nothing if they are both the same
        {
            return
        }
        
        if(self.ratingCount == 1)   //if the oldRating was the first time the kitchen was rated ever, simply update to the new rating
        {
            self.rating = newRating
        }
        else
        {
            self.rating = limitToTwoDecimal(input: (((self.rating * Float(self.ratingCount)) - oldRating + newRating)/Float(self.ratingCount)))
        }
        
        self.ratingThisSession = Int(newRating)
        
        writeRatingToServer()
    }
}


extension User : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            User.sharedInstance!.userLocation =  location
            
            if(User.loadingLocation)
            {
                User.dispatchGroupLocation.leave()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if(User.loadingLocation)
        {
            User.dispatchGroupLocation.leave()
        }
    }
}
