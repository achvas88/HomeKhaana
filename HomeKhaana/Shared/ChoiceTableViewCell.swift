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
            lblDisplayTitle.text = choice.displayTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        
       let path = UIBezierPath(roundedRect:self.imgRepresentation.bounds,
                                byRoundingCorners:[.bottomLeft],
                                cornerRadii: CGSize(width: 6, height:  6))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.imgRepresentation.layer.mask = maskLayer
        
        
        self.choiceOuterView.layer.cornerRadius = 6
        self.choiceOuterView.layer.masksToBounds = true
        self.choiceOuterView.layer.shadowColor = UIColor.systemGray.cgColor
        self.choiceOuterView.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.choiceOuterView.layer.shadowOpacity = 0.2
        self.choiceOuterView.layer.borderWidth = 1.0
         
        if #available(iOS 13.0, *) {
            self.choiceOuterView.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            self.choiceOuterView.layer.borderColor = UIColor.systemGray.cgColor
        }
        
    }
}
