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
    
    var kitchen: Kitchen? {
        didSet {
            guard let kitchen = kitchen else { return }
            
            kitchenImg.image = kitchen.image
            name.text = kitchen.name
            self.distanceBetweenPoints(location1: User.sharedInstance!.userLocation.coordinate, location2: kitchen.kitchenLocation.coordinate)
            type.text = kitchen.type
            rating.text = String(kitchen.rating.floatValue)
            ratingCount.text = "(" + String(kitchen.ratingCount.intValue) + ")"
        }
    }
    
    func distanceBetweenPoints(location1: CLLocationCoordinate2D, location2:CLLocationCoordinate2D)
    {
        let mapItemLoc1 = MKMapItem(placemark: MKPlacemark(coordinate: location1))
        let mapItemLoc2 = MKMapItem(placemark: MKPlacemark(coordinate: location2))
        
        let req = MKDirections.Request()
        req.source = mapItemLoc1
        req.destination = mapItemLoc2
        let dir = MKDirections(request:req)
        dir.calculate { response, error in
            guard let response = response else {
                // if error in route calculation, just print out direct distance.
                let distance:CLLocationDistance = User.sharedInstance!.userLocation.distance(from: self.kitchen!.kitchenLocation)
                let distanceInMiles:Double = distance * 0.62137 / 1000
                let distanceStr = NSString(format: "~ %.1f mi", distanceInMiles)
                self.distance.text = distanceStr as String
                return
            }
            let route:MKRoute = response.routes[0] // I'm feeling insanely lucky
            let distance = route.distance
            let distanceInMiles:Double = distance * 0.62137 / 1000
            let distanceStr = NSString(format: "%.2f mi", distanceInMiles)
            self.distance.text = distanceStr as String
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
        
        outerView.layer.cornerRadius = 6
        outerView.layer.masksToBounds = false
        outerView.layer.shadowColor = UIColor.lightGray.cgColor
        outerView.layer.shadowOffset = CGSize(width: 3, height: 3);
        outerView.layer.shadowOpacity = 0.2
        outerView.layer.borderWidth = 1.0
        outerView.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).cgColor
    }
    
}
