//
//  DataManager.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DataManager {
    
    //static var choices:Dictionary<String,[Choice]> = [:]  // total list of choices = kitchen id: menu items map
    //static var inCart:Dictionary<String,[Choice]> = [:]  // Cart map = kitchen id: menu items map
    static var choices:[Choice] = []  // total list of choices = kitchen id: menu items map
    static var kitchens:Dictionary<String, Kitchen> = [:]  // kitchen id: kitchen
    static var menuItems:Dictionary<String,[ChoiceGroup]> = [:] //kitchen Id: ChoiceGroup array. (Choice group is a group of choices)
    static var inventoryLoaded = false
    
    public static func initData(completion: @escaping () -> ()) -> Void {
        
        if(!User.sharedInstance!.isKitchen)
        {
            // load all kitchens
            LoaderController.sharedInstance.updateTitle(title: "Loading Kitchens")
            let kitchensRef = db.child("Kitchens")
            kitchensRef.observe(.value, with: { (snapshot) in
                self.kitchens = [:]
                for kitchenChild in snapshot.children {
                    if let snapshot = kitchenChild as? DataSnapshot,
                        let kitchen:Kitchen = Kitchen(snapshot: snapshot)
                    {
                        let kitchenId:String = snapshot.key
                        self.kitchens[kitchenId] = kitchen
                    }
                }
                
                completion();
            })
        }
        else
        {
            // load just the kitchen. For the very first time a kitchen is created, this will do nothing.
            LoaderController.sharedInstance.updateTitle(title: "Loading...")
            
            let kitchenId:String = User.sharedInstance!.id
            
            db.child("Kitchens").child(kitchenId).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                if(value != nil)
                {
                    let kitchen = Kitchen(dictionary: value!, id: kitchenId)
                    self.kitchens[kitchenId] = kitchen
                }
                
                completion();
            });
        }
    }
    
    public static func getKitchens() -> [Kitchen]
    {
        if(!User.sharedInstance!.isVegetarian)
        {
            return Array(self.kitchens.values)
        }
        else
        {
            let allKitchens:[Kitchen] = Array(self.kitchens.values)
            var hasVegKitchens:[Kitchen] = []
            for kitchen in allKitchens
            {
                if(kitchen.offersVegetarian)
                {
                    hasVegKitchens.append(kitchen)
                }
            }
            return hasVegKitchens
        }
    }
    
    // WARNING: Use only for user workflows. Not for kitchen workflows. Kitchen workflows do not care about isVegetarian flag that this function would check.
    public static func getChoiceGroups(kitchenId: String) -> [ChoiceGroup]?
    {
        var retChoiceGroups:[ChoiceGroup] = []
        let allChoiceGroups:[ChoiceGroup]? = self.menuItems[kitchenId]
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
    
    public static func getChoiceGroup(kitchenId: String, groupTitle:String)-> ChoiceGroup?
    {
        let menuItems:[ChoiceGroup]? = DataManager.menuItems[kitchenId]
        if(menuItems == nil)
        {
            return nil
        }
        else
        {
            for choiceGroup in menuItems!
            {
                if(choiceGroup.displayTitle == groupTitle)
                {
                    return choiceGroup
                }
            }
            return nil
        }
    }
    
    public static func createChoiceGroup(kitchenId: String, displayTitle: String, choices: [Choice])
    {
        let choiceGroupID: String = UUID().uuidString
        let newGroup:ChoiceGroup = ChoiceGroup(id: choiceGroupID, displayTitle: displayTitle, choices: choices)
        
        let allChoiceGroups:[ChoiceGroup]? = self.menuItems[kitchenId]
        if(allChoiceGroups == nil)
        {
           self.menuItems[kitchenId] = []
        }
        self.menuItems[kitchenId]?.append(newGroup)
    }
    
    
    public static func loadMenuItems(kitchenId: String, completion: @escaping () -> ()) -> Void {
        let menuItemsRef = db.child("MenuItems/\(kitchenId)")
        menuItemsRef.observe(.value, with: { (snapshot) in
            self.menuItems[kitchenId]=[]
            for sectionChild in snapshot.children {
                if let sectionSnapshot = sectionChild as? DataSnapshot {
                    let sectionId:String = sectionSnapshot.key
                    let sectionObject = sectionSnapshot.value as AnyObject
                    let sectionName:String = sectionObject["name"] as! String
                    let menuItemCount = self.menuItems[kitchenId]!.count
                    self.menuItems[kitchenId]!.append(ChoiceGroup(id: sectionId, displayTitle: sectionName, choices: []))
                    
                    if(sectionSnapshot.hasChild("items")) {
                        let sectionItemsSnapshot = sectionSnapshot.childSnapshot(forPath: "items")
                        for choiceChild in sectionItemsSnapshot.children {
                            if let choiceSnapshot = choiceChild as? DataSnapshot,
                                let choice:Choice? = Choice(kitchenId: kitchenId, snapshot: choiceSnapshot)
                            {
                                if(choice != nil)
                                {
                                    self.menuItems[kitchenId]![menuItemCount].addChoice(choice: choice!)
                                }
                            }
                        }
                    }
                }
            }
            
            inventoryLoaded = true
            
            completion();
        })
    }
    
    public static func saveMenuItems()
    {
        if(inventoryLoaded)    //if inventory was never loaded, do not write back as that would clear out the inventory :)
        {
            db.child("MenuItems/\(User.sharedInstance!.id)").setValue(getMenuItemsDictionary()){
                (error:Error?, ref:DatabaseReference) in
                
                if let error = error
                {
                    fatalError("Error uploading menu items data: \(error).")
                }
                else
                {
                    print("Its done.")
                }
            }
        }
    }
    
    private static func getMenuItemsDictionary() -> Dictionary<String, Any>
    {
        var retMap:Dictionary<String,Any> = [:]
        
        if(self.menuItems[User.sharedInstance!.id] == nil)
        {
            return retMap
        }
        
        
        let choiceGroups:[ChoiceGroup] = self.menuItems[User.sharedInstance!.id]!
        for choiceGroup in choiceGroups
        {
            retMap[choiceGroup.id] = choiceGroup.getDictionary()
        }
        
        return retMap
    }
}



/* Older Code
 
 
 
 LoaderController.sharedInstance.updateTitle(title: "Initializing Menu Items")
 let menuItemsRef = db.child("MenuItems")
 menuItemsRef.observe(.value, with: { (snapshot) in
 self.choices = []
 for choiceChild in snapshot.children {
 if let snapshot = choiceChild as? DataSnapshot,
 let choice:Choice? = Choice(snapshot: snapshot)
 {
 if(choice != nil)
 {
 self.choices.append(choice!)
 }
 }
 }
 
 LoaderController.sharedInstance.updateTitle(title: "Loading Deliverable Locations")
 let locationRef = db.child("Locations")
 locationRef.observeSingleEvent(of: .value, with: { (snapshot) in
 self.locations = []
 
 if let addresses = snapshot.value as? [String: AnyObject]
 {
 for items in addresses {
 let key=items.key
 let val = items.value as! String
 self.locations.append(Address(title: val, address: key))
 }
 }
 
 completion();
 })
 })*/