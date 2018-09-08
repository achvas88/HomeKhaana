//
//  CartTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblDisplayTitle: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    
    var choice:Choice?
    var quantity: Int = 0
    
    func setupCell(id: String, quantity: Int) -> Void
    {
        self.choice = DataManager.getChoiceForId(id: Int(id)!)
        self.quantity = quantity
        self.lblDisplayTitle?.text = choice!.displayTitle
        self.lblCost?.text = "$\(convertToCurrency(input: (choice!.cost * Float(quantity))))"
        self.lblQuantity?.text = String(quantity)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
