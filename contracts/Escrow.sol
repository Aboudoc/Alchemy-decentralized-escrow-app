// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

error Escrow__NotTheDepositor();
error Escrow__NotPending();

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
    Status private s_status;

    enum Status {
        PENDING,
        APPROVED,
        DISPUTTED,
        REFUNDED,
        WITHDRAWED
    }

    event Approved(uint);

    constructor(address _arbiter, address _beneficiary) payable {
        beneficiary = _beneficiary;
        arbiter = _arbiter;
        depositor = msg.sender;
        s_status = Status.PENDING;
    }

    function approve() external {
        require(msg.sender == arbiter);
        uint balance = address(this).balance;
        (bool success, ) = beneficiary.call{value: address(this).balance}("");
        require(success);
        s_status = Status.APPROVED;
        isApproved = true;
        emit Approved(balance);
    }

    function claim() external {
        if (msg.sender != depositor) {
            revert Escrow__NotTheDepositor();
        }
        if (s_status != Status.PENDING) {
            revert Escrow__NotPending();
        }
        s_status = Status.DISPUTTED;
    }
}
