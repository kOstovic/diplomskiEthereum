// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'
import { default as Sha1} from 'sha1';

// Import our contract artifacts and turn them into usable abstractions.
import metacoin_artifacts from '../../build/contracts/MetaCoin.json'
import piiszg_artifacts from '../../build/contracts/piiSZG.json'

// MetaCoin is our usable abstraction, which we'll use through the code below.
var MetaCoin = contract(metacoin_artifacts);
var piiSZG = contract(piiszg_artifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;
const hour = 3600;
const minute = 60;
var baseUrl;
var pii;
/*
if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
  window.web3 = new Web3(web3.currentProvider);
  piiSZG.setProvider(web3.currentProvider);
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
 } else {
  // set the provider you want from Web3.providers
  var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  piiSZG.setProvider(web3.currentProvider);
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
 }*/

 //App.start(); 
/*
if (typeof web3 !== 'undefined') {
  console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
  // Use Mist/MetaMask's provider
  //window.history.pushState("object or string", "Title", "/"+window.location.href.substring(window.location.href.lastIndexOf('/') + 1).split("?")[0]);
  window.web3 = new Web3(web3.currentProvider);
}*/
window.App = {
  start: function() {
    var self = this;

    self.setStatus("Not ready for transactions");
    piiSZG.setProvider(web3.currentProvider);
    piiSZG.deployed().then(function(instance) {
      pii = instance;
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
      self.setStatus("Ready for transactions");
      });
    });
  },

  setStatus: function(message) {
    var status = document.getElementById("status");
    console.log(message);
    status.innerHTML = message;
  },

  refreshStatus: function(universityKeyHashed,n) {
    var self = this;

    /*var pii;
    piiSZG.deployed().then(function(instance) {
      pii = instance;*/
      pii.getAccess.call(universityKeyHashed, n, {from: account})
      .then(function(value) {
        self.setStatus(value.toString());
      }).catch(function(e) {
        console.log(e);
        self.setStatus("Error getting getAccess; see log.");
    });
  /*}).catch(function(e) {
    console.log(e);
    self.setStatus("Error getting getAccess; see log.");
  })*/
},
  createUniversityComponent:  function() {
    var self = this;  
    var universityKey = document.getElementById('uKeyCreateUComponent').value;
    var universityComponenetType = document.getElementById('uCTypeCreateUComponent').selectedIndex;
    var openingTime = parseInt(document.getElementById('openingTimeCreateUComponent').value);
    var closingTime = parseInt(document.getElementById('closingTimeCreateUComponent').value);

    var universityKeyHash = Sha1(universityKey);
    var universityKeyHashed = "0x"+universityKeyHash;

    this.setStatus("Initiating transaction of creating University Component... (please wait)");

    /*var pii;
    piiSZG.deployed().then(function(instance) {
      pii = instance;*/
      pii.createUniversityComponenet(universityKeyHashed,universityComponenetType, openingTime, closingTime, {from: account})
     .then(function(creation) {
      if(creation.receipt.status == "0x01"){
        console.log(creation);
        self.setStatus("Creating University Component complete!");
        baseUrl = window.location.href.split("?")[0];
        window.history.pushState('name', '', baseUrl);
      }
      else{
        console.log(creation);
        baseUrl = window.location.href.split("?")[0];
        window.history.pushState('name', '', baseUrl);
      }
      }).catch(function(e) {
        console.log(e);
        baseUrl = window.location.href.split("?")[0];
        window.history.pushState('name', '', baseUrl);
        self.setStatus("Error creating University Component; see log.");
      });
    /*.catch(function(e) {
      console.log(e);
      baseUrl = window.location.href.split("?")[0];
      window.history.pushState('name', '', baseUrl);
      self.setStatus("Error creating University Component; see log.");
    });
  });*/
  window.location.reload();
  },
  
  createMember: function() {
    var self = this;
    var jmbag = document.getElementById('jmbagCreateMem').value;
    var personType = document.getElementById('personTypeCreateMem').selectedIndex;
    var uComponenetType = document.getElementById('uComponenetTypeCreateMem').selectedIndex;

    var jmbagHash = Sha1(jmbag);
    var jmbagHashed = "0x"+jmbagHash;
    
    this.setStatus("Initiating transaction of creating Member... (please wait)");

    //var pii;
    /*piiSZG.deployed().then(function(instance) {
      pii = instance;*/
      pii.createMember(jmbagHashed, personType, uComponenetType, {from: account})
      .then(function(creation) {
      if(creation.receipt.status == "0x01"){
        console.log(creation);
        self.setStatus("Creating Member complete!");
        baseUrl = window.location.href.split("?")[0];
        window.history.pushState('name', '', baseUrl);
      }
      else {
      console.log(creation);
      baseUrl = window.location.href.split("?")[0];
      window.history.pushState('name', '', baseUrl);
      }
      }).catch(function(e) {
        console.log(e);
        baseUrl = window.location.href.split("?")[0];
        window.history.pushState('name', '', baseUrl);
        self.setStatus("Error creating Member; see log.");
      });
    /*}).catch(function(e) {
        console.log(e);
        baseUrl = window.location.href.split("?")[0];
        window.history.pushState('name', '', baseUrl);
        self.setStatus("Error creating Member; see log.");
      });*/
  },
  
  callAccessTransaction: function() {
    var self = this;
    var jmbag = document.getElementById('jmbagCheck').value;
    var universityKey = document.getElementById('uKeyCheck').value;
    var d = new Date();
    var n = Date.now();
    let ttime = d.getHours()*hour+d.getMinutes()*minute;

    var jmbagHash = Sha1(jmbag);
    var jmbagHashed = "0x"+jmbagHash;
    var universityKeyHash = Sha1(universityKey);
    var universityKeyHashed = "0x"+universityKeyHash;
    
    //var pii;
    //piiSZG.deployed().then(function(instance) {
      //pii = instance;
      pii.callAccessTransaction(jmbagHashed, universityKeyHashed, ttime, n, {from: account})
      .then(function(access) {
        console.log(access);
        self.setStatus("Transaction complete!");
        self.refreshStatus(universityKeyHashed,n);
      })
      .catch(function(e) {
        console.log(e);
        self.setStatus("Error in callAccessTransaction; see log.");
    });
   /* }).catch(function(e) {
        console.log(e);
        self.setStatus("Error in callAccessTransaction; see log.");
    })*/
  }
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    //window.history.pushState("object or string", "Title", "/"+window.location.href.substring(window.location.href.lastIndexOf('/') + 1).split("?")[0]);
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    //window.history.pushState("object or string", "Title", "/"+window.location.href.substring(window.location.href.lastIndexOf('/') + 1).split("?")[0]);
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));
  }

  App.start();
});
