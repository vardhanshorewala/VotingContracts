pragma solidity ^0.8.0;

contract Voting {
    string public proposal;
    bool[] public options;
    uint public voteCount;

    struct Voter {
        bool hasVoted;
        uint256 vote;
    }

    mapping(address => Voter) public voters;
    mapping(uint => address) private holders;

    event VoteCast(address voter);
    event VotingFinished();

    constructor(string memory _proposal, bool[] memory _options) {
        proposal = _proposal;
        options = _options;
        voteCount = 0;
    }

    function castVote(uint256 _optionIndex) public {
        require(!voters[msg.sender].hasVoted, "You have already voted.");
        require(_optionIndex < options.length, "Invalid option index.");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].vote = _optionIndex;
        holders[voteCount] = msg.sender;
        voteCount++;
        emit VoteCast(msg.sender);
    }

    function getVoteCount() public view returns (uint256, uint256) {
        uint256 yesVotes = getOptionVoteCount(1);
        uint256 noVotes = getOptionVoteCount(0);
        return (yesVotes, noVotes);
    }

    function getOptionVoteCount(
        uint256 _optionIndex
    ) internal view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < voteCount; i++) {
            if (voters[holders[i]].vote == _optionIndex) {
                count++;
            }
        }
        return count;
    }

    function finishVoting() public {
        emit VotingFinished();
    }
}
