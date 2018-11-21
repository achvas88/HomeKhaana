//
//  HomeTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    //var choices:[Choice] = []
    var menuItems: [ChoiceGroup] = []
    
    var kitchen: Kitchen?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.choices = DataManager.getChoices()
        var menuItems:[ChoiceGroup]? = DataManager.getChoiceGroups(kitchenId: self.kitchen!.id)
        if(menuItems != nil)
        {
            self.menuItems = menuItems!
        }
        else
        {
            LoaderController.sharedInstance.showLoader(indicatorText: "Loading Menu Items", holdingView: self.view)
            DataManager.loadMenuItems(kitchenId: self.kitchen!.id, completion:
                {
                    LoaderController.sharedInstance.removeLoader();
                    menuItems = DataManager.getChoiceGroups(kitchenId: self.kitchen!.id)
                    if(menuItems != nil)
                    {
                        self.menuItems = menuItems!
                    }
                    self.tableView.reloadData()
                }
            )
        }

        self.title = self.kitchen!.name
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        if(self.menuItems.count>0)
        {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
        
        if(Cart.sharedInstance.cart.count == 0) {self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = nil}
        else {self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = String(Cart.sharedInstance.cart.count)}
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return choices.count
        return menuItems[section].getChoices().count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choiceCell", for: indexPath) as! ChoiceTableViewCell

        // Configure the cell...
        //let choice = choices[indexPath.row]
        //cell.choice = choice
        let choice = menuItems[indexPath.section].getChoices()[indexPath.row]
        cell.choice = choice
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(menuItems.count == 1) {
            return ""   // do not show section title if there is only one section
        }
        else {
            return menuItems[section].displayTitle
        }
        
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
        if (segue.identifier == "choiceDetail")
        {
            let detailsVC: ChoiceDetailViewController? = segue.destination as? ChoiceDetailViewController
            let currentRow: ChoiceTableViewCell? = sender as! ChoiceTableViewCell?
            
            if(detailsVC != nil && currentRow != nil)
            {
                detailsVC!.theChoice = currentRow!.choice
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
