// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// Remove the import statement for PriceConverter.sol

error NotOwner();

contract FundMe {
    // Remove the "using PriceConverter for uint256;" statement

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value >= MINIMUM_USD, "You need to spend more ETH!");
        
        bool isFunder = false;
        for(uint256 i = 0; i < funders.length; i++) {
            if(funders[i] == msg.sender) {
                isFunder = true;
                break;
            }
        }
        if(!isFunder) {
            addressToAmountFunded[msg.sender] += msg.value;
            funders.push(msg.sender);
        }
    }
    
    modifier onlyOwner {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address ;
        
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
