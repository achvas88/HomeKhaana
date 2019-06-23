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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        self.kitchens = DataManager.getKitchens()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.kitchens.count>0)
        {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
        
        if(Cart.sharedInstance.cart.count == 0) {self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = nil}
        else {self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = String(Cart.sharedInstance.cart.count)}
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.kitchens.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "kitchenTableViewCell", for: indexPath) as! KitchenTableViewCell
        
        // Configure the cell...
        let kitchen = kitchens[indexPath.row]
        kitchen.containingTableViewDelegate = self
        cell.kitchen = kitchen
        return cell
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
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
