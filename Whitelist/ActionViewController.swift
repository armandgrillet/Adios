//
//  ActionViewController.swift
//  Whitelist
//
//  Created by Armand Grillet on 01/09/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import MobileCoreServices
import SafariServices

class ActionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var domains = [String]()
    
    @IBOutlet weak var domainsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
                if let ignoredList = userDefaults.arrayForKey("whitelist") as! [String]? {
                    self.domains = ignoredList as [String]
                }
            }
                    
            for item: AnyObject in self.extensionContext!.inputItems {
                let extItem = item as! NSExtensionItem
                if let attachments = extItem.attachments {
                    for itemProvider: AnyObject in attachments {
                        if itemProvider.hasItemConformingToTypeIdentifier(String(kUTTypePropertyList)) {
                            itemProvider.loadItemForTypeIdentifier(String(kUTTypePropertyList), options: nil, completionHandler: { (item, error) in
                                let dictionary = item as! [String: AnyObject]
                                let domain = ((dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! [NSObject: AnyObject])["url"] as? String)!
                                if !self.domains.contains(domain) {
                                    self.domains.append(domain)
                                    if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
                                        userDefaults.setObject(self.domains, forKey: "whitelist")
                                        userDefaults.synchronize()
                                    }
                                } else {
//                                    self.domains.removeAtIndex(self.domains.indexOf(domain)!)
//                                    if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
//                                        userDefaults.setObject(self.domains, forKey: "whitelist")
//                                        userDefaults.synchronize()
//                                    }
                                }
                            })
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.domainsTableView.dataSource = self
                self.domainsTableView.delegate = self
                self.domainsTableView.allowsMultipleSelectionDuringEditing = false
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func apply(sender: UIButton) {
        var whitelistAssembled = ""
        for domain in domains {
            whitelistAssembled += IgnoringRule(domain: domain).toString()
        }
        
        var baseListWithoutWhitelist = ""
        var secondListWithoutWhitelist = ""
        
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            userDefaults.setObject(domains, forKey: "whitelist")
            userDefaults.synchronize()
            
            if let sharedBaseListWithoutWhitelist = userDefaults.stringForKey("baseListWithoutWhitelist") {
                baseListWithoutWhitelist = sharedBaseListWithoutWhitelist
            }
            if let sharedSecondListWithoutWhitelist = userDefaults.stringForKey("secondListWithoutWhitelist") {
                secondListWithoutWhitelist = sharedSecondListWithoutWhitelist
            }
            if let whitelist = userDefaults.arrayForKey("whitelist") as! [String]? {
                for domain in whitelist {
                    whitelistAssembled += IgnoringRule(domain: domain).toString()
                }
            }
        }
        
        let fileManager = NSFileManager()
        let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios")
        let sharedContainerPathLocation = groupUrl?.path
        
        var baseList = baseListWithoutWhitelist + whitelistAssembled
        baseList = "[" + baseList.substringToIndex(baseList.endIndex.predecessor()) + "]" // Removing the last coma
        let baseListPath = sharedContainerPathLocation! + "/baseList.json"
        if !fileManager.fileExistsAtPath(baseListPath) {
            fileManager.createFileAtPath(baseListPath, contents: baseList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
        } else {
            try! baseList.writeToFile(baseListPath, atomically: true, encoding: NSUTF8StringEncoding)
        }
        
        var secondList = secondListWithoutWhitelist + whitelistAssembled
        secondList = "[" + secondList.substringToIndex(secondList.endIndex.predecessor()) + "]" // Removing the last coma
        let secondListPath = sharedContainerPathLocation! + "/secondList.json"
        if !fileManager.fileExistsAtPath(secondListPath) {
            fileManager.createFileAtPath(secondListPath, contents: secondList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
        } else {
            try! secondList.writeToFile(secondListPath, atomically: true, encoding: NSUTF8StringEncoding)
        }
        
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.BaseContentBlocker") { (error: NSError?) -> Void in
            if error == nil {
                NSLog("Le base passe")
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                    if error == nil {
                        NSLog("Listes appliquees")
                        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
                    } else {
                        NSLog("%@", otherError!)
                    }
                }
            } else {
                NSLog("%@", error!)
            }
        }
    }
    
    func removeDomain(domain: String, indexPath: NSIndexPath) {
        domains.removeAtIndex(domains.indexOf(domain)!)
        domainsTableView.beginUpdates()
        domainsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        domainsTableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removeDomain(domains[indexPath.row], indexPath: indexPath)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return domains.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = domains[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell!.textLabel?.text = identifier
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    
}
