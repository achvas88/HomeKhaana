//
//  DishCollectionViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/27/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class DishCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCollCell: UIImageView!
    @IBOutlet weak var lblCollCell: UILabel!
    
    var choice: Choice? {
        didSet {
            guard let choice = choice else { return }
            
            imgCollCell.image = choice.image
            lblCollCell.text = choice.displayTitle
        }
    }
    
    var kitchen: Kitchen? {
        didSet {
            guard let kitchen = kitchen else { return }
            
            imgCollCell.image = kitchen.image
            lblCollCell.text = kitchen.name
        }
    }
    
    override func layoutSubviews() {
        
        let path = UIBezierPath(roundedRect:self.imgCollCell.bounds,
                                byRoundingCorners:[.topRight, .topLeft],
                                cornerRadii: CGSize(width: 6, height:  6))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.imgCollCell.layer.mask = maskLayer
        
        
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3);
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).cgColor
    }
}
