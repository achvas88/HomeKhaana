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
import MapKit
import FirebaseAuth
import FirebaseMessaging

final class User: NSObject{
    
    static var sharedInstance:User? = nil   //singleton
    static var isUserInitialized: Bool = false
    static var userJustCreated: Bool = false
    static let locationManager = CLLocationManager()
    static var dispatchGroupLocation = DispatchGroup();
    static var dispatchGroupFavorites = DispatchGroup();
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
    var ratingHandler: RatingHandler
    var mostRecentOrders: [Order]?
    
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
            "rating": User.sharedInstance!.ratingHandler.rating,
            "ratingCount": User.sharedInstance!.ratingHandler.ratingCount
        ]
    }
    
    //designated constructors
    public init(name:String, isVegetarian:Bool, id:String, email:String, customerID:String, defaultAddress: String, isKitchen: Bool, latitude: Double, longitude: Double, rating: Double, ratingCount: Int)
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
        User.isUserInitialized = true
        self.ratingHandler = RatingHandler(rating: rating,ratingCount: ratingCount, isForKitchen: false, id: self.id)
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
        let rating = dictionary["rating"] as? Double
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
    
    //writes back User data to the database
    public static func saveData()
    {
        if (User.isUserInitialized)
        {
            if(User.sharedInstance!.isKitchen != true)
            {
                UserDataManager.saveData()
            }
            else
            {
                KitchenDataManager.saveData()
            }
        }
    }
    
    // logs the user out
    public static func Logout(vcHost: UIViewController)
    {
        if Auth.auth().currentUser != nil
        {
            do
            {
                User.saveData()
                
                try Auth.auth().signOut()
                
                GIDSignIn.sharedInstance().signOut()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                vcHost.present(vc, animated: true, completion: nil)
                
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        }
    }
    
    //load user from server. Currently used by the rating control
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
    
    //loads the user's location
    private static func loadUserLocation(completion: @escaping () -> ())
    {
        LoaderController.sharedInstance.updateTitle(title: "Loading User Location")
        
        User.dispatchGroupLocation.enter()
        User.loadingLocation = true
        
        lookupUserLocation()
        
        User.dispatchGroupLocation.notify(queue: DispatchQueue.main) {
            User.loadingLocation = false
            lookupFavoriteKitchens(completion: completion)
        }
    }
    
    private static func lookupFavoriteKitchens(completion: @escaping () -> ())
    {
        LoaderController.sharedInstance.updateTitle(title: "Loading User Favorites")
        
        User.dispatchGroupFavorites.enter()
        
        getMostRecentOrders()
        
        User.dispatchGroupFavorites.notify(queue: DispatchQueue.main) {
            allDone(completion: completion)
        }
    }
    
    public static func getMostRecentOrders()
    {
        let mostRecentOrdersQuery = db.child("Orders/\(User.sharedInstance!.id)").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
        
        mostRecentOrdersQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            User.sharedInstance!.mostRecentOrders = []
            for orderChild in snapshot.children {
                if let snapshot = orderChild as? DataSnapshot,
                    let order:Order? = Order(snapshot: snapshot)
                {
                    if(order != nil)
                    {
                        User.sharedInstance!.mostRecentOrders!.insert(order!, at: 0)
                    }
                }
            }
            User.dispatchGroupFavorites.leave()
        })
    }
    
    //helper function to actually load the user location
    private static func lookupUserLocation() {
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
    }
    
    //all the loading for a user is done.
    private static func allDone(completion: @escaping () -> ())
    {
        /*Messaging.messaging().subscribe(toTopic: User.sharedInstance!.id) { error in
            print("Subscribed for remote notifications")
        }*/
        
        //write fcm token to server now.
        let userRef = db.child("Users/\(User.sharedInstance!.id)")
        userRef.child("fcmToken").setValue(Messaging.messaging().fcmToken)
        
        //clear the badge count
        userRef.child("badgeCount").setValue(0)
        UIApplication.shared.applicationIconBadgeNumber = 0

        
        print("Finished Loading")
        LoaderController.sharedInstance.updateTitle(title: "Finished Loading")
        completion();
    }
    
    /* Payment related functions
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
     }*/
    
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
