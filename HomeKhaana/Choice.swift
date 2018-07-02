//
//  Choice.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation

class Choice
{
    var displayTitle: String
    var description:String
    var cost:Float
    var isVegetarian:Bool
    var imgName: String
    var currency: String
    var id:Int
    
    init(id:Int, title:String,description:String,cost:Float,isVegetarian:Bool,imgName:String,currency:String) {
        self.id = id
        self.displayTitle = title
        self.description = description
        self.cost = cost
        self.isVegetarian = isVegetarian
        self.imgName = imgName
        self.currency = currency
    }
}
