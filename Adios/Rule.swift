//
//  Rule.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import SwiftyJSON

class Rule {
    var triggerUrlFilter: String = ""
    var triggerUrlFilterIsCaseSensitive: Bool?
    var triggerResourceType: [String]?
    var triggerLoadType: [String]?
    var triggerIfDomain: [String]?
    var triggerUnlessDomain: [String]?
    
    var actionType: String = ""
    var actionSelector: String?
    
    func toString() -> String {
        var stringRule = "{ \"trigger\": { \"url-filter\": \"\(triggerUrlFilter)\""
        if let displayedTriggerUrlFilterIsCaseSensitive = triggerUrlFilterIsCaseSensitive {
            stringRule += ",\"url-filter-is-case-sensitive\": \(displayedTriggerUrlFilterIsCaseSensitive)"
        }
        if let displayedTriggerResourceType = triggerResourceType {
            stringRule += ",\"resource-type\": ["
            for resourceType in displayedTriggerResourceType {
                stringRule += "\"\(resourceType)\","
            }
            stringRule = stringRule.substringToIndex(stringRule.endIndex.predecessor()) // Removing the last coma.
            stringRule += "]"
        }
        if let displayedTriggerLoadType = triggerLoadType {
            stringRule += ",\"load-type\": ["
            for loadType in displayedTriggerLoadType {
                stringRule += "\"\(loadType)\","
            }
            stringRule = stringRule.substringToIndex(stringRule.endIndex.predecessor())
            stringRule += "]"
        }
        if let displayedTriggerIfDomain = triggerIfDomain {
            stringRule += ",\"if-domain\": ["
            for ifDomain in displayedTriggerIfDomain {
                stringRule += "\"\(ifDomain)\","
            }
            stringRule = stringRule.substringToIndex(stringRule.endIndex.predecessor())
            stringRule += "]"
        } else if let displayedTriggerUnlessDomain = triggerUnlessDomain {
            stringRule += ",\"unless-domain\": ["
            for unlessDomain in displayedTriggerUnlessDomain {
                stringRule += "\"\(unlessDomain)\","
            }
            stringRule = stringRule.substringToIndex(stringRule.endIndex.predecessor())
            stringRule += "]"
        }
        
        stringRule += "}, \"action\": {\"type\": \"\(actionType)\""
        
        if let displayedActionSelector = actionSelector {
            stringRule += ",\"selector\": \"\(displayedActionSelector)\""
        }
        
        return stringRule + "}},"
    }
    
    init(jsonRule: JSON) {
        var triggerUrlFilterWithCorrectSyntax = jsonRule["trigger"]["url-filter"].string!.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
        triggerUrlFilterWithCorrectSyntax = triggerUrlFilterWithCorrectSyntax.stringByReplacingOccurrencesOfString("\"", withString: "\\\"") // One quote => Backslash + quote
        self.triggerUrlFilter = triggerUrlFilterWithCorrectSyntax
        if jsonRule["trigger"]["url-filter-is-case-sensitive"].bool != nil {
            self.triggerUrlFilterIsCaseSensitive = jsonRule["trigger"]["url-filter-is-case-sensitive"].bool
        }
        if jsonRule["trigger"]["resource-type"].array != nil {
            self.triggerResourceType = []
            for resourceType in jsonRule["trigger"]["resource-type"].array! {
                self.triggerResourceType!.append(resourceType.string!)
            }
        }
        if jsonRule["trigger"]["load-type"].array != nil {
            self.triggerLoadType = []
            for loadType in jsonRule["trigger"]["load-type"].array! {
                self.triggerLoadType!.append(loadType.string!)
            }
        }
        if jsonRule["trigger"]["if-domain"].array != nil {
            self.triggerIfDomain = []
            for ifDomain in jsonRule["trigger"]["if-domain"].array! {
                self.triggerIfDomain!.append(ifDomain.string!)
            }
        } else if jsonRule["trigger"]["unless-domain"].array != nil {
            self.triggerUnlessDomain = []
            for unlessDomain in jsonRule["trigger"]["unless-domain"].array! {
                self.triggerUnlessDomain!.append(unlessDomain.string!)
            }
        }
        
        self.actionType = jsonRule["action"]["type"].string!
        
        if jsonRule["action"]["selector"].string != nil {
            var jsonRuleWithCorrectSyntax = jsonRule["action"]["selector"].string!.stringByReplacingOccurrencesOfString("\\", withString: "\\\\") // One backslash => Two backslahes
            jsonRuleWithCorrectSyntax = jsonRuleWithCorrectSyntax.stringByReplacingOccurrencesOfString("\"", withString: "\\\"") // One quote => Backslash + quote
            self.actionSelector = jsonRuleWithCorrectSyntax
        }
    }
}
