// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Flutter web bootstrap script for development or production environments.

// If we were previously loaded by a web service worker, make sure they
// get terminated.
if ("serviceWorker" in navigator) {
  window.addEventListener("load", function () {
    navigator.serviceWorker.register("/flutter_service_worker.js");
  });
}

// This script must be included in <head> to reflect Flutter web's requirements
// for CSP configuration.
var serviceWorkerVersion = null;

var scriptLoaded = false;
function loadMainDartJs() {
  if (scriptLoaded) {
    return;
  }
  scriptLoaded = true;
  var scriptTag = document.createElement("script");
  scriptTag.src = "main.dart.js";
  scriptTag.type = "application/javascript";
  document.body.append(scriptTag);
}

// The browser-compatible initialization method that will be called by Flutter.
window._flutter = { loader: {} };
window._flutter.loader.didCreateEngineInitializer = function(engineInitializer) {
  engineInitializer.initializeEngine().then(function(appRunner) {
    appRunner.runApp();
  });
};

// Define the loader API.
var flutter = {
  loader: {
    loadEntrypoint: function(options) {
      return new Promise(function(resolve, reject) {
        try {
          loadMainDartJs();
          resolve(true);
        } catch (e) {
          reject(e);
        }
      });
    }
  }
};

window.flutter = flutter; 