//
//  IgnoringRule.swift
//  Adios
//
//  Created by Armand Grillet on 26/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class IgnoringRule {
    var triggerUrlFilter: String = ""
    var triggerUrlFilterIsCaseSensitive: Bool?
    var triggerResourceType: [String]?
    var triggerLoadType: [String]?
    var triggerIfDomain: [String]?
    var triggerUnlessDomain: [String]?
    
    var actionType: String = ""
    var actionSelector: String?
    
    func toString() -> String {
        return "{ \"trigger\": { \"url-filter\": \"\(triggerUrlFilter)\"}, \"action\": {\"type\": \"ignore-previous-rules\"}},"
    }
    
    init(domain: String) {
        self.triggerUrlFilter = domain
        self.actionType = "ignore-previous-rules"
    }
}