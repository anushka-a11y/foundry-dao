// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DAO} from "../src/DAO.sol";
import{MyGovTokenContract} from "../src/MyGovTokenContract.sol";


contract DeployDAO is Script {
    DAO dao;
    MyGovTokenContract public myGovTokenContract;

    function setUp() public {}

    function run() public returns(DAO) {
        vm.startBroadcast();
        myGovTokenContract = new MyGovTokenContract(5000); //obviously!!!!
        //need to instantiate the token contract too
        dao = new DAO(address(myGovTokenContract), 1000); //voteTokenAddress and quorum
        vm.stopBroadcast();
        return(dao);
    }
}
