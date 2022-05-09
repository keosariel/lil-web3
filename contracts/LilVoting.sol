// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


/**
  * @title LilVoting
  * @author Kenneth Gabriel
*/
contract LilVoting {

    enum State {
        CREATED,
        VOTING,
        ENDED
    }

    State public votingState;
    mapping(address => bool) voters;

    struct Choice {
        uint id;
        string name;
        uint votes;
    }

    struct Ballot {
        uint id;
        string name;
        Choice[] choices;
    }

    address public admin;
    uint nextBallotId = 1;
    uint totalVoters = 0;
    mapping(uint => Ballot) ballots;
    mapping(address => mapping(uint => bool)) votes;

    event voterAdded(address);
    event voteStarted();
    event voteEnded();


    constructor (){
        admin = msg.sender;
        votingState = State.CREATED;
    }

    modifier onlyAdim() {
        require(msg.sender == admin, "Only Admin");
        _;
    }

    /**
      * @notice adds new voters
      * @param _voters list of unique voters
    */
    function addVoter(address[] calldata _voters) external onlyAdim() {
        // Voters cannot be added when voting has started or ended
        require(votingState == State.CREATED, "Voting has either started or ended");

        for(uint i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
            totalVoters++;
        }
    }

    // @notice nobody can cast a vote until voting has started
    function startVoting() public onlyAdim() {
        votingState = State.VOTING;
        emit voteStarted();
    }

    function endVoting() public onlyAdim() {
        votingState = State.ENDED;
        emit voteEnded();
    }

    /**
      * @notice creates a new ballot
      * @param name the name of the ballot
      * @param _choices the only choices for the ballot
    */
    function createBallot(string memory name, string[] memory _choices) public {
        ballots[nextBallotId].id = nextBallotId;
        ballots[nextBallotId].name = name;
        for(uint x = 0; x < _choices.length; x++) {
            ballots[nextBallotId].choices.push(Choice(x, _choices[x], 0));
        }

        nextBallotId++;
    }   

    /**
      * @notice one can only vote if registered, while the vote has started
      * and hasn't voted before
      * @param ballotId the ballot's ID
      * @param choiceId the choice you choose to vote for
    */
    function vote(uint ballotId, uint choiceId) external {
        require(voters[msg.sender] == true, "You are not registered to vote");
        require(votes[msg.sender][ballotId] == false, "Voter can only vote once for a ballot");
        require(votingState == State.VOTING, "Voting has either no started or has ended");

        votes[msg.sender][ballotId] = true;
        ballots[ballotId].choices[choiceId].votes++;
    }
    

    function results (uint ballotId) public view returns (Choice[] memory){
        require(votingState == State.ENDED, "Voting has not ended");
        return ballots[ballotId].choices;
    }
}