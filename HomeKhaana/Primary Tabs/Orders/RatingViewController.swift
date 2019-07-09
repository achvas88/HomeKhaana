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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        
        if(self.currentOrder!.orderRating != nil && self.currentOrder!.orderRating != -1)
        {
            self.stkRating.rating = self.currentOrder!.orderRating!
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func btnAcceptClicked(_ sender: Any) {
        if(self.stkRating!.rating == 0)
        {
            return
        }
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
}
