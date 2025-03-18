// Minimal Flutter web bootstrapper
// The official flutter.js gets replaced by Flutter SDK 
// during the build process

// Flutter web initialization script
(function() {
  "use strict";
  
  // Define loader API
  var _flutter = window._flutter || (window._flutter = {});
  var _loader = _flutter.loader || (_flutter.loader = {});
  
  // Create the initialization method
  _loader.loadEntrypoint = function(options) {
    var entrypointUrl = options.entrypointUrl || "main.dart.js";
    
    return new Promise(function(resolve, reject) {
      // Load the main script
      var script = document.createElement("script");
      script.src = entrypointUrl;
      script.type = "application/javascript";
      
      script.addEventListener("load", function() {
        if (window.init) {
          console.log("Flutter main script loaded successfully");
          window.init().then(function(engineInitializer) {
            if (options.onEntrypointLoaded) {
              options.onEntrypointLoaded(engineInitializer);
            } else {
              engineInitializer.initializeEngine().then(function(appRunner) {
                appRunner.runApp();
              });
            }
          }).catch(function(error) {
            console.error("Failed to initialize Flutter engine:", error);
            reject(error);
          });
        } else {
          var error = new Error("Could not find Flutter initialization function");
          console.error(error);
          reject(error);
        }
      });
      
      script.addEventListener("error", function(error) {
        console.error("Failed to load Flutter main script:", error);
        reject(error);
      });
      
      document.body.appendChild(script);
    });
  };
})(); 