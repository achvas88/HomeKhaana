//
//  User.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/17/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation

struct User{
    var name:String
    var isVegetarian: Bool
    var id: String
    var emailAddress: String
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "isVegetarian": isVegetarian,
            "emailAddress": emailAddress
        ]
    }
}

extension User{
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
              let isVegetarian = dictionary["isVegetarian"] as? Bool,
              let emailAddress = dictionary["emailAddress"] as? String
        else { return nil }
        
        self.init(name: name, isVegetarian: isVegetarian, id: emailAddress, emailAddress: emailAddress)
    }
}
