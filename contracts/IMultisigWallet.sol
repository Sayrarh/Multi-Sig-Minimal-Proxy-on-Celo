// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IMultisigWallet {
    function initialize(address[] memory _owners, uint8 _quorum) external;
}
