//
//  DataManager.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit

class DataManager {
    static var choices:[Choice] = []  // total list of choices = kitchen id: menu items map
    static var kitchens:Dictionary<String, Kitchen> = [:]  // kitchen id: kitchen
    static var menuItems:Dictionary<String,[ChoiceGroup]> = [:] //kitchen Id: ChoiceGroup array. (Choice group is a group of choices)
    static var kitchenDistancesToBeCalculated = 0
    
    public static func initData(completion: @escaping () -> ()) -> Void {
        if(!User.sharedInstance!.isKitchen) // if this is a regular user, not a kitchen...
        {
           UserDataManager.initData(completion: completion)
        }
        else // if this is a kitchen
        {
            KitchenDataManager.initData(completion: completion)
        }
    }
    
    public static func getUserFavoriteKitchens() -> [Kitchen]
    {
        return UserDataManager.getUserFavoriteKitchens()
    }
    
    //returns an array of kitchens
    public static func getKitchens(onlyPopular: Bool = false) -> [Kitchen]
    {
        let popularityThreshold = 4.0
        var kitchenArray:Array = Array(DataManager.kitchens.values)
        
        kitchenArray.sort(by: {(kitchen1: Kitchen, kitchen2: Kitchen) in
            return kitchen1.distanceInMiles! < kitchen2.distanceInMiles!
        })
        
        if(!User.sharedInstance!.isVegetarian)
        {
            if(onlyPopular)
            {
                var popKitchens:[Kitchen] = []
                for kitchen in kitchenArray
                {
                    if(kitchen.ratingHandler.rating >= popularityThreshold)
                    {
                        popKitchens.append(kitchen)
                    }
                }
                return popKitchens
            }
            else
            {
                return kitchenArray
            }
        }
        else
        {
            let allKitchens:[Kitchen] = kitchenArray
            var hasVegKitchens:[Kitchen] = []
            for kitchen in allKitchens
            {
                if(kitchen.offersVegetarian)
                {
                    if(onlyPopular)
                    {
                        if(kitchen.ratingHandler.rating >= popularityThreshold)
                        {
                            hasVegKitchens.append(kitchen)
                        }
                    }
                    else
                    {
                        hasVegKitchens.append(kitchen)
                    }
                }
            }
            return hasVegKitchens
        }
    }
}
