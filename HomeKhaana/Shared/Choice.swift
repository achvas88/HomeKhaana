//
//  Choice.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 6/23/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class Choice: Equatable
{
    static func == (lhs: Choice, rhs: Choice) -> Bool {
        return lhs.id == rhs.id
    }
    
    weak var containingTableViewDelegate: RefreshTableViewWhenImgLoadsDelegate?
    var displayTitle: String
    var description:String
    var cost:Float
    var isVegetarian:Bool
    var hasImage: Bool
    var id:String
    var items: String // In the future this can be different. For now, this is good enough.
    var kitchenId: String
    var quantity: Int?
    var order: Int
    
    var image: UIImage? {
        didSet {
            self.writeImagetoDB()
        }
    }
    
    init(id:String, title:String,description:String,cost:Float,isVegetarian:Bool,hasImage:Bool, items: String, kitchenId: String, order: Int) {
        self.id = id
        self.displayTitle = title
        self.description = description
        self.cost = cost
        self.isVegetarian = isVegetarian
        self.hasImage = hasImage
        self.items = items
        self.kitchenId = kitchenId
        self.order = order
        
        if(self.hasImage)
        {
            self.loadImageFromDB()
        }
    }
    
    public convenience init?(displayTitle: String, quantity: Int, cost: Float)
    {
        self.init(id: "", title: displayTitle, description: "", cost: cost, isVegetarian: true, hasImage: false, items: "", kitchenId: "", order: 0)
        self.quantity = quantity
    }
    
    public convenience init?(kitchenId:String, snapshot: DataSnapshot)
    {
        let snapshot = snapshot.value as AnyObject
        
        let displayTitle = snapshot["title"] as! String
        let description = snapshot["description"] as! String
        let cost = snapshot["cost"] as! Float
        let isVegetarian = snapshot["isVegetarian"] as! Bool
        let hasImage = snapshot["hasImage"] as! Bool
        let id = snapshot["id"] as! String
        let items = snapshot["items"] as! String
        let order = snapshot["order"] as! Int
        
        self.init(id: id, title: displayTitle , description: description, cost: cost, isVegetarian: isVegetarian, hasImage: hasImage, items: items, kitchenId: kitchenId, order: order)
    }
    
    public func getDictionary() -> Dictionary<String,Any>
    {
        return  [
            "title": self.displayTitle,
            "description": self.description,
            "cost": self.cost,
            "isVegetarian": self.isVegetarian,
            "hasImage": self.hasImage,
            "id": self.id,
            "items": self.items
            // Note that the value of the 'order' property is calculated only in the ChoiceGroup code. So, the dictionary doesnt return it.
        ]
    }
    
    func loadImageFromDB()
    {
        let filePath = "\(self.kitchenId)/\("MenuItems")/\(id)/\("itemPhoto")"
        // Assuming a < 10MB file, though you can change that
        let storageRef = Storage.storage().reference()
        storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            self.image = UIImage(data: data!)
            self.containingTableViewDelegate?.reloadTableView()
        })
    }
    
    func writeImagetoDB()
    {
        if (self.image != nil)
        {
            let data = UIImageJPEGRepresentation(self.image!, 0.8)!
            
            // set upload path
            let filePath = "\(User.sharedInstance!.id)/\("MenuItems")/\(id)/\("itemPhoto")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            // Create a root reference
            let storageRef = Storage.storage().reference()
            storageRef.child(filePath).putData(data, metadata: metaData)
            {
                (metaData,error) in
                if let error = error
                {
                    print(error.localizedDescription)
                    return
                }
                else
                {
                    self.hasImage = true
                    //do not have to store the download url as it can be calculated
                    
                    //store downloadURL
                    //let downloadURL = metaData!.path
                    //store downloadURL at database
                    //db.child("Kitchens/\(id)").updateChildValues(["kitchenPhoto": downloadURL!])
                }
            }
        }
    }
}
