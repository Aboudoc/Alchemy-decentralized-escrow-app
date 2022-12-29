// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

error Escrow__NotTheDepositor();
error Escrow__NotTheArbiter();
error Escrow__NotPending();
error Escrow__NotDisputted();
error Escrow__AlreadyApproved();

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
        REFUNDED
    }

    event Approved(uint);
    event Refunded(uint);

    constructor(address _arbiter, address _beneficiary) payable {
        beneficiary = _beneficiary;
        arbiter = _arbiter;
        depositor = msg.sender;
        s_status = Status.PENDING;
    }

    function approve() external {
        require(msg.sender == arbiter);
        if (s_status == Status.APPROVED) {
            revert Escrow__AlreadyApproved();
        }
        uint balance = address(this).balance;
        (bool success, ) = beneficiary.call{value: address(this).balance}("");
        require(success);
        s_status = Status.APPROVED;
        isApproved = true;
        emit Approved(balance);
    }

    function refund() external {
        if (msg.sender != arbiter) {
            revert Escrow__NotTheArbiter();
        }
        if (s_status != Status.DISPUTTED) {
            revert Escrow__NotDisputted();
        }
        s_status = Status.REFUNDED;
        uint balance = address(this).balance;
        (bool success, ) = depositor.call{value: balance}("");
        require(success);
        emit Refunded(balance);
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
