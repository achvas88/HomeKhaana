//
//  UserDataManager.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/12/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserDataManager {
    
    // load all kitchens
    public static func initData(completion: @escaping () -> ()) -> Void {
        LoaderController.sharedInstance.updateTitle(title: "Loading Service Providers")
        if(User.sharedInstance!.latitude == -1 || User.sharedInstance!.longitude == -1)
        {
            completion();   //you cannot yet load the kitchens for the user as the location is not yet known!
        }
        loadKitchens(completion: completion);
    }
    
    public static func loadKitchens(completion: @escaping () -> ())
    {
        let userLocation = String(Int(round(User.sharedInstance!.latitude))) + ":" + String(Int(round(User.sharedInstance!.longitude)))
        let kitchensRef = db.child("Kitchens/ByLocation/\(userLocation)")
        kitchensRef.observe(.value, with: { (snapshot) in
            DataManager.kitchens = [:]
            for kitchenChild in snapshot.children {
                if let snapshot = kitchenChild as? DataSnapshot,
                    let kitchen:Kitchen = Kitchen(snapshot: snapshot),
                    kitchen.isOnline == true
                {
                    let kitchenId:String = snapshot.key
                    DataManager.kitchens[kitchenId] = kitchen
                }
            }
            loadDistanceOfKitchensFromUser(completion: completion)
        })
    }
    
    public static func loadDistanceOfKitchensFromUser(completion: @escaping () -> ())
    {
        LoaderController.sharedInstance.updateTitle(title: "Triangulating")
        
        DataManager.kitchenDistancesToBeCalculated = DataManager.kitchens.count
        if(DataManager.kitchens.count > 0)
        {
            for (_, kitchen) in DataManager.kitchens {
                calculateDistanceOfKitchenFromCurrentUser(kitchen: kitchen, completion: completion)
            }
        }
        else
        {
            completion();
        }
    }
    
    
    public static func calculateDistanceOfKitchenFromCurrentUser(kitchen: Kitchen, completion: @escaping () -> ()) -> Void
    {
        let location1 =  User.sharedInstance!.userLocation.coordinate
        let location2 =  kitchen.kitchenLocation.coordinate
        let mapItemLoc1 = MKMapItem(placemark: MKPlacemark(coordinate: location1))
        let mapItemLoc2 = MKMapItem(placemark: MKPlacemark(coordinate: location2))
        
        let req = MKDirections.Request()
        req.source = mapItemLoc1
        req.destination = mapItemLoc2
        let dir = MKDirections(request:req)
        dir.calculate { response, error in
            
            DataManager.kitchenDistancesToBeCalculated = DataManager.kitchenDistancesToBeCalculated-1
            guard let response = response else {
                // if error in route calculation, just print out direct distance.
                let distance:CLLocationDistance = User.sharedInstance!.userLocation.distance(from: kitchen.kitchenLocation)
                let distanceInMiles:Double = distance * 0.62137 / 1000
                kitchen.distanceInMiles = distanceInMiles
                let distanceStr = NSString(format: "~ %.2f mi", distanceInMiles)
                kitchen.distanceFromLoggedInUser = (distanceStr as String)
                
                if(DataManager.kitchenDistancesToBeCalculated == 0)
                {
                    completion()
                }
                return
            }
            let route:MKRoute = response.routes[0]
            let distance = route.distance
            let distanceInMiles:Double = distance * 0.62137 / 1000
            kitchen.distanceInMiles = distanceInMiles
            let distanceStr = NSString(format: "%.2f mi", distanceInMiles)
            kitchen.distanceFromLoggedInUser = (distanceStr as String)
            if(DataManager.kitchenDistancesToBeCalculated == 0)
            {
                completion()
            }
        }
    }
    
    //saves user data to the database
    public static func saveData() {
        if(User.sharedInstance!.markingAsKitchen ?? false)
        {
            User.sharedInstance!.isKitchen = true
        }
        
        let id=User.sharedInstance!.id
        let userRef = db.child("Users/\(id)")
        
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
        //updateDefaultPayment() <- this now exists commented in UserDataManager.swift
    }
    
    public static func getUserFavoriteKitchens() -> [Kitchen]
    {
        var retKitchens:[Kitchen] = []
        var kitchenDic: Dictionary<String,Bool> = [:]
        let mostRecentOrders:[Order]? = User.sharedInstance!.mostRecentOrders
        
        if(mostRecentOrders != nil)
        {
            for order in mostRecentOrders!
            {
                let kitchenId = order.kitchenId
                if(kitchenDic[kitchenId] != true)
                {
                    kitchenDic[kitchenId] = true
                    let kitchen = DataManager.kitchens[kitchenId]
                    if(kitchen != nil)
                    {
                        retKitchens.append(kitchen!)
                    }
                }
            }
        }
        
        return retKitchens
    }
}
