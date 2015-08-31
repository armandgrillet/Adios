//
//  Rule.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

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
        var stringRule = "{\"trigger\":{\"url-filter\":\"\(triggerUrlFilter)\""
        if let displayedTriggerUrlFilterIsCaseSensitive = triggerUrlFilterIsCaseSensitive {
            stringRule += ",\"url-filter-is-case-sensitive\":\(displayedTriggerUrlFilterIsCaseSensitive)"
        }
        if let displayedTriggerResourceType = triggerResourceType {
            stringRule += ",\"resource-type\":["
            for resourceType in displayedTriggerResourceType {
                stringRule += "\"\(resourceType)\","
            }
            stringRule = stringRule.substringToIndex(stringRule.endIndex.predecessor()) // Removing the last coma.
            stringRule += "]"
        }
        if let displayedTriggerLoadType = triggerLoadType {
            stringRule += ",\"load-type\":["
            for loadType in displayedTriggerLoadType {
                stringRule += "\"\(loadType)\","
            }
            stringRule = stringRule.substringToIndex(stringRule.endIndex.predecessor())
            stringRule += "]"
        }
        if let displayedTriggerIfDomain = triggerIfDomain {
            stringRule += ",\"if-domain\":["
            for ifDomain in displayedTriggerIfDomain {
                stringRule += "\"\(ifDomain)\","
            }
            stringRule = stringRule.substringToIndex(stringRule.endIndex.predecessor())
            stringRule += "]"
        } else if let displayedTriggerUnlessDomain = triggerUnlessDomain {
            stringRule += ",\"unless-domain\":["
            for unlessDomain in displayedTriggerUnlessDomain {
                stringRule += "\"\(unlessDomain)\","
            }
            stringRule = stringRule.substringToIndex(stringRule.endIndex.predecessor())
            stringRule += "]"
        }
        
        stringRule += "},\"action\":{\"type\": \"\(actionType)\""
        
        if let displayedActionSelector = actionSelector {
            stringRule += ",\"selector\":\"\(displayedActionSelector)\""
        }
        
        return stringRule + "}},"
    }
}