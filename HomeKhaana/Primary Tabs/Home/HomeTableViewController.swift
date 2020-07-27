//
//  HomeTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController,RefreshTableViewWhenImgLoadsDelegate {
    
    var menuItems: [ChoiceGroup] = []
    var kitchen: Kitchen?
    
    func reloadTableView()
    {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var menuItems:[ChoiceGroup]? = KitchenDataManager.getChoiceGroups(kitchenId: self.kitchen!.id)
        if(menuItems != nil)
        {
            self.menuItems = menuItems!
        }
        else
        {
            LoaderController.sharedInstance.showLoader(indicatorText: "Loading Menu Items", holdingView: self.view)
            KitchenDataManager.loadMenuItems(kitchenId: self.kitchen!.id, completion:
                {
                    LoaderController.sharedInstance.removeLoader();
                    menuItems = KitchenDataManager.getChoiceGroups(kitchenId: self.kitchen!.id)
                    if(menuItems != nil)
                    {
                        self.menuItems = menuItems!
                    }
                    self.tableView.reloadData()
                }
            )
        }

        self.title = self.kitchen!.name
    }

    override func viewDidAppear(_ animated: Bool) {
        Cart.sharedInstance.updateCartBadge(vc: self)
        
        //        if(self.menuItems.count>0)
        //        {
        //            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return 1
        }
        return menuItems[section-1].getChoices().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
           let cell = tableView.dequeueReusableCell(withIdentifier: "kitchenHeader", for: indexPath) as! KitchenHeaderTableViewCell
            cell.kitchen = self.kitchen!
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "choiceCell", for: indexPath) as! ChoiceTableViewCell

            let choice = menuItems[indexPath.section-1].getChoices()[indexPath.row]
            choice.containingTableViewDelegate = self
            cell.choice = choice
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(menuItems.count == 1 || section == 0) {
            return ""   // do not show section title if there is only one section
        }
        else {
            return menuItems[section-1].displayTitle
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0)
        {
            return 160
        }
        return 220
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "choiceDetail")
        {
            let detailsVC: ChoiceDetailViewController? = segue.destination as? ChoiceDetailViewController
            let currentRow: ChoiceTableViewCell? = sender as! ChoiceTableViewCell?
            
            if(detailsVC != nil && currentRow != nil)
            {
                detailsVC!.theChoice = currentRow!.choice
                detailsVC!.comingFromHome = true
            }
        }
    }
}
