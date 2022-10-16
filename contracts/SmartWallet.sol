//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract SmartWallet {
    event Log(string msg);
    address public owner = msg.sender;
    mapping(address => uint) spendAllowance;

    uint constant minConfirmations = 3;
    mapping(address => uint) voteCount;
    struct Guard {
        bool guard;
        bool voted;
        address vote;
    }
    mapping(address => Guard) guards;

    modifier isOwner {
        require(msg.sender == owner, "Caller is not the Owner");
        _;
    }

    modifier isAllowed(uint amount) {
        if (msg.sender != owner) {
            require(spendAllowance[msg.sender] > 0, "Spending denied");
        }
        require(address(this).balance >= amount, "Out of funds");
        _;
    }
    

    function spend(address payable to, uint amount) public isAllowed(amount) {
        spendAllowance[msg.sender] -= amount;
        to.transfer(amount);
    }

    function spendWithPayload(address payable to, uint amount, bytes memory payload) public isAllowed(amount) returns(bytes memory) {
        spendAllowance[msg.sender] -= amount;
        (bool success, bytes memory response) = to.call{value: amount}(payload);
        require(success, "Spending failed");
        return response;
    }

    function allowSpending(address a, uint amount) public isOwner {
        spendAllowance[a] = amount;
    }

    function addGuard(address a) public isOwner {
        guards[a] = Guard(true, false, address(0));
    }

    function denySpending(address a) public isOwner {
        spendAllowance[a] = 0;
    }

    function voteForNewOwner(address newOwner) public {
        require(guards[msg.sender].guard, "Voting denied");
        require(!guards[msg.sender].voted, "You have already voted");
        guards[msg.sender].voted = true;
        guards[msg.sender].vote = newOwner;
        voteCount[newOwner] += 1;
        if (voteCount[newOwner] == minConfirmations) {
            owner = newOwner;
            emit Log("New owner elected");
        }
    }

    function unvote() public {
        require(guards[msg.sender].guard, "Unvoting denied");
        require(guards[msg.sender].voted, "You didn't vote yet");
        guards[msg.sender].voted = false;
        voteCount[guards[msg.sender].vote] -= 1;
        guards[msg.sender].vote = address(0);
    }

    receive() external payable {}
}