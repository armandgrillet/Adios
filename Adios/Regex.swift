//
//  Regex.swift
//  Parser
//
//  Created by Armand Grillet on 30/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(pattern: String) {
        self.pattern = pattern
        self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: .ReportCompletion, range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}