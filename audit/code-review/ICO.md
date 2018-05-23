# ICO

Source file [../../contracts/ICO.sol](../../contracts/ICO.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity 0.4.23;

// BK Next 5 Ok
import "./OneledgerToken.sol";
import "./OneledgerTokenVesting.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";


// BK Ok
contract ICO is Ownable {
    // BK Ok
    using SafeMath for uint256;

    // BK Ok
    struct WhiteListRecord {
        // BK Ok
        uint256 offeredWei;
        // BK Ok
        uint256 lastPurchasedTimestamp;
    }

    // BK Ok
    OneledgerToken public token;
    // BK Ok
    address public wallet; // Address where funds are collected
    // BK Ok
    uint256 public rate;   // How many token units a buyer gets per eth
    // BK Ok
    mapping (address => WhiteListRecord) public whiteList;
    // BK Next 4 Ok
    uint256 public initialTime;
    bool public saleClosed;
    uint256 public weiCap;
    uint256 public weiRaised;

    // BK Ok
    uint256 public TOTAL_TOKEN_SUPPLY = 1000000000 * (10 ** 18);

    // BK Next 2 Ok - Event
    event BuyTokens(uint256 weiAmount, uint256 rate, uint256 token, address beneficiary);
    event UpdateRate(uint256 rate);

    /**
    * @dev constructor
    */
    // BK Ok - Constructor
    constructor(address _wallet, uint256 _rate, uint256 _startDate, uint256 _weiCap) public {
        // BK Next 3 Ok
        require(_rate > 0);
        require(_wallet != address(0));
        require(_weiCap.mul(_rate) <= TOTAL_TOKEN_SUPPLY);

        // BK Next 6 Ok
        wallet = _wallet;
        rate = _rate;
        initialTime = _startDate;
        saleClosed = false;
        weiCap = _weiCap;
        weiRaised = 0;

        // BK Ok
        token = new OneledgerToken();
    }

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     */
    // BK Ok - Whitelisted accounts can call to buy tokens by sending ETH after the start date, before the sale is closed
    function() external payable {
        // BK Ok
        buyTokens();
    }

    /**
     * @dev update the rate
     */
    // BK Ok - Only owner can execute, before initialTime
    function updateRate(uint256 rate_) public onlyOwner {
      // BK Ok
      require(now <= initialTime);
      // BK Ok
      rate = rate_;
      // BK Ok
      emit UpdateRate(rate);
    }

    /**
     * @dev buy tokens
     */
    // BK Ok - Whitelisted accounts can call the buy tokens by sending ETH after the start date, before the sale is closed
    function buyTokens() public payable {
        // BK Ok
        validatePurchase(msg.value);
        // BK Ok
        uint256 tokenToBuy = msg.value.mul(rate);
        // BK Ok
        whiteList[msg.sender].lastPurchasedTimestamp = now;
        // BK Ok
        weiRaised = weiRaised.add(msg.value);
        // BK Ok
        token.mint(msg.sender, tokenToBuy);
        // BK Ok
        wallet.transfer(msg.value);
        // BK Ok - Log event
        emit BuyTokens(msg.value, rate, tokenToBuy, msg.sender);
    }

    /**
    * @dev add to white list
    * param addresses the list of address added to white list
    * param weiPerContributor the wei can be transfer per contributor
    * param capWei for the user in this list
    */
    // BK Ok - Only owner can execute
    function addToWhiteList(address[] addresses, uint256 weiPerContributor) public onlyOwner {
        // BK Ok
        for (uint32 i = 0; i < addresses.length; i++) {
            // BK Ok
            whiteList[addresses[i]] = WhiteListRecord(weiPerContributor, 0);
        }
    }

    /**
     * @dev mint token to new address, either contract or a wallet
     * param OneledgerTokenVesting vesting contract
     * param uint256 total token number to mint
    */
    // BK Ok - Only owner can execute to mint tokens for the specified account
    function mintToken(address target, uint256 tokenToMint) public onlyOwner {
      // BK Ok
      token.mint(target, tokenToMint);
    }

    /**
     * @dev close the ICO
     */
    // BK Ok - Only owner can execute
    function closeSale() public onlyOwner {
        // BK NOTE - Could add a `require(!saleClosed);` statement here, but does not matter as the token contract calls will throw an error
        saleClosed = true;
        // BK Ok
        token.mint(owner, TOTAL_TOKEN_SUPPLY.sub(token.totalSupply()));
        // BK Ok
        token.finishMinting();
        // BK Ok
        token.transferOwnership(owner);
    }

    // BK Ok - Internal view function
    function validatePurchase(uint256 weiPaid) internal view{
        // BK Ok
        require(!saleClosed);
        // BK Ok
        require(initialTime <= now);
        // BK Ok
        require(whiteList[msg.sender].offeredWei > 0);
        // BK Ok
        require(weiPaid <= weiCap.sub(weiRaised));
        // can only purchase once every 24 hours
        // BK Ok
        require(now.sub(whiteList[msg.sender].lastPurchasedTimestamp) > 24 hours);
        // BK Ok
        uint256 elapsedTime = now.sub(initialTime);
        // check day 1 buy limit
        // BK CHECK - fail if elapsedTime <= 24h && msg.value > whiteList[msg.sender].offeredWei
        require(elapsedTime > 24 hours || msg.value <= whiteList[msg.sender].offeredWei);
        // check day 2 buy limit
        // BK CHECK - fail if elapsedTime <= 48h && msg.value > 2 x whiteList[msg.sender].offeredWei
        require(elapsedTime > 48 hours || msg.value <= whiteList[msg.sender].offeredWei.mul(2));
    }
}

```
