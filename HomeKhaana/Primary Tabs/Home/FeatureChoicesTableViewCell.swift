//
//  FeatureChoicesTableViewCell.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/8/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class FeatureChoicesTableViewCell: UITableViewCell {

    @IBOutlet weak var featuredChoicesCollection: UICollectionView!
    
    var collectionViewOffset: CGFloat {
        get {
            return featuredChoicesCollection.contentOffset.x
        }
        
        set {
            featuredChoicesCollection.contentOffset.x = newValue
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

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate) {
        featuredChoicesCollection.delegate = dataSourceDelegate
        featuredChoicesCollection.dataSource = dataSourceDelegate
        featuredChoicesCollection.reloadData()
    }
}
