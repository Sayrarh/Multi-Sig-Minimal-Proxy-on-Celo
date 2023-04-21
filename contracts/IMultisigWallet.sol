// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract IMultisigWallet {
    function initialize(
        address[] memory _owners,
        uint8 _quorum
    ) external payable {}
}
