/**
CREDITS:

Standardisation effort:

Library proposal & example implementation by Michael Connor, EY, 2019,
including:
Functions, arrangement, logic, inheritance structure, and interactions with a proposed Verifier_Registry.

With thanks to:
Duncan Westland
Chaitanya Konda
Harry R
*/

/**
@title Verifier_Register_Library
@dev Example Verifier Register Library Implementation - to be imported by the verifier registry and other dependent contracts.

This is an example of the storage layout for a Verifier_Register; a register which stores the data of the Verifier_Registry contract.
I've separated these Structs from the main Verifier_Registry, to allow other Register Libraries to be developed over time.

@notice Do not use this example in any production code!
*/

pragma solidity ^0.5.8;

library Verifier_Register_Library {

  struct ProofEntry {
      bytes32 proofId; //duplicate of proofIds array, but allows quick existence check
      bytes32[] vkIds; //although we would only expect 1 vkId per proofEntry, if there was only 1 vkId, someone could maliciously fill it with the wrong vk!
      //Points.G1Point vk_x_inputs;
      address[] proofSubmitters;
      address[] verifiers; //could be a contract or a human
      mapping(address => bool) results; //mapped to from verifierContracts or Address of a Verifier (human)
      mapping(address => address) verifierCallers; //mapped to from a verifier
      string description;
  }

  struct VkEntry {
      bytes32 vkId; //duplicate of vkIds array, but allows quick existence check
      uint256[] vk;
      address vkSubmitter;
      address[] verifiers;
      bytes32[] proofIds;
      string description;
  }

  struct VerifierContractEntry {
      address contractAddress;
      address submitter;
      address owner;
      bytes32[] vkIds;
      bytes32[] proofIds;
      string description;
  }

}
