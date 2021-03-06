pragma solidity ^0.5.0;

import "contracts/proof/Fin4BaseProofType.sol";

contract MinimumInterval is Fin4BaseProofType {

  constructor(address Fin4MainAddress)
    Fin4BaseProofType(Fin4MainAddress)
    public {
      name = "MinimumInterval";
      description = "Defines a minimum time that has to pass between claims.";
      // minimumInterval = 1 * 24 * 60 * 60 * 1000; // 1 day
      messageType = MessageType.INFO;
    }

    function submitProof_MinimumInterval(address tokenAdrToReceiveProof, uint claimId) public returns(bool) {
      if (minimumIntervalRequirementMet(tokenAdrToReceiveProof, msg.sender, claimId)) {
        _sendApproval(tokenAdrToReceiveProof, claimId);
      } else {
        string memory message = string(abi.encodePacked(
          Fin4TokenStrut(tokenAdrToReceiveProof).name(),
          ": The time between your previous claim and this one is shorter than the minimum required timespan of ",
          uint2str(_getMinimumInterval(tokenAdrToReceiveProof) / 1000), "s."
        ));
        Fin4Messages(_Fin4MessagesAddr()).addMessage(uint(messageType), msg.sender, msg.sender, message, address(this), "");
      }
      return true;
    }

    function minimumIntervalRequirementMet(address tokenAddressUsingThisProofType, address claimer, uint claimId) private view returns(bool) {
      uint timeBetween = Fin4TokenStrut(tokenAddressUsingThisProofType).getTimeBetweenThisClaimAndThatClaimersPreviousOne(claimer, claimId);
      return timeBetween >= _getMinimumInterval(tokenAddressUsingThisProofType);
    }

    // @Override
    function getParameterForActionTypeCreatorToSetEncoded() public pure returns(string memory) {
      return "uint:minimumInterval:days";
    }

    // @Override
    function getParameterizedDescription(address token) public view returns(string memory) {
      return string(abi.encodePacked(
          "The action type creator defined the minimum time that has to pass between claims as ",
          uint2str(_getMinimumInterval(token) / (1000 * 60 * 60 * 24)), " days."
        ));
    }

    function _getMinimumInterval(address token) private view returns(uint) {
      return fin4TokenToParametersSetOnThisProofType[token][0] * 24 * 60 * 60 * 1000; // from days to miliseconds
    }

}
