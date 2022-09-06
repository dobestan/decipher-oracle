// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Caller is Ownable {
    uint private _btcPrice;
    address private _oracle;
    mapping(uint => bool) private _requests;

    function setOracle(address oracle_) public onlyOwner {
        _oracle = oracle_;
    } 

    function getBtcPrice() public {
        // #TODO: get request id from oracle contract
        // #TODO: set requests[id] to true
    }

    function callback(uint id_, uint btcPrice_) public onlyOracle {
        require(_requests[id_], "Caller: no matching request id");
        _btcPrice = btcPrice_;
        delete _requests[id_];
    }

    modifier onlyOracle() {
        require(msg.sender == _oracle, "Caller: only oracle can call callback function.");
        _;
    }
}