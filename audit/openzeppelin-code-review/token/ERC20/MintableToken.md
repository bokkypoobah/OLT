# MintableToken

Source file [../../../openzeppelin-contracts/token/ERC20/MintableToken.sol](../../../openzeppelin-contracts/token/ERC20/MintableToken.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.23;

// BK Next 2 Ok
import "./StandardToken.sol";
import "../../ownership/Ownable.sol";


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
// BK Ok
contract MintableToken is StandardToken, Ownable {
  // BK Next 2 Ok - Events
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  // BK Ok
  bool public mintingFinished = false;


  // BK Ok - Modifier
  modifier canMint() {
    // BK Ok
    require(!mintingFinished);
    // BK Ok
    _;
  }

  // BK Ok - Modifier
  modifier hasMintPermission() {
    // BK Ok
    require(msg.sender == owner);
    // BK Ok
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  // BK Ok - Only owner can mint. The owner is the ICO contract until the sale is closed, when minting is disabled
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    // BK Ok
    totalSupply_ = totalSupply_.add(_amount);
    // BK Ok
    balances[_to] = balances[_to].add(_amount);
    // BK Next 2 Ok - Log events
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    // BK Ok
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  // BK Ok - Only owner can execute. The owner is the ICO contract until the sale is closed
  function finishMinting() onlyOwner canMint public returns (bool) {
    // BK Ok
    mintingFinished = true;
    // BK Ok - Log event
    emit MintFinished();
    // BK Ok
    return true;
  }
}

```
