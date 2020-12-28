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
    @IBOutlet weak var lblAdvanceNotice: UILabel!
    
    var choice: Choice? {
        didSet {
            guard let choice = choice else { return }
            
            lblDisplayTitle.text = choice.displayTitle
            lblCost.text = "$\(convertToCurrency(input:choice.cost))"
            imgRepresentation.image = choice.image
            if(choice.needsAdvanceNotice)
            {
                lblAdvanceNotice.isHidden = false
                if(choice.noticeDays == 1)
                {
                    lblAdvanceNotice.text! = " Needs \(choice.noticeDays!) day notice "
                }
                else
                {
                    lblAdvanceNotice.text! = " Needs \(choice.noticeDays!) days notice "
                }
            }
            else
            {
                lblAdvanceNotice.isHidden = true
            }
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
        self.layer.shadowColor = UIColor.systemGray.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3);
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 1.0
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            self.layer.borderColor = UIColor.systemGray.cgColor
        }
    }
}
