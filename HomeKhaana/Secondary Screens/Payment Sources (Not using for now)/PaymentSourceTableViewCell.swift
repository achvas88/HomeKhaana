//
//  PaymentSourceTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/16/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class PaymentSourceTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCardBrand: UIImageView!
    @IBOutlet weak var lblCardNumber: UILabel!
    
    var paymentSource:PaymentSource? {
        didSet {
            guard let paymentSource = paymentSource else { return }
            
            imgCardBrand.image = paymentSource.cardImage
            lblCardNumber.text = "**** " + String(paymentSource.cardNumber)
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
