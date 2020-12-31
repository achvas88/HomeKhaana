//
//  KitchensTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 11/13/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class KitchensTableViewController: UITableViewController,RefreshTableViewWhenImgLoadsDelegate {
    
    var kitchens:[Kitchen] = []
    var yourKitchens: [Kitchen] = []
    var yourKitchensStoredOffset: CGFloat = 0.0
    var popularKitchensStoredOffset: CGFloat = 0.0
    var popularKitchens: [Kitchen] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    func setupNavigationBar()
    {
        // Create a navView to add to the navigation bar
        let navView = UIView()

        // Create the label
        let label = UILabel()
        label.text = "Home Khaana"
        label.font = UIFont(name: "Noteworthy Light", size: 19)!
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center

        // Create the image view
        let image = UIImageView()
        image.image = UIImage(named: "vegetables.png")
        // To maintain the image's aspect ratio:
        let imageAspect = image.image!.size.width/image.image!.size.height
        // Setting the image frame so that it's immediately before the text:
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect - 5, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIView.ContentMode.scaleAspectFit

        // Add both the label and image view to the navView
        navView.addSubview(label)
        navView.addSubview(image)

        // Set the navigation bar's navigation item's titleView to the navView
        self.navigationItem.titleView = navView

        // Set the navView's frame to fit within the titleView
        navView.sizeToFit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.kitchens = DataManager.getKitchens()
        self.yourKitchens = DataManager.getUserFavoriteKitchens()
        self.popularKitchens = DataManager.getKitchens(onlyPopular: true)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if(self.kitchens.count>0)
//        {
//            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
//        }
        Cart.sharedInstance.updateCartBadge()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.kitchens.count == 0)
        {
            return 1
        }
        var retKitchenCount:Int = self.kitchens.count
        if(self.yourKitchens.count > 0)
        {
            retKitchenCount = retKitchenCount + 1
        }
        if(self.popularKitchens.count > 0)
        {
            retKitchenCount = retKitchenCount + 1
        }
        return retKitchenCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let yourKitchensExists:Bool = (self.yourKitchens.count > 0)
        let popularKitchensExists:Bool = (self.kitchens.count > 0)
        if(self.kitchens.count > 0)
        {
            if(yourKitchensExists && popularKitchensExists)
            {
                if(indexPath.row == 0)
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "specialKitchenTableViewCell", for: indexPath) as! SpecialKitchenTableViewCell
                    cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, headerString: "Your Favorites")
                    cell.collectionViewOffset = yourKitchensStoredOffset
                    return cell
                }
                else if(indexPath.row == 1)
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "specialKitchenTableViewCell", for: indexPath) as! SpecialKitchenTableViewCell
                    cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, headerString: "Popular in Your Area")
                    cell.collectionViewOffset = popularKitchensStoredOffset
                    return cell
                }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "kitchenTableViewCell", for: indexPath) as! KitchenTableViewCell
                    let kitchen = kitchens[indexPath.row - 2]
                    kitchen.containingTableViewDelegate = self
                    cell.kitchen = kitchen
                    return cell
                }
            }
            else if(!yourKitchensExists && popularKitchensExists)
            {
                if(indexPath.row == 0)
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "specialKitchenTableViewCell", for: indexPath) as! SpecialKitchenTableViewCell
                    cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, headerString: "Popular in Your Area")
                    cell.collectionViewOffset = popularKitchensStoredOffset
                    return cell
                }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "kitchenTableViewCell", for: indexPath) as! KitchenTableViewCell
                    let kitchen = kitchens[indexPath.row - 1]
                    kitchen.containingTableViewDelegate = self
                    cell.kitchen = kitchen
                    return cell
                }
            }
            else if(yourKitchensExists && !popularKitchensExists)
            {
                if(indexPath.row == 0)
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "specialKitchenTableViewCell", for: indexPath) as! SpecialKitchenTableViewCell
                    cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, headerString: "Your Favorites")
                    cell.collectionViewOffset = yourKitchensStoredOffset
                    return cell
                }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "kitchenTableViewCell", for: indexPath) as! KitchenTableViewCell
                    let kitchen = kitchens[indexPath.row - 1]
                    kitchen.containingTableViewDelegate = self
                    cell.kitchen = kitchen
                    return cell
                }
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "kitchenTableViewCell", for: indexPath) as! KitchenTableViewCell
                let kitchen = kitchens[indexPath.row]
                kitchen.containingTableViewDelegate = self
                cell.kitchen = kitchen
                return cell
            }
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyKitchen", for: indexPath) as! EmptyOrderTableViewCell
            cell.mainText.text = "Sorry! There are no providers nearby!"
            cell.subText.text = "We are working on getting some in your area... "
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let yourKitchensExists:Bool = (self.yourKitchens.count > 0)
        let popularKitchensExists:Bool = (self.kitchens.count > 0)
        
        if(self.kitchens.count > 0)
        {
            if(yourKitchensExists && popularKitchensExists)
            {
                if(indexPath.row == 0)
                {
                    guard let tableViewCell = cell as? SpecialKitchenTableViewCell else { return }
                    
                    yourKitchensStoredOffset = tableViewCell.collectionViewOffset
                }
                else if(indexPath.row == 1)
                {
                    guard let tableViewCell = cell as? SpecialKitchenTableViewCell else { return }
                    
                    popularKitchensStoredOffset = tableViewCell.collectionViewOffset
                }
            }
            else if(!yourKitchensExists && popularKitchensExists)
            {
                if(indexPath.row == 0)
                {
                    guard let tableViewCell = cell as? SpecialKitchenTableViewCell else { return }
                    
                    popularKitchensStoredOffset = tableViewCell.collectionViewOffset
                }
            }
            else if(yourKitchensExists && !popularKitchensExists)
            {
                if(indexPath.row == 0)
                {
                    guard let tableViewCell = cell as? SpecialKitchenTableViewCell else { return }
                    
                    yourKitchensStoredOffset = tableViewCell.collectionViewOffset
                }
            }
        }
    }
    
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let yourKitchensExists:Bool = (self.yourKitchens.count > 0)
        let popularKitchensExists:Bool = (self.kitchens.count > 0)
        
        if(self.kitchens.count == 0)
        {
            return self.view.frame.height - 100
        }
        else
        {
            if(yourKitchensExists && popularKitchensExists)
            {
                if(indexPath.row == 0 || indexPath.row == 1)
                {
                    return 185
                }
            }
            if(yourKitchensExists || popularKitchensExists)
            {
                if(indexPath.row == 0)
                {
                    return 185
                }
            }
            return 226
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMenuItems")
        {
            let menuItemsVC: KitchenViewController? = segue.destination as? KitchenViewController
            let currentRow: KitchenTableViewCell? = sender as! KitchenTableViewCell?
            
            if(menuItemsVC != nil && currentRow != nil)
            {
                menuItemsVC!.kitchen = currentRow!.kitchen!
            }
        }
        else if (segue.identifier == "showMenuItems2")
        {
            let menuItemsVC: KitchenViewController? = segue.destination as? KitchenViewController
            let currentKitchen: SpecialKitchenCollectionViewCell? = sender as! SpecialKitchenCollectionViewCell?
            
            if(menuItemsVC != nil && currentKitchen != nil)
            {
                menuItemsVC!.kitchen = currentKitchen!.kitchen!
            }
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension KitchensTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        let yourKitchensExists:Bool = (self.yourKitchens.count > 0)
        let popularKitchensExists:Bool = (self.kitchens.count > 0)
        
        if(yourKitchensExists && popularKitchensExists)
        {
            if(collectionView.tag == 0)
            {
                return yourKitchens.count
            }
            else if(collectionView.tag == 1)
            {
                return popularKitchens.count
            }
        }
        else if(!yourKitchensExists && popularKitchensExists)
        {
            if(collectionView.tag == 0)
            {
                return popularKitchens.count
            }
        }
        else if(yourKitchensExists && !popularKitchensExists)
        {
            if(collectionView.tag == 0)
            {
                return yourKitchens.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "specialKitchenCollectionViewCell",
                                                      for: indexPath) as! SpecialKitchenCollectionViewCell
        let yourKitchensExists:Bool = (self.yourKitchens.count > 0)
        let popularKitchensExists:Bool = (self.kitchens.count > 0)
        
        if(yourKitchensExists && popularKitchensExists)
        {
            if(collectionView.tag == 0)
            {
                cell.kitchen = yourKitchens[indexPath.item]
            }
            else if(collectionView.tag == 1)
            {
                cell.kitchen = popularKitchens[indexPath.item]
            }
        }
        else if(!yourKitchensExists && popularKitchensExists)
        {
            if(collectionView.tag == 0)
            {
                cell.kitchen = popularKitchens[indexPath.item]
            }
        }
        else if(yourKitchensExists && !popularKitchensExists)
        {
            if(collectionView.tag == 0)
            {
                cell.kitchen = yourKitchens[indexPath.item]
            }
        }
        return cell
    }
}
