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
    
    @IBOutlet weak var choiceOuterView: UIView!
    
    var choice: Choice? {
        didSet {
            guard let choice = choice else { return }
            
            lblDisplayTitle.text = choice.displayTitle
            lblDescription.text = choice.description
            lblCost.text = "\(choice.currency)\(convertToCurrency(input:choice.cost))"
            if(choice.isVegetarian) { imgIsVegetarian.image = UIImage(named: "leaf") }
            imgRepresentation.image = UIImage(named: choice.imgName)
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

        let path = UIBezierPath(roundedRect:self.imgRepresentation.bounds,
                                byRoundingCorners:[.bottomLeft,.topRight],
                                cornerRadii: CGSize(width: 6, height:  6))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.imgRepresentation.layer.mask = maskLayer
        
        choiceOuterView.layer.cornerRadius = 6
        choiceOuterView.layer.masksToBounds = false
        choiceOuterView.layer.shadowColor = UIColor.lightGray.cgColor
        choiceOuterView.layer.shadowOffset = CGSize(width: 3, height: 3);
        choiceOuterView.layer.shadowOpacity = 0.2
        choiceOuterView.layer.borderWidth = 1.0
        choiceOuterView.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).cgColor
    }
}
