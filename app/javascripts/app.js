// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
console.log(Web3.version);
import { default as contract } from 'truffle-contract'
import { default as Sha1} from 'sha1';


// Import our contract artifacts and turn them into usable abstractions.

import piiszg_artifacts from '../../build/contracts/piiSZG.json'

var piiSZG = contract(piiszg_artifacts);

// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;
const hour = 3600;
const minute = 60;
var baseUrl;
var hashedTemp = '';
var hashedTemp2 = '';
var hashedTemp3 = '';
var hashedTemp4 = '';


window.App = {
  start: function() {
    var self = this;
    
    // Bootstrap the MetaCoin abstraction for Use.
    piiSZG.setProvider(web3.currentProvider);
    
    //dirty hack for web3@1.0.0 support for localhost testrpc, see https://github.com/trufflesuite/truffle-contract/issues/56#issuecomment-331084530
    if (typeof piiSZG.currentProvider.sendAsync !== "function") {
      piiSZG.currentProvider.sendAsync = function() {
        return piiSZG.currentProvider.send.apply(
          piiSZG.currentProvider, arguments
        );
      };
    }
    
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
      
      self.setStatus("Loading");
      if(self.getCookie("hashMem")!== '')
        self.refreshMem();
      if(self.getCookie("hashUC")!== '')
        self.refreshUC();
      if(self.getCookie("hashAccess1")!== '')
        self.refreshAccess();
    });
  },
  
  setCookie: function(cname, cvalue, exhours) {
    var d = new Date();
    d.setTime(d.getTime() + (exhours*60*60*1000));
    var expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  },
  
  
  getCookie: function(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  },
  //setting top banner message
  setStatus: function(message) {
    var status = document.getElementById("status");
    console.log(message);
    status.innerHTML = message;
    baseUrl = window.location.href.split("?")[0];
    window.history.pushState('name', '', baseUrl)
  },


    createUniversityComponent:  function() {
      var pii;
      var self = this;  
      var universityKey = document.getElementById('uKeyCreateUComponent').value;
      var universityComponenetType = document.getElementById('uCTypeCreateUComponent').selectedIndex;
      var openingTime = parseInt(document.getElementById('openingTimeCreateUComponent').value);
      var closingTime = parseInt(document.getElementById('closingTimeCreateUComponent').value);
      
      //hash of entered key
      var universityKeyHash = Sha1(universityKey);
      var universityKeyHashed = "0x"+universityKeyHash;
      self.setCookie("hashUC",universityKeyHashed,1);
      
      this.setStatus("Initiating transaction of creating University Component... (please wait)");
      
      //sending UniversityComponent to smart contract
      var pii;
      piiSZG.deployed().then(function(instance) {
        pii = instance;
        return pii.createUniversityComponenet(universityKeyHashed,universityComponenetType, openingTime, closingTime, {from: account});
      }).then(function(creation) {
          if(creation.receipt.status == "0x01"){
            console.log(creation);
            self.setStatus("Creating University Component complete!");
            self.refreshUC();
          }
          else{
            console.log(creation);
            self.refreshUC();
          }
        }).catch(function(e) {
          console.log(e);
          self.setStatus("Error creating University Component; see log.");
          self.refreshUC();
        });
    },
    
    createMember: function() {
      var self = this;
      var jmbag = document.getElementById('jmbagCreateMem').value;
      var personType = document.getElementById('personTypeCreateMem').selectedIndex;
      var uComponenetType = document.getElementById('uComponenetTypeCreateMem').selectedIndex;
      var tidCreateMem = document.getElementById('tidCreateMem').value;
      
      //hash of entered key
      var jmbagHash = Sha1(jmbag).toString();
      var jmbagHashed = "0x"+jmbagHash;
      self.setCookie("hashMem",jmbagHashed,1);
      
      this.setStatus("Initiating transaction of creating Member... (please wait)");  
        var pii;
        
        //sending Member to smart contract
        piiSZG.deployed().then(function(instance) {
          pii = instance;
          return pii.createMember(jmbagHashed, personType, uComponenetType, tidCreateMem, {from: account});
        }).then(function(creation) {
          if(creation.receipt.status == "0x01") {
            self.setStatus("Creating Member complete!");
            self.refreshMem();
          }
          else{
            console.log(error);
            self.setStatus("Error creating Member; see log.");
          }
        }).catch(function(e) {
          console.log(e);
          self.setStatus("Error creating Member; see log.");
          self.refreshMem();
        });
        
      },
      
      callAccessTransaction: function() {
        var pii;
        var self = this;
        var jmbag = document.getElementById('jmbagCheck').value;
        var universityKey = document.getElementById('uKeyCheck').value;
        var tidCheck = document.getElementById('tidCheck').value;
        var d = new Date();
        var n = Date.now();
        let ttime = d.getHours()*hour+d.getMinutes()*minute+d.getSeconds();
        
        var jmbagHash = Sha1(jmbag);
        var jmbagHashed = "0x"+jmbagHash;
        var universityKeyHash = Sha1(universityKey);
        var universityKeyHashed = "0x"+universityKeyHash;
        self.setCookie("hashAccess1",universityKeyHashed,1);
        self.setCookie("hashAccess2",n,1);

        //sending transaction to smart contract
        var pii;
        piiSZG.deployed().then(function(instance) {
          pii = instance;
          pii.callAccessTransaction(jmbagHashed, universityKeyHashed, ttime, n, tidCheck, {from: account})
        //on fullfiled promise refresh status about transaction
        .then(function(access) {
          console.log(access);
          self.setStatus("Transaction complete!");
          self.refreshAccess();
          /*var wEvent = pii.ControlEvent();
          wEvent.watch(function(error, result){
            if (!error)
            {
              
              var status_element = document.getElementById("status");
              status_element.innerHTML = result.args.controlEvent;
              
            } else {
              console.log(error);
              
            }
          });*/
        })
          .catch(function(e) {
            console.log(e);
            self.setStatus("Error in callAccessTransaction; see log.");
            self.refreshAccess();
          });
        }).catch(function(e) {
          console.log(e);
          self.setStatus("Error in callAccessTransaction; see log.");
          self.refreshAccess();
        })
      },    
      
      refreshMem: function() {
        var self = this;
        var pii;
        hashedTemp = self.getCookie("hashMem");
        piiSZG.deployed().then(function(instance) {
          pii = instance;
          //get public mapping members
          return pii.members.call(hashedTemp,{from: account});
        }).then(function(value) {
          var status_element = document.getElementById("status");
          status_element.innerHTML = value.valueOf().toString();
        }).catch(function(e) {
          console.log(e);
          self.setStatus("Error getting temp balancee; see log.");
        });
      },
      refreshUC: function() {
        var self = this;
        var pii;
        hashedTemp2 = self.getCookie("hashUC");
        piiSZG.deployed().then(function(instance) {
          pii = instance;
          //get public mapping universityComponenets
          return pii.universityComponenets.call(hashedTemp2,{from: account});
        }).then(function(value) {
          var status_element = document.getElementById("status2");
          status_element.innerHTML = value.valueOf().toString();
        }).catch(function(e) {
          console.log(e);
          self.setStatus("Error getting temp balancee; see log.");
        });
      },

      refreshAccess: function() {
        var self = this;
        var pii;
        hashedTemp3 = self.getCookie("hashAccess1");
        hashedTemp4 = self.getCookie("hashAccess2");
        piiSZG.deployed().then(function(instance) {
          pii = instance;
          //get public mapping universityComponenets
          return pii.getAccessFromUC.call(hashedTemp3, hashedTemp4, {from: account});
        }).then(function(value) {
          var status_element = document.getElementById("status3");
          status_element.innerHTML = value.valueOf().toString();
        }).catch(function(e) {
          console.log(e);
          self.setStatus("Error getting temp balancee; see log.");
        });
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
    