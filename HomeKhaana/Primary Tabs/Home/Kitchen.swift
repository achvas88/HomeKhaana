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
    
    var dictionary: [String: Any] {
        return [
            "address": self.address,
            "imgName": self.imgName,
            "name": self.name,
            "offersVegetarian": self.offersVegetarian,
            "rating": self.rating,
            "ratingCount": self.ratingCount,
            "timeForFood": self.timeForFood,
            "type": self.type
        ]
    }
    
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
    
    //convenience constructors
    public convenience init?(dictionary: NSDictionary, id: String)
    {
        guard let name = dictionary["name"] as? String,
            let rating = dictionary["rating"] as? NSNumber,
            let timeForFood = dictionary["timeForFood"] as? String,
            let address = dictionary["address"] as? String,
            let type = dictionary["type"] as? String,
            let ratingCount = dictionary["ratingCount"] as? NSNumber,
            let imgName = dictionary["imgName"] as? String,
            let offersVegetarian = dictionary["offersVegetarian"] as? Bool
            else { return nil }
        
         self.init(id: id, name:name, rating: rating, timeForFood: timeForFood,address: address, type: type, ratingCount: ratingCount, imgName: imgName, offersVegetarian: offersVegetarian)
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
