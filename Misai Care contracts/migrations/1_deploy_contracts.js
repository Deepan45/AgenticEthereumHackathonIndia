const VCRegistry = artifacts.require("VCRegistry");

module.exports = function (deployer) {
  deployer.deploy(VCRegistry);
};
