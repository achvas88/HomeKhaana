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
    var currentUser:User?
    
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
        else
        {
            if(self.currentUser!.ratingThisSession != nil)
            {
                self.stkRating.rating = self.currentUser!.ratingThisSession!
            }
        }
    }
    
    @IBAction func btnAcceptClicked(_ sender: Any) {
        if(self.stkRating!.rating == 0)
        {
            return
        }
        
        //if and end user (not a kitchen is logged in, then set the rating for the kitchen
        if(self.currentOrder != nil)
        {
            let kitchenId = self.currentOrder!.kitchenId
            let kitchen:Kitchen? = DataManager.kitchens[kitchenId]
            if(kitchen != nil)
            {
                if(self.currentOrder!.orderRating != nil && self.currentOrder!.orderRating != -1)
                {
                    kitchen!.updateRating(oldRating: Float(self.currentOrder!.orderRating!), newRating: Float(stkRating!.rating))
                }
                else
                {
                    kitchen!.addRating(rating: Float(stkRating!.rating))
                }
            }
            self.currentOrder!.setRating(rating: stkRating!.rating)
            self.performSegue(withIdentifier: "returnAfterRating", sender: self)
        }
        else if(self.currentUser != nil)  //if a kitchen is logged in, set the rating for the user.
        {
            if(self.currentUser!.ratingThisSession != nil)
            {
                self.currentUser!.updateRating(oldRating: Float(self.currentUser!.ratingThisSession!), newRating: Float(self.stkRating!.rating))
            }
            else
            {
                self.currentUser!.addRating(rating: Float(stkRating!.rating))
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
