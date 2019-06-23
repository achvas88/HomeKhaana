//
//  Cart.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 11/17/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import UIKit

class Cart: NSObject {
    
    public var kitchenId: String = ""
    public var cart:[Choice] = []
    static let sharedInstance = Cart()
    
    override init()
    {
        super.init()
    }
    
    public func isCartEmpty() -> Bool
    {
        return self.cart.count==0
    }
    
    public func updateCart(choice: Choice, vc: UIViewController, isAddingNew: Bool, completion: @escaping () -> ())    // TODO: TEST THIS
    {
        if(choice.quantity == nil || choice.quantity! == 0) //we are removing an item from the cart.
        {
            removeItemFromCart(choiceToRemove: choice)
            completion()
        }
        else    //We are updating cart
        {
            if(self.cart.count == 0) {                  //if cart is empty, simply add to it.
                self.kitchenId = choice.kitchenId
                self.cart.append(choice)
                completion()
            }
            else    // cart contains something.
            {
                let choiceInCart:Choice? = cartContainsChoice(choiceToFind: choice)
                if(choiceInCart != nil) // if the cart already contains the choice, then update the quantity
                {
                    if(isAddingNew) //if adding a new item.
                    {
                    choiceInCart!.quantity = choiceInCart!.quantity! + choice.quantity!
                    }
                    else    // if updating an item already in the cart (Update button visible)
                    {
                        choiceInCart!.quantity = choice.quantity!
                    }
                    completion()
                }
                else    //cart doesnt contain the choice
                {
                    if(choice.kitchenId == self.kitchenId)  // if the kitchen id is the same as the choice's kitchen, then we can add it to the cart
                    {
                        self.cart.append(choice)
                        completion()
                    }
                    else    // the kitchen id is different, so ask to replace the cart with the new choice
                    {
                        shouldEraseCartAndReplaceWithChoice(choice: choice, vc: vc, completion: completion)
                    }
                }
            }
        }
    }
    
    private func cartContainsChoice(choiceToFind: Choice) -> Choice?
    {
        for choice in self.cart
        {
            if(choice.id == choiceToFind.id)
            {
                return choice
            }
        }
        return nil
    }
    
    private func removeItemFromCart(choiceToRemove: Choice) -> Void
    {
        for (choiceIndex,choice) in self.cart.enumerated()
        {
            if(choice.id == choiceToRemove.id)
            {
                self.cart.remove(at: choiceIndex)
                return
            }
        }
    }
    
    private func shouldEraseCartAndReplaceWithChoice(choice: Choice, vc: UIViewController, completion: @escaping () -> ())
    {
        let alertController = UIAlertController(title: "Cart contains items from a different kitchen",
                                                message: "Do you wish to clear the cart and then add the current item?",
                                                preferredStyle: .alert)
        var alertAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.clearCart()
            self.cart.append(choice)
            self.kitchenId = choice.kitchenId
            completion()
        })
        alertController.addAction(alertAction)
        alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            completion()
        })
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true)
    }
    
    public func clearCart() -> Void
    {
        self.cart.removeAll()
        self.kitchenId = ""
    }
}
