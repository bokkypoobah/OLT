# OneledgerToken

Source file [../../contracts/OneledgerToken.sol](../../contracts/OneledgerToken.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity 0.4.23;

// BK Next 2 Ok
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";


/**
* @title OneledgerToken
* @dev this is the oneledger token
*/
// BK Ok
contract OneledgerToken is MintableToken {
    // BK Ok
    using SafeMath for uint256;

    // BK Next 2 Ok
    string public name = "Oneledger Token";
    string public symbol = "OLT";
    // BK Ok
    uint8 public decimals = 18;
    // BK Ok
    bool public active = false;
    /**
     * @dev restrict function to be callable when token is active
     */
    // BK Ok - Modifier
    modifier activated() {
        // BK Ok
        require(active == true);
        // BK Ok
        _;
    }

    /**
     * @dev activate token transfers
     */
    // BK Ok - Only owner can execute
    function activate() public onlyOwner {
        // BK Ok
        active = true;
    }

    /**
     * @dev transfer    ERC20 standard transfer wrapped with `activated` modifier
     */
    // BK Ok - Any account can execute when activated
    function transfer(address to, uint256 value) public activated returns (bool) {
        // BK Ok
        return super.transfer(to, value);
    }

    /**
     * @dev transfer    ERC20 standard transferFrom wrapped with `activated` modifier
     */
    // BK Ok - Any account can execute when activated
    function transferFrom(address from, address to, uint256 value) public activated returns (bool) {
        // BK Ok
        return super.transferFrom(from, to, value);
    }
}

```
