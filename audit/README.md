# OneLedger Crowdsale Contract Audit

[OneLedger](https://oneledger.io/) intends to run a crowdsale commencing on May 25 2018.

TODO: What is the version of the OpenZeppelin library? This test will assume 1.8.0 as advised.

Commits [0892237](https://github.com/Oneledger/OLT/commit/0892237bd158f483e3cc03bf975d49b2bf376c62) and
[f1c5bb7](https://github.com/Oneledger/OLT/commit/f1c5bb7a439782a85204e9764598d695649098f4).

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

### OpenZeppelin 1.8.0 Dependencies

* [ ] [openzeppelin-code-review/math/SafeMath.md](openzeppelin-code-review/math/SafeMath.md)
  * [ ] library SafeMath
* [ ] [openzeppelin-code-review/ownership/Ownable.md](openzeppelin-code-review/ownership/Ownable.md)
  * [ ] contract Ownable
* [ ] [openzeppelin-code-review/token/ERC20/BasicToken.md](openzeppelin-code-review/token/ERC20/BasicToken.md)
  * [ ] contract BasicToken is ERC20Basic
    * [ ] using SafeMath for uint256;
* [ ] [openzeppelin-code-review/token/ERC20/ERC20.md](openzeppelin-code-review/token/ERC20/ERC20.md)
  * [ ] contract ERC20 is ERC20Basic
* [ ] [openzeppelin-code-review/token/ERC20/ERC20Basic.md](openzeppelin-code-review/token/ERC20/ERC20Basic.md)
  * [ ] contract ERC20Basic
* [ ] [openzeppelin-code-review/token/ERC20/MintableToken.md](openzeppelin-code-review/token/ERC20/MintableToken.md)
  * [ ] contract MintableToken is StandardToken, Ownable
* [ ] [openzeppelin-code-review/token/ERC20/StandardToken.md](openzeppelin-code-review/token/ERC20/StandardToken.md)
  * [ ] contract StandardToken is ERC20, BasicToken

<br />

### Excluded - Only Used For Testing

* [../contracts/Migrations.sol](../contracts/Migrations.sol)

### Compiler Error

There is a Solidity command line compiler bug in OS/X version 0.4.23 where certain statements in the constructor cannot be evaluated without the compiler throwing an internal error. The statement that triggers this error is in the constructor of ICO.sol and is the line `require(_weiCap.mul(_rate) <= TOTAL_TOKEN_SUPPLY);`. For this testing, this statement has been automatically removed to enable the compilation of the Solidity smart contracts.

This error does not appear in the Remix version of Solidity compiler 0.4.23.

```
Internal compiler error during compilation:
/tmp/solidity-20180501-9472-436klv/solidity_0.4.23/libsolidity/interface/CompilerStack.cpp(732): Throw in function void dev::solidity::CompilerStack::compileContract(const dev::solidity::ContractDefinition &, map<const dev::solidity::ContractDefinition *, const eth::Assembly *> &)
Dynamic exception type: boost::exception_detail::clone_impl<dev::solidity::InternalCompilerError>
std::exception::what: Assembly exception for bytecode
[dev::tag_comment*] = Assembly exception for bytecode
```

### Compiler Warnings

The following compiler warning messages is due to the use of the Solidity compiler version 0.4.23 with code written for earlier versions of the Solidity compiler. These warnings relate to the changes where contract constructors are now named `constructor(...)` instead of a function with the same name as the contract, and the event logging statements must now be preceded with the `emit` keyword.

```
ownership/Ownable.sol:20:3: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
  function Ownable() public {
  ^ (Relevant source part starts here and spans across multiple lines).
token/ERC20/BasicToken.sol:38:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(msg.sender, _to, _value);
    ^-------------------------------^
token/ERC20/StandardToken.sol:33:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(_from, _to, _value);
    ^--------------------------^
token/ERC20/StandardToken.sol:49:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, _value);
    ^------------------------------------^
token/ERC20/StandardToken.sol:75:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    ^-----------------------------------------------------------^
token/ERC20/StandardToken.sol:96:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    ^-----------------------------------------------------------^
ownership/Ownable.sol:38:5: Warning: Invoking events without "emit" prefix is deprecated.
    OwnershipTransferred(owner, newOwner);
    ^-----------------------------------^
token/ERC20/MintableToken.sol:34:5: Warning: Invoking events without "emit" prefix is deprecated.
    Mint(_to, _amount);
    ^----------------^
token/ERC20/MintableToken.sol:35:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(address(0), _to, _amount);
    ^--------------------------------^
token/ERC20/MintableToken.sol:45:5: Warning: Invoking events without "emit" prefix is deprecated.
    MintFinished();
    ^------------^
ownership/Ownable.sol:20:3: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
  function Ownable() public {
  ^ (Relevant source part starts here and spans across multiple lines).
token/ERC20/BasicToken.sol:38:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(msg.sender, _to, _value);
    ^-------------------------------^
token/ERC20/StandardToken.sol:33:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(_from, _to, _value);
    ^--------------------------^
token/ERC20/StandardToken.sol:49:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, _value);
    ^------------------------------------^
token/ERC20/StandardToken.sol:75:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    ^-----------------------------------------------------------^
token/ERC20/StandardToken.sol:96:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    ^-----------------------------------------------------------^
ownership/Ownable.sol:38:5: Warning: Invoking events without "emit" prefix is deprecated.
    OwnershipTransferred(owner, newOwner);
    ^-----------------------------------^
token/ERC20/MintableToken.sol:34:5: Warning: Invoking events without "emit" prefix is deprecated.
    Mint(_to, _amount);
    ^----------------^
token/ERC20/MintableToken.sol:35:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(address(0), _to, _amount);
    ^--------------------------------^
token/ERC20/MintableToken.sol:45:5: Warning: Invoking events without "emit" prefix is deprecated.
    MintFinished();
    ^------------^
ownership/Ownable.sol:20:3: Warning: Defining constructors as functions with the same name as the contract is deprecated. Use "constructor(...) { ... }" instead.
  function Ownable() public {
  ^ (Relevant source part starts here and spans across multiple lines).
token/ERC20/BasicToken.sol:38:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(msg.sender, _to, _value);
    ^-------------------------------^
token/ERC20/StandardToken.sol:33:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(_from, _to, _value);
    ^--------------------------^
token/ERC20/StandardToken.sol:49:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, _value);
    ^------------------------------------^
token/ERC20/StandardToken.sol:75:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    ^-----------------------------------------------------------^
token/ERC20/StandardToken.sol:96:5: Warning: Invoking events without "emit" prefix is deprecated.
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    ^-----------------------------------------------------------^
ownership/Ownable.sol:38:5: Warning: Invoking events without "emit" prefix is deprecated.
    OwnershipTransferred(owner, newOwner);
    ^-----------------------------------^
token/ERC20/MintableToken.sol:34:5: Warning: Invoking events without "emit" prefix is deprecated.
    Mint(_to, _amount);
    ^----------------^
token/ERC20/MintableToken.sol:35:5: Warning: Invoking events without "emit" prefix is deprecated.
    Transfer(address(0), _to, _amount);
    ^--------------------------------^
token/ERC20/MintableToken.sol:45:5: Warning: Invoking events without "emit" prefix is deprecated.
    MintFinished();
    ^------------^
```