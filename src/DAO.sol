// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {console} from "forge-std/console.sol";
import{MyGovTokenContract} from "../src/MyGovTokenContract.sol";


contract DAO is MyGovTokenContract{
    error DAO__deadlineExceededToVote();
    error DAO__needTokens();
    error DAO__votingOngoing();
    error DAO__alreadyExecuted();
    error DAO__quorumNotMet();
    error DAO__onlyTokenHoldersCanProposeOrVote();
    error DAO__alreadyVoted();

    uint private QUORUM; //threshold to execute a proposal
    //yesCount+noCount > QUORUM
    IERC20 private voteToken;
    struct Proposal {
        address to;
        uint deadline;
        bool executed;
        uint yesCount;
        uint noCount;
    }

    constructor(address _voteTokenAddress, uint _quorum) MyGovTokenContract(5000){
        voteToken = IERC20(_voteTokenAddress);
        QUORUM = _quorum;
    }

    Proposal[] private proposals;
    mapping(uint proposalId => mapping(address voterAddr => bool choice)) private voteChoice;
    mapping(uint proposalId => mapping(address voterAddr => bool voted)) private hasVoted;

    function createProposal(address _to, uint _deadline) external {
        if(voteToken.balanceOf(msg.sender) ==0) {
            console.log(voteToken.balanceOf(msg.sender), "reverted");
            revert DAO__onlyTokenHoldersCanProposeOrVote();
        }
        console.log(voteToken.balanceOf(msg.sender), "not reverted");
        Proposal memory proposal = Proposal({
            to: _to,
            deadline: _deadline,
            executed: false,
            yesCount: 0,
            noCount: 0
        });
        proposals.push(proposal);
    }

    function vote(uint _proposalId, bool _voteChoice) external {
        Proposal storage proposal = proposals[_proposalId];
        if (proposal.deadline < block.timestamp) { //deadline ke pehle vote krna hai
            revert DAO__deadlineExceededToVote();//used instead of require()
        }
        if (hasVoted[_proposalId][msg.sender]) {
            console.log("already voted"); //allow to change votee!!
            revert DAO__alreadyVoted();
        } 
        if(voteToken.balanceOf(msg.sender) ==0) {
            revert DAO__onlyTokenHoldersCanProposeOrVote();
        }
            //uint votePower= (voteToken.balanceOf(msg.sender));
            //if(votePower ==0) { //used instead of require()
            //    revert DAO__needTokens();
            //}
            //else{
        if(_voteChoice) {
            proposal.yesCount+= voteToken.balanceOf(msg.sender);
        }
        else {
            proposal.noCount+= voteToken.balanceOf(msg.sender);
        }
            //}
        hasVoted[_proposalId][msg.sender]= true;
    }

    function execute(uint _proposalId) external view{
        Proposal memory proposal = proposals[_proposalId];
        if(proposal.deadline > block.timestamp) {
            revert DAO__votingOngoing();
        }
        if(proposal.executed) {
            revert DAO__alreadyExecuted();
        }
        if(proposal.yesCount + proposal.noCount < ((25* initialSupply)/100)) {
            revert DAO__quorumNotMet();
        }
        if(proposal.yesCount<= proposal.noCount) {
            console.log("yes< no");
        }        
        proposal.executed=true;

        
    }

    //getters

    function getQUORUM() public view returns(uint){
        return QUORUM;
    }
    function getVoteToken() public view returns(IERC20) {
        return voteToken;
    }
    function getVoteChoice(uint proposalId) public view returns(bool ) {
        return voteChoice[proposalId][msg.sender];
    }
    function getHasVoted(uint proposalId) public view returns(bool ) {
        return hasVoted[proposalId][msg.sender];
    }
    function getProposal(uint index) public view returns(
    address to,
    uint deadline,
    bool executed,
    uint yesCount,
    uint noCount) {
        Proposal memory proposal= proposals[index];
        return (proposal.to, proposal.deadline, proposal.executed, proposal.yesCount, proposal.noCount);
    }
    function getBalances(address addr) public view returns(uint) {
        return(voteToken.balanceOf(addr));
    }
    
}
