// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'
import { default as Sha1} from 'sha1';

// Import our contract artifacts and turn them into usable abstractions.
//mport metacoin_artifacts from '../../build/contracts/MetaCoin.json'
import piisznetwork_artifacts from '../../build/contracts/piiSZGNetwork.json'

// MetaCoin is our usable abstraction, which we'll use through the code below.
//var MetaCoin = contract(metacoin_artifacts);
var piiSZGNetwork = contract(piisznetwork_artifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;
const hour = 3600;
const minute = 60;

window.App = {
  start: function() {
    var self = this;

    // Bootstrap the MetaCoin abstraction for Use.
    //MetaCoin.setProvider(web3.currentProvider);
    piiSZGNetwork.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

      //self.refreshBalance();
    });
  },

  setStatus: function(message) {
    var status = document.getElementById("status");
    console.log(message);
    status.innerHTML = message;
  },
/*
  refreshBalance: function() {
    var self = this;

    var meta;
    MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.getBalance.call(account, {from: account});
    }).then(function(value) {
      var balance_element = document.getElementById("balance");
      balance_element.innerHTML = value.valueOf();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error getting balance; see log.");
    });
  },

  sendCoin: function() {
    var self = this;

    var amount = parseInt(document.getElementById("amount").value);
    var receiver = document.getElementById("receiver").value;

    this.setStatus("Initiating transaction... (please wait)");

    var meta;
    MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.sendCoin(receiver, amount, {from: account});
    }).then(function() {
      self.setStatus("Transaction complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error sending coin; see log.");
    });
  },*/

  createUniversityComponent:  function() {
    var universityKey = document.getElementById('uKeyCreateUComponent').value;
    var universityComponenetType = document.getElementById('uCTypeCreateUComponent').selectedIndex;
    var openingTime = parseInt(document.getElementById('openingTimeCreateUComponent').value);
    var closingTime = parseInt(document.getElementById('closingTimeCreateUComponent').value);

    var universityKeyHashed = Sha1(universityKey);

    this.setStatus("Initiating transaction of creating University Component... (please wait)");

    var pii;
    piiSZGNetwork.deployed().then(function(instance) {
      pii = instance;
      return pii.createUniversityComponenet(universityKeyHashed,universityComponenetType, openingTime, closingTime, {from: account});//
    }).then(function(creation) {
      if(creation == true)
        self.setStatus("Creating University Component complete!");
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error creating University Component; see log.");
    });
  },
  
  createMember: function() {
    var jmbag = document.getElementById('jmbagCreateMem').value;
    var personType = document.getElementById('personTypeCreateMem').selectedIndex;
    var uComponenetType = document.getElementById('uComponenetTypeCreateMem').selectedIndex;

    var jmbagHashed = Sha1(jmbag);
    
    this.setStatus("Initiating transaction of creating Member... (please wait)");

    var pii;
    piiSZGNetwork.deployed().then(function(instance) {
      pii = instance;
      return pii.createMember(jmbagHashed, personType, uComponenetType, {from: account});
    }).then(function(creation) {
      if(creation == true)
        self.setStatus("Creating Member complete!");
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error creating Member; see log.");
    });
  
  },
  
  callAccessTransaction: function() {
    var jmbag = document.getElementById('jmbagCheck').value;
    var universityKey = document.getElementById('uKeyCheck').value;
    var d = new Date();
    var n = Date.now();
    let ttime = d.getHours()*hour+d.getMinutes()*minute;

    var jmbagHashed = Sha1(jmbag);
    var universityKeyHashed = Sha1(universityKey);
    

    var pii;
    piiSZGNetwork.deployed().then(function(instance) {
      pii = instance;
      return pii.callAccessTransaction(jmbagHashed, universityKeyHashed, ttime, n, {from: account});//
    }).then(function(access) {
      if(access == true)
        var accesS = "granted";
      else accesS = "denied";
      self.setStatus("Access had been "+accesS+" .");
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error creating Member; see log.");
    });
  
  }
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:9545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"));
  }

  App.start();
});
