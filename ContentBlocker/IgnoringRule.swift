//
//  IgnoringRule.swift
//  Adios
//
//  Created by Armand Grillet on 12/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class IgnoringRule: Rule {
    init(domain: String) {
        super.init()
        self.triggerUrl = domain
        self.actionType = "ignore-previous-rules"
    }
}