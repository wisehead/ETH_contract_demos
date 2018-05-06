var MyContract = artifacts.require("EncryptedToken");

module.exports = function(deployer) {
  deployer.deploy(MyContract);
};
