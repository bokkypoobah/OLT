# ERC20Basic

Source file [../../../openzeppelin-contracts/token/ERC20/ERC20Basic.sol](../../../openzeppelin-contracts/token/ERC20/ERC20Basic.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
// BK Ok
contract ERC20Basic {
  // BK Next 3 Ok
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  // BK Ok - Event
  event Transfer(address indexed from, address indexed to, uint256 value);
}

```
