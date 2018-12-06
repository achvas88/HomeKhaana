//
//  Choice.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Choice
{
    var displayTitle: String
    var description:String
    var cost:Float
    var isVegetarian:Bool
    var imgName: String
    var id:String
    var items: String // In the future this can be different. For now, this is good enough.
    var kitchenId: String
    var quantity: Int?
    
    init(id:String, title:String,description:String,cost:Float,isVegetarian:Bool,imgName:String, items: String, kitchenId: String) {
        self.id = id
        self.displayTitle = title
        self.description = description
        self.cost = cost
        self.isVegetarian = isVegetarian
        self.imgName = imgName
        self.items = items
        self.kitchenId = kitchenId
    }
    
    public convenience init?(displayTitle: String, quantity: Int, cost: Float)
    {
        self.init(id: "", title: displayTitle, description: "", cost: cost, isVegetarian: true, imgName: "", items: "", kitchenId: "")
        self.quantity = quantity
    }
    
    public convenience init?(kitchenId:String, snapshot: DataSnapshot)
    {
        let snapshot = snapshot.value as AnyObject
        
        let displayTitle = snapshot["title"] as! String
        let description = snapshot["description"] as! String
        let cost = snapshot["cost"] as! Float
        let isVegetarian = snapshot["isVegetarian"] as! Bool
        let imgName = snapshot["imgName"] as! String
        let id = snapshot["id"] as! String
        let items = snapshot["items"] as! String
        
        self.init(id: id, title: displayTitle , description: description, cost: cost, isVegetarian: isVegetarian, imgName: imgName, items: items, kitchenId: kitchenId)
    }
    
}
