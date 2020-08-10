//
//  KitchenViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/8/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class KitchenViewController: UIViewController, RefreshTableViewWhenImgLoadsDelegate
{
    @IBOutlet weak var tblMenuItems: UITableView!
    @IBOutlet weak var lblKitchenName: UILabel!
    @IBOutlet weak var lblKitchenType: UILabel!
    @IBOutlet weak var lblKitchenRating: UILabel!
    @IBOutlet weak var lblKitchenAddress: UILabel!
    @IBOutlet weak var imgKitchen: UIImageView!
    @IBOutlet weak var cstKitchenImgHeight: NSLayoutConstraint!
    
    var choiceGroups: [ChoiceGroup] = []
    var kitchen: Kitchen?
    var hasFeaturedItems: Bool = false
    var featuredChoices: [Choice] = []
    let headerViewMaxHeight: CGFloat = 250
    let headerViewMinHeight: CGFloat = 80 //+ UIApplication.shared.statusBarFrame.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblMenuItems.dataSource = self
        self.tblMenuItems.delegate = self
        self.loadKitchenDetails()
        
        var menuItems:[ChoiceGroup]? = KitchenDataManager.getChoiceGroups(kitchenId: self.kitchen!.id)
        if(menuItems != nil)
        {
            for choiceGroup in menuItems!
            {
                self.choiceGroups.append(choiceGroup)
                for choice in choiceGroup.getChoices()
                {
                    if(choice.isFeatured)
                    {
                        self.hasFeaturedItems = true
                        self.featuredChoices.append(choice)
                    }
                }
            }
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
                        for choiceGroup in menuItems!
                        {
                            self.choiceGroups.append(choiceGroup)
                            for choice in choiceGroup.getChoices()
                            {
                                if(choice.isFeatured)
                                {
                                    self.hasFeaturedItems = true
                                    self.featuredChoices.append(choice)
                                }
                            }
                        }
                    }
                    
                    self.reloadTableView()
                }
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Cart.sharedInstance.updateCartBadge(vc: self)
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
        else if (segue.identifier == "choiceDetail2")
        {
            let detailsVC: ChoiceDetailViewController? = segue.destination as? ChoiceDetailViewController
            let currentChoiceCell: FeaturedChoiceCollectionViewCell? = sender as! FeaturedChoiceCollectionViewCell?
            
            if(detailsVC != nil && currentChoiceCell != nil)
            {
                detailsVC!.theChoice = currentChoiceCell!.choice
                detailsVC!.comingFromHome = true
            }
        }
    }

    @IBAction func btnClose(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func loadKitchenDetails()
    {
        self.lblKitchenName.text = kitchen?.name
        self.imgKitchen.image = kitchen?.image
        self.lblKitchenType.text = kitchen?.type
        self.lblKitchenRating.text = String(kitchen!.ratingHandler.rating)
        self.lblKitchenAddress.text = kitchen?.address
    }
    
    func reloadTableView()
    {
        self.tblMenuItems.reloadData()
    }
}

extension KitchenViewController:UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.hasFeaturedItems)
        {
            if(section == 0)
            {
                return 1
            }
            else
            {
                let count = self.choiceGroups[section-1].getChoices().count
                return count;
            }
        }
        return self.choiceGroups[section].getChoices().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var choice:Choice
        if(self.hasFeaturedItems)
        {
            if(indexPath.section == 0)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "featuredChoicesCell", for: indexPath) as! FeatureChoicesTableViewCell
                cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self)
                return cell
            }
            else
            {
                choice = choiceGroups[indexPath.section-1].getChoices()[indexPath.row]
            }
        }
        else
        {
            choice = choiceGroups[indexPath.section].getChoices()[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "choiceCell", for: indexPath) as! ChoiceTableViewCell
        choice.containingTableViewDelegate = self
        cell.choice = choice
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.hasFeaturedItems)
        {
            return choiceGroups.count + 1
        }
        return choiceGroups.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(self.hasFeaturedItems)
        {
            if(choiceGroups.count == 1 || section == 0)
            {
                return ""   // do not show section title if there is only one section
            }
            else
            {
                return choiceGroups[section-1].displayTitle
            }
        }
        else
        {
            if(choiceGroups.count == 1)
            {
                return ""
            }
            else
            {
                return choiceGroups[section].displayTitle
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.groupTableViewBackground //black.withAlphaComponent(0.4)
        //(view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
}

extension KitchenViewController:UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.featuredChoices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredChoiceCollectionViewCell",
                                                      for: indexPath) as! FeaturedChoiceCollectionViewCell
        cell.choice = self.featuredChoices[indexPath.item]
        return cell
    }
}

extension KitchenViewController:UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y: CGFloat = scrollView.contentOffset.y
        let newHeaderViewHeight: CGFloat = cstKitchenImgHeight.constant - y
        
        if newHeaderViewHeight > headerViewMaxHeight {
            cstKitchenImgHeight.constant = headerViewMaxHeight
        } else if newHeaderViewHeight < headerViewMinHeight {
            cstKitchenImgHeight.constant = headerViewMinHeight
        } else {
            cstKitchenImgHeight.constant = newHeaderViewHeight
            scrollView.contentOffset.y = 0 // block scroll view
        }
        
    }
}
