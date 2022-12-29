// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/** @title A  contract for escrow
 * @author Reda Aboutika
 * @notice This contract is to demo a simple escrow contract
 */
contract Escrow {
    // State variables
    address public depositor;
    address public beneficiary;
    address public arbiter;
    bool public isApproved;

    event Approved(uint);

    constructor(address _arbiter, address _beneficiary) payable {
        beneficiary = _beneficiary;
        arbiter = _arbiter;
        depositor = msg.sender;
    }

    function approve() external {
        require(msg.sender == arbiter);
        uint balance = address(this).balance;
        (bool success, ) = beneficiary.call{value: address(this).balance}("");
        require(success);
        isApproved = true;
        emit Approved(balance);
    }
}
