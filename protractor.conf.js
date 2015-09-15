var argv = require('yargs').argv

var protractor_hash = {
  seleniumAddress: 'http://localhost:4444/wd/hub',

  framework: 'mocha',
  // stackTrace: false,

  capabilities: {
    'browserName': 'chrome'
    // "chromeOptions": {
    //   binary: '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome',
    //   args: [],
    //   extensions: [],
    // }
  },

  mochaOpts: {
    ui: 'bdd',
    reporter: "nyan",
    timeout: 300000, // 5 minutes
    grep: argv.grep,
    bail: true
  },

  restartBrowserBetweenTests: false,

  onPrepare: function() {
    global.byAttr = global.by;
    global.has    = global.by;
    browser.driver.manage().window().setPosition(400,8000);
    browser.apiUrl = argv.apiUrl
  }
}

exports.config = protractor_hash
