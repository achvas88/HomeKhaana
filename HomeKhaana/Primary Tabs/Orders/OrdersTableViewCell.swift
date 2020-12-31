//
//  OrdersTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/19/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

// TODO: need to update this.
class OrdersTableViewCell: UITableViewCell {

    @IBOutlet weak var imgOrder: UIImageView!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var btnCartLink: UIButton!
    @IBOutlet weak var orderOuterView: UIView!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stkRating: RatingControl!
    @IBOutlet weak var lblPickupTime: UILabel!
    
    
    var order:Order? {
        didSet {
            guard let order = order else { return }
            
            //ratings related
            stkRating.isHidden = true
            stkRating.isUserInteractionEnabled = false
            if(order.status == "Completed")
            {
                // if not already rated
                if(order.orderRating == nil || order.orderRating == -1)
                {
                    // do nothing
                }
                else
                {
                    stkRating.rating = order.orderRating!
                    stkRating.isHidden = false
                }
            }
            
            if(order.status != "Ordered" && order.status != "Ready for Pick-Up")
            {
                imgHeightConstraint.constant = 0
            }
            else
            {
                imgHeightConstraint.constant = 0 // 120 -- always hide the image for now.
            }
            
            //order image
            let choice:Choice = order.cart[0]
            
            //let kitchen:Kitchen? = DataManager.kitchens[order.kitchenId]
            //self.imgOrder.image = kitchen?.image

            //cart link title
            var cartLinkTitle:String = choice.displayTitle
            let totalInCart = order.cart.count - 1
            if(totalInCart>0)
            {
                cartLinkTitle = cartLinkTitle + ", \(totalInCart) other"
            }
            self.btnCartLink.setTitle(cartLinkTitle, for: .normal)
            
            //others
            lblOrderDate.text = self.order!.getOrderDateString()
            lblDueDate.text = self.order!.getDueDateString()
            if(self.order!.pickupTime != nil && self.order!.pickupTime!.count > 0)
            {
                lblPickupTime.text! = self.order!.pickupTime!
            }
            else
            {
                lblPickupTime.text! = "Not yet confirmed"
            }
            lblStatus.text = self.order!.status
            lblWhere.text = DataManager.kitchens[self.order!.kitchenId]?.name
            
            lblTotal.text = "$\(convertToCurrency(input: self.order!.orderTotal))"
            
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
        
        if(self.order!.status == "Completed")
        {
            if #available(iOS 13.0, *) {
                lblStatus.textColor = UIColor.secondaryLabel
            } else {
                lblStatus.textColor = UIColor.systemGray
            }
        }
        else
        {
            lblStatus.textColor = UIColor.systemOrange
        }

        self.selectionStyle = .none
        
        //let path = UIBezierPath(roundedRect:self.imgOrder.bounds,
        //                        byRoundingCorners:[.topRight, .topLeft],
        //                        cornerRadii: CGSize(width: 6, height:  6))
        
        //let maskLayer = CAShapeLayer()
        //maskLayer.path = path.cgPath
        //self.imgOrder.layer.mask = maskLayer
        
        orderOuterView.layer.cornerRadius = 6
        orderOuterView.layer.masksToBounds = false
        orderOuterView.layer.shadowColor = UIColor.systemGray.cgColor
        orderOuterView.layer.shadowOffset = CGSize(width: 3, height: 3);
        orderOuterView.layer.shadowOpacity = 0.2
        orderOuterView.layer.borderWidth = 1.0
        if #available(iOS 13.0, *) {
            orderOuterView.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            orderOuterView.layer.borderColor = UIColor.systemGray.cgColor
        }
    }
}
