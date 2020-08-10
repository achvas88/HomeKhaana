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
    
    override func layoutSubviews() {
        
        let path = UIBezierPath(roundedRect:self.imgRepresentation.bounds,
                                byRoundingCorners:[.bottomRight, .bottomLeft],
                                cornerRadii: CGSize(width: 6, height:  6))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.imgRepresentation.layer.mask = maskLayer
        
        
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3);
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).cgColor
    }
}

/*
1       2       3          4
H       HH
T       TT
N       NN
        HT
        HN
        NT
        NH
        TN
        TH

 A
 s1 E1 D1
 s2 E2
    e3
 
 9*9          4
 
 
 As1e1
 As1e2
 As2e1
 As2e2
 
 Bs1e1
 Bs1e2
 Bs2e1
 bs2e2
 
 Cs1e1
 Cs1e2
 cs2e1
 cs2e2
 
 */
