pragma solidity ^0.5.0;

import "contracts/proof/Fin4BaseProofType.sol";
import "contracts/proof/modules/ApprovalByOneAddress.sol";
import "contracts/Fin4TokenBase.sol";
import "contracts/utils.sol";

contract ApprovalBySpecificAddress is Fin4BaseProofType, ApprovalByOneAddress, utils {

  constructor(address Fin4MainAddress)
    Fin4BaseProofType("ApprovalBySpecificAddress", "The specified address has to approve", Fin4MainAddress)
    public {}

  function submitProof(address tokenAdrToReceiveProof, uint claimId, address approver) public returns(bool) {
    PendingApproval storage pa = pendingApprovals[approver];
    pa.tokenAdrToReceiveProof = tokenAdrToReceiveProof;
    pa.claimIdOnTokenToReceiveProof = claimId;
    pa.requester = msg.sender;
    pa.approver = approver;
    string memory message = string(abi.encodePacked(
      "You were requested to approve the proof type ApprovalBySpecificAddress on the action type ",
      Fin4TokenBase(tokenAdrToReceiveProof).name(), ", claim #", uint2str(claimId)));
    Fin4MainStrut(Fin4Main).addMessage(msg.sender, approver, message, address(this));
    return true;
  }

  function receiveApprovalFromSpecificAddress() public returns(bool) {
    require(pendingApprovals[msg.sender].approver == msg.sender, "This address is not registered as approver for any pending approval");
    _sendApproval(pendingApprovals[msg.sender].tokenAdrToReceiveProof, pendingApprovals[msg.sender].claimIdOnTokenToReceiveProof);
    return true;
  }

}
