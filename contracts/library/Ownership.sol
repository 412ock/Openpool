// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownership {
    address private owner;

    modifier onlyOwner(address sender){
        require(sender == owner, "Not owner");
        _;
    }
}