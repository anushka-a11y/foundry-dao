// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MyGovTokenContract} from "src/MyGovTokenContract.sol";
import {DeployToken} from "script/DeployToken.s.sol";

//i want to test if tokens are getting claimed properly

contract TestToken is Test {
    MyGovTokenContract myGovTokenContract;
    address VOTER= makeAddr("viter");
    uint private constant CLAIM_AMOUNT= 1250;

    function setUp() public {
        DeployToken deployToken = new DeployToken();
        myGovTokenContract= deployToken.run();
    }

    function testHasClaimedTokensAlready() public {
        vm.prank(VOTER);
        myGovTokenContract.claim(CLAIM_AMOUNT);

        vm.prank(VOTER);
        vm.expectRevert();
        myGovTokenContract.claim(CLAIM_AMOUNT);
    }

    function testClaimAmountAndInitialSupplyRelation() public view{
        assert(CLAIM_AMOUNT <= (50 * myGovTokenContract.getInitialSupply())/100);
    }

    function testTokensTranferred() public {
        uint preVoterBalance= myGovTokenContract.getBalance(VOTER);
        uint preContractBalance= myGovTokenContract.getBalance(address(myGovTokenContract));

        vm.prank(VOTER);
        myGovTokenContract.claim(CLAIM_AMOUNT);

        uint postVoterBalance= myGovTokenContract.getBalance(VOTER);
        uint postContractBalance= myGovTokenContract.getBalance(address(myGovTokenContract));

        assertEq(preVoterBalance + CLAIM_AMOUNT, postVoterBalance);
        assertEq(preContractBalance - CLAIM_AMOUNT, postContractBalance);

    }

}