# diplomskiEthereum

#prvi terminal pokrenuti mining node
ganache-cli

#iz direktorija webapp drugi terminal compalirati contracte i pokrenuti truffle
truffle compile
truffle migrate --reset
npm run dev


#metamask trenutni privatni account
#0x0a2192380E4a24c37944D73909cf4373D6359Ac4
#husband ozone distance segment trap vanish buzz only maple reject obtain choice

#slanje novca 1ETH na test account, from pogledati u ganache-cli pod private account bilo koji
curl -d '{"jsonrpc":"2.0","method":"eth_sendTransaction","params": [{"from":"0x8b0ac83ad710429eeda0de0bf764d8fded9bac72", "to":"0x0a2192380E4a24c37944D73909cf4373D6359Ac4", "value": 1e18}], "id":1}' -X POST http://127.0.0.1:8545/


#address _hValue je string, enumi kao PersonType _personType su uint, ttime je uint




