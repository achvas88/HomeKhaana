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
    var popularDishes: [Choice] = []
    var popularDishesStoredOffset: CGFloat = 0.0
    var popularKitchensStoredOffset: CGFloat = 0.0
    var popularKitchens: [Kitchen] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.kitchens = DataManager.getKitchens()
        self.popularDishes = DataManager.getPopularDishes()
        self.popularKitchens = DataManager.getKitchens(onlyPopular: true)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.kitchens.count>0)
        {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
        }
        
        Cart.sharedInstance.updateCartBadge(vc: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.kitchens.count == 0)
        {
            return 1
        }
        return self.kitchens.count + 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.kitchens.count > 0)
        {
            if(indexPath.row == 0)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dishTableViewCell", for: indexPath) as! DishTableViewCell
                cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, headerString: "Recommended for you")
                cell.collectionViewOffset = popularDishesStoredOffset
                return cell
            }
            else if(indexPath.row == 1)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dishTableViewCell", for: indexPath) as! DishTableViewCell
                cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, headerString: "Popular Kitchens")
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
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyKitchen", for: indexPath) as! EmptyOrderTableViewCell
            cell.mainText.text = "Sorry! There are no providers nearby!"
            cell.subText.text = "We are working on getting some in your area... "
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(self.kitchens.count > 0)
        {
            if(indexPath.row == 0)
            {
                guard let tableViewCell = cell as? DishTableViewCell else { return }
                
                popularDishesStoredOffset = tableViewCell.collectionViewOffset
            }
            else if(indexPath.row == 1)
            {
                guard let tableViewCell = cell as? DishTableViewCell else { return }
                
                popularKitchensStoredOffset = tableViewCell.collectionViewOffset
            }
        }
    }
    
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(self.kitchens.count == 0)
        {
            return self.view.frame.height - 100
        }
        else
        {
            if(indexPath.row != 0 && indexPath.row != 1)
            {
                return 226
            }
            else
            {
                return 185
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMenuItems")
        {
            let menuItemsVC: HomeTableViewController? = segue.destination as? HomeTableViewController
            let currentRow: KitchenTableViewCell? = sender as! KitchenTableViewCell?
            
            if(menuItemsVC != nil && currentRow != nil)
            {
                menuItemsVC!.kitchen = currentRow!.kitchen!
            }
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension KitchensTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView.tag == 0)
        {
            return popularDishes.count
        }
        else if(collectionView.tag == 1)
        {
            return popularKitchens.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dishCollectionViewCell",
                                                      for: indexPath) as! DishCollectionViewCell
        
        if(collectionView.tag == 0)
        {
            cell.choice = popularDishes[indexPath.item]
        }
        else if(collectionView.tag == 1)
        {
            cell.kitchen = popularKitchens[indexPath.item]
        }
        
        return cell
    }
}
