//
//  ChoiceGroup.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 11/14/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation

class ChoiceGroup
{
    var displayTitle: String
    private var choices:[Choice]
    var id: String
    private var vegChoices:[Choice]
    
    init(id: String, displayTitle: String, choices: [Choice]) {
        self.id = id
        self.displayTitle = displayTitle
        self.choices = choices
        self.vegChoices = []
        if(self.choices.count>0) { self.populateVegChoices() }
    }
    
    private func populateVegChoices() -> Void
    {
        for choice in self.choices
        {
            if(choice.isVegetarian)
            {
                self.vegChoices.append(choice)
            }
        }
    }
    
    public func removeChoice(atIndex: Int) -> Choice
    {
        //we assume that the call is made correctly.
        let choiceRemoved:Choice = self.choices.remove(at: atIndex)
        if(choiceRemoved.isVegetarian)
        {
            vegChoices.remove(object: choiceRemoved)
        }
        return choiceRemoved
    }
    
    public func addChoice(choice: Choice) -> Void
    {
        self.choices.append(choice)
        if(choice.isVegetarian) { self.vegChoices.append(choice) }
    }
    
    public func rearrangeChoice(fromIndex: Int, toIndex: Int)
    {
        let choiceRemoved:Choice = removeChoice(atIndex: fromIndex)
        self.choices.insert(choiceRemoved, at: toIndex)
        // NOTE: we need not worry about the vegChoices here because it is only the kitchen workflow that would call this function and
        // they wouldnt care about veg choices.
    }
    
    public func getChoices(ignorePreferences:Bool = false) -> [Choice]
    {
        if(ignorePreferences || !User.sharedInstance!.isVegetarian)
        {
            return self.choices;
        }
        else
        {
            return self.vegChoices
        }
    }
    
    public func getDictionary() ->  Dictionary<String,Any>
    {
        return [
            "name": self.displayTitle,
            "items": getChoicesDictionary()
        ]
    }
    
    private func getChoicesDictionary() -> Dictionary<String,Any>
    {
        var retMap:Dictionary<String,Any> = [:]
        var orderID:Int = 0
        for choice in self.choices
        {
            orderID=orderID+1
            var choiceDic:Dictionary<String,Any> = choice.getDictionary()
            choiceDic["order"]=orderID
            retMap[choice.id] = choiceDic
        }
        return retMap
    }
    
    public func sortChoicesByID()
    {
        self.choices.sort(by: { $0.order < $1.order })
        self.vegChoices.sort(by: { $0.order < $1.order })
    }
}
