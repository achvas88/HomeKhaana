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
    static var inCart:Dictionary<String,Int> = Dictionary<String,Int>()
    static var locations:[Address] = []
    
    static func initData() -> Void {
        
        //initialize the choices
        
        // remember remember... do not have titles longer than 35 characters... lest things will wrap weirdly.
        choices=[
            Choice(id:"1", title: "North Indian Veg Thali", description: "2 Chapathis, Rice, Aloo Mutter, Dal Tadka", cost: 7, isVegetarian: true, imgName: "NVT",currency: "$"),
            Choice(id:"2", title: "North Indian Non-Veg Thali", description: "2 Chapathis, Rice, Chicken Tikka Masala, Dal Tadka", cost: 7.50, isVegetarian: false, imgName: "NNVT",currency: "$"),
            Choice(id:"3", title: "North Indian Very Hungry Non-Veg Thali", description: "4 Chapathis, Rice, Aloo Mutter, Chicken Tikka Masala, Dal Tadka", cost: 9.50, isVegetarian: false, imgName: "NVHNVT",currency: "$"),
            Choice(id:"4", title: "South Indian Veg Thali", description: "Rice, Sambar, Gutti Venkaya, Kootu", cost: 7, isVegetarian: true, imgName: "SVT",currency: "$"),
            Choice(id:"5", title: "South Indian Non-Veg Thali", description: "Rice, Sambar, Mutton Curry, Kootu", cost: 7.50, isVegetarian: false, imgName: "SNVT",currency: "$"),
            Choice(id:"6", title: "South Indian Very Hungry Non-Veg Thali", description: "Rice, Sambar, Gutti Venkaya,Mutton Curry, Kootu", cost: 9.50, isVegetarian: false, imgName: "SVHNVT",currency: "$")
        ]
        
        //initialize the cart
        inCart=[:]
        
        //initializa the locations
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
        })
    }
    
    static func getAddressForTitle(title:String) ->Address?
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
    
    static func getAddressForKey(key:String) ->Address?
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
    
    static func getChoiceForId(id:Int) -> Choice
    {
        return choices[(id-1)]
    }
    
    static func generateTestData() -> [Choice] {
        if(choices.count==0) {initData()}
        return choices
    }
    
    static func updateCart(choiceID: String,quantity: Int)
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
