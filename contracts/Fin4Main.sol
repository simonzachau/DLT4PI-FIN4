pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import 'contracts/Fin4Token.sol';
import 'contracts/proof/Fin4BaseProofType.sol';

contract Fin4Main {

  address[] public children; // all Action Types
  // mapping (address => bool) public officialChildren; // TODO for Sergiu's TCR

  // This methods creates new action types and gets called from TypeCreation
	function createNewToken(string memory name, string memory symbol, address[] memory requiredProofTypes,
    uint[] memory paramValues, uint[] memory paramValuesIndices) public returns(address) {
    Fin4Token newToken = new Fin4Token(name, symbol, address(this), msg.sender);

    for (uint i = 0; i < requiredProofTypes.length; i++) { // add the required proof types as selected by the action type creator
      newToken.addRequiredProofType(requiredProofTypes[i]);
      // ProofTypes must be minters because "they" (via msg.sender) are the ones calling mint() if the last required proof type is set to true
      newToken.addMinter(requiredProofTypes[i]);

      // This approach enables setting integer-parameters for the proof types that require parameters.
      // The challenge to solve here was that some don't need parameters and others need multiple.
      // Therefore the paramValuesIndices array encodes successively the start- and end indices for
      // each proof type as they appear in the paramValues array.
      // An example:
      //    Proof type A has parameter values 4, 7 and 9, Proof type B as no parameters and Proof type C has the parameter 5.
      //    paramValues would look like this [4, 7, 9, 5] whereas paramValuesIndices would like like this: [0, 2, 99, 99, 3, 3]
      //    --> Proof type A has the parameters from index 0 to index 2, Proof type b has no parameters as indicated by the 99
      //        and Proof type C has the single parameter at index 3
      uint indexStart = paramValuesIndices[i * 2];
      uint indexEnd = paramValuesIndices[i * 2 + 1];
      if (indexStart != 99) {
        uint paramsCount = indexEnd - indexStart + 1;
        uint[] memory params = new uint[](paramsCount);
        for (uint j = indexStart; j <= indexEnd; j ++) {
            params[j - indexStart] = paramValues[j];
        }
        // Send parameters to proof type, it will be stored there linked to the new tokens address
        Fin4BaseProofType(requiredProofTypes[i]).setParameters(address(newToken), params);
      }
    }
    children.push(address(newToken));
    return address(newToken);
  }

  function getChildren() public view returns(address[] memory) {
    return children;
  }

  // ------------------------- BALANCE -------------------------

  // used by More (the marketplace)
  function getChildrenWhereUserHasNonzeroBalance() public view returns(address[] memory) {
    uint count = 0;
    for (uint i = 0; i < children.length; i ++) {
      if (getBalance(msg.sender, children[i]) > 0) {
        count ++;
      }
    }
    address[] memory nonzeroBalanceTokens = new address[](count);
    for (uint i = 0; i < count; i ++) {
      if (getBalance(msg.sender, children[i]) > 0) {
        nonzeroBalanceTokens[i] = children[i];
      }
    }
    return nonzeroBalanceTokens;
  }

  function getBalance(address user, address tokenAddress) public view returns(uint256) {
      return Fin4Token(tokenAddress).balanceOf(user);
  }

  // ------------------------- ACTION WHERE USER HAS CLAIMS -------------------------

  // to keep track on which action types the user has claims (independent of their approval-statuses)
  mapping (address => address[]) public actionsWhereUserHasClaims; // key = user, value = action addresses

  function _userClaimedOnThisActionAlready(address user, address action) private view returns (bool) {
    for (uint i = 0; i < actionsWhereUserHasClaims[user].length; i++) {
      if (actionsWhereUserHasClaims[user][i] == action) {
        return true;
      }
    }
    return false;
  }

  // used in PreviousClaims
  function getActionsWhereUserHasClaims() public view returns(address[] memory) {
    return actionsWhereUserHasClaims[msg.sender];
  }

  function claimSubmissionPingback(address claimer, address token) public returns(bool) {
    if (!_userClaimedOnThisActionAlready(claimer, token)) {
      actionsWhereUserHasClaims[claimer].push(token);
    }
  }

  // used in Claim - could also happen directly on the Token, but that would complicate the workflow in the front end
  function submitClaim(address tokenAddress, uint quantity, uint date, string memory comment) public returns(uint) {
    claimSubmissionPingback(msg.sender, tokenAddress);
    return Fin4Token(tokenAddress).submit(msg.sender, quantity, date, comment);
  }

  // ------------------------- PROOF TYPES -------------------------

  // all the proof types that action type creators can use
  address[] public proofTypes;

  function addProofType(address proofType) public returns(bool) {
    proofTypes.push(proofType);
    return true;
  }

  function getProofTypes() public view returns(address[] memory) {
    return proofTypes;
  }

  function getProofTypeName(address proofType) public view returns(string memory) {
    require(proofTypeIsRegistered(proofType), "Address is not registered as proof type on Fin4Main");
    return Fin4BaseProofType(proofType).getName();
  }

  // called from Fin4Token instances to ensure the required proof types there are a subset of the proofTypes here
  function proofTypeIsRegistered(address proofTypeToCheck) public view returns(bool) {
    for (uint i = 0; i < proofTypes.length; i++) {
      if (proofTypes[i] == proofTypeToCheck) {
        return true;
      }
    }
    return false;
  }

  // ------------------------- MESSAGES -------------------------

  // contract handling messages to the user is outsourced
  address public Fin4MessagesAddr;

  function setFin4MessagesAddress(address addr) public {
    Fin4MessagesAddr = addr;
  }

  function getFin4MessagesAddress() public view returns(address) {
    return Fin4MessagesAddr;
  }

}
