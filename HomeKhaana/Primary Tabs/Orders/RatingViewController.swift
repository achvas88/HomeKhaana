//
//  RatingViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/6/19.
//  Copyright © 2019 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var stkRating: RatingControl!
    
    var currentOrder:Order?
    var currentUserRatingHandler:RatingHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        self.hideKeyboardWhenTappedAround()
        
        if(self.currentOrder != nil)    //rating an order/kitchen
        {
            if(self.currentOrder!.orderRating != nil && self.currentOrder!.orderRating != -1)
            {
                self.stkRating.rating = self.currentOrder!.orderRating!
            }
        }
//        else
//        {
//            if(self.currentUser!.ratingHandler.ratingThisSession != nil)
//            {
//                self.stkRating.rating = self.currentUser!.ratingHandler.ratingThisSession!
//            }
//        }
    }
    
    @IBAction func btnAcceptClicked(_ sender: Any) {
        if(self.stkRating!.rating == 0)
        {
            return
        }
        
        //if an end user (not a kitchen) is logged in, then set the rating for the kitchen
        if(self.currentOrder != nil)
        {
            let kitchenId = self.currentOrder!.kitchenId
            if(kitchenId != "")
            {
                //ensure that the newest ratings are obtained from the server
                db.child("KitchenRatings").child(kitchenId).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let kitchenRatings = snapshot.value as? NSDictionary
                    let rating = kitchenRatings?["rating"] as? Double
                    let ratingCount = kitchenRatings?["ratingCount"] as? Int
                    let ratingHandlerForKitchen = RatingHandler(rating: rating ?? -1, ratingCount: ratingCount ?? 0, isForKitchen: true, id: kitchenId)
                    
                    if(self.currentOrder!.orderRating != nil && self.currentOrder!.orderRating != -1)
                    {
                        ratingHandlerForKitchen.updateRating(oldRating: Double(self.currentOrder!.orderRating!), newRating: Double(self.stkRating!.rating)) //there may be a chance that the rating has not been updated yet from the previous save. This is going to be rare enough that I am ignoring this for now.
                    }
                    else
                    {
                        ratingHandlerForKitchen.addRating(rating: Double(self.stkRating!.rating))
                    }
                    self.currentOrder!.setRating(rating: self.stkRating!.rating)
                    self.performSegue(withIdentifier: "returnAfterRating", sender: self)
                });
            }
        }
        else if(self.currentUserRatingHandler != nil)  //if a kitchen is logged in, set the rating for the user.
        {
            self.currentUserRatingHandler!.addRating(rating: Double(stkRating!.rating))
            self.dismiss(animated: true, completion: nil)
        }
    }
}
