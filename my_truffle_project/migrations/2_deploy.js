const Mycontractdapp = artifacts.require("Mycontractdapp");

module.exports = function(deployer){
    deployer.deploy(Mycontractdapp);
};
