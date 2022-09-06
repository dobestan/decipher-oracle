// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./DecipherOracle.sol";


contract DecipherManager is Ownable {
    address private _oracle;
    mapping(uint => bool) private _requests;
    mapping(string => uint) public leaderboard;

    event SetOracle(address oracle);

    constructor(address oracle_) {
        setOracle(oracle_);
    }

    function setOracle(address oracle_) public onlyOwner {
        _oracle = oracle_;
        emit SetOracle(oracle_);
    } 

    function getPOC(string calldata name) public returns (uint) {
        DecipherOracle oracle = DecipherOracle(_oracle);
        uint id = oracle.getPOC(name);
        _requests[id] = true;
        return id;
    }

    function setPOC(uint _id, string calldata _name, uint _poc) public onlyOracle {
        require(_requests[_id], "Caller: no matching request id");
        leaderboard[_name] = _poc;
        delete _requests[_id];
    }

    modifier onlyOracle() {
        require(msg.sender == _oracle, "Caller: only oracle can call callback function.");
        _;
    }
}