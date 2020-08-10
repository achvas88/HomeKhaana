//
//  FeaturedChoiceCollectionViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/8/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class FeaturedChoiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgRepresentation: UIImageView!
    @IBOutlet weak var lblDisplayTitle: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    
    var choice: Choice? {
        didSet {
            guard let choice = choice else { return }
            
            lblDisplayTitle.text = choice.displayTitle
            lblCost.text = "$\(convertToCurrency(input:choice.cost))"
            imgRepresentation.image = choice.image
        }
    }
}
