//
//  ListsManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import CloudKit
import SafariServices

class ListsManager {
    func addRuleToList(list: String, rule: String) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if var searchedlist = userDefaults.arrayForKey(list) as! [String]? {
                searchedlist.append(rule)
                userDefaults.setObject(Array(Set(searchedlist)), forKey: list) // Array(Set(array)) to be sure everything is unique.
            }
        }
    }
    
    func getDisplayableLists() -> [String] {
        //return ["Arabic region 🇪🇬", "Bulgaria 🇧🇬", "China 🇨🇳", "Czech and Slovak Rep. 🇸🇰", "Denmark 🇩🇰", "France 🇫🇷", "Estonia 🇪🇪", "Germany 🇩🇪", "Iceland 🇮🇸", "Greece 🇬🇷", "Hungary 🇭🇺", "Japan 🇯🇵", "Indonesia 🇮🇩", "Italy 🇮🇹", "Israel 🇮🇱", "Latvia 🇱🇻", "Poland 🇵🇱", "Netherlands 🇳🇱", "Romania 🇷🇴", "Russia 🇷🇺", "United Kingdom 🇬🇧", "U.S.A 🇺🇸"]
        return ["List for Adios", "Test list for Adios"]
    }
    
    func getListFromDisplayableList(displayableList: String) -> String? {
        switch displayableList {
        case "List for Adios":
            return "AdiosList"
        case "Test list for Adios":
            return "AdiosListTest"
        default:
            return nil
        }
    }
    
    func applyLists() {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (error: NSError?) -> Void in
            if error == nil {
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                    if error == nil {
                        print("Rules applied")
                    } else {
                        print(otherError)
                    }
                }
            } else {
               print(error)
            }
        }
    }
    
    func deleteRuleFromList(list: String, rule: String) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if var searchedlist = userDefaults.arrayForKey(list) as! [String]? {
                if searchedlist.indexOf(rule) != nil {
                    searchedlist.removeAtIndex(searchedlist.indexOf(rule)!)
                    userDefaults.setObject(Array(Set(searchedlist)), forKey: list)
                }
                
            }
        }
    }
    
    func getFollowedLists() -> [String] {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            return userDefaults.arrayForKey("followedLists") as! [String]
        } else {
            return []
        }
    }
    
    func printLists() {
        let followedLists = getFollowedLists()
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            for list in followedLists {
                if let displayedList = userDefaults.arrayForKey("\(list)Block") as! [String]? {
                    print(displayedList)
                }
                if let displayedList = userDefaults.arrayForKey("\(list)BlockCookies") as! [String]? {
                    print(displayedList)
                }
                if let displayedList = userDefaults.arrayForKey("\(list)CSSDisplayNone") as! [String]? {
                    print(displayedList)
                }
                if let displayedList = userDefaults.arrayForKey("\(list)IgnorePreviousRules") as! [String]? {
                    print(displayedList)
                }
            }
        }
    }
    
    func createList(list: String, records: [CKRecord]) {
        print("On créer la liste \(list)")
        
        var rulesBlock: [String] = []
        var rulesBlockCookies: [String] = []
        var rulesCSSDisplayNone: [String] = []
        var rulesIgnorePreviousRules: [String] = []
        
        for record in records {
            let sourceList = record["List"] as! CKReference
            print(sourceList.recordID.recordName)
            let rule = ruleFromRecord(record)
            switch rule.actionType {
                case "block":
                rulesBlock.append(rule.toString())
                case "block-cookies":
                rulesBlockCookies.append(rule.toString())
                case "css-display-none":
                rulesCSSDisplayNone.append(rule.toString())
                case "ignore-previous-rules":
                rulesIgnorePreviousRules.append(rule.toString())
                default:
                print("Problem with a rule that is not well formatted: \(rule.toString())")
            }
        }
        
        // Set the four group defaults here.
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            var followedLists = userDefaults.arrayForKey("followedLists")
            userDefaults.setObject(Array(Set(rulesBlock)), forKey: "\(list)Block")
            userDefaults.setObject(Array(Set(rulesBlockCookies)), forKey: "\(list)BlockCookies")
            userDefaults.setObject(Array(Set(rulesCSSDisplayNone)), forKey: "\(list)CSSDisplayNone")
            userDefaults.setObject(Array(Set(rulesIgnorePreviousRules)), forKey: "\(list)IgnorePreviousRules")
            
            if followedLists == nil {
                followedLists = [list]
            } else {
               followedLists!.append(list)
            }
            userDefaults.setObject(followedLists, forKey: "followedLists")
            
            userDefaults.synchronize()
        }
    }
    
    func updateRulesWithRecords(recordsCreated: [CKRecord], recordsDeleted: [CKRecord]) {
        for record in recordsCreated {
            let recordList = (record["List"] as! CKReference).recordID.recordName
            let rule = ruleFromRecord(record)
            switch rule.actionType {
            case "block":
                addRuleToList("\(recordList)Block", rule: rule.toString())
            case "block-cookies":
                addRuleToList("\(recordList)BlockCookies", rule: rule.toString())
            case "css-display-none":
                addRuleToList("\(recordList)CSSDisplayNone", rule: rule.toString())
            case "ignore-previous-rules":
                addRuleToList("\(recordList)IgnorePreviousRules", rule: rule.toString())
            default:
                print("Problem with a rule that is not well formatted: \(rule.toString())")
            }
        }
        
        for record in recordsDeleted {
            let recordList = (record["List"] as! CKReference).recordID.recordName
            let rule = ruleFromRecord(record)
            switch rule.actionType {
            case "block":
                deleteRuleFromList("\(recordList)Block", rule: rule.toString())
            case "block-cookies":
                deleteRuleFromList("\(recordList)BlockCookies", rule: rule.toString())
            case "css-display-none":
                deleteRuleFromList("\(recordList)CSSDisplayNone", rule: rule.toString())
            case "ignore-previous-rules":
                deleteRuleFromList("\(recordList)IgnorePreviousRules", rule: rule.toString())
            default:
                print("Problem with a rule that is not well formatted: \(rule.toString())")
            }
        }
        
        applyLists()
    }
    
    func removeAllLists() {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if let followedLists = userDefaults.arrayForKey("followedLists") {
                for list in followedLists {
                    userDefaults.removeObjectForKey("\(list)Block")
                    userDefaults.removeObjectForKey("\(list)BlockCookies")
                    userDefaults.removeObjectForKey("\(list)CSSDisplayNone")
                    userDefaults.removeObjectForKey("\(list)IgnorePreviousRules")
                }
                userDefaults.removeObjectForKey("followedLists")
            }
        }
    }
    
    func ruleFromRecord(record: CKRecord) -> Rule {
        let rule = Rule(triggerUrlFilterWithOneBackslash: record["TriggerUrlFilter"] as! String, actionType: record["ActionType"] as! String)
        if let _ = record["TriggerUrlFilterIsCaseSensitive"] as? Int {
            rule.triggerUrlFilterIsCaseSensitive = true
        }
        if let triggerResourceType = record["TriggerResourceType"] as? [String] {
            rule.triggerResourceType = triggerResourceType
        }
        if let triggerLoadType = record["TriggerLoadType"] as? [String] {
            rule.triggerLoadType = triggerLoadType
        }
        if let triggerIfDomain = record["TriggerIfDomain"] as? [String] {
            rule.triggerIfDomain = triggerIfDomain
        } else if let triggerUnlessDomain = record["TriggerUnlessDomain"] as? [String] {
            rule.triggerUnlessDomain = triggerUnlessDomain
        }
        
        if let actionSelector = record["ActionSelector"] as? String {
            rule.actionSelector = actionSelector
        }
        return rule
    }
}