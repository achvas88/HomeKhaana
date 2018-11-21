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
    
    var choice: Choice? {
        didSet {
            guard let choice = choice else { return }
            
            self.lblDisplayTitle?.text = choice.displayTitle
            self.lblCost?.text = "$\(convertToCurrency(input: (choice.cost * Float(choice.quantity!))))"
            self.lblQuantity?.text = String(choice.quantity!)
        }
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
