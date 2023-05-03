const { expect } = require("chai");

describe("Voting", function () {
  let voting;
  const proposal = "Should we approve the new budget?";
  const options = [true, false];

  beforeEach(async function () {
    const Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy(proposal, options);
    await voting.deployed();
  });

  it("should return the correct proposal and options", async function () {
    expect(await voting.proposal()).to.equal(proposal);
    expect(await voting.options(0)).to.equal(options[0]);
    expect(await voting.options(1)).to.equal(options[1]);
  });

  it("should allow a voter to cast a vote", async function () {
    const [voter] = await ethers.getSigners(); // use array destructuring to get the first signer
    const optionIndex = 1;
    await voting.connect(voter).castVote(optionIndex);
    const voterVote = await voting.voters(voter.address);
    expect(voterVote.hasVoted).to.equal(true);
    expect(voterVote.vote).to.equal(optionIndex);
  });

  it("should not allow a voter to cast multiple votes", async function () {
    const voter = await ethers.provider.getSigner(0);
    const optionIndex = 1;
    await voting.connect(voter).castVote(optionIndex);
    await expect(voting.connect(voter).castVote(optionIndex)).to.be.revertedWith(
      "You have already voted."
    );
  });

  it("should not allow a voter to cast an invalid vote", async function () {
    const voter = await ethers.provider.getSigner(0);
    const optionIndex = 2;
    await expect(voting.connect(voter).castVote(optionIndex)).to.be.revertedWith(
      "Invalid option index."
    );
  });

  it("should return the correct vote counts", async function () {
    const voter1 = await ethers.provider.getSigner(0);
    const voter2 = await ethers.provider.getSigner(1);
    const optionIndex1 = 1;
    const optionIndex2 = 0;
    await voting.connect(voter1).castVote(optionIndex1);
    await voting.connect(voter2).castVote(optionIndex2);
    const [yesVotes, noVotes] = await voting.getVoteCount();
    expect(yesVotes).to.equal(1);
    expect(noVotes).to.equal(1);
  });
});