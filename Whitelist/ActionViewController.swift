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
    var baseListWithoutWhitelist = ""
    var secondListWithoutWhitelist = ""
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var domainsTableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
            if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
                if let ignoredList = userDefaults.arrayForKey("whitelist") as! [String]? {
                    domains = ignoredList as [String]
                }
                if let sharedBaseListWithoutWhitelist = userDefaults.stringForKey("baseListWithoutWhitelist") {
                    baseListWithoutWhitelist = sharedBaseListWithoutWhitelist
                }
                if let sharedSecondListWithoutWhitelist = userDefaults.stringForKey("secondListWithoutWhitelist") {
                    secondListWithoutWhitelist = sharedSecondListWithoutWhitelist
                }
            }
                    
            for item: AnyObject in self.extensionContext!.inputItems {
                let extItem = item as! NSExtensionItem
                if let attachments = extItem.attachments {
                    for itemProvider: AnyObject in attachments {
                        if itemProvider.hasItemConformingToTypeIdentifier(String(kUTTypePropertyList)) {
                            itemProvider.loadItemForTypeIdentifier(String(kUTTypePropertyList), options: nil, completionHandler: { (item, error) in
                                let dictionary = item as! [String: AnyObject]
                                if let domain = ((dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! [NSObject: AnyObject])["url"] as? String) {
                                    if !self.domains.contains(domain) {
                                        self.domains.append(domain)
                                    } else {
                                        //                                    self.domains.removeAtIndex(self.domains.indexOf(domain)!)
                                        //                                    if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
                                        //                                        userDefaults.setObject(self.domains, forKey: "whitelist")
                                        //                                        userDefaults.synchronize()
                                        //                                    }
                                    }
                                    self.domainsTableView.dataSource = self
                                    self.domainsTableView.delegate = self
                                    self.domainsTableView.allowsMultipleSelectionDuringEditing = false
                                    self.domainsTableView.backgroundView = nil
                                    self.domainsTableView.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
                                    self.domainsTableView.reloadData()
                                    self.saveButton.enabled = true
                                } else {
                                    self.done(false)
                                }
                            })
                        }
                    }
                }
            }
    }
    
    func updateAndDone() {
        domainsTableView.userInteractionEnabled = false
        saveButton.enabled = false
        cancelButton.enabled = false
        domainsTableView.alpha = 0
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var whitelistAssembled = ""
            for domain in self.domains {
                whitelistAssembled += IgnoringRule(domain: domain).toString()
            }
            
            let fileManager = NSFileManager()
            let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios")
            let sharedContainerPathLocation = groupUrl?.path
            
            var baseList = self.baseListWithoutWhitelist + whitelistAssembled
            baseList = "[" + baseList.substringToIndex(baseList.endIndex.predecessor()) + "]" // Removing the last coma
            let baseListPath = sharedContainerPathLocation! + "/baseList.json"
            if !fileManager.fileExistsAtPath(baseListPath) {
                fileManager.createFileAtPath(baseListPath, contents: baseList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
            } else {
                try! baseList.writeToFile(baseListPath, atomically: true, encoding: NSUTF8StringEncoding)
            }
            
            var secondList = self.secondListWithoutWhitelist + whitelistAssembled
            secondList = "[" + secondList.substringToIndex(secondList.endIndex.predecessor()) + "]" // Removing the last coma
            let secondListPath = sharedContainerPathLocation! + "/secondList.json"
            if !fileManager.fileExistsAtPath(secondListPath) {
                fileManager.createFileAtPath(secondListPath, contents: secondList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
            } else {
                try! secondList.writeToFile(secondListPath, atomically: true, encoding: NSUTF8StringEncoding)
            }
        
            dispatch_async(dispatch_get_main_queue()) {
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.BaseContentBlocker") { (error: NSError?) -> Void in
                    if error == nil {
                        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                            if otherError == nil {
                                self.done(true)
                            } else {
                                self.done(true)
                            }
                        }
                    } else {
                        self.done(true)
                    }
                }
            }
        }
    }
    
    func done(reload: Bool) {
        let resultsProvider = NSItemProvider(item: [NSExtensionJavaScriptFinalizeArgumentKey: ["reload": reload]], typeIdentifier: String(kUTTypePropertyList))
        
        let resultsItem = NSExtensionItem()
        resultsItem.attachments = [resultsProvider]
        
        self.extensionContext!.completeRequestReturningItems([resultsItem], completionHandler: nil)
        
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        done(false)
    }
    @IBAction func save(sender: AnyObject) {
        let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios")!
        if let ignoredDomains = userDefaults.arrayForKey("whitelist") as! [String]? {
            if domains != ignoredDomains {
               userDefaults.setObject(domains, forKey: "whitelist")
                updateAndDone()
            } else {
                done(false)
            }
        } else {
            userDefaults.setObject(domains, forKey: "whitelist")
            updateAndDone()
        }
    }
    
    @IBAction func apply(sender: UIButton) {
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            NSLog("%d", domains.count)
            domains.removeAtIndex(domains.indexOf(domains[indexPath.row])!)
            NSLog("%d", domains.count)
            domainsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            domainsTableView.reloadData()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
