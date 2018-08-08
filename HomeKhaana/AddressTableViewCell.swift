//
//  AddressTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/5/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblAddresss: UILabel!
    
    var address:Address? {
        didSet {
            guard let address = address else { return }
            
            lblLocation.text = address.title
            lblAddresss.text = address.address
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
