//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {console} from "forge-std/console.sol";

contract MyGovTokenContract is ERC20{
    error MyGovTokenContract__claimedAlready();
    error MyGovTokenContract__tooManyTokens();

    uint public initialSupply;
    mapping(address voter => bool claimed) hasClaimedTokens;

    constructor(uint256 _initalSupply) ERC20("MyGovToken" , "MGT") {
        _mint(address(this), _initalSupply);
        initialSupply= _initalSupply;
    } //minting new tokens to this contract
     
    function claim(uint claimAmount) external {
        if(hasClaimedTokens[msg.sender]) {
            revert MyGovTokenContract__claimedAlready();
        }
        if(claimAmount >= (50 * initialSupply)/100) {
            revert MyGovTokenContract__tooManyTokens();
        }
        
        _transfer(address(this), msg.sender, claimAmount);
        hasClaimedTokens[msg.sender]=true;

    } // tokens getting transferred from this contract address to msg,senders address
    //getter
    function getInitialSupply() public view returns(uint) {
        return initialSupply;
    }
    function getHasClaimedTokens(address addr) public view returns(bool){
        return(hasClaimedTokens[addr]);
    }

    function getBalance(address addr) public view returns(uint) {
        return(balanceOf(addr));
    }
}

