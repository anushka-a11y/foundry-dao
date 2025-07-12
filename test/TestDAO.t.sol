// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DAO} from "../src/DAO.sol";
import {DeployDAO} from "../script/DeployDAO.s.sol";
import {MyGovTokenContract} from "../src/MyGovTokenContract.sol";

contract TestDAO is Test{
    DAO dao;
    MyGovTokenContract myGovTokenContract;

    
    address VOTER= makeAddr("voter");
    address TO= makeAddr("to");
    address PLAYER= makeAddr("PLAYER");
    uint private DEADLINE= 7 days;
    uint private PROPOSAL_ID=0;
    bool private CHOICE;

    function setUp() public {
        DeployDAO deployDAO= new DeployDAO();
        dao= deployDAO.run();
        myGovTokenContract = deployDAO.myGovTokenContract();
        //get the deployed instance of the token contract
        //without ths, .claim will be called on address(0)
        
    }

    modifier hasClaimed100Tokens() {
        vm.prank(VOTER);
        myGovTokenContract.claim(100);
        _;
    }

    modifier proposalHasBeenCreated() {
        vm.prank(VOTER);
        dao.createProposal(TO, DEADLINE);
        _;
    }

    function testOnlyTokenHoldersCanPropose() public {
        //voter hasnt claimed any tokens...createproposal will revert adn test will pass
        vm.prank(VOTER);
        vm.expectRevert();
        dao.createProposal(TO, DEADLINE);
    }

    function testCreateProposalAndProposalIsPushedInArray() public hasClaimed100Tokens proposalHasBeenCreated{
        /*vm.startPrank(VOTER);

        dao.createProposal(TO, DEADLINE);

        vm.stopPrank();*/

        (
            address to,
            uint deadline,
            bool executed,
            uint yesCount,
            uint noCount
        ) = dao.getProposal(0);
        

        assertEq(to, TO);
        assertEq(deadline, DEADLINE);
        assertEq(executed, false);
        assertEq(yesCount, 0);
        assertEq(noCount, 0);
    }
    
    function testCanOnlyVoteBeforeDeadline() public hasClaimed100Tokens proposalHasBeenCreated{
        vm.prank(VOTER);
        vm.warp(block.timestamp + DEADLINE + 1);
        vm.expectRevert();
        dao.vote(PROPOSAL_ID, CHOICE);
    }

    function testCanOnlyVoteOnce() public hasClaimed100Tokens proposalHasBeenCreated{
        vm.startPrank(VOTER);
        dao.vote(PROPOSAL_ID, CHOICE);
        //console.log(dao.getHasVoted(PROPOSAL_ID));
        vm.expectRevert(DAO.DAO__alreadyVoted.selector);
        dao.vote(PROPOSAL_ID, CHOICE);

        vm.stopPrank();

    }

    function testOnlyTokenHoldersCanVote() public hasClaimed100Tokens proposalHasBeenCreated{
        address VOTER2= makeAddr("voter2");
        vm.prank(VOTER2);
        vm.expectRevert();
        dao.vote(PROPOSAL_ID, CHOICE);
    }

    function testYesCountIncreases() public hasClaimed100Tokens proposalHasBeenCreated{
        vm.startPrank(VOTER);
        dao.vote(PROPOSAL_ID, true);
        (,,,uint yesCount, )= dao.getProposal(PROPOSAL_ID);
        console.log(dao.getBalances(VOTER));
        vm.stopPrank();

        assertEq(yesCount, dao.getBalances(VOTER));
    }

    function testNoCountIncreases() public hasClaimed100Tokens proposalHasBeenCreated{
        vm.startPrank(VOTER);
        dao.vote(PROPOSAL_ID, false);
        (,,,,uint noCount)= dao.getProposal(PROPOSAL_ID);
        console.log(dao.getBalances(VOTER));
        vm.stopPrank();

        assertEq(noCount, dao.getBalances(VOTER));
    }

    function testProposalExecutedAfterDeadline() public hasClaimed100Tokens proposalHasBeenCreated {
        vm.prank(VOTER);
        vm.expectRevert();
        dao.execute(PROPOSAL_ID);
    }
    /*function testProposalHasNotBeenExecutedBefore() public hasClaimed100Tokens proposalHasBeenCreated {
        vm.warp(block.timestamp+DEADLINE + 1);
        vm.startPrank(VOTER);
        (,,,uint yesCount, )= dao.getProposal(PROPOSAL_ID);
        (,,,,uint noCount)= dao.getProposal(PROPOSAL_ID);
        yesCount + noCount 


        dao.execute(PROPOSAL_ID);

        vm.expectRevert(DAO.DAO__alreadyExecuted.selector);
        vm.prank(VOTER);
        dao.execute(PROPOSAL_ID);



    }*/

    /*function testQuorumMet() public hasClaimed100Tokens proposalHasBeenCreated{
        (,,,uint yesCount, )= dao.getProposal(PROPOSAL_ID);
        console.log(yesCount);
        (,,,,uint noCount)= dao.getProposal(PROPOSAL_ID);
        console.log(noCount);
        console.log((25*myGovTokenContract.getInitialSupply())/100);
        assert(yesCount + noCount > ((25*myGovTokenContract.getInitialSupply())/100));
    }*/
    
    
    


}
