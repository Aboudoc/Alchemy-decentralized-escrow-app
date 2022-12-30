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
    uint256 private s_totalApproved;
    uint256 private s_totalRefund;

    enum Status {
        PENDING,
        CONFIRMED,
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

    /**
     * @notice Allows the arbiter to approve the transaction and send the balance to the beneficiary
     */
    function approve() external {
        if (msg.sender != arbiter) {
            revert Escrow__NotTheArbiter();
        }
        if (s_status == Status.APPROVED) {
            revert Escrow__AlreadyApproved();
        }
        uint balance = address(this).balance;
        (bool success, ) = beneficiary.call{value: address(this).balance}("");
        require(success);
        s_status = Status.APPROVED;
        isApproved = true;
        s_totalApproved++;
        emit Approved(balance);
    }

    /**
     * @notice Allows the arbiter to refund the depositor if the claim is accepted
     */
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
        s_totalRefund++;
        emit Refunded(balance);
    }

    /**
     * @notice Allows the depositor to confirm the transaction
     */
    function confirm() external {
        if (msg.sender != depositor) {
            revert Escrow__NotTheDepositor();
        }
        if (s_status != Status.PENDING) {
            revert Escrow__NotPending();
        }
        s_status = Status.CONFIRMED;
    }

    /**
     * @notice Allows the depositor to open a claim and "pause" the transaction
     */
    function claim() external {
        if (msg.sender != depositor) {
            revert Escrow__NotTheDepositor();
        }
        if (s_status != Status.PENDING) {
            revert Escrow__NotPending();
        }
        s_status = Status.DISPUTTED;
    }

    function getStatus() public view returns (Status) {
        return s_status;
    }

    function getTotalApproved() public view returns (uint) {
        return s_totalApproved;
    }

    function getTotalRefund() public view returns (uint) {
        return s_totalRefund;
    }
}
