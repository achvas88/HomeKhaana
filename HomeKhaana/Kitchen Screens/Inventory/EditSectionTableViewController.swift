//
//  EditSectionTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 12/30/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class EditSectionTableViewController: UITableViewController {

    var menuItems: [ChoiceGroup] = []
    let kitchen: Kitchen? = DataManager.kitchens[User.sharedInstance!.id]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadMenuItems()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    private func loadMenuItems()
    {
        let menuItems:[ChoiceGroup]? = DataManager.menuItems[self.kitchen!.id]
        
        if(menuItems != nil)
        {
            self.menuItems = menuItems!
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.menuItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell", for: indexPath)

        cell.textLabel?.text = self.menuItems[indexPath.row].displayTitle

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            KitchenDataManager.removeChoiceGroup(kitchenID: User.sharedInstance!.id, atIndex: indexPath.row)
            self.loadMenuItems()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        KitchenDataManager.rearrangeChoiceGroup(kitchenID: User.sharedInstance!.id, fromIndex: fromIndexPath.row, toIndex: to.row)
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
