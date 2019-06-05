/**
CREDITS:

Standardisation effort:

Interface proposal & example implementation by Michael Connor, EY, 2019,
including:
Functions, arrangement, logic, inheritance structure, and interactions with a proposed Verifier Registry interface.

With thanks to:
Duncan Westland
Chaitanya Konda
Harry R
*/

/**
@title Verifier_Interface
@dev Example Verifier Implementation - to be imported by the proposed Verifier Registry and other dependent contracts.
@notice Do not use this example in any production code!
*/

pragma solidity ^0.5.8;

interface Verifier_Interface {

  function verify(uint256[] calldata _proof, uint256[] calldata _inputs, bytes32 _vkId) external returns (bool result);

  function getRegistry() external view returns (address);

}
