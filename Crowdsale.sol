pragma solidity ^0.5.0;

import "./ShareCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

// Inherit the crowdsale contracts
contract ShareCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale {

    constructor(
        uint rate,
        address payable wallet, // sale beneficiary
        ShareCoin token, // the ShareCoin token itself that the contract will work with
        uint goal, //the minimum goal
        uint cap,
        uint openingTime,
        uint closingTime
    )
        Crowdsale (rate, wallet, token)
        CappedCrowdsale(cap)
        TimedCrowdsale(openingTime, closingTime)
        RefundableCrowdsale(goal)
        public
    {
        // constructor can stay empty
    }
}

contract ShareCoinSaleDeployer {

    address public token_sale_address; // will store ShareCoinSale's address once deployed
    address public token_address; // will store ShareCoin's address once deployed
    uint goal = 100;
    uint cap = 10000;

    constructor(
        string memory name,
        string memory symbol,
        address payable wallet // this address will receive all Ether raised by the sale
    )
        public
    {
        // Create the ShareCoin and keep its address handy
        ShareCoin token = new ShareCoin(name, symbol, 0); // create token with name, symbol, and initial supply
        token_address = address(token); // allows us to easily fetch the token address

        // Create the ShareCoinSale and tell it about the token, set the goal, and set the open and close times to now and now + 24 weeks.
        ShareCoinSale token_sale = new ShareCoinSale(1, wallet, token, goal, cap, now, now + 24 weeks); 
        token_sale_address = address(token_sale); 

        // Make the ShareCoinSale contract a minter, then have the ShareCoinSaleDeployer renounce its minter role
        token.addMinter(token_sale_address);
        token.renounceMinter();
    }
}
