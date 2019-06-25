//
//  EmptyOrderTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/25/19.
//  Copyright © 2019 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class EmptyOrderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var subText: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
