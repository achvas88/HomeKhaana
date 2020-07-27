//
//  KitchenDataManager.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/12/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase

class KitchenDataManager {
    private static var inventoryLoaded = false
    
    
    //loads the kitchen details from the database
    public static func initData(completion: @escaping () -> ()) -> Void {
        // load just the kitchen. For the very first time a kitchen is created, this will do nothing.
        LoaderController.sharedInstance.updateTitle(title: "Loading...")
        
        let kitchenId:String = User.sharedInstance!.id
        db.child("Kitchens").child(kitchenId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if(value != nil)
            {
                let kitchen = Kitchen(dictionary: value!, id: kitchenId)
                DataManager.kitchens[kitchenId] = kitchen
            }
            completion()
        });
    }
    
    //writes the kitchen details and the menu items to the database
    public static func saveData()
    {
        let id=User.sharedInstance!.id
        let currentKitchen:Kitchen? = DataManager.kitchens[id]
        
        if(currentKitchen != nil)
        {
            let kitchenRef = db.child("Kitchens/\(id)")
            kitchenRef.updateChildValues(currentKitchen!.dictionary, withCompletionBlock: {
                (error:Error?, ref:DatabaseReference) in
                
                if let error = error
                {
                    // It reaches here in a very specific workflow. Convert to kitchen and then logout. but things work fine. So commenting this out.
                    //fatalError("Error uploading kitchen data: \(error).")
                }
                else
                {
                    print("Kitchen details uploaded")
                }
            })
            
            saveMenuItems()
        }
    }
    
    //loads the menu items for the given kitchen and runs the completion code after its done loading.
    public static func loadMenuItems(kitchenId: String, completion: @escaping () -> ()) -> Void {
        let menuItemsRef = db.child("MenuItems/\(kitchenId)")
        menuItemsRef.observe(.value, with: { (snapshot) in
            DataManager.menuItems[kitchenId]=[]
            for sectionChild in snapshot.children {
                if let sectionSnapshot = sectionChild as? DataSnapshot {
                    let sectionId:String = sectionSnapshot.key
                    let sectionObject = sectionSnapshot.value as AnyObject
                    let sectionName:String = sectionObject["name"] as! String
                    let menuItemCount = DataManager.menuItems[kitchenId]!.count
                    DataManager.menuItems[kitchenId]!.append(ChoiceGroup(id: sectionId, displayTitle: sectionName, choices: []))
                    
                    if(sectionSnapshot.hasChild("items")) {
                        let sectionItemsSnapshot = sectionSnapshot.childSnapshot(forPath: "items")
                        for choiceChild in sectionItemsSnapshot.children {
                            if let choiceSnapshot = choiceChild as? DataSnapshot,
                                let choice:Choice? = Choice(kitchenId: kitchenId, snapshot: choiceSnapshot)
                            {
                                if(choice != nil)
                                {
                                    DataManager.menuItems[kitchenId]![menuItemCount].addChoice(choice: choice!)
                                }
                            }
                        }
                        DataManager.menuItems[kitchenId]![menuItemCount].sortChoicesByID()
                    }
                }
            }
            
            KitchenDataManager.inventoryLoaded = true
            
            completion();
        })
    }
    
    // WARNING: Use only for user workflows. Not for kitchen workflows. Kitchen workflows do not care about isVegetarian flag that this function would check.
    public static func getChoiceGroups(kitchenId: String) -> [ChoiceGroup]?
    {
        var retChoiceGroups:[ChoiceGroup] = []
        let allChoiceGroups:[ChoiceGroup]? = DataManager.menuItems[kitchenId]
        if(allChoiceGroups == nil)
        {
            return nil
        }
        for choiceGroup in allChoiceGroups!
        {
            if(choiceGroup.getChoices().count>0)    // if this is vegetarian or if there is nothing within a group, then do not add it to the list of final groupps
            {
                retChoiceGroups.append(choiceGroup)
            }
        }
        if(retChoiceGroups.count == 0) { return nil }
        return retChoiceGroups
    }
    
    //save menu items to the database
    private static func saveMenuItems()
    {
        if(KitchenDataManager.inventoryLoaded)    //if inventory was never loaded, do not write back as that would clear out the inventory :)
        {
            db.child("MenuItems/\(User.sharedInstance!.id)").setValue(getMenuItems(), withCompletionBlock:{
                (error:Error?, ref:DatabaseReference) in
                
                if let error = error
                {
                    fatalError("Error uploading menu items data: \(error).")
                }
                else
                {
                    print("Its done.")
                }
            })
        }
    }
    
    //Returns the list of menu items
    private static func getMenuItems() -> Dictionary<String, Any>
    {
        var retMap:Dictionary<String,Any> = [:]
        
        if(DataManager.menuItems[User.sharedInstance!.id] == nil)
        {
            return retMap
        }
        
        
        let choiceGroups:[ChoiceGroup] = DataManager.menuItems[User.sharedInstance!.id]!
        for choiceGroup in choiceGroups
        {
            retMap[choiceGroup.id] = choiceGroup.getDictionary()
        }
        
        return retMap
    }
}
