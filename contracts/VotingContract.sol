// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract VotingContract {
    address public owner;
    uint256 public counter;
    uint256 public maxCandidatesNum;

    struct Candidate {
        uint256 balance;
        bool isExistOnThisVoting;
    }

    struct Voting {
        bool started;
        address Winner;
        uint256 startDate;
        uint256 WinnerBalance;
        uint256 Bank;
        uint256 Period;
        mapping(address => Candidate) Candidates;
    }

    mapping(uint256 => Voting) private Votings;

    uint8 public immutable Comission;

    constructor(uint256 _maxCandidatesNum, uint8 _comissoin) {
        owner = msg.sender;
        maxCandidatesNum = _maxCandidatesNum;
        Comission = _comissoin;
    }

    function getPartInVoting(uint8 _votingID, address _candidate) public payable {
        require( Votings[_votingID].started == true, "Voting not starded yet.");
        require(
            Votings[_votingID].startDate + Votings[_votingID].Period < block.timestamp,
            "Voting is end."
        );
        // require(
        //    checkCandidate(_votingID, _candidate), 
        //    "Candidate does not exist on this voting.");

        Votings[_votingID].Candidates[_candidate].balance += msg.value;
        Votings[_votingID].Bank += msg.value;

        if ( Votings[_votingID].Candidates[_candidate].balance > Votings[_votingID].WinnerBalance) {
            Votings[_votingID].WinnerBalance = Votings[_votingID].Candidates[_candidate].balance; 
            Votings[_votingID].Winner = _candidate;
        }        
    }

    function WithdrawMyPrize(uint256 _votingID) public {
        //проверка, что голосование стартовало
        require(Votings[_votingID].started, "Voting hasn't started yet.");
        
        //проверка, что закончилось голосование
        require(    
            (Votings[_votingID].startDate + Votings[_votingID].Period) > block.timestamp,
            "Voting hasn't ended yet.");
        
        //провека, что ты победитель
        require(Votings[_votingID].Winner == msg.sender, "You are not winner!");

        //проверка, что в банке есть денги
        require(Votings[_votingID].Bank > 0, "Money already paid");
        
        //посчитать комиссию
        uint256 amount = Votings[_votingID].Bank;
        uint256 ownerComission = (amount*Comission)/100;
        uint256 prize = amount - ownerComission;
        
        //Обнулить банк
        Votings[_votingID].Bank = 0;
        
        //перевести комиссию и награду
        payable(owner).transfer(ownerComission);
        payable(msg.sender).transfer(prize);        
    }

    function getVotingInfo(uint256 _votingID) public view 
        returns (
            bool,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        )
    {
        return (
            Votings[_votingID].started,        
            Votings[_votingID].startDate,
            Votings[_votingID].WinnerBalance,
            Votings[_votingID].Bank,
            Votings[_votingID].Period,
            Votings[_votingID].Winner
        );
    }



    function checkCandidate(uint256 _votingID, uint256 _candidate) public view 
        returns (bool) 
    {
        return (Votings[_votingID].Candidates[_candidate].isExistOnThisVoting)
    }


    function addVoting(uint256 _period, address[] calldata _candidates) 
        public onlyOwner 
    {
        //проверка на количество 
    }

    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }
}