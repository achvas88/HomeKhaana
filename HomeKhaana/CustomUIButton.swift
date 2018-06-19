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
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.clear
        
        let borderColor : UIColor = UIColor(red: 0/255, green: 109/255, blue: 240/255, alpha: 1.0)
        
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = 3
        self.contentEdgeInsets = UIEdgeInsetsMake(10,0,10,0)
        
        guard let image = UIImage(named: "right-arrow")?.withRenderingMode(.alwaysOriginal) else
        {
            return
        }
        
        self.imageView?.contentMode = .scaleAspectFit
        
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsetsMake(0, self.bounds.size.width-image.size.width*1.5, 0, 0);
    }

}
