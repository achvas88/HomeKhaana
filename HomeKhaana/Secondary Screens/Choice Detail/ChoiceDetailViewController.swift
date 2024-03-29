//
//  ChoiceDetailViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/30/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class ChoiceDetailViewController: UIViewController {

    var theChoice:Choice?
    var isAddingToCart:Bool = true
    var buttonCaption:String = "ADD TO CART"
    var comingFromHome:Bool = false
    
    @IBOutlet weak var imgRepresentation: UIImageView!
    @IBOutlet weak var lblDisplayTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var stkVegetarian: UIStackView!
    @IBOutlet weak var lblItems: UILabel!
    @IBOutlet weak var lblKitchen: UILabel!
    @IBOutlet weak var lblAdvanceNoticeWarning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isAddingToCart = true
        let quantity:Int? = theChoice?.quantity
        if(quantity != nil && quantity! != 0 && comingFromHome != true)
        {
            self.lblQuantity.text=String(quantity!)
            self.buttonCaption = "UPDATE CART"
            self.isAddingToCart = false
        }
        self.lblDisplayTitle.text = theChoice!.displayTitle
        self.lblItems.text = theChoice!.items
        self.lblDescription.text = theChoice!.description
        
        let kitchen:Kitchen = DataManager.kitchens[theChoice!.kitchenId]!
        self.lblKitchen.text = kitchen.name
        
        if(!theChoice!.isVegetarian) { stkVegetarian.isHidden = true }
        imgRepresentation.image = theChoice!.image
        setAddToCartTitle()
        
        if(theChoice!.needsAdvanceNotice)
        {
            lblAdvanceNoticeWarning.isHidden = false
            if(theChoice!.noticeDays == 1)
            {
            lblAdvanceNoticeWarning.text! = " Item requires advance notice of \(theChoice!.noticeDays!) day "
            }
            else
            {
                lblAdvanceNoticeWarning.text! = " Item requires advance notice of \(theChoice!.noticeDays!) days "
            }
        }
        else
        {
            lblAdvanceNoticeWarning.isHidden = true
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func btnMinusClicked(_ sender: Any) {
        var quantity:Int = Int(self.lblQuantity.text!)!
        if(self.isAddingToCart && quantity==1) { return }
        if(!self.isAddingToCart && quantity==0) { return }  // if updating cart, then allow removing item from the cart.
        quantity = quantity - 1
        self.lblQuantity.text=String(quantity)
        setAddToCartTitle()
    }
    
    @IBAction func btnPlusClicked(_ sender: Any) {
        var quantity:Int = Int(self.lblQuantity.text!)!
        if(quantity==5) {return}
        quantity = quantity+1
        self.lblQuantity.text=String(quantity)
        
        setAddToCartTitle()
    }
    
    @IBAction func btnAddToCartClicked(_ sender: Any) {
        let quantity:Int = Int(self.lblQuantity.text!)!
        Cart.sharedInstance.updateCart(quantity: quantity, choice: theChoice!, vc: self, isAddingNew: comingFromHome, completion:
            {
                self.dismiss(animated: true, completion: nil)
            }
        )
    }
    
    func setAddToCartTitle()
    {
        btnAddToCart.setTitle("\(self.buttonCaption)  -  $\(convertToCurrency(input:(theChoice!.cost * Float(lblQuantity.text!)!)))", for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
