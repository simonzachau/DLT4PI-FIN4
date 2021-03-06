pragma solidity ^0.5.0;

import "contracts/proof/SpecificAddress.sol";

contract ActionTypeCreator is SpecificAddress {

  constructor(address Fin4MainAddress)
    SpecificAddress(Fin4MainAddress)
    public {}

  // @Override
  function setNameAndDescription() public returns(bool) {
    name = "ActionTypeCreator";
    description = "The action type creator has to approve.";
  }

  function submitProof_ActionTypeCreator(address tokenAdrToReceiveProof, uint claimId) public returns(bool) {
    submitProof_SpecificAddress(tokenAdrToReceiveProof, claimId, getCreatorOfToken(tokenAdrToReceiveProof));
  }

  // @Override
  function getMessageText() public pure returns(string memory) {
    return "You as the action type creator were requested to approve the proof type ActionTypeCreator on the action type ";
  }

}
