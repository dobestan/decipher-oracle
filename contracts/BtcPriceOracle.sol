// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Caller.sol";


contract BtcPriceOracle is Ownable {
    mapping(uint => bool) private _requests;
    uint private _requestsCount = 0;  // also works as "salt"

    event GetBtcPrice(address indexed caller, uint id);
    event SetBtcPrice(address indexed caller, uint id, uint btcPrice);

    function getBtcPrice() public returns (uint) {
        _requestsCount++;
        uint _id = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _requestsCount)));
        _requests[_id] = true;
        emit GetBtcPrice(msg.sender, _id);
        // #TODO: Client should listen to GetBtcPrice event.
        return _id;
    }

    function setBtcPrice(uint _id, uint _btcPrice, address _caller) public onlyOwner {
        require(_requests[_id], "Oracle: no matching request id");
        delete _requests[_id];
        Caller caller = Caller(_caller);
        caller.callback(_id, _btcPrice);
        emit SetBtcPrice(_caller, _id, _btcPrice);
    }
}