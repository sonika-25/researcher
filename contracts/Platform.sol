// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "./ReviewerView.sol";
import "./PaperResultsView.sol";
import "./Paper.sol";
import "hardhat/console.sol";

contract Platform {
    mapping(address => ReviewerView) reviewerViews;
    mapping(address => PaperResultsView) paperResultsViews;

    mapping(address => IPaper[]) paperBuffer;

    event create(string message);
    event complete(string message);

    function signInAsAuthor() public {
        if (paperResultsViews[msg.sender] == PaperResultsView(address(0))) {
            // create one instance of a research paper result view for a creator
            createPaperResultsView(msg.sender);
            console.log("Result view address", address(paperResultsViews[msg.sender]));
        } else {
            console.log("Not creating duplicate view");
        }
    }

    function signInAsReviewer() public {
        if (reviewerViews[msg.sender] == ReviewerView(address(0))) {
            // create one instance of reviewer view for a participant
            createReviewerView(msg.sender);
        }
        IPaper[] memory papers = paperBuffer[msg.sender];
        for (uint i = 0; i < papers.length; i++) {
            reviewerViews[msg.sender].addPaper(papers[i]);
        }
        delete paperBuffer[msg.sender];
    }

    // Author add the contract they created to the platform
    function addExistingPaper(
        address newPaperAddress
    ) public returns (address) {
        signInAsAuthor();
        PaperResultsView resultsView = paperResultsViews[msg.sender];

        console.log("Adding paper to results view");
        resultsView.addPaper(IPaper(newPaperAddress));
        /*for (uint i = 0; i < _participants.length; i++) {
            address participant = _participants[i];
            paperBuffer[participant].push(IPaper(newPaperAddress));
        }*/
        console.log("Completed adding paper to results view");
        return address(newPaperAddress);
    }

    function createPaperResultsView(address author) private {
        PaperResultsView resultsView = new PaperResultsView(author);
        paperResultsViews[author] = resultsView;
    }

    function createReviewerView(address reviewer) private {
        ReviewerView reviewerView = new ReviewerView(reviewer);
        reviewerViews[reviewer] = reviewerView;
    }

    function getAuthorsResultAddress() public view returns (address) {
        return address(paperResultsViews[msg.sender]);
    }

    function getReviewerViewAddress() public view returns (address) {
        return address(reviewerViews[msg.sender]);
    }
}