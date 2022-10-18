//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external;
    function decimals() external view returns(uint);
}

contract TokenSale {
    uint tokenPrice = 1 ether;
    address payable tokenOwner;
    IERC20 token;

    constructor(address _token, address payable _tokenOwner){
        tokenOwner = _tokenOwner;
        token = IERC20(_token);
    }

    function purchaseToken() public payable {
        require(msg.value >= tokenPrice, "Not enough money sent");
        uint tokensToSell = msg.value / tokenPrice;
        uint remainder = msg.value - tokensToSell * tokenPrice;
        token.transferFrom(tokenOwner, msg.sender, tokensToSell * 10 ** token.decimals());
        tokenOwner.transfer(tokensToSell * tokenPrice);
        payable(msg.sender).transfer(remainder);
    }
}