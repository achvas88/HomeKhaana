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
    private var rootViewController: UIViewController?
    
    struct cartNoticePeriod
    {
        var differentNoticePeriodsInCart: Bool
        var maxNoticePeriod: Int
    }
    
    override init()
    {
        super.init()
    }
    
    public func setRootViewController(rootViewController: UIViewController) -> Void
    {
        self.rootViewController = rootViewController
    }
    
    public func isCartEmpty() -> Bool
    {
        return self.cart.count==0
    }
    
    public func updateCartBadge()//vc: UIViewController)
    {
        if(self.cart.count == 0)
        {
            (self.rootViewController as? UITabBarController)?.tabBar.items?[1].badgeValue = nil
        }
        else
        {
            (self.rootViewController as? UITabBarController)?.tabBar.items?[1].badgeValue = String(self.cart.count)
        }
    }
    
    public func updateCart(quantity: Int, choice: Choice, vc: UIViewController, isAddingNew: Bool, completion: @escaping () -> ())
    {
        if(quantity == 0) //we are removing an item from the cart.
        {
            removeItemFromCart(choiceToRemove: choice)
            self.updateCartBadge()
            completion()
        }
        else    //We are updating cart
        {
            if(self.cart.count == 0) {                  //if cart is empty, simply add to it.
                self.kitchenId = choice.kitchenId
                choice.quantity = quantity
                self.cart.append(choice)
                self.updateCartBadge()
                completion()
            }
            else    // cart contains something.
            {
                let choiceInCart:Choice? = cartContainsChoice(choiceToFind: choice)
                if(choiceInCart != nil) // if the cart already contains the choice, then update the quantity
                {
                    if(isAddingNew) //if adding a new item.
                    {
                        choiceInCart!.quantity = choiceInCart!.quantity! + quantity
                    }
                    else    // if updating an item already in the cart (Update button visible)
                    {
                        choiceInCart!.quantity = quantity
                    }
                    self.updateCartBadge()
                    completion()
                }
                else    //cart doesnt contain the choice
                {
                    choice.quantity = quantity
                    if(choice.kitchenId == self.kitchenId)  // if the kitchen id is the same as the choice's kitchen, then we can add it to the cart
                    {
                        let cartNoticePeriodInfo:cartNoticePeriod = cartItemsNoticePeriodsInfo(choice: choice)
                        if(cartNoticePeriodInfo.differentNoticePeriodsInCart)
                        {
                            showWarningAboutDifferingNoticeDays(highestNoticeDay: cartNoticePeriodInfo.maxNoticePeriod, choice: choice, vc: vc, completion: completion)
                        }
                        else
                        {
                            self.cart.append(choice)
                            self.updateCartBadge()
                            completion()
                        }
                    }
                    else    // the kitchen id is different, so ask to replace the cart with the new choice
                    {
                        shouldEraseCartAndReplaceWithChoice(choice: choice, vc: vc, completion: completion)
                    }
                }
            }
        }
    }
    
    private func cartItemsNoticePeriodsInfo(choice: Choice) -> cartNoticePeriod
    {
        var ret:cartNoticePeriod = cartNoticePeriod(differentNoticePeriodsInCart: false, maxNoticePeriod: -1);
        var currentNoticeDays = -1
        self.cart.append(choice)
        for choice in self.cart
        {
            let choiceNoticeDays: Int = choice.noticeDays ?? 0
            if(ret.maxNoticePeriod < choiceNoticeDays) { ret.maxNoticePeriod = choiceNoticeDays }
            
            if(currentNoticeDays == -1)
            {
                currentNoticeDays = choiceNoticeDays
                continue
            }
            
            if(choiceNoticeDays != currentNoticeDays)
            {
                ret.differentNoticePeriodsInCart = true
            }
        }
        self.cart.remove(object: choice)
        return ret
    }
    
    public func clearCart() -> Void
    {
        self.cart.removeAll()
        self.kitchenId = ""
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
            self.updateCartBadge()
            completion()
        })
        alertController.addAction(alertAction)
        alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            completion()
        })
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true)
    }
    
    private func showWarningAboutDifferingNoticeDays(highestNoticeDay: Int, choice: Choice, vc: UIViewController, completion: @escaping () -> ())
    {
        let alertController = UIAlertController(title: "Cart contains items with different pickup dates",
                                                message: "Do you wish to pick up the entire order \(highestNoticeDay) day(s) from now?",
                                                preferredStyle: .alert)
        var alertAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.cart.append(choice)
            self.updateCartBadge()
            completion()
        })
        alertController.addAction(alertAction)
        alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            completion()
        })
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true)
    }
}
