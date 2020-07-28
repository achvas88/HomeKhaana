//
//  KitchenTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 11/13/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import MapKit

class KitchenTableViewCell: UITableViewCell {

    @IBOutlet weak var kitchenImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var ratingCount: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var star: UIImageView!
    
    var kitchen: Kitchen? {
        didSet {
            guard let kitchen = kitchen else { return }
            
            kitchenImg.image = kitchen.image
            name.text = kitchen.name
            distance.text = kitchen.distanceFromLoggedInUser
            type.text = kitchen.type
            if(kitchen.ratingHandler.rating != -1)
            {
                rating.text = String(kitchen.ratingHandler.rating)
                ratingCount.text = "(" + String(kitchen.ratingHandler.ratingCount) + ")"
                rating.isHidden = false
                ratingCount.isHidden = false
                star.isHidden = false
            }
            else
            {
                rating.isHidden = true
                ratingCount.isHidden = true
                star.isHidden = true
            }
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

    
    override func layoutSubviews() {
        self.selectionStyle = .none
        
        let path = UIBezierPath(roundedRect:self.kitchenImg.bounds,
                                byRoundingCorners:[.bottomLeft,.topRight, .topLeft , .bottomRight],
                                cornerRadii: CGSize(width: 6, height:  6))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.kitchenImg.layer.mask = maskLayer
        
        //outerView.layer.cornerRadius = 6
        outerView.layer.masksToBounds = false
        outerView.layer.shadowColor = UIColor.lightGray.cgColor
        outerView.layer.shadowOffset = CGSize(width: 3, height: 3);
        outerView.layer.shadowOpacity = 0.1
        outerView.layer.borderWidth = 0.5
        outerView.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).cgColor
    }
    
}
