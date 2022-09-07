// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BtcPriceOracle.sol";


contract Caller is Ownable {
    uint private _btcPrice;
    address private _oracle;
    mapping(uint => bool) private _requests;

    event SetOracle(address oracle);

    constructor(address oracle_) {
        setOracle(oracle_);
    }

    function setOracle(address oracle_) public onlyOwner {
        _oracle = oracle_;
        emit SetOracle(oracle_);
    } 

    function getBtcPrice() public returns (uint) {
        BtcPriceOracle oracle = BtcPriceOracle(_oracle);
        uint id = oracle.getBtcPrice();
        _requests[id] = true;
        return id;
    }

    function setBtcPrice(uint id_, uint btcPrice_) public onlyOracle {
        require(_requests[id_], "Caller: no matching request id");
        _btcPrice = btcPrice_;
        delete _requests[id_];
    }

    modifier onlyOracle() {
        require(msg.sender == _oracle, "Caller: only oracle can call callback function.");
        _;
    }
}