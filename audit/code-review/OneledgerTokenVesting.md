# OneledgerTokenVesting

Source file [../../contracts/OneledgerTokenVesting.sol](../../contracts/OneledgerTokenVesting.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity 0.4.23;

// BK Next 2 Ok
import "./OneledgerToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

// BK Ok
contract OneledgerTokenVesting {
    // BK Ok
    using SafeMath for uint256;

    // BK Ok - Event
    event Released(uint256 amount);

    // beneficiary of tokens after they are released
    // BK Ok
    address public beneficiary;

    // BK Next 3 Ok
    uint256 public startFrom;
    uint256 public period;
    uint256 public tokensReleasedPerPeriod;

    // BK Ok
    uint256 public elapsedPeriods;

    // BK Ok
    OneledgerToken private token;

    /**
     * @dev Creates a vesting contract for OneledgerToken
     * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param _startFrom Datetime when the vesting will begin
     * @param _period The preiod to release the token
     * @param _tokensReleasedPerPeriod the token to release per period
     */
    // BK Ok - Constructor
    constructor(
        address _beneficiary,
        uint256 _startFrom,
        uint256 _period,
        uint256 _tokensReleasedPerPeriod,
        OneledgerToken _token
    ) public {
        // BK Ok
        require(_beneficiary != address(0));
        // BK Ok
        require(_startFrom >= now);

        // BK Next 5 Ok
        beneficiary = _beneficiary;
        startFrom = _startFrom;
        period = _period;
        tokensReleasedPerPeriod = _tokensReleasedPerPeriod;
        elapsedPeriods = 0;
        token = _token;
    }

    /**
     *  @dev getToken this may be more convinience for user
     *        to check if their vesting contract is binded with a right token
     * return OneledgerToken
     */
     function getToken() public returns(OneledgerToken) {
       return token;
     }

    /**
     * @dev release
     * param _token Oneledgertoken that will be released to beneficiary
     */
    // BK NOTE - Anyone can call, but the tokens are only transferred to the beneficiary
    // BK Ok
    function release() public {
        // BK Ok
        require(token.balanceOf(this) >= 0 && now >= startFrom);
        // BK Ok
        uint256 elapsedTime = now.sub(startFrom);
        // BK Ok
        uint256 periodsInCurrentRelease = elapsedTime.div(period).sub(elapsedPeriods);
        // BK Ok
        uint256 tokensReadyToRelease = periodsInCurrentRelease.mul(tokensReleasedPerPeriod);
        // BK Ok
        uint256 amountToTransfer = tokensReadyToRelease > token.balanceOf(this) ? token.balanceOf(this) : tokensReadyToRelease;
        // BK Ok
        require(amountToTransfer > 0);
        // BK Ok
        elapsedPeriods = elapsedPeriods.add(periodsInCurrentRelease);
        // BK Ok
        token.transfer(beneficiary, amountToTransfer);
        // BK Ok - Log event
        emit Released(amountToTransfer);
    }
}

```
