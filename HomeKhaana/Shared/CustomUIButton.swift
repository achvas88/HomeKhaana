//
//  CustomUIButton.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/18/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class CustomUIButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //set background
        self.backgroundColor = UIColor.clear
        
        //set border
        self.layer.borderWidth = 0.5
        let borderColor : UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        self.layer.borderColor = borderColor.cgColor
        //self.layer.cornerRadius = 3
        
        //set padding
        self.contentEdgeInsets = UIEdgeInsets(top: 10,left: 90,bottom: 10,right: 20)
        self.imageEdgeInsets = UIEdgeInsets(top: 0,left: -30,bottom: 0,right: 0)
        
        //set font
        //self.titleLabel?.font = UIFont(name: "Segoe UI", size: 8)
        self.titleLabel?.textAlignment = .left
        self.setTitleColor(UIColor.darkText, for: .normal)
        
        //height anchor
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
