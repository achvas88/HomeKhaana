//
//  DeliveryTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 9/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol MarkAsDeliveredDelegate{
    func markAsDeliveredClicked(at index:IndexPath)
    func btnCartLinkClicked(at index:IndexPath)
}

class DeliveryTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCustomer: UILabel!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblOrderTime: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblWhen: UILabel!
    @IBOutlet weak var lblWhat: UIButton!
    @IBOutlet weak var orderOuterView: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    
    var indexPath: IndexPath?
    var delegate:MarkAsDeliveredDelegate?
    
    var order:Order? {
        didSet {
            guard let order = order else { return }
            
            //cart link title
            let choice:Choice = DataManager.getChoiceForId(id: Int(order.cart.keys.first!)!)
            var cartLinkTitle:String = choice.displayTitle + " (\(order.cart.values.first!))"
            let totalInCart = order.cart.keys.count - 1
            if(totalInCart>0)
            {
                cartLinkTitle = cartLinkTitle + ", \(totalInCart) other"
            }
            self.lblWhat.setTitle(cartLinkTitle, for: .normal)
            
            //others
            lblOrderID.text = String(self.order!.id)
            lblOrderTime.text = self.order!.orderDate
            lblWhere.text = self.order!.selectedAddress?.address
            if(self.order!.status != "Delivered")
            {
                lblWhen.text = "11-12PM, " + self.order!.deliveryDate
            }
            else
            {
                lblWhen.text = self.order!.deliveryDate
            }
            lblStatus.text = self.order!.status
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
    
    @IBAction func btnMarkAsDeliveredClicked(_ sender: Any) {
        self.delegate?.markAsDeliveredClicked(at: self.indexPath!)
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
