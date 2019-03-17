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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupButtons()
        
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
        //DataManager.updateCart(choiceID: theChoice!.id, quantity: Int(lblQuantity.text!)!)
        let quantity:Int = Int(self.lblQuantity.text!)!
        theChoice!.quantity = quantity
        Cart.sharedInstance.updateCart(choice: theChoice!, vc: self, completion:
            {
                self.dismiss(animated: true, completion: nil)
            }
        )
    }
    
    func setAddToCartTitle()
    {
        btnAddToCart.setTitle("\(self.buttonCaption)  -  $\(convertToCurrency(input:(theChoice!.cost * Float(lblQuantity.text!)!)))", for: .normal)
    }
    
    func setupButtons()
    {
        self.btnAddToCart.backgroundColor = UIColor(red: 69/255, green: 191/255, blue: 34/255, alpha: 1.0)
        self.btnAddToCart.setTitleColor(UIColor.white, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
