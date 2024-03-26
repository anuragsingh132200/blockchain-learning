// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// Import PriceConverter library
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        
        bool isFunder = false;
        for(uint256 i = 0; i < funders.length; i++) {
            if(funders[i] == msg.sender) {
                addressToAmountFunded[msg.sender] += msg.value;
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
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        i_owner = newOwner;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}
