//
//  Order.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/12/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Order
{
    //other meta-data
    var id:UInt
    var orderDate:String
    var deliveryDate:String
    var orderRating:Int?
    var status:String
    
    //order items
    var cart:Dictionary<String,Int>
    
    //cost
    var subTotal:Float
    var tax:Float
    var convenienceFee:Float
    var discount:Float
    var orderTotal:Float
    
    //payment source and address
    var selectedPayment:PaymentSource?
    var selectedAddress:Address?
    
    var dictionary: Dictionary<String, Any> {
        return [
            "id": id,
            "orderDate": self.orderDate,
            "deliveryDate": self.deliveryDate,
            "orderRating": orderRating ?? -1,
            "cart": cart as [String:AnyObject],
            "subTotal": subTotal,
            "tax": tax,
            "convenienceFee": convenienceFee,
            "discount": discount,
            "orderTotal": orderTotal,
            "source": self.selectedPayment!.id,
            "amount": Int(floor(self.orderTotal*100)),
            "address": selectedAddress!.address,
            "status": self.status
        ]
    }
    
    public init(id:UInt)
    {
        self.id=id
        self.status = "New"
        //set date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        self.orderDate = dateFormatter.string(from: Date.init())
        dateFormatter.timeStyle = .none
        self.deliveryDate = dateFormatter.string(from: Date.init(timeInterval: TimeInterval.init(exactly: (24*60*60))!, since: Date.init()))
        self.cart = Dictionary<String,Int>()
        self.orderRating = -1
        self.subTotal = 0
        self.tax = 0
        self.convenienceFee = 0
        self.discount = 0
        self.orderTotal = 0
    }
    
    public init(id: UInt, orderDate: String, deliveryDate: String, orderRating: Int?, status: String, cart: Dictionary<String,Int>, subTotal: Float, tax: Float, convenienceFee: Float, discount: Float, orderTotal: Float, source: PaymentSource?, deliveryAddress: Address?)
    {
        self.id = id
        self.orderDate = orderDate
        self.deliveryDate = deliveryDate
        self.orderRating = orderRating
        self.status = status
        self.cart = cart
        self.subTotal = subTotal
        self.tax = tax
        self.convenienceFee = convenienceFee
        self.discount = discount
        self.orderTotal = orderTotal
        self.selectedPayment = source
        self.selectedAddress = deliveryAddress
    }
    
    public convenience init?(snapshot: DataSnapshot)
    {
        guard
            let value = snapshot.value as? [String: AnyObject]
            else { return nil }
        
        //other meta-data
        var id:UInt?
        var orderDate:String?
        var deliveryDate:String?
        var orderRating:Int?
        var status:String?
        
        //order items
        var cart:Dictionary<String,Int>?
        
        //cost
        var subTotal:Float?
        var tax:Float?
        var convenienceFee:Float?
        var discount:Float?
        var orderTotal:Float?
        
        //payment source and address
        var selectedPayment:PaymentSource?
        var selectedAddress:Address?
        
        
        var address:String?
        var selectedPaymentID: String?
        
        
        for items in value {
            let key=items.key
            let val = items.value
            if(key == "address") { address = val as? String }
            else if(key == "cart") {
                cart = val as? [String:Int]
            }
            else if(key == "convenienceFee") { convenienceFee = val as? Float  }
            else if(key == "discount") { discount = val as? Float }
            else if(key == "id") { id = val as? UInt }
            else if(key == "orderDate") { orderDate = val as? String }
            else if(key == "orderRating") { orderRating = val as? Int }
            else if(key == "orderTotal") { orderTotal = val as? Float }
            else if(key == "source") { selectedPaymentID = val as? String }
            else if(key == "subTotal") { subTotal = val as? Float }
            else if(key == "tax") { tax = val as? Float }
            else if(key == "deliveryDate") { deliveryDate = val as? String }
            else if(key == "status") { status = val as? String }
        }
        
        selectedPayment = User.getPaymentSourceForID(id: selectedPaymentID!)
        selectedAddress = DataManager.getAddressForKey(key: address!)
        
        self.init(id: id!, orderDate: orderDate ?? "", deliveryDate: deliveryDate ?? "", orderRating: orderRating, status: status ?? "New", cart: cart!, subTotal: subTotal!, tax: tax!, convenienceFee: convenienceFee!, discount: discount!, orderTotal: orderTotal!, source: selectedPayment, deliveryAddress: selectedAddress)
    }
 
    func processResponse(snapshot: DataSnapshot) -> String
    {
        guard
            let value = snapshot.value as? [String: AnyObject]
            else { return "" }
        
        let errorString = value["error"] as? String
        if(errorString != nil)
        {
            return errorString!
        }
        
        let statusString = value["status"] as? String
        if(statusString != nil)
        {
            return statusString!
        }
        
        return ""
    }
}

