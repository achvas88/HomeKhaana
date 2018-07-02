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
    
    @IBOutlet weak var imgRepresentation: UIImageView!
    @IBOutlet weak var lblDisplayTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var stkVegetarian: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupButtons()
        
        self.lblDisplayTitle.text = theChoice!.displayTitle
        self.lblDescription.text = theChoice!.description
        if(!theChoice!.isVegetarian) { stkVegetarian.isHidden = true }
        imgRepresentation.image = UIImage(named: theChoice!.imgName)
        setAddToCartTitle()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnMinusClicked(_ sender: Any) {
        var quantity:Int = Int(self.lblQuantity.text!)!
        if(quantity==1) { return}
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
        DataManager.addToCart(choiceID: theChoice!.id, quantity: Int(lblQuantity.text!)!)
        
        self.dismiss(animated: true
            , completion: nil)
    }
    
    func setAddToCartTitle()
    {
        btnAddToCart.setTitle("Add to Cart  -  \(theChoice!.cost * Float(lblQuantity.text!)!)\(theChoice!.currency)", for: .normal)
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
