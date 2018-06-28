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
    var cost:String
    var isVegetarian:Bool
    var imgName: String
    
    init(title:String,description:String,cost:String,isVegetarian:Bool,imgName:String) {
        self.displayTitle = title
        self.description = description
        self.cost = cost
        self.isVegetarian = isVegetarian
        self.imgName = imgName
    }
}
