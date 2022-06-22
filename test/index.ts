import { ethers } from "hardhat";
const { expect } = require("chai");

describe("Platform contract", function () {
  it("Sign in to platform should create only one result view for user", async function () {
    const [owner] = await ethers.getSigners();
    const Utils = await ethers.getContractFactory("Utils");
    const utils = Utils.deploy();
    const utilsAddress = (await utils).address;
    const Platform = await ethers.getContractFactory("Platform");

    const platform1 = await Platform.deploy();

    await platform1.signInAsAuthor();
    await platform1.signInAsAuthor();
    
    console.log(await platform1.getAuthorsResultAddress());

    await platform1.signInAsReviewer();
    console.log (await platform1.getReviewerViewAddress())
    
  });
});
