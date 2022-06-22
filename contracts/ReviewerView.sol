// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./Paper.sol";
import "./semaphore/Ownable.sol";


contract ReviewerView is Ownable {
        
    struct ReviewerViewWrapper {
        IPaper[] papers;
        string[] paperNames;
        mapping(IPaper => bool) paperMap;
    }

    ReviewerViewWrapper reviewerViewWrapper;
    address reviewerAddress;

    constructor(address _reviewerAddress) Ownable() {
        reviewerAddress = _reviewerAddress;
    }

    function getPaperNames() public view returns (string[] memory) {
        require(msg.sender == reviewerAddress, "Only reviewer can view paper names");
        return reviewerViewWrapper.paperNames;
    }

    function getAllPaperAddresses() public view returns (IPaper[] memory) {
        require(msg.sender == reviewerAddress, "Only reviewer can view paper addresses");
        return reviewerViewWrapper.papers;
    }

    function openPaper(address paperAddress, uint256 identityCommitment) public {
        require(msg.sender == reviewerAddress, "Only reviewer can open paper instance");
    }

    function submitPaperResponse() public {
        require(msg.sender == reviewerAddress, "Only reviewer can submit paper review");
    }
    function addPaper(IPaper newPaper) public onlyOwner {
        reviewerViewWrapper.papers.push(newPaper);
        reviewerViewWrapper.paperNames.push(newPaper.getPaperName());
        reviewerViewWrapper.paperMap[newPaper] = true;
    } 
}