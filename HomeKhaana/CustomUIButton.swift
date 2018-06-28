//
//  CustomUIButton.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/18/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class CustomUIButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
        self.contentEdgeInsets = UIEdgeInsetsMake(10,90,10,20)
        self.imageEdgeInsets = UIEdgeInsetsMake(0,-40,0,0)
        
        //set font
        //self.titleLabel?.font = UIFont(name: "Segoe UI", size: 8)
        self.titleLabel?.textAlignment = .left
        self.setTitleColor(UIColor.darkText, for: .normal)
        
        //set image
        /*guard let image = UIImage(named: "right-arrow")?.withRenderingMode(.alwaysOriginal) else
        {
            return
        }
        self.imageView?.contentMode = .center
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsetsMake(0, self.bounds.size.width-image.size.width*1.5, 0, 0);*/
    }
}
