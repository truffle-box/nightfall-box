/**
CREDITS:

Standardisation effort:

Interface proposal & example implementation by Michael Connor, EY, 2019, including:
Functions, arrangement, logic, inheritance structure, and interactions with a proposed Verifier interface.

With thanks to:
Duncan Westland
Chaitanya Konda
Harry R
*/

/**
@title Verifier_Registry
@dev Example Verifier Registry Implementation.
@notice Do not use this example in any production code!
*/

pragma solidity ^0.5.8;

import "./Verifier_Register_Library.sol";
import "./Verifier_Interface.sol";

contract Verifier_Registry {

    using Verifier_Register_Library for *;


    event NewProofSubmitted(bytes32 indexed _proofId, uint256[] _proof, uint256[] _inputs);

    event NewVkRegistered(bytes32 indexed _vkId);

    event NewVerifierContractRegistered(address indexed _contractAddress);

    event NewAttestation(bytes32 indexed _proofId, address indexed _verifier, bool indexed _result);


    //mapped to by vkId:
    mapping(bytes32 => Verifier_Register_Library.VkEntry) public vkRegister;
    //duplicate of vkId within the structs, but allows one to lookup all vkId keys:
    bytes32[] vkIds;
    //mapped to by proofId:
    mapping(bytes32 => Verifier_Register_Library.ProofEntry) public proofRegister;
    //duplicate of proofId within the structs, but allows one to lookup all proofId keys.
    bytes32[] proofIds;
    //mapped to by verifierContract address:
    mapping(address => Verifier_Register_Library.VerifierContractEntry) public verifierContractRegister;
    //duplicate of contractAddress within the structs, but allows one to lookup all proofId keys.
    address[] verifierContracts;


    //This is the only getter function required by Verifier contracts. The other getter functions are an ugly consequence of limitations of not being able to easily 'get' data from mappings and structs in the current EVM.
    function getVk(bytes32 _vkId) external view returns (uint256[] memory) {
        return vkRegister[_vkId].vk;
    }

    function registerVerifierContract(address _verifierContract) external returns (bool) {
        require(verifierContractRegister[_verifierContract].contractAddress == address(0), "Contract already registered");

        //create a new entry in the verifierContractRegister
        verifierContractRegister[_verifierContract].contractAddress = _verifierContract;
        verifierContractRegister[_verifierContract].submitter = msg.sender;
        verifierContractRegister[_verifierContract].owner = msg.sender;

        emit NewVerifierContractRegistered(_verifierContract);

        return true;
    }

    function registerVk(uint256[] calldata _vk, address[] calldata _verifierContracts) external returns (bytes32) {
        //create a new vkId
        //VKID has to be a HASH of the contents of the vk, or people could call a verifier expecting their proof to be checked against a vk, but end up with a false positive (or false negative). due to a different vk being stored against the vkId in the verifier they call.
        bytes32 vkId = createNewVkId(_vk);

        if (vkRegister[vkId].vkId == 0) {
            vkRegister[vkId].vkId = vkId;
        }
        //we also allow an already-registered vk to have more verifierContracts assigned to it through this function

        for (uint i = 0; i < _verifierContracts.length; i++) {
            //ensure the verifier contracts are all registered
            require(verifierContractRegister[_verifierContracts[i]].contractAddress != address(0), "Verifier contract not yet registered");

            //update the verifierContractRegister:
            verifierContractRegister[_verifierContracts[i]].vkIds.push(vkId);
            //update the vk's register with any additional verifier contracts:
            vkRegister[vkId].verifiers.push(_verifierContracts[i]);
        }

        //update the vkRegister:
        vkRegister[vkId].vk = _vk;
        vkRegister[vkId].vkSubmitter = msg.sender;

        emit NewVkRegistered(vkId);

        return vkId;
    }

    function submitProof(uint256[] calldata _proof, uint256[] calldata _inputs, bytes32 _vkId) external returns (bytes32) {

        require(vkRegister[_vkId].vkId == _vkId, "vkId not yet registered");
        //duplicate proofs are allowed - no check required!

        bytes32 proofId = createNewProofId(_proof, _inputs);

        //add proof to ProofRegister:
        if (proofRegister[proofId].proofId == 0) {//proof not yet submitted
          proofRegister[proofId].proofId = proofId;
        }
        proofRegister[proofId].proofSubmitters.push(tx.origin); //tx.origin ensures smart contracts which forward calls aren't being recorded as the submitter.
        proofRegister[proofId].vkIds.push(_vkId); //we allow multiple vks to be mapped to by a proof (even though this is infeasible) because if there was a single slot, a malicious actor could fill it with the wrong vk.

        //update the vkRegister with this association:
        vkRegister[_vkId].proofIds.push(proofId);

        emit NewProofSubmitted(proofId, _proof, _inputs);

        return proofId;
    }

    //OVERLOADED - designed for verifier contracts to call, so as to associate themselves with the proof
    function submitProof(uint256[] calldata _proof, uint256[] calldata _inputs, bytes32 _vkId, address _verifierContract) external returns (bytes32) {

        require(verifierContractRegister[_verifierContract].contractAddress != address(0), "Verifier contract not yet registered");
        require(vkRegister[_vkId].vkId == _vkId, "vkId not yet registered");
        //duplicate proofs are allowed - no check required!

        bytes32 proofId = createNewProofId(_proof, _inputs);

        //add proof to ProofRegister:
        if (proofRegister[proofId].proofId == 0) {//proof not yet submitted
            proofRegister[proofId].proofId = proofId;
        }
        proofRegister[proofId].proofSubmitters.push(tx.origin); //tx.origin ensures smart contracts which forward calls aren't being recorded as the submitter.
        proofRegister[proofId].vkIds.push(_vkId); //we allow multiple vks to be mapped to by a proof (even though this is infeasible) because if there was a single slot, a malicious actor could fill it with the wrong vk.
        proofRegister[proofId].verifiers.push(_verifierContract);

        //update the vkRegister with this association:
        vkRegister[_vkId].proofIds.push(proofId);

        //update the verifierContractRegister with this association:
        verifierContractRegister[_verifierContract].proofIds.push(proofId);

        emit NewProofSubmitted(proofId, _proof, _inputs);

        return proofId;
    }


    function submitProofAndVerify(uint256[] calldata _proof, uint256[] calldata _inputs, bytes32 _vkId, address _verifierContract) external returns (bytes32 proofId, bool result) {

      require(vkRegister[_vkId].vkId == _vkId, "vkId not yet registered");
      require(verifierContractRegister[_verifierContract].contractAddress != address(0), "Verifier contract not yet registered");
      //duplicate proofs are allowed - no check required!

      proofId = createNewProofId(_proof, _inputs);

      //add proof to ProofRegister:
      if (proofRegister[proofId].proofId == 0) {//proof not yet submitted
          proofRegister[proofId].proofId = proofId;
      }
      proofRegister[proofId].proofSubmitters.push(msg.sender);
      proofRegister[proofId].vkIds.push(_vkId);//we allow multiple vks to be mapped to by a proof (even though this is infeasible) because if there was a single slot, a malicious actor could fill it with the wrong vk.
      proofRegister[proofId].verifiers.push(_verifierContract);

      //update the vkRegister with this association:
      vkRegister[_vkId].proofIds.push(proofId);

      //update the verifierContractRegister with this association:
      verifierContractRegister[_verifierContract].proofIds.push(proofId);

      emit NewProofSubmitted(proofId, _proof, _inputs);

      //returns to the contract through attestProofs to change storage states before returning the result
      Verifier_Interface verifierContract;
      verifierContract = Verifier_Interface(_verifierContract);

      result = verifierContract.verify(_proof, _inputs, _vkId);

      emit NewAttestation(proofId, _verifierContract, result);

      //attestProof
      proofRegister[proofId].results[address(verifierContract)] = result;
      proofRegister[proofId].verifierCallers[msg.sender]=msg.sender;

      return (proofId, result);
    }



    //including vkId is important, because otherwise a proof might be 'verified' against a bogus vk
    function attestProof(bytes32 _proofId, bytes32 _vkId, bool _result) external {

        require(proofRegister[_proofId].proofId == _proofId, "proofId not yet registered");
        require(vkRegister[_vkId].vkId == _vkId, "vkId not yet registered");
        bool vkAssociated = false;
        for (uint i=0; i < proofRegister[_proofId].vkIds.length; i++) {
            if (proofRegister[_proofId].vkIds[i] == _vkId) {
              vkAssociated = true;
            }
        }
        require(vkAssociated == true, "This proofId has not been associated with this vkId");

        proofRegister[_proofId].results[msg.sender] = _result;
        proofRegister[_proofId].verifierCallers[tx.origin]=tx.origin;

        emit NewAttestation(_proofId, msg.sender, _result);
    }



    //including vkId is important, because otherwise a proof might be 'verified' against a bogus vk
    function attestProofs(bytes32[] calldata _proofIds, bytes32[] calldata _vkIds, bool[] calldata _results) external {

        for (uint i = 0; i < _proofIds.length; i++) {
            bytes32 proofId;
            bytes32 vkId;
            bool result;

            proofId = _proofIds[i];
            vkId = _vkIds[i];
            result = _results[i];

            require(proofRegister[proofId].proofId == proofId, "proofId not yet registered");
            require(vkRegister[vkId].vkId == vkId, "vkId not yet registered");

            proofRegister[proofId].vkIds.push(vkId);
            proofRegister[proofId].results[msg.sender] = result;
            proofRegister[proofId].verifierCallers[tx.origin] = tx.origin;

            vkRegister[vkId].proofIds.push(proofId);

            emit NewAttestation(proofId, msg.sender, result);
        }
    }

    /*TODO - implement this
    */
    //function challengeAttestation(bytes32 _proofId, uint256[] _proof, uint256[] _inputs, address _verifierContract) public {}


    //we put this vkId creation in the registry, so that people 'trust' its calculation.
    function createNewVkId(uint256[] memory _vk) internal pure returns (bytes32) {

        bytes32 newVkId = keccak256(abi.encodePacked(_vk));

        return newVkId;
    }

    //we put this vkId creation in the registry, so that people 'trust' its calculation.
    function createNewProofId(uint256[] memory _proof, uint256[] memory _inputs) internal pure returns (bytes32) {

        bytes32 newProofId = keccak256(abi.encodePacked(_proof, _inputs));

        return newProofId;
    }


    //GETTER FUNCTIONS FOR STRUCTS - these do not form part of the standard.
    //It's ugly, but Solidity doesn't give us a neat way of accessing structs via mappings from an external contract or from a web3 call.
    //We can't even use the Verifier_Register library to assign native functions to the three Struct Types (proofEntry, vkEntry, verifierContractEntry) because we need to access the Structs through mappings, and hence 'complex' key types (arrays and mappings within the structs) are hidden from the external caller!
    //Once ABIEncoder_V2 is production-ready, we can switch to that, which allows structs to be passed into and returned from functions.

    function getProofEntryProofId(bytes32 _proofId) public view returns (bytes32) {return proofRegister[_proofId].proofId;}

    function getProofEntryVkIds(bytes32 _proofId) public view returns (bytes32[] memory) {return proofRegister[_proofId].vkIds;}

    function getProofEntryProofSubmitters(bytes32 _proofId) public view returns (address[] memory) {return proofRegister[_proofId].proofSubmitters;}

    function getProofEntryVerifiers(bytes32 _proofId) public view returns (address[] memory) {return proofRegister[_proofId].verifiers;}

    function getProofEntryResult(bytes32 _proofId, address _verifier) public view returns (bool) {return proofRegister[_proofId].results[_verifier];}

    function getProofEntryVerifierCaller(bytes32 _proofId, address _verifier) public view returns (address) {return proofRegister[_proofId].verifierCallers[_verifier];}

    function getProofEntryDescription(bytes32 _proofId) public view returns (string memory) {return proofRegister[_proofId].description;}


    function getVkEntryVkId(bytes32 _vkId) public view returns (bytes32) {return vkRegister[_vkId].vkId;}

    function getVkEntryVk(bytes32 _vkId) public view returns (uint256[] memory) {return vkRegister[_vkId].vk;}

    function getVkEntryVkSubmitter(bytes32 _vkId) public view returns (address) {return vkRegister[_vkId].vkSubmitter;}

    function getVkEntryVerifiers(bytes32 _vkId) public view returns (address[] memory) {return vkRegister[_vkId].verifiers;}

    function getVkEntryProofIds(bytes32 _vkId) public view returns (bytes32[] memory) {return vkRegister[_vkId].proofIds;}

    function getVkEntryDescription(bytes32 _vkId) public view returns (string memory) {return vkRegister[_vkId].description;}


    function getVerifierContractAddress(address _contractAddress) public view returns (address) {return verifierContractRegister[_contractAddress].contractAddress;}

    function getVerifierContractEntrySubmitter(address _contractAddress) public view returns (address) {return verifierContractRegister[_contractAddress].submitter;}

    function getVerifierContractEntryOwner(address _contractAddress) public view returns (address) {return verifierContractRegister[_contractAddress].owner;}

    function getVerifierContractEntryVkIds(address _contractAddress) public view returns (bytes32[] memory) {return verifierContractRegister[_contractAddress].vkIds;}

    function getVerifierContractEntryProofIds(address _contractAddress) public view returns (bytes32[] memory) {return verifierContractRegister[_contractAddress].proofIds;}

    function getVerifierContractEntryDescription(address _contractAddress) public view returns (string memory) {return verifierContractRegister[_contractAddress].description;}

}
