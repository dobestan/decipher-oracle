// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./DecipherManager.sol";


contract DecipherOracle is Ownable {
    mapping(uint => bool) private _requests;
    uint private _requestsCount = 0;  // also works as "salt"

    event GetPOC(address indexed manager, uint id, string name);
    event SetPOC(address indexed manager, uint id, string name, uint poc);

    function getPOC(string calldata name) public returns (uint) {
        _requestsCount++;
        uint _id = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _requestsCount)));
        _requests[_id] = true;
        emit GetPOC(msg.sender, _id, name);
        return _id;
    }

    function setPOC(uint _id, string calldata _name, uint _poc, address _manager) public onlyOwner {
        require(_requests[_id], "Oracle: no matching request id");
        delete _requests[_id];
        DecipherManager manager = DecipherManager(_manager);
        manager.setPOC(_id, _name, _poc);
        emit SetPOC(_manager, _id, _name, _poc);
    }
}