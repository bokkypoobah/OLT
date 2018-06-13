# OneLedger Crowdsale Contract Audit

## Summary

[OneLedger](https://oneledger.io/) intends to run a crowdsale commencing on May 25 2018.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Ethereum smart contracts for OneLedger's crowdsale.

This audit has been conducted on OneLedger's source code in commits
[0892237](https://github.com/Oneledger/OLT/commit/0892237bd158f483e3cc03bf975d49b2bf376c62),
[f1c5bb7](https://github.com/Oneledger/OLT/commit/f1c5bb7a439782a85204e9764598d695649098f4),
[ea16049](https://github.com/Oneledger/OLT/commit/ea160497e62fa84ac5d057ecaf3a43175f4d0d00),
[df0cd5d](https://github.com/Oneledger/OLT/commit/df0cd5d4eca6f2d216ffdea19e224ceda75e8e7a),
[c88c6c4](https://github.com/Oneledger/OLT/commit/c88c6c4dcfe30ec111abd1dcfb4b1c5427231148) and
[572e128](https://github.com/Oneledger/OLT/commit/572e128606be3fb3c03c38c8bd681848efd4d9f9).

No potential vulnerabilities have been identified in the crowdsale, token and vesting contracts.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

* [x] **HIGH IMPORTANCE** A malicious third party can call `OneledgerTokenVesting.release(...)` with a token contract other than the real *OLT* token contract and deny the beneficiaries from ever receiving the real *OLT* tokens, as the `elapsedPeriods` variable can be made to update with the incorrect token contract
  * [x] Fixed in [ea16049](https://github.com/Oneledger/OLT/commit/ea160497e62fa84ac5d057ecaf3a43175f4d0d00)
* [x] **MEDIUM IMPORTANCE** To improve the security on the *OneledgerTokenVesting* contract, derive this class from *Ownable* and add `require(msg.sender == owner || msg.sender == beneficiary);` to  `OneledgerTokenVesting.release(...)`
  * [x] Updated in [df0cd5d](https://github.com/Oneledger/OLT/commit/df0cd5d4eca6f2d216ffdea19e224ceda75e8e7a)
* [x] **LOW IMPORTANCE** `OneledgerTokenVesting.getToken()` should be made a `view` function, or remove `getToken()` and make `token` public
  * [x] Fixed in [df0cd5d](https://github.com/Oneledger/OLT/commit/df0cd5d4eca6f2d216ffdea19e224ceda75e8e7a)
* [x] **LOW IMPORTANCE** `OneledgerToken.decimals` returns the `uint256` data type instead of `uint8` as recommended in the [ERC20 token standard]
  * [x] Fixed in [df0cd5d](https://github.com/Oneledger/OLT/commit/df0cd5d4eca6f2d216ffdea19e224ceda75e8e7a)

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the crowdsale, token and vesting contracts.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds
contributed to these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is to
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the OneLedger's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition
before funding any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on
the crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as
duplicating crowdsale websites. Potential participants should NOT just click on any links received through these messages.
Scammers have also hacked the crowdsale website to replace the crowdsale contract address with their scam address.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address
matches the audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

Ethers contributed to the crowdsale contract are transferred directly to the crowdsale wallet, and tokens are generated for the contributing account. This reduces the severity of any attacks on the crowdsale contract.

The token contract is a simple extension of the OpenZeppelin library token contract that is used by many other tokens.

Once the vesting contract is deployed, and tokens transferred to the vesting contract, only the beneficiary or the vesting contract owner is able to execute the token release function when the tokens are vested.

<br />

<hr />

## Testing

Details of the testing environment can be found in [test](test).

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy crowdsale contract
  * [x] Deploy token contract
* [x] Whitelist accounts
* [x] Contribute to the crowdsale contract during the 1st whitelist period with amount <= whitelisted amount
* [x] Contribute to the crowdsale contract during the 1st whitelist period with amount <= whitelisted amount and rejecting double contributions
* [x] Contribute to the crowdsale contract during the 2nd whitelist period with amount <= 2 x whitelisted amount
* [x] Contribute to the crowdsale contract after the 2nd whitelist period with no whitelisted amount limits
* [x] Crowdsale owner mint tokens
* [x] Finalise crowdsale
* [x] `transfer(...)`, `approve(...)` and `transferFrom(...)`
* [x] Deploy vesting contract
* [x] Transfer tokens to the vesting contract
* [x] Beneficiary execute vesting token release function
* [x] Vesting contract owner execute vesting token release function

<br />

<hr />

## Code Review

* [x] [code-review/ICO.md](code-review/ICO.md)
  * [x] contract ICO is Ownable
    * [x] using SafeMath for uint256;
* [x] [code-review/OneledgerToken.md](code-review/OneledgerToken.md)
  * [x] contract OneledgerToken is MintableToken
    * [x] using SafeMath for uint256;
* [x] [code-review/OneledgerTokenVesting.md](code-review/OneledgerTokenVesting.md)
  * [x] contract OneledgerTokenVesting
    * [x] using SafeMath for uint256;

<br />

### OpenZeppelin 1.10.0 Dependencies

The version of OpenZeppelin was upgrade from 1.8.0 to 1.10.0 in [572e128](https://github.com/Oneledger/OLT/commit/572e128606be3fb3c03c38c8bd681848efd4d9f9).

* [x] [openzeppelin-code-review/math/SafeMath.md](openzeppelin-code-review/math/SafeMath.md)
  * [x] library SafeMath
* [x] [openzeppelin-code-review/ownership/Ownable.md](openzeppelin-code-review/ownership/Ownable.md)
  * [x] contract Ownable
* [x] [openzeppelin-code-review/token/ERC20/ERC20Basic.md](openzeppelin-code-review/token/ERC20/ERC20Basic.md)
  * [x] contract ERC20Basic
* [x] [openzeppelin-code-review/token/ERC20/ERC20.md](openzeppelin-code-review/token/ERC20/ERC20.md)
  * [x] contract ERC20 is ERC20Basic
* [x] [openzeppelin-code-review/token/ERC20/BasicToken.md](openzeppelin-code-review/token/ERC20/BasicToken.md)
  * [x] contract BasicToken is ERC20Basic
    * [x] using SafeMath for uint256;
* [x] [openzeppelin-code-review/token/ERC20/StandardToken.md](openzeppelin-code-review/token/ERC20/StandardToken.md)
  * [x] contract StandardToken is ERC20, BasicToken
* [x] [openzeppelin-code-review/token/ERC20/MintableToken.md](openzeppelin-code-review/token/ERC20/MintableToken.md)
  * [x] contract MintableToken is StandardToken, Ownable

<br />

### Excluded - Only Used For Testing

* [../contracts/Migrations.sol](../contracts/Migrations.sol)

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for OneLedger - Jun 14 2018. The MIT Licence.

[ERC20 token standard]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md