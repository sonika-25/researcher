// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./Paper.sol";
import "./semaphore/Ownable.sol";


contract PaperResultsView is Ownable {

    struct PaperResultsWrapper {
        IPaper[] papers;
        string[] paperNames;
        mapping(IPaper => bool) paperMap;
    }

    PaperResultsWrapper paperResultsWrapper;
    address author;

    constructor(address _author) {
        author = _author;
    }
    
    // Retrieves all paper results
    function getPaperNames() public view returns (string[] memory) {
        require(author == msg.sender, "Only authors can view papers");
        return paperResultsWrapper.paperNames;
    }

    function getAllPaperAddresses() public view returns (IPaper[] memory) {
        require(author == msg.sender, "Only authors can view papers");
        return paperResultsWrapper.papers;
    }

    function addPaper(IPaper newPaper) public onlyOwner {
        paperResultsWrapper.papers.push(newPaper);
        paperResultsWrapper.paperNames.push(newPaper.getPaperName());
        paperResultsWrapper.paperMap[newPaper] = true;
    } 
}