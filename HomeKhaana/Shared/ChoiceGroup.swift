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
    
    public func addChoice(choice: Choice) -> Void
    {
        self.choices.append(choice)
        if(choice.isVegetarian) { self.vegChoices.append(choice) }
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
        for choice in self.choices
        {
            retMap[choice.id] = choice.getDictionary()
        }
        return retMap
    }
}
