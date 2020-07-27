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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.kitchens = DataManager.getKitchens()
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
        return self.kitchens.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.kitchens.count > 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "kitchenTableViewCell", for: indexPath) as! KitchenTableViewCell
            let kitchen = kitchens[indexPath.row]
            kitchen.containingTableViewDelegate = self
            cell.kitchen = kitchen
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyKitchen", for: indexPath) as! EmptyOrderTableViewCell
            cell.mainText.text = "Sorry! There are no providers nearby!"
            cell.subText.text = "We are working on getting some in your area... "
            return cell
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
            return 306
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
