//
//  DeliveryTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 9/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol CurrentOrderActionsDelegate{
    func markAsReadyforPickupClicked(at index:IndexPath)
    func markAsCompletedClicked(at index:IndexPath)
    func btnCartLinkClicked(at index:IndexPath)
}

class CurrentOrdersTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCustomer: UILabel!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblOrderTime: UILabel!
    @IBOutlet weak var lblWhat: UIButton!
    @IBOutlet weak var orderOuterView: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnMarkAsReady: UIButton!
    @IBOutlet weak var btnMarkAsCompleted: UIButton!
    
    var indexPath: IndexPath?
    var delegate:CurrentOrderActionsDelegate?
    
    var order:Order? {
        didSet {
            guard let order = order else { return }
            
            //cart link title
            let choice:Choice = Cart.sharedInstance.cart[0]
            var cartLinkTitle:String = choice.displayTitle //+ " (\(order.cart.values.first!))"
            let totalInCart = order.cart.count - 1
            if(totalInCart>0)
            {
                cartLinkTitle = cartLinkTitle + ", \(totalInCart) other"
            }
            self.lblWhat.setTitle(cartLinkTitle, for: .normal)
            
            //others
            lblOrderID.text = String(self.order!.id)
            lblOrderTime.text = self.order!.orderDate
            lblStatus.text = self.order!.status
            if(self.order!.status == "Ready for Pick-Up")
            {
                self.btnMarkAsCompleted.isHidden = false
                self.btnMarkAsReady.isHidden = true
            }
            else
            {
                self.btnMarkAsCompleted.isHidden = true
                self.btnMarkAsReady.isHidden = false
            }
            self.lblCustomer.text = self.order!.orderingUserName
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
    
    @IBAction func btnMarkAsReadyForPickupClicked(_ sender: Any) {
        self.delegate?.markAsReadyforPickupClicked(at: self.indexPath!)
    }
    
    @IBAction func btnMarkAsCompletedClicked(_ sender: Any) {
        self.delegate?.markAsCompletedClicked(at: self.indexPath!)
    }
    
    @IBAction func btnCartLinkClicked(_ sender: Any) {
        self.delegate?.btnCartLinkClicked(at: self.indexPath!)
    }
    
    override func layoutSubviews() {
        self.selectionStyle = .none
        orderOuterView.layer.cornerRadius = 6
        orderOuterView.layer.masksToBounds = false
        orderOuterView.layer.shadowColor = UIColor.lightGray.cgColor
        orderOuterView.layer.shadowOffset = CGSize(width: 3, height: 3);
        orderOuterView.layer.shadowOpacity = 0.2
        orderOuterView.layer.borderWidth = 1.0
        orderOuterView.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).cgColor
    }
}
