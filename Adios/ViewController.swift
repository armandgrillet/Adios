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
    
    @IBOutlet weak var wheel: UIActivityIndicatorView!
    @IBOutlet weak var loader: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reloadBlockerList(sender: UIButton) {
            SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.List") { (error: NSError?) -> Void in
                let realError = error.debugDescription
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Done", message: realError, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    })
            }
    }
}

