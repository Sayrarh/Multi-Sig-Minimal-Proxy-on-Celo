// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./IMultisigWallet.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract MultisigProxyFactory {
    event ContractCreated(address indexed newMultisig, uint256 position);

    address implementation;
    address[] allMultiSigContractAddresses;

    uint256 contractIndex = 1;

    mapping(uint256 => address) public getContractAddress;

    // setting the implementation contract address
    constructor(address _implementation) {
        implementation = _implementation;
    }

    function createClone(
        address[] memory validSigners,
        uint8 _quorum
    ) external returns (address) {
        bytes32 salt = keccak256(
            abi.encodePacked(block.timestamp, contractIndex)
        );
        address proxy = Clones.cloneDeterministic(implementation, salt);
        IMultisigWallet(proxy).initialize(validSigners, _quorum);

        getContractAddress[contractIndex] = proxy;
        allMultiSigContractAddresses.push(proxy);

        contractIndex = contractIndex + 1;

        emit ContractCreated(proxy, allMultiSigContractAddresses.length);
        return proxy;
    }

    function getAllCreatedAddresses() external view returns (address[] memory) {
        return allMultiSigContractAddresses;
    }

    function returnClonedContractLength() external view returns (uint256) {
        return contractIndex;
    }
}
