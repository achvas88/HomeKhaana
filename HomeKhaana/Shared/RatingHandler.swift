//
//  RatingHandler.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/12/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase

class RatingHandler {
    var rating: Double
    var ratingThisSession: Int?
    var ratingCount: Int
    var isForKitchen: Bool
    var id: String //id of the user or the kitchen.
    
    public init(rating: Double, ratingCount: Int, isForKitchen: Bool,id: String) {
        self.rating = rating
        self.ratingCount = ratingCount
        self.isForKitchen = isForKitchen
        self.id = id
    }
    
    public func addRating(rating: Double)
    {
        if(self.rating == -1)
        {
            self.rating = rating
        }
        else
        {
            self.rating = limitToTwoDecimal(input: ((self.rating * Double(self.ratingCount) + rating)/Double(self.ratingCount + 1)))
        }
        
        self.ratingCount = self.ratingCount + 1
        self.ratingThisSession = Int(rating)
        
        //write it to the server
        writeRatingToServer()
    }
    
    private func writeRatingToServer()
    {
        var userRef: DatabaseReference
        if(self.isForKitchen)
        {
            userRef = db.child("Kitchens/\(self.id)")
        }
        else
        {
            userRef = db.child("Users/\(self.id)")
        }
        userRef.child("rating").setValue(self.rating)
        userRef.child("ratingCount").setValue(self.ratingCount)
    }
    
    public func updateRating(oldRating: Double, newRating:Double)
    {
        if(oldRating == newRating)  //do nothing if they are both the same
        {
            return
        }
        
        if(self.ratingCount == 1)   //if the oldRating was the first time the kitchen was rated ever, simply update to the new rating
        {
            self.rating = newRating
        }
        else
        {
            self.rating = limitToTwoDecimal(input: (((self.rating * Double(self.ratingCount)) - oldRating + newRating)/Double(self.ratingCount)))
        }
        
        self.ratingThisSession = Int(newRating)
        
        writeRatingToServer()
    }
}
