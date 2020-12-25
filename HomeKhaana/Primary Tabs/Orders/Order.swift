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
    var id:String
    var orderDate:String
    var dueDate: String
    var orderRating:Int?
    var status:String
    var orderingUserID:String
    var orderingUserName:String
    var kitchenId: String
    var timestamp: Int64
    var customInstructions: String?
    var noticeDays: Int
    
    //order items
    var cart:[Choice]
    
    //cost
    var subTotal:Float
    var tax:Float
    var discount:Float
    var orderTotal:Float
    
    //payment source and address
    var selectedPayment:PaymentSource?
    
    var dictionary: Dictionary<String, Any> {
        return [
            "id": id,
            "orderDate": self.orderDate,
            "dueDate": self.dueDate,
            "orderRating": orderRating ?? -1,
            "subTotal": subTotal,
            "tax": tax,
            "discount": discount,
            "orderTotal": orderTotal,
            "source": self.selectedPayment?.id ?? "",
            "amount": Int(floor(self.orderTotal*100)),
            "status": self.status,
            "orderingUserID": self.orderingUserID,  //these values are used in delivery workflows
            "orderingUserName": self.orderingUserName, // these values are used in delivery workflows
            "kitchenId": self.kitchenId,
            "timestamp": self.timestamp,
            "cart": getCartDetails(),
            "instructions": customInstructions ?? "",
            "noticeDays": self.noticeDays
        ]
    }
    
    public init()
    {
        self.id=""
        self.status = "New"
        self.orderDate = ""
        self.dueDate = ""
        self.cart = []
        self.orderRating = -1
        self.subTotal = 0
        self.tax = 0
        self.discount = 0
        self.orderTotal = 0
        self.orderingUserName = User.sharedInstance!.name   // this function will be called from non-kitchen workflows. so, directly using the User variable is fine.
        self.orderingUserID = User.sharedInstance!.id
        self.kitchenId = ""
        self.timestamp = -1
        self.noticeDays = 0
    }
    
    public init(id: String, orderDate: String, dueDate: String, orderRating: Int?, status: String, cart: [Choice], subTotal: Float, tax: Float, discount: Float, orderTotal: Float, source: PaymentSource?, kitchenId: String, orderingUserId: String?, orderingUserName: String?, timestamp: Int64, instructions: String?, noticeDays: Int?)
    {
        self.id = id
        self.orderDate = orderDate
        self.dueDate = dueDate
        self.orderRating = orderRating
        self.status = status
        self.cart = cart
        self.subTotal = subTotal
        self.tax = tax
        self.discount = discount
        self.orderTotal = orderTotal
        self.selectedPayment = source
        self.orderingUserName = orderingUserName ?? User.sharedInstance!.name
        self.orderingUserID = orderingUserId ?? User.sharedInstance!.id
        self.kitchenId = kitchenId
        self.timestamp = timestamp
        self.customInstructions = instructions
        self.noticeDays = noticeDays ?? 0
    }
    
    public convenience init?(snapshot: DataSnapshot)
    {
        let snapshotCpy:DataSnapshot = snapshot
        let snapshot = snapshot.value as AnyObject
        
        //other meta-data
        let id = snapshot["id"] as? String
        let orderDate = snapshot["orderDate"] as? String
        let dueDate = snapshot["dueDate"] as? String
        let orderRating = snapshot["orderRating"] as? Int
        let status = snapshot["status"] as? String
        let kitchenId = snapshot["kitchenId"] as? String
        let orderingUserId = snapshot["orderingUserID"] as? String
        let orderingUserName = snapshot["orderingUserName"] as? String
        let timestamp = snapshot["timestamp"] as? Int64
        let customInstructions = snapshot["instructions"] as? String
        let noticeDays = snapshot["noticeDays"] as? Int
        
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
        
        //cost
        let subTotal = snapshot["subTotal"] as? Float
        let tax = snapshot["tax"] as? Float
        let discount = snapshot["discount"] as? Float
        let orderTotal = snapshot["orderTotal"] as? Float
        
        //let selectedPaymentID = snapshot["source"] as? String
        //payment source and address
        let selectedPayment:PaymentSource? = nil //User.getPaymentSourceForID(id: selectedPaymentID ?? "")
        
        self.init(id: id!, orderDate: orderDate ?? "", dueDate: dueDate ?? (orderDate ?? ""), orderRating: orderRating ?? -1, status: status ?? "New", cart: cart, subTotal: subTotal!, tax: tax!, discount: discount!, orderTotal: orderTotal!, source: selectedPayment, kitchenId: kitchenId!, orderingUserId: orderingUserId, orderingUserName: orderingUserName, timestamp: timestamp!, instructions: customInstructions, noticeDays: noticeDays ?? 0)
    }
 
    public func setRating(rating: Int)
    {
        self.orderRating = rating
        db.child("Orders/\(self.orderingUserID)/\(self.id)/\("orderRating")").setValue(rating)
    }
    
    public func populateDates() -> Void
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        let today = Date.init()
        self.orderDate = dateFormatter.string(from: today)
        let dueDate = Calendar.current.date(byAdding: .day, value: self.noticeDays, to: today)!
        self.dueDate = dateFormatter.string(from: dueDate)
        dateFormatter.timeStyle = .none
        //self.deliveryDate = dateFormatter.string(from: Date.init(timeInterval: TimeInterval.init(exactly: (24*60*60))!, since: Date.init()))
        
        self.timestamp = Date().getCurrentTimeStamp()
    }
    
    private func getCartDetails() -> Dictionary<String, String>
    {
        var retMap:Dictionary<String,String> = [:]
        for choice in self.cart
        {
            retMap[choice.displayTitle] = String(choice.cost) + ":" + String(choice.quantity!)
        }
        return retMap
    }
    
    /*func processResponse(snapshot: DataSnapshot) -> String
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
     }*/
}
