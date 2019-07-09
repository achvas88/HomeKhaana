//
//  KitchenHeaderTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/4/19.
//  Copyright © 2019 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class KitchenHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var kitchenImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var kitchen: Kitchen? {
        didSet {
            guard let kitchen = kitchen else { return }
            
            kitchenImg.image = kitchen.image
            name.text = kitchen.name
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
