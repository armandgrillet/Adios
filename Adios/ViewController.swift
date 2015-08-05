//
//  ViewController.swift
//  Adios
//
//  Created by Armand Grillet on 27/06/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import SafariServices
import Foundation

class ViewController: UIViewController {
    let defaults = NSUserDefaults(suiteName: "group.AG.Adios.List")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Hey")
        
        defaults.addObserver(self, forKeyPath: "ignore", options: NSKeyValueObservingOptions.New, context: nil)
        
        // self.reloadBlockerList(UIButton())
    }
    
    deinit {
        print("Deinit")
        defaults.removeObserver(self, forKeyPath: "ignore")
    }
    
    internal override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("yo")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func reloadBlockerList(sender: UIButton) {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.List") { (error: NSError?) -> Void in
            print(error)
        }
        
        if let ignoredList = defaults.arrayForKey("ignore") as! [String]? {
            defaults.setObject(ignoredList, forKey: "ignore")
            defaults.synchronize()
        }
    }
}

