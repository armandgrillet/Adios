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

class WhitelistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var domains = [String]()
    var baseListWithoutWhitelist = ""
    var secondListWithoutWhitelist = ""
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var domainsTableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let ignoredList = NSUserDefaults.standardUserDefaults().arrayForKey("whitelist") as! [String]? {
            domains = ignoredList as [String]
        }
        if let sharedBaseListWithoutWhitelist = NSUserDefaults.standardUserDefaults().stringForKey("baseListWithoutWhitelist") {
            baseListWithoutWhitelist = sharedBaseListWithoutWhitelist
        }
        if let sharedSecondListWithoutWhitelist = NSUserDefaults.standardUserDefaults().stringForKey("secondListWithoutWhitelist") {
            secondListWithoutWhitelist = sharedSecondListWithoutWhitelist
        }
        
        self.domainsTableView.dataSource = self
        self.domainsTableView.delegate = self
        self.domainsTableView.allowsMultipleSelectionDuringEditing = false
        self.domainsTableView.backgroundView = nil
        self.domainsTableView.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
        self.domainsTableView.reloadData()
    }
    
    @IBAction func addDomain(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add domain", message: "Websites in the whitelist are not analyzed by Adios", preferredStyle: .Alert)
        let domainAction = UIAlertAction(title: "Add", style: .Default) { (_) in
            let domainTextField = alertController.textFields![0] as UITextField
            var domain = domainTextField.text!
            domain = domain.substringFromIndex( domain.rangeOfString("://", options: .LiteralSearch, range: nil, locale: nil)?.startIndex.successor().successor().successor() ?? domain.startIndex )
            if domain.characters.last == "/" {
                domain = domain.substringToIndex(domain.endIndex.predecessor())
            }
            self.domains.insert(domain, atIndex: 0)
            self.domainsTableView.reloadData()
        }
        domainAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "www.igen.fr"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                var domain = textField.text!
                domain = domain.substringFromIndex( domain.rangeOfString("://", options: .LiteralSearch, range: nil, locale: nil)?.startIndex.successor().successor().successor() ?? domain.startIndex )
                if domain.characters.last == "/" {
                    domain = domain.substringToIndex(domain.endIndex.predecessor())
                }
                    
                if Regex(pattern: "^(?!\\-)(?:[a-zA-Z\\d\\-]{0,62}[a-zA-Z\\d]\\.){1,126}(?!\\d+)[a-zA-Z\\d]{1,63}$").test(domain) { // Real domain.
                    if self.domains.contains(domain) {
                        domainAction.enabled = false
                    } else {
                       domainAction.enabled = true
                    }
                } else {
                    domainAction.enabled = false
                }
            }
        }
        
        alertController.addAction(domainAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func apply(sender: UIButton) {
        domainsTableView.userInteractionEnabled = false
        addButton.enabled = false
        cancelButton.enabled = false
        applyButton.setTitle("Applying...", forState: .Disabled)
        applyButton.setTitleColor(UIColor.blackColor(), forState: .Disabled)
        applyButton.enabled = false
        domainsTableView.alpha = 0
        
        var whitelistAssembled = ""
        for domain in self.domains {
            whitelistAssembled += IgnoringRule(domain: domain).toString()
        }
        NSUserDefaults.standardUserDefaults().setObject(self.domains, forKey: "whitelist")
        NSUserDefaults.standardUserDefaults().synchronize()
        
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
        
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.BaseContentBlocker") { (error: NSError?) -> Void in
            if error == nil {
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                    if otherError == nil {
                        self.performSegueWithIdentifier("Done", sender: self)
                    } else {
                        self.performSegueWithIdentifier("Done", sender: self)
                    }
                }
            } else {
                self.performSegueWithIdentifier("Done", sender: self)
            }
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            domains.removeAtIndex(domains.indexOf(domains[indexPath.row])!)
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
