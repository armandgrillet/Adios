//
//  ListsManager.swift
//  Adios
//
//  Created by Armand Grillet on 01/09/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

public class ListsManager {
    public class func applyLists(completion: (() -> Void)) {
        var whitelistAssembled = ""
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if let whitelist = userDefaults.arrayForKey("whitelist") as! [String]? {
                for domain in whitelist {
                    whitelistAssembled += IgnoringRule(domain: domain).toString()
                }
            }
        }
        
        let fileManager = NSFileManager()
        let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios")
        let sharedContainerPathLocation = groupUrl?.path
        
        var baseListWithoutWhitelist = ""
        let baseListWithoutWhitelistPath = sharedContainerPathLocation! + "/baseListWithoutWhitelist.txt"
        if let content = fileManager.contentsAtPath(baseListWithoutWhitelistPath) {
            baseListWithoutWhitelist = String(data: content, encoding: NSUTF8StringEncoding)!
        }
        var baseList = baseListWithoutWhitelist + whitelistAssembled
        baseList = "[" + baseList.substringToIndex(baseList.endIndex.predecessor()) + "]" // Removing the last coma
        let baseListPath = sharedContainerPathLocation! + "/baseList.json"
        if !fileManager.fileExistsAtPath(baseListPath) {
            fileManager.createFileAtPath(baseListPath, contents: baseList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
        } else {
            try! baseList.writeToFile(baseListPath, atomically: true, encoding: NSUTF8StringEncoding)
        }
        
        var secondListWithoutWhitelist = ""
        let secondListWithoutWhitelistPath = sharedContainerPathLocation! + "/secondListWithoutWhitelist.txt"
        if let content = fileManager.contentsAtPath(secondListWithoutWhitelistPath) {
            secondListWithoutWhitelist = String(data: content, encoding: NSUTF8StringEncoding)!
        }
        var secondList = secondListWithoutWhitelist + whitelistAssembled
        secondList = "[" + secondList.substringToIndex(secondList.endIndex.predecessor()) + "]" // Removing the last coma
        let secondListPath = sharedContainerPathLocation! + "/secondList.json"
        if !fileManager.fileExistsAtPath(secondListPath) {
            fileManager.createFileAtPath(secondListPath, contents: secondList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
        } else {
            try! secondList.writeToFile(secondListPath, atomically: true, encoding: NSUTF8StringEncoding)
        }
        
        completion()
    }
}