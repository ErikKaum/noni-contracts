//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

contract Feedback {

    using Counters for Counters.Counter;
    Counters.Counter public likes;
    Counters.Counter public dislikes;

    constructor() {

    }

    function like() public {
        likes.increment();
    }

    function dislike() public {
        dislikes.increment(); 
    }

    function getFeedBack() public view returns(uint256[2] memory) {
        uint256 currentLikes = likes.current();
        uint256 currentDislikes = dislikes.current();

        return [currentLikes, currentDislikes];
    }

}