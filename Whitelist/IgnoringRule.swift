//
//  IgnoringRule.swift
//  Adios
//
//  Created by Armand Grillet on 12/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class IgnoringRule {
    var triggerUrlFilter: String
    
    func toString() -> String {
        return "{ \"trigger\": { \"url-filter\":\".*\",\"if-domain\":[\"*\(triggerUrlFilter)\"]}, \"action\": {\"type\": \"ignore-previous-rules\"}},"
    }
    
    init(domain: String) {
        self.triggerUrlFilter = domain
    }
}