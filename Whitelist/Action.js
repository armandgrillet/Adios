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
    arguments.completionFunction({ "url" : location.origin });
},
    
finalize: function(arguments) {
    document.location.reload();
}
    
};

var ExtensionPreprocessingJS = new Action