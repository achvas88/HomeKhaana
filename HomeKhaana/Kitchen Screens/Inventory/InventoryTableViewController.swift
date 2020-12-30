//
//  InventoryTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 12/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class InventoryTableViewController: UITableViewController, RefreshTableViewWhenImgLoadsDelegate {
    
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    
    var menuItems: [ChoiceGroup] = []
    
    
    var kitchen: Kitchen? = DataManager.kitchens[User.sharedInstance!.id]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        //self.loadMenuItems()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func loadMenuItems()
    {
        self.btnAdd.isEnabled = false
        let menuItems:[ChoiceGroup]? = DataManager.menuItems[self.kitchen!.id]
        if(menuItems != nil)
        {
            self.menuItems = menuItems!
            self.btnAdd.isEnabled = true
            self.tableView.reloadData()
        }
        else
        {
            LoaderController.sharedInstance.showLoader(indicatorText: "Loading Menu Items", holdingView: self.view)
            KitchenDataManager.loadMenuItems(kitchenId: self.kitchen!.id, completion:
                {
                    LoaderController.sharedInstance.removeLoader();
                    self.menuItems = DataManager.menuItems[self.kitchen!.id]!
                    self.btnAdd.isEnabled = true
                    self.tableView.reloadData()
            }
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadMenuItems()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(menuItems.count == 0)
        {
            return 1
        }
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(menuItems.count == 0)
        {
            return 1
        }
        return menuItems[section].getChoices(ignorePreferences: true).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(menuItems.count == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noItems", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "choiceCell", for: indexPath) as! ChoiceTableViewCell
        
        // Configure the cell...
        //let choice = choices[indexPath.row]
        //cell.choice = choice
        let choice = menuItems[indexPath.section].getChoices(ignorePreferences: true)[indexPath.row]
        choice.containingTableViewDelegate = self
        cell.choice = choice
        cell.showsReorderControl = true
        cell.shouldIndentWhileEditing = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(menuItems.count <= 1) {
            return ""   // do not show section title if there is only one section
        }
        else {
            return menuItems[section].displayTitle
        }
    }
    
//    uncomment below if you want to update header UI
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
//        if #available(iOS 13.0, *) {
//            view.tintColor = UIColor.tertiarySystemFill
//        }
//        //let header = view as! UITableViewHeaderFooterView
//        //header.textLabel?.textColor = UIColor.systemGray
//    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if(menuItems.count == 0)
        {
            return false
        }
        return true
    }
 
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            // Delete the row from the data source
            let _ = DataManager.menuItems[self.kitchen!.id]?[indexPath.section].removeChoice(atIndex: indexPath.row)
            if(DataManager.menuItems[self.kitchen!.id]?[indexPath.section].getChoices(ignorePreferences: true).count == 0) // if no more choices in the group, delete group.
            {
                DataManager.menuItems[self.kitchen!.id]?.remove(at: indexPath.section)
            }
            
            //self.loadMenuItems()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        // at this point there is a guarantee that the sections in 'moveRowAt' and 'to' are the same.
        DataManager.menuItems[self.kitchen!.id]?[fromIndexPath.section].rearrangeChoice(fromIndex: fromIndexPath.row, toIndex: to.row)
        self.loadMenuItems()
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return NSIndexPath(row: row, section: sourceIndexPath.section) as IndexPath
        }
        return proposedDestinationIndexPath
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.prepare
        
        if (segue.identifier == "editDetails")
        {
            let addItemVC: InventoryAddItemViewController? = segue.destination as? InventoryAddItemViewController
            
            let currentRow: ChoiceTableViewCell? = sender as! ChoiceTableViewCell?
            addItemVC!.choice = currentRow!.choice!
            
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                addItemVC!.choiceGroupTitle = menuItems[indexPath.section].displayTitle
            }
        }
    }
}
