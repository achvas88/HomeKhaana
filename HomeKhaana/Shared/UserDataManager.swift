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
        let kitchensRef = db.child("Kitchens")
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
