//
//  ListsManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import CloudKit

class ListsManager {
    func addRuleToList(list: String, ruleAsRecord: CKRecord) {
        print("We want to add a rule to a list")
    }
    func deleteRuleFromList(list: String, ruleAsRecord: CKRecord) {
        print("We want to remove a rule to a list")
    }
    func createList(list: String, records: [CKRecord]) {
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
            userDefaults.setObject(rulesBlock, forKey: "\(list)Block")
            userDefaults.setObject(rulesBlockCookies, forKey: "\(list)BlockCookies")
            userDefaults.setObject(rulesCSSDisplayNone, forKey: "\(list)CSSDisplayNone")
            userDefaults.setObject(rulesIgnorePreviousRules, forKey: "\(list)IgnorePreviousRules")
            
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
        
    }
    
    func removeAllLists() {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if var followedLists = userDefaults.arrayForKey("followedLists") {
                for list in followedLists {
                    userDefaults.removeObjectForKey("\(list)Block")
                }
            }
            
        }
    }
    
    func ruleFromRecord(record: CKRecord) -> Rule {
        let rule = Rule()
        if let triggerUrlFilter = record["TriggerUrlFilter"] as? String {
            rule.triggerUrlFilter = triggerUrlFilter
        }
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
        
        if let actionType = record["ActionType"] as? String {
            rule.actionType = actionType
        }
        if let actionSelector = record["ActionSelector"] as? String {
            rule.actionSelector = actionSelector
        }
        return rule
    }
}