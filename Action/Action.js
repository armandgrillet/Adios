//
//  Action.js
//  Action
//
//  Created by Armand Grillet on 27/07/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        // Here, you can run code that modifies the document and/or prepares
        // things to pass to your action's native code.
        
        // We will not modify anything, but will pass the body's background
        // style to the native code.
        
        arguments.completionFunction({ "url" : location.origin })
    },
    
    finalize: function(arguments) {
        alert(arguments["alert"])
    }
    
};
    
var ExtensionPreprocessingJS = new Action
