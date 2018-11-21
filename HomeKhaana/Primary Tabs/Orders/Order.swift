//
//  Order.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/12/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

// TODO: Need to update this file.

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
    var orderingUserID:String
    var orderingUserName:String
    var kitchenId: String
    
    //order items
    var cart:[Choice]
    
    //cost
    var subTotal:Float
    var tax:Float
    var convenienceFee:Float
    var discount:Float
    var orderTotal:Float
    
    //payment source and address
    var selectedPayment:PaymentSource?
    
    var dictionary: Dictionary<String, Any> {
        return [
            "id": id,
            "orderDate": self.orderDate,
            "deliveryDate": self.deliveryDate,
            "orderRating": orderRating ?? -1,
            "subTotal": subTotal,
            "tax": tax,
            "convenienceFee": convenienceFee,
            "discount": discount,
            "orderTotal": orderTotal,
            "source": self.selectedPayment!.id,
            "amount": Int(floor(self.orderTotal*100)),
            "status": self.status,
            "orderingUserID": self.orderingUserID,  //these values are used in delivery workflows
            "orderingUserName": self.orderingUserName, // these values are used in delivery workflows
            "kitchenId": self.kitchenId,
            "cart": getMapFromCart()
        ]
    }
    
    private func getMapFromCart() -> Dictionary<String, String>
    {
        var retMap:Dictionary<String,String> = [:]
        for choice in self.cart
        {
            retMap[choice.displayTitle] = String(choice.cost) + ":" + String(choice.quantity!)
        }
        return retMap
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
        self.cart = [] //Dictionary<String,Int>()
        self.orderRating = -1
        self.subTotal = 0
        self.tax = 0
        self.convenienceFee = 0
        self.discount = 0
        self.orderTotal = 0
        self.orderingUserName = User.sharedInstance!.name
        self.orderingUserID = User.sharedInstance!.id
        self.kitchenId = ""
    }
    
    public init(id: UInt, orderDate: String, deliveryDate: String, orderRating: Int?, status: String, cart: [Choice], subTotal: Float, tax: Float, convenienceFee: Float, discount: Float, orderTotal: Float, source: PaymentSource?, kitchenId: String)
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
        self.orderingUserName = User.sharedInstance!.name
        self.orderingUserID = User.sharedInstance!.id
        self.kitchenId = kitchenId
    }
    
    /*public convenience init?(snapshot: DataSnapshot)
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
                cart = val as? Dictionary<String,Int>
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
        
        if(cart == nil) //this happens. figure out why the hell.
        {
            return nil
        }
        
        self.init(id: id!, orderDate: orderDate ?? "", deliveryDate: deliveryDate ?? "", orderRating: orderRating, status: status ?? "New", cart: cart!, subTotal: subTotal!, tax: tax!, convenienceFee: convenienceFee!, discount: discount!, orderTotal: orderTotal!, source: selectedPayment, deliveryAddress: selectedAddress)
    }*/
    
    public convenience init?(snapshot: DataSnapshot)
    {
        let snapshotCpy:DataSnapshot = snapshot
        let snapshot = snapshot.value as AnyObject
        
        //other meta-data
        let id = snapshot["id"] as? UInt
        let orderDate = snapshot["orderDate"] as? String
        let deliveryDate = snapshot["deliveryDate"] as? String
        let orderRating = snapshot["orderRating"] as? Int
        let status = snapshot["status"] as? String
        let kitchenId = snapshot["kitchenId"] as? String
        
        //order items
        var cart:[Choice] = []
        if(snapshotCpy.hasChild("cart"))
        {
            let cartRef = snapshotCpy.childSnapshot(forPath: "cart")
            
            let cartDic = cartRef.value as? Dictionary<String,String>
            if(cartDic != nil)
            {
                for items in cartDic! {
                    let choiceTitle:String = items.key
                    let val:String  = String(items.value)
                    let choiceParts : [String] = val.components(separatedBy: ":")
                    cart.append(Choice(displayTitle: choiceTitle, quantity: Int(choiceParts[1])!, cost: Float(choiceParts[0])!)!)
                }
            }
        }
        
        /*var cart:Dictionary<String,Int> = [:]
        let cartDic = snapshot["cart"] as? Dictionary<String,Int>
        if (cartDic != nil)
        {
            for items in cartDic! {
                let key=items.key
                let val = items.value
                cart[key] = val
            }
        }
        else
        {
            let cartArr = snapshot["cart"] as? NSArray as? [Int?]
            var counter:Int = 0
            if (cartArr != nil)
            {
                for val in cartArr!
                {
                    if(val != nil)
                    {
                        cart[String(counter)] = val!
                    }
                    counter = counter+1
                }
            }
        }*/
        
        //cost
        let subTotal = snapshot["subTotal"] as? Float
        let tax = snapshot["tax"] as? Float
        let convenienceFee = snapshot["convenienceFee"] as? Float
        let discount = snapshot["discount"] as? Float
        let orderTotal = snapshot["orderTotal"] as? Float
        
        let selectedPaymentID = snapshot["source"] as? String
        //payment source and address
        let selectedPayment:PaymentSource? = User.getPaymentSourceForID(id: selectedPaymentID!)
        
        self.init(id: id!, orderDate: orderDate ?? "", deliveryDate: deliveryDate ?? "", orderRating: orderRating ?? -1, status: status ?? "New", cart: cart, subTotal: subTotal!, tax: tax!, convenienceFee: convenienceFee!, discount: discount!, orderTotal: orderTotal!, source: selectedPayment, kitchenId: kitchenId!)
    }
 
    func processResponse(snapshot: DataSnapshot) -> String
    {
        guard
            let value = snapshot.value as? AnyObject
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
