# OneLedger Crowdsale Contract Audit

[OneLedger](https://oneledger.io/) intends to run a crowdsale commencing on May 25 2018.

TODO: What is the version of the OpenZeppelin library

<br />

<hr />

## Table Of Contents

* [Code Review](#code-review)

<br />

<hr />

## Code Review

* [ ] [code-review/ICO.md](code-review/ICO.md)
  * [ ] contract ICO is Ownable
    * [ ] using SafeMath for uint256;
* [ ] [code-review/OneledgerToken.md](code-review/OneledgerToken.md)
  * [ ] contract OneledgerToken is MintableToken
    * [ ] using SafeMath for uint256;
* [ ] [code-review/OneledgerTokenVesting.md](code-review/OneledgerTokenVesting.md)
  * [ ] contract OneledgerTokenVesting
    * [ ] using SafeMath for uint256;

<br />

OpenZeppelin Dependencies

* ICO
  * import "zeppelin-solidity/contracts/math/SafeMath.sol";
  * import "zeppelin-solidity/contracts/ownership/Ownable.sol";
  * import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
    * import "./ERC20Basic.sol";
* OneLedgerToken
  * import "zeppelin-solidity/contracts/math/SafeMath.sol";
  * import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
    * import "./StandardToken.sol";
      * import "./BasicToken.sol";
        * import "./ERC20Basic.sol";
        * import "../../math/SafeMath.sol";
      * import "./ERC20.sol";
        * import "./ERC20Basic.sol";
    * import "../../ownership/Ownable.sol";
* OneledgerTokenVesting
  * import "zeppelin-solidity/contracts/math/SafeMath.sol";

<br />

Excluded as this is used for testing:

* [../contracts/Migrations.sol](../contracts/Migrations.sol)
