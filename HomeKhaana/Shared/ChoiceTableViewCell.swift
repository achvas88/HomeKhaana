//
//  ChoiceTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/24/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class ChoiceTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var lblDisplayTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgRepresentation: UIImageView!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var imgIsVegetarian: UIImageView!
    @IBOutlet weak var lblItems: UILabel!
    
    @IBOutlet weak var choiceOuterView: UIView!
    
    var choice: Choice? {
        didSet {
            guard let choice = choice else { return }
            
            lblDisplayTitle.text = choice.displayTitle
            lblDescription.text = choice.description
            lblCost.text = "$\(convertToCurrency(input:choice.cost))"
            if(choice.isVegetarian)
            {
                imgIsVegetarian.image = UIImage(named: "leaf")
            }
            else
            {
                imgIsVegetarian.image = nil
            }
            imgRepresentation.image = choice.image
            lblItems.text = choice.items
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
