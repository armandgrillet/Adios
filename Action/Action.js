//
//  Action.js
//  Action
//
//  Created by Armand Grillet on 09/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        document.documentElement.innerHTML = "<h3 style=\"font-family: -apple-system; color:#e00b00;\">Enabling or disabling Adios for this website, wait a few seconds and the page will  automatically be reloaded...</h3>";
        arguments.completionFunction({ "url" : location.origin });
    },
    
    finalize: function(arguments) {
        document.location.reload();
    }
    
};
    
var ExtensionPreprocessingJS = new Action
