//
//  SharedFunctions.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/3/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase


func convertToCurrency(input:Float)->String
{
    //return round(input*1000)/1000 - can be used in the future to actually store float value
    return String(format: "%.2f", input)
}

enum Constants
{
    static let publishableKey = "pk_test_E7O4iRuxgXcMDjnMPNJvVtXX"
}

let db: DatabaseReference! = Database.database().reference()
