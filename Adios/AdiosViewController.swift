//
//  AdiosViewController.swift
//  Adios
//
//  Created by Armand Grillet on 16/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class AdiosViewController: UIViewController {
    let listsManager = ListsManager()
    
    @IBOutlet weak var configurationState: UILabel!
    @IBOutlet weak var mainList: UILabel!
    @IBOutlet weak var secondList: UILabel!
    @IBOutlet weak var socialList: UILabel!
    @IBOutlet weak var lastUpdate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let alwaysFollowedLists = ["AdiosList"]
        let followedLists = listsManager.getFollowedLists()
        if followedLists != [] {
            configurationState.text = "Adios is configured, you're following the lists:"
        } else {
            configurationState.text = "Adios doesn't block ads yet! Configure Adios first."
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


