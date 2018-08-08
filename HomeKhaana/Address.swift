//
//  Address.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/5/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Address{
    var title:String
    var address:String
    
    public init(title:String, address:String)
    {
        self.title = title
        self.address = address
    }
}
