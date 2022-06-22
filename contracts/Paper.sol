// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./semaphore/Semaphore.sol";
import "./Utils.sol";
import "./semaphore/Ownable.sol";
import "hardhat/console.sol";

interface IPaper{
    function getPaperScore() external 
        returns(string[] memory _paperLinks, uint _paperScore);
    function getPaperName() external returns (string memory);
}

interface ISemaphore {
    function addExternalNullifier(uint232 _externalNullifier) external;
    function broadcastSignal(
        bytes memory _signal,
        uint256[8] memory _proof,
        uint256 _root,
        uint256 _nullifiersHash,
        uint232 _externalNullifier
    ) external;
    function transferOwnership(address newOwner) external;
    function insertIdentity(uint256 _identityCommitment) external;
}

contract Paper is Ownable {

    string[] linksToPaper;
    string paperName;
    ISemaphore semaphore;

    uint232 externalNullifier;
    uint[] private paperValidation;
    uint private paperScore;
    uint private numRespondents;

    // control contract to update paper scores only when necessary
    bool shouldUpdatePaperScore;

    uint256[] identityCommitments;

    mapping(address => bool) trackValidationMap;

    modifier hasSemaphore() {
        require(semaphore != ISemaphore(address(0)), "must have semaphore");
        _;
    }
    
    constructor(
        string[] memory _paperLinks, 
        string memory _paperName,
        address _semaphoreAddress
    ) Ownable() {
        console.log("Entering constructor for Paper...");
        linksToPaper = _paperLinks;
        
        semaphore = ISemaphore(_semaphoreAddress);
        paperName = _paperName;
        shouldUpdatePaperScore = false;
    }

    function addExternalNullifier() public onlyOwner {
        bytes memory encoded = abi.encode(address(this));
        externalNullifier = uint232(uint256(keccak256(encoded)));
        semaphore.addExternalNullifier(externalNullifier);
        console.log("Paper: Adding external nullifier: ", externalNullifier);
    }

    function insertIdentity(uint256 _identityCommitment) public {
        require(trackValidationMap[msg.sender] == false, 
           "Validator can only insert identity once");
        console.log("Paper:start insert identity");
        semaphore.insertIdentity(_identityCommitment);
        identityCommitments.push(_identityCommitment);
        trackValidationMap[msg.sender] = true;
        uint numCommitments = identityCommitments.length;
        console.log("Number of commitments in Paper", numCommitments);
        console.log("Paper:complete insert identity");
    }

    function checkInsertIdentityStatus() public view returns (bool) {
        return trackValidationMap[msg.sender];
    }

    function verifyPaperSubmission(string[] memory _paperLinks) private view returns (bool) {
        // check that the response size is equal to the number of questions
        if (_paperLinks.length != linksToPaper.length) {
            console.log("questions array length invalid");
            return false;
        }
        
        /*for (uint i = 0; i < _paperLinks.length; i++) {
            string memory link = _paperLinks[i];
            if (link != linksToPaper[i]) {
                console.log("link invalid");
                return false;
            }
        }*/
        return true;
    }

    function updatePaperResult(
        string[] memory links,
        uint[] memory validations,
        bytes memory validationBytes,
        uint256[8] memory _proof,
        uint256 _root,
        uint256 _nullifiersHash)
    public hasSemaphore {
        require(verifyPaperSubmission(links), "Submission is incorrect");
        console.log("Paper:external nullifier in update paper result: ", externalNullifier);
        semaphore.broadcastSignal(
            validationBytes, 
            _proof, 
            _root, 
            _nullifiersHash, 
            externalNullifier
        );
        numRespondents++;
        for(uint i = 0; i < validations.length; i++) {
            uint score = validations[i];
            paperValidation.push(score);
        }
        shouldUpdatePaperScore = true;
    }

    // This function will be used to retrieve results
    function calcAverageScoreOfPaper() public {
        if (!shouldUpdatePaperScore) {
            console.log("Do not need to update paper score");
            return;
        }
        // remove all average scores stored in array
        delete paperScore;
        uint avgScore = Utils.getArraySum( paperValidation ) / numRespondents;
        paperScore = avgScore;
        
        console.log("Complete updating paper score");
        shouldUpdatePaperScore = false;
    }

    function getPaper() public view onlyOwner hasSemaphore returns(string[] memory _links, uint _validations) {
        return (linksToPaper, paperScore);
    }

    function getPaperName() public view returns (string memory) {
        return paperName;
    }

    function getIdentityCommitments() public view returns (uint256[] memory) {
        return identityCommitments;
    }

    function getExternalNullifier() public view returns (uint232) {
        return externalNullifier;
    }
}
