//
//  CartViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class CartViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblConvenienceFee: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTax: UILabel!
    @IBOutlet weak var btnAddPayment: CustomUIButton!
    @IBOutlet weak var btnCheckout: UIButton!
    @IBOutlet weak var tblItems: UITableView!
    
    var inCart:Array<(key:Int, value:Int)> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupButtons()
        self.inCart = Array(DataManager.inCart)
        self.tblItems.dataSource = self
        //self.tblItems.delegate = self
        //self.tblItems.register(CartTableViewCell.self, forCellReuseIdentifier: "cartCell")
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        //tblItems.frame = CGRect(x: tblItems.frame.origin.x, y: tblItems.frame.origin.y, width: tblItems.frame.size.width, height: tblItems.contentSize.height)
        tblItems.heightAnchor.constraint(equalToConstant: tblItems.contentSize.height).isActive = true
        
    }
    
    override func viewDidLayoutSubviews() {
        //tblItems.frame = CGRect(x: tblItems.frame.origin.x, y: tblItems.frame.origin.y, width: tblItems.frame.size.width, height: tblItems.contentSize.height)
        tblItems.heightAnchor.constraint(equalToConstant: tblItems.contentSize.height).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons()
    {
        self.btnCheckout.backgroundColor = UIColor(red: 69/255, green: 191/255, blue: 34/255, alpha: 1.0)
        self.btnCheckout.setTitleColor(UIColor.white, for: .normal)
        
        self.tblItems.layer.borderWidth = 0.5
        let borderColor : UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        self.tblItems.layer.borderColor = borderColor.cgColor
        self.tblItems.layer.cornerRadius = 3
    }
    
    // Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inCart.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CartTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        
        // Configure the cell...
        setupCell(theCell:cell, id: self.inCart[indexPath.row].key, quantity: self.inCart[indexPath.row].value)
        
        return cell
    }
    
    func setupCell(theCell:CartTableViewCell, id: Int, quantity: Int) -> Void
    {
        let choice = DataManager.getChoiceForId(id: id)
        //self.quantity = quantity
        theCell.lblDisplayTitle.text = choice.displayTitle
        theCell.lblCost.text = "\(choice.cost * Float(quantity))\(choice.currency)"
        theCell.lblQuantity.text = String(quantity)
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
