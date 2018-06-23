//
//  DataManager.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation

class DataManager {
    
    static func generateTestData() -> [Choice] {
        return [
            Choice(title: "North Indian Veg Thali", description: "2 Chapathis, Rice, Aloo Mutter, Dal Tadka", cost: "7$", isVegetarian: true),
            Choice(title: "North Indian Non-Veg Thali", description: "2 Chapathis, Rice, Chicken Tikka Masala, Dal Tadka", cost: "7.50$", isVegetarian: false),
            Choice(title: "North Indian Very Hungry Non-Veg Thali", description: "4 Chapathis, Rice, Aloo Mutter, Chicken Tikka Masala, Dal Tadka", cost: "9.50$", isVegetarian: false),
            Choice(title: "South Indian Veg Thali", description: "Rice, Sambar, Gutti Venkaya, Kootu", cost: "7$", isVegetarian: true),
            Choice(title: "South Indian Non-Veg Thali", description: "Rice, Sambar, Mutton Curry, Kootu", cost: "7.50$", isVegetarian: false),
            Choice(title: "South Indian Very Hungry Non-Veg Thali", description: "Rice, Sambar, Gutti Venkaya,Mutton Curry, Kootu", cost: "9.50$", isVegetarian: false)
        ]
    }
}
