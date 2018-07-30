//
//  PaymentSource.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/15/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import Stripe
import FirebaseDatabase

class PaymentSource
{
    var cardNumber:String
    var expMonth: Int32
    var expYear: Int32
    var brand:String
    var isDefault:Bool
    var cardImage:UIImage
    
    var dictionary: [String: Any] {
        return [
            "cardNumber": cardNumber,
            "expMonth": expMonth,
            "expYear": expYear,
            "brand": brand,
            "isDefault": isDefault
        ]
    }
    
    public init(cardNumber:String, expMonth: Int32, expYear: Int32, brand: String, isDefault: Bool, cardImage: UIImage)
    {
        self.cardNumber = cardNumber
        self.expMonth = expMonth
        self.expYear = expYear
        self.brand = brand
        self.isDefault = isDefault
        self.cardImage = cardImage
    }
    
    public convenience init?(snapshot: DataSnapshot)
    {
        guard
            let value = snapshot.value as? [String: AnyObject]
            else { return nil }
        
        var cardNumber:String?
        var expMonth: Int32?
        var expYear: Int32?
        var brand: String?
        
        for items in value {
            let key=items.key
            let val = items.value
            if(key == "last4") { cardNumber = val as? String }
            else if(key == "exp_month") { expMonth = val as? Int32  }
            else if(key == "exp_year") { expYear = val as? Int32 }
            else if(key == "brand") { brand = val as? String }
        }
        
        let cardBrand = STPCard.brand(from: brand!)
        let cardImage = STPImageLibrary.brandImage(for: cardBrand)
        
        self.init(cardNumber: cardNumber!, expMonth: expMonth!, expYear: expYear!, brand: brand!, isDefault: false, cardImage: cardImage)
    }
}
