//
//  SharedFunctions.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/3/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation

func convertToCurrency(input:Float)->String
{
    //return round(input*1000)/1000 - can be used in the future to actually store float value
    return String(format: "%.2f", input)
}
