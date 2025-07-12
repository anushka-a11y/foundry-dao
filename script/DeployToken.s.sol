//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {MyGovTokenContract} from "src/MyGovTokenContract.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployToken is Script{
    MyGovTokenContract myGovTokenContract;
    function setUp() public {}
    function run() public returns(MyGovTokenContract) {
        vm.startBroadcast();
        myGovTokenContract= new MyGovTokenContract(5000);
        vm.stopBroadcast();
        return myGovTokenContract;
    }
}