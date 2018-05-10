# OneLedger Crowdsale Contract Audit

[OneLedger](https://oneledger.io/) intends to run a crowdsale commencing on May 25 2018.

TODO: What is the version of the OpenZeppelin library? This test will assume 1.9.0 until advised.

Commits [0892237](https://github.com/Oneledger/OLT/commit/0892237bd158f483e3cc03bf975d49b2bf376c62).

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

Compiler warnings:

```
ownership/Ownable.sol:20:3: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
  function Ownable() public {
  ^ (Relevant source part starts here and spans across multiple lines).
ownership/Ownable.sol:20:3: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
  function Ownable() public {
  ^ (Relevant source part starts here and spans across multiple lines).
OneledgerTokenVesting.sol:27:5: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
    function OneledgerTokenVesting(
    ^ (Relevant source part starts here and spans across multiple lines).
ICO.sol:34:5: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
    function ICO(address _wallet, uint256 _rate, uint256 _startDate, uint256 _weiCap) public {
    ^ (Relevant source part starts here and spans across multiple lines).
ICO.sol:100:5: Warning: Function state mutability can be restricted to view
    function validatePurchase(uint256 weiPaid) internal {
    ^ (Relevant source part starts here and spans across multiple lines).
ownership/Ownable.sol:20:3: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
  function Ownable() public {
  ^ (Relevant source part starts here and spans across multiple lines).
OneledgertokenVesting.sol:27:5: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
    function OneledgerTokenVesting(
    ^ (Relevant source part starts here and spans across multiple lines).
```