// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@OpenZeppelin/contracts/utils/math/SafeMath.sol";


/**
  * @title LilDivorce
  * @author kenneth gariel
*/
contract LilDivorce {
    address payable public husbandAddress;
    address payable public wifeAddress;

    using SafeMath for uint256;

    enum State {
        Initiated,
        Inactive
    }

    event InitiatedContract(address husbandAddress, address wifeAddress, uint wifeCut);
    event Deposit(address sender, uint value, uint newBalance);
    event Split(address sender);
    event ContractFinalized();

    /// Wive's cut in percentage
    uint256 public wifeCut;
    uint256 public balance; 
    
    State public state;

    receive() external payable {
        balance  = balance.add(msg.value);
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /**
      * @notice Initiate the contract by assigning a husband's and wife's
      * address and also the agreed percentage split.
      * @param _husbandAddress is the address of the husband
      * @param _wifeAddress is the address of the wife
    */
    constructor (address payable _husbandAddress, address payable _wifeAddress, uint _wifeCut) payable {
        require((_husbandAddress != address(0)) && (_wifeAddress != address(0)));
        require(_wifeCut < 100);

        emit InitiatedContract(_husbandAddress, _wifeAddress, _wifeCut);

        husbandAddress = _husbandAddress;
        wifeAddress = _wifeAddress;
        wifeCut = _wifeCut;
        balance = msg.value;
        state = State.Initiated;
    }

    modifier onlyOwner() {
        require(msg.sender == husbandAddress || msg.sender == wifeAddress);
        _;
    }

    modifier onlyState(State _state) {
        require(_state == state);
        _;
    }

    /**
      * @notice splits the money and sends the cut to their
      * respective owner
    */
    function splitBalance() external onlyOwner onlyState(State.Initiated) {
        emit Split(msg.sender);
        (uint wifeAmount, uint husbandAmount) = _getPercentages();

        wifeAddress.transfer(wifeAmount);
        husbandAddress.transfer(husbandAmount);
        state = State.Inactive;
        emit ContractFinalized();
    }

    /**
      * @notice splits the money based on the cut agreed upon
      * @return the husband's and wife's cut respectively
    */
    function _getPercentages() private view returns (uint, uint) {
        uint si = address(this).balance.mul(wifeCut).div(100);
        return (si, address(this).balance - si);
    }
}