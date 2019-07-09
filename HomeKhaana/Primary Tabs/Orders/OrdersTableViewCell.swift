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

    /*
     image
     order id,
     order status,
     order date,
     delivery address,
     order rating if status = Completed
     cart
     order total
     */
    @IBOutlet weak var imgOrder: UIImageView!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var btnCartLink: UIButton!
    @IBOutlet weak var orderOuterView: UIView!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stkRating: RatingControl!
    
    
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
                imgHeightConstraint.constant = 120
            }
            
            //order image
            let choice:Choice = order.cart[0]
            
            let kitchen:Kitchen? = DataManager.kitchens[order.kitchenId]
            self.imgOrder.image = kitchen?.image
            
            //self.imgOrder.image = UIImage(named: kitchen?.imgName ?? "shopping-cart (1)")
            
            //cart link title
            var cartLinkTitle:String = choice.displayTitle
            let totalInCart = order.cart.count - 1
            if(totalInCart>0)
            {
                cartLinkTitle = cartLinkTitle + ", \(totalInCart) other"
            }
            self.btnCartLink.setTitle(cartLinkTitle, for: .normal)
            
            //others
            lblOrderDate.text = self.order!.orderDate
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
            lblStatus.textColor = UIColor.darkGray
        }
        else
        {
            lblStatus.textColor = UIColor(red: 65, green: 117/255, blue: 79/255, alpha: 1)
        }

        self.selectionStyle = .none
        
        // just use the layer's shadow... adding the Bezier
        //let shadowPath = UIBezierPath(roundedRect: orderOuterView.bounds, cornerRadius: cornerRadius)
        //orderOuterView.layer.shadowPath = shadowPath.cgPath
        let path = UIBezierPath(roundedRect:self.imgOrder.bounds,
                                byRoundingCorners:[.topRight, .topLeft],
                                cornerRadii: CGSize(width: 6, height:  6))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.imgOrder.layer.mask = maskLayer
        
        if (self.order?.status != "Ordered" && self.order?.status != "Ready for Pick-Up")
        {
            orderOuterView.layer.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1).cgColor
        }
        else
        {
            orderOuterView.layer.backgroundColor = UIColor.white.cgColor
        }
        orderOuterView.layer.cornerRadius = 6
        orderOuterView.layer.masksToBounds = false
        orderOuterView.layer.shadowColor = UIColor.lightGray.cgColor
        orderOuterView.layer.shadowOffset = CGSize(width: 3, height: 3);
        orderOuterView.layer.shadowOpacity = 0.2
        orderOuterView.layer.borderWidth = 1.0
        orderOuterView.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).cgColor
    }
}
