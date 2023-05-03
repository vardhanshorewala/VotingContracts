pragma solidity ^0.8.0;

contract PollFactory {
    struct Poll {
        string proposal;
        uint yesCount;
        uint noCount;
        bool locked;
        uint lockTime;
        address[] voters;
    }

    Poll[] public polls;

    event PollCreated(uint pollIndex, string proposal);
    event VoteCast(uint pollIndex, address voter);
    event VotingFinished(uint pollIndex);

    function createPoll(string memory _proposal, uint _duration) public {
        Poll memory newPoll = Poll({
            proposal: _proposal,
            yesCount: 0,
            noCount: 0,
            locked: false,
            lockTime: block.timestamp + _duration,
            voters: new address[](0)
        });

        polls.push(newPoll);

        emit PollCreated(polls.length - 1, _proposal);
    }

    function castVote(uint _pollIndex, uint _optionIndex) public {
        require(_pollIndex < polls.length, "Invalid poll index.");
        require(!polls[_pollIndex].locked, "Voting has ended.");
        require(
            !votedInPoll(_pollIndex, msg.sender),
            "You have already voted."
        );

        polls[_pollIndex].voters.push(msg.sender);

        if (_optionIndex == 0) {
            polls[_pollIndex].noCount++;
        } else {
            polls[_pollIndex].yesCount++;
        }

        emit VoteCast(_pollIndex, msg.sender);
    }

    function votedInPoll(
        uint _pollIndex,
        address _voter
    ) internal view returns (bool) {
        for (uint i = 0; i < polls[_pollIndex].voters.length; i++) {
            if (polls[_pollIndex].voters[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    function getPollData(
        uint _pollIndex
    ) public view returns (string memory, uint, uint, uint, bool) {
        require(_pollIndex < polls.length, "Invalid poll index.");
        return (
            polls[_pollIndex].proposal,
            polls[_pollIndex].yesCount,
            polls[_pollIndex].noCount,
            polls[_pollIndex].lockTime,
            polls[_pollIndex].locked
        );
    }

    function endVote(uint _pollIndex) public {
        require(_pollIndex < polls.length, "Invalid poll index.");
        require(!polls[_pollIndex].locked, "Voting has already ended.");
        require(
            block.timestamp >= polls[_pollIndex].lockTime,
            "Voting period has not yet ended."
        );
        polls[_pollIndex].locked = true;
        emit VotingFinished(_pollIndex);
    }
}
