// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
  * @title LilEscrow
  * @author Kenneth Gabriel
*/
contract LilEscrow{
    address payable public seller;
    address payable public buyer; 
    uint public value;

    enum State {
        Created, Locked, 
        Release, Inactive
    }

    State public state;

    event PurchaseConfirmed();
    event Aborted();
    event ItemReceived();
    event SellerRefunded();

    constructor () payable {
        seller = payable(msg.sender);
        value  = msg.value;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only Seller");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only Buyer");
        _;
    }

    modifier isState(State _state) {
        require(state == _state, "Not in required state");
        _;
    }

    /**
      * @notice this function confirm the purchase as buyer.
    */
    function confirmPurchase() external isState(State.Created){
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    /**
      * @notice this function confirms that the buyer received the item.
      * This will release the locked ether.
    */
    function confirmReceived() external onlyBuyer isState(State.Locked){
        emit ItemReceived();
        state = State.Release;

        buyer.transfer(value);
    }
    
    /**
      * @notice This function refunds the seller
    */
    function refundSeller() external onlySeller isState(State.Locked){
        emit SellerRefunded();
        state = State.Inactive;

        seller.transfer(value);
    }

    /** 
      * @notice lets the seller reclaim ether.
      * This only be called by the seller before
      * the contract is locked.
    */
    function abort() external onlySeller isState(State.Created){
        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
}