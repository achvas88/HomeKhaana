//
//  DataManager.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DataManager {
    
    static var choices:[Choice] = []
    static var inCart:Dictionary<String,Int> = [:]
    static var locations:[Address] = []
    
    public static func initData(completion: @escaping () -> ()) -> Void {
        
        LoaderController.sharedInstance.updateTitle(title: "Initializing Menu Items")
        let menuItemsRef = db.child("MenuItems")
        menuItemsRef.observe(.value, with: { (snapshot) in
            self.choices = []
            for choiceChild in snapshot.children {
                if let snapshot = choiceChild as? DataSnapshot,
                    let choice:Choice? = Choice(snapshot: snapshot)
                {
                    if(choice != nil)
                    {
                        self.choices.append(choice!)
                    }
                }
            }
            
            LoaderController.sharedInstance.updateTitle(title: "Loading Deliverable Locations")
            let locationRef = db.child("Locations")
            locationRef.observeSingleEvent(of: .value, with: { (snapshot) in
                self.locations = []
                
                if let addresses = snapshot.value as? [String: AnyObject]
                {
                    for items in addresses {
                        let key=items.key
                        let val = items.value as! String
                        self.locations.append(Address(title: val, address: key))
                    }
                }
                
                completion();
            })
        })
    }
    
    public static func getAddressForTitle(title:String) ->Address?
    {
        for address in locations
        {
            if(address.title == title)
            {
                return address
            }
        }
        return nil
    }
    
    public static func getAddressForKey(key:String) ->Address?
    {
        for location in locations
        {
            if(location.address == key)
            {
                return location
            }
        }
        return nil
    }
    
    public static func getChoiceForId(id:Int) -> Choice
    {
        return choices[(id-1)]
    }
    
    public static func updateCart(choiceID: String,quantity: Int)
    {
        if(quantity == 0)
        {
            inCart[choiceID] = nil
        }
        else
        {
            inCart[choiceID] = quantity
        }
    }
}
