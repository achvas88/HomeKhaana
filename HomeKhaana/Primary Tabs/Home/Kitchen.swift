//
//  Kitchen.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 11/13/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//


import Foundation
import FirebaseDatabase

class Kitchen
{
    var id: String
    var name: String
    var rating:NSNumber
    var timeForFood:String
    var address: String
    var type: String
    var ratingCount: NSNumber
    var imgName: String
    var offersVegetarian: Bool
    
    init(id:String, name:String, rating:NSNumber, timeForFood:String, address: String, type: String, ratingCount: NSNumber, imgName: String, offersVegetarian: Bool) {
        self.id = id
        self.name = name
        self.rating = rating
        self.timeForFood = timeForFood
        self.address = address
        self.type = type
        self.ratingCount = ratingCount
        self.imgName = imgName
        self.offersVegetarian = offersVegetarian
    }
    
    public convenience init?(snapshot: DataSnapshot)
    {
        let id = snapshot.key as String
        let snapshot = snapshot.value as AnyObject
        
        let name = snapshot["name"] as! String
        let rating = snapshot["rating"] as! NSNumber
        let timeForFood = snapshot["timeForFood"] as! String
        let address = snapshot["address"] as! String
        let type = snapshot["type"] as! String
        let ratingCount = snapshot["ratingCount"] as! NSNumber
        let imgName = snapshot["imgName"] as! String
        let offersVegetarian = snapshot["offersVegetarian"] as! Bool
        
        self.init(id: id, name:name, rating: rating, timeForFood: timeForFood,address: address, type: type, ratingCount: ratingCount, imgName: imgName, offersVegetarian: offersVegetarian)
    }
}
