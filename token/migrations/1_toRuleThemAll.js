const IdeaAddress   = artifacts.require('./IdeaAddress.sol');
const IdeaBasicCoin = artifacts.require('./IdeaBasicCoin.sol');
const IdeaCoin      = artifacts.require('./IdeaCoin.sol');
const IdeaProject   = artifacts.require('./IdeaProject.sol');
const IdeaString    = artifacts.require('./IdeaString.sol');
const IdeaSubCoin   = artifacts.require('./IdeaSubCoin.sol');
const IdeaTypeBind  = artifacts.require('./IdeaTypeBind.sol');
const IdeaUint      = artifacts.require('./IdeaUint.sol');
const Migrations    = artifacts.require('./Migrations.sol');

module.exports = function(deployer) {
    // Migration
    deployer.deploy(Migrations);

    // Libs and utils
    deployer.deploy(IdeaAddress);
    deployer.deploy(IdeaUint);
    deployer.deploy(IdeaString);
    deployer.deploy(IdeaTypeBind);

    // Basic coin
    deployer.deploy(IdeaBasicCoin);

    // Top-level contracts
    deployer.deploy(IdeaSubCoin);
    deployer.deploy(IdeaProject);
    deployer.deploy(IdeaCoin);
};