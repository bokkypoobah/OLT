# Ownable

Source file [../../openzeppelin-contracts/ownership/Ownable.sol](../../openzeppelin-contracts/ownership/Ownable.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.23;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
// BK Ok
contract Ownable {
  // BK Ok
  address public owner;


  // BK Next 2 Ok - Events
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  // BK Ok - Constructor
  constructor() public {
    // BK Ok
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  // BK Ok - Modifier
  modifier onlyOwner() {
    // BK Ok
    require(msg.sender == owner);
    // BK Ok
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  // BK Ok - Only owner can execute
  function renounceOwnership() public onlyOwner {
    // BK Ok - Log event
    emit OwnershipRenounced(owner);
    // BK Ok
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  // BK Ok - Only owner can execute
  function transferOwnership(address _newOwner) public onlyOwner {
    // BK Ok
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  // BK Ok - Internal function
  function _transferOwnership(address _newOwner) internal {
    // BK Ok
    require(_newOwner != address(0));
    // BK Ok - Log event
    emit OwnershipTransferred(owner, _newOwner);
    // BK Ok
    owner = _newOwner;
  }
}

```
