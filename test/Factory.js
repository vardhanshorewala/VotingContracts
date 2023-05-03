const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PollFactory", function () {
  let pollFactory;
  let owner;
  let user1;

  beforeEach(async function () {
    [owner, user1] = await ethers.getSigners();
    const PollFactory = await ethers.getContractFactory("PollFactory");
    pollFactory = await PollFactory.deploy();
    await pollFactory.deployed();
  });

  it("should create a new poll", async function () {
    const proposal = "Test proposal";
    const duration = 86400; // 1 day
    await pollFactory.createPoll(proposal, duration);
    const pollData = await pollFactory.getPollData(0);
    expect(pollData[0]).to.equal(proposal);
    expect(pollData[3]).to.equal(duration);
    expect(pollData[4]).to.be.false;
  });

  it("should cast a vote", async function () {
    const proposal = "Test proposal";
    const duration = 86400; // 1 day
    await pollFactory.createPoll(proposal, duration);
    await pollFactory.connect(user1).castVote(0, 1);
    const pollData = await pollFactory.getPollData(0);
    expect(pollData[1]).to.equal(1);
  });

  it("should end the vote", async function () {
    const proposal = "Test proposal";
    const duration = 86400; // 1 day
    await pollFactory.createPoll(proposal, duration);
    await pollFactory.endVote(0);
    const pollData = await pollFactory.getPollData(0);
    expect(pollData[4]).to.be.true;
  });
});