#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

TOKENSOL=`grep ^TOKENSOL= settings.txt | sed "s/^.*=//"`
TOKENJS=`grep ^TOKENJS= settings.txt | sed "s/^.*=//"`
CROWDSALESOL=`grep ^CROWDSALESOL= settings.txt | sed "s/^.*=//"`
CROWDSALEJS=`grep ^CROWDSALEJS= settings.txt | sed "s/^.*=//"`
VESTINGSOL=`grep ^VESTINGSOL= settings.txt | sed "s/^.*=//"`
VESTINGJS=`grep ^VESTINGJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

START_DATE=`echo "$CURRENTTIME+30" | bc`
START_DATE_S=`date -r $START_DATE -u`
END_DATE=`echo "$CURRENTTIME+60*1+30" | bc`
END_DATE_S=`date -r $END_DATE -u`

printf "MODE               = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT    = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD           = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR          = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "TOKENSOL           = '$TOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "TOKENJS            = '$TOKENJS'\n" | tee -a $TEST1OUTPUT
printf "CROWDSALESOL       = '$CROWDSALESOL'\n" | tee -a $TEST1OUTPUT
printf "CROWDSALEJS        = '$CROWDSALEJS'\n" | tee -a $TEST1OUTPUT
printf "VESTINGSOL       = '$VESTINGSOL'\n" | tee -a $TEST1OUTPUT
printf "VESTINGJS        = '$VESTINGJS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA     = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS          = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT        = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS       = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME        = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE         = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE           = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/$TOKENSOL .`
`cp $SOURCEDIR/$CROWDSALESOL .`
`cp $SOURCEDIR/$VESTINGSOL .`
`cp -rp ../openzeppelin-contracts/* .`

# --- Modify parameters ---
`perl -pi -e "s/zeppelin-solidity\/contracts\///" *.sol`
`perl -pi -e "s/require\(_weiCap\.mul\(_rate\) \<\= TOTAL_TOKEN_SUPPLY\);/\/\/ require\(_weiCap\.mul\(_rate\) \<\= TOTAL_TOKEN_SUPPLY\);/" $CROWDSALESOL`
`perl -pi -e "s/24 hours/30 seconds/" $CROWDSALESOL`
`perl -pi -e "s/48 hours/60 seconds/" $CROWDSALESOL`

for FILE in $TOKENSOL $CROWDSALESOL $VESTINGSOL
do
  DIFFS1=`diff $SOURCEDIR/$FILE $FILE`
  echo "--- Differences $SOURCEDIR/$FILE $FILE ---" | tee -a $TEST1OUTPUT
  echo "$DIFFS1" | tee -a $TEST1OUTPUT
done

solc_0.4.23 --version | tee -a $TEST1OUTPUT

echo "var tokenOutput=`solc_0.4.23 --optimize --pretty-json --combined-json abi,bin,interface $TOKENSOL`;" > $TOKENJS
echo "var crowdsaleOutput=`solc_0.4.23 --optimize --pretty-json --combined-json abi,bin,interface $CROWDSALESOL`;" > $CROWDSALEJS
echo "var vestingOutput=`solc_0.4.23 --optimize --pretty-json --combined-json abi,bin,interface $VESTINGSOL`;" > $VESTINGJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$TOKENJS");
loadScript("$CROWDSALEJS");
loadScript("$VESTINGJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["$TOKENSOL:OneledgerToken"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$TOKENSOL:OneledgerToken"].bin;
var crowdsaleAbi = JSON.parse(crowdsaleOutput.contracts["$CROWDSALESOL:ICO"].abi);
var crowdsaleBin = "0x" + crowdsaleOutput.contracts["$CROWDSALESOL:ICO"].bin;
var vestingAbi = JSON.parse(vestingOutput.contracts["$VESTINGSOL:OneledgerTokenVesting"].abi);
var vestingBin = "0x" + vestingOutput.contracts["$VESTINGSOL:OneledgerTokenVesting"].bin;

// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));
// console.log("DATA: crowdsaleAbi=" + JSON.stringify(crowdsaleAbi));
// console.log("DATA: crowdsaleBin=" + JSON.stringify(crowdsaleBin));
// console.log("DATA: vestingAbi=" + JSON.stringify(vestingAbi));
// console.log("DATA: vestingBin=" + JSON.stringify(vestingBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var crowdsaleMessage = "Deploy Crowdsale Contract";
var rate = "1000";
var weiCap = new BigNumber("2000").shift(18);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + crowdsaleMessage + " ----------");
var crowdsaleContract = web3.eth.contract(crowdsaleAbi);
var crowdsaleTx = null;
var crowdsaleAddress = null;
var tokenAddress = null;
var token = null;
var crowdsale = crowdsaleContract.new(wallet, rate, $START_DATE, weiCap, {from: contractOwnerAccount, data: crowdsaleBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        crowdsaleTx = contract.transactionHash;
      } else {
        crowdsaleAddress = contract.address;
        addAccount(crowdsaleAddress, "Crowdsale Contract");
        addCrowdsaleContractAddressAndAbi(crowdsaleAddress, crowdsaleAbi);
        console.log("DATA: crowdsaleAddress=" + crowdsaleAddress);
        tokenAddress = crowdsale.token();
        token = eth.contract(tokenAbi).at(tokenAddress);
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(crowdsaleTx, crowdsaleMessage);
printTxData("crowdsaleAddress=" + crowdsaleAddress, crowdsaleTx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


var fullTesting = true;

if (fullTesting) {
// -----------------------------------------------------------------------------
var whitelistMessage = "Whitelist Accounts - ac3 and ac4 for 10 ETH each";
var whitelistAccounts = [account3, account4];
var whitelistAmount = web3.toWei(10, "ether");
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + whitelistMessage + " ----------");
var whitelist1_1Tx = crowdsale.addToWhiteList(whitelistAccounts, whitelistAmount, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(whitelist1_1Tx, whitelistMessage);
printTxData("whitelist1_1Tx", whitelist1_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");

waitUntil("crowdsale.initialTime", crowdsale.initialTime(), 0);

// -----------------------------------------------------------------------------
var sendContribution0Message = "Send Contribution #0";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + sendContribution0Message + " ----------");
var sendContribution0_1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("0.5", "ether")});
var sendContribution0_2Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("15", "ether")});
var sendContribution0_3Tx = eth.sendTransaction({from: account5, to: crowdsaleAddress, gas: 400000, value: web3.toWei("0.5", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution0_1Tx, sendContribution0Message + " - ac3 0.5 ETH");
passIfTxStatusError(sendContribution0_2Tx, sendContribution0Message + " - ac4 15 ETH - Expecting failure as amount over whitelisted limit");
passIfTxStatusError(sendContribution0_3Tx, sendContribution0Message + " - ac5 0.5 ETH - Expecting failure as account not whitelisted");
printTxData("sendContribution0_1Tx", sendContribution0_1Tx);
printTxData("sendContribution0_2Tx", sendContribution0_2Tx);
printTxData("sendContribution0_3Tx", sendContribution0_3Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + sendContribution1Message + " ----------");
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("0.5", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("0.5", "ether")});
var sendContribution1_3Tx = eth.sendTransaction({from: account5, to: crowdsaleAddress, gas: 400000, value: web3.toWei("0.5", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
passIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 0.5 ETH - Expecting failure as account already contributed in 1st period");
failIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac4 0.5 ETH");
passIfTxStatusError(sendContribution1_3Tx, sendContribution1Message + " - ac5 0.5 ETH - Expecting failure as account not whitelisted");
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printTxData("sendContribution1_3Tx", sendContribution1_3Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("crowdsale.initialTime + 1 period + contribution#1 mined time", crowdsale.initialTime(), 45);


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2 - Up to 2 x whitelisted limit";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + sendContribution2Message + " ----------");
var sendContribution2_1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("20", "ether")});
var sendContribution2_2Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("20", "ether")});
var sendContribution2_3Tx = eth.sendTransaction({from: account5, to: crowdsaleAddress, gas: 400000, value: web3.toWei("20", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac3 20 ETH");
failIfTxStatusError(sendContribution2_2Tx, sendContribution2Message + " - ac4 20 ETH");
passIfTxStatusError(sendContribution2_3Tx, sendContribution2Message + " - ac5 0.5 ETH - Expecting failure as account not whitelisted");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printTxData("sendContribution2_2Tx", sendContribution2_2Tx);
printTxData("sendContribution2_3Tx", sendContribution2_3Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("crowdsale.initialTime + 2 period + contribution#2 mined time", crowdsale.initialTime(), 80);


// -----------------------------------------------------------------------------
var sendContribution3Message = "Send Contribution #3 - Outside whitelisted ETH limits";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + sendContribution3Message + " ----------");
var sendContribution3_1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("100", "ether")});
var sendContribution3_2Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("100", "ether")});
var sendContribution3_3Tx = eth.sendTransaction({from: account5, to: crowdsaleAddress, gas: 400000, value: web3.toWei("100", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution3_1Tx, sendContribution3Message + " - ac3 100 ETH");
failIfTxStatusError(sendContribution3_2Tx, sendContribution3Message + " - ac4 100 ETH");
passIfTxStatusError(sendContribution3_3Tx, sendContribution3Message + " - ac5 100 ETH - Expecting failure as account not whitelisted");
printTxData("sendContribution3_1Tx", sendContribution3_1Tx);
printTxData("sendContribution3_2Tx", sendContribution3_2Tx);
printTxData("sendContribution3_3Tx", sendContribution3_3Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");
}


// -----------------------------------------------------------------------------
var finalise_Message = "Finalise And Activate Token Transfers";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + finalise_Message + " ----------");
var finalise_1Tx = crowdsale.closeSale({from: contractOwnerAccount, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var finalise_2Tx = token.activate({from: contractOwnerAccount, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(finalise_1Tx, finalise_Message + " - Close sale");
failIfTxStatusError(finalise_2Tx, finalise_Message + " - Activate token transfer");
printTxData("finalise_1Tx", finalise_1Tx);
printTxData("finalise_2Tx", finalise_2Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


if (fullTesting) {
// -----------------------------------------------------------------------------
var transfer1_Message = "Move Tokens #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + transfer1_Message + " ----------");
var transfer1_1Tx = token.transfer(account5, "1000000000000", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
var transfer1_2Tx = token.approve(account6,  "30000000000000000", {from: account4, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transfer1_3Tx = token.transferFrom(account4, account7, "30000000000000000", {from: account6, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("transfer1_1Tx", transfer1_1Tx);
printTxData("transfer1_2Tx", transfer1_2Tx);
printTxData("transfer1_3Tx", transfer1_3Tx);
failIfTxStatusError(transfer1_1Tx, transfer1_Message + " - transfer 0.000001 tokens ac3 -> ac5. CHECK for movement");
failIfTxStatusError(transfer1_2Tx, transfer1_Message + " - approve 0.03 tokens ac4 -> ac6");
failIfTxStatusError(transfer1_3Tx, transfer1_Message + " - transferFrom 0.03 tokens ac4 -> ac7 by ac6. CHECK for movement");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");
}


// -----------------------------------------------------------------------------
var deployVesting_Message = "Deploy Vesting Contract";
var vestingPeriod = 30; // 30 seconds
var tokensReleasedPerPeriod = new BigNumber(100).shift(18);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployVesting_Message + " ----------");
var vestingContract = web3.eth.contract(vestingAbi);
var vestingTx = null;
var vestingAddress = null;
var vestingStart = parseInt(new Date()/1000) + 30;
var vesting = vestingContract.new(vestingBeneficiary, vestingStart, vestingPeriod, tokensReleasedPerPeriod, tokenAddress, {from: contractOwnerAccount, data: vestingBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        vestingTx = contract.transactionHash;
      } else {
        vestingAddress = contract.address;
        addAccount(vestingAddress, "Vesting Contract");
        addVestingContractAddressAndAbi(vestingAddress, vestingAbi);
        console.log("DATA: vestingAddress=" + vestingAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(vestingTx, deployVesting_Message);
printTxData("vestingAddress=" + vestingAddress, vestingTx);
printVestingContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transferToVesting1_Message = "Transfer To Vesting Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + transferToVesting1_Message + " ----------");
var transferToVesting1_1Tx = token.transfer(vestingAddress, new BigNumber(150).shift(18), {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("transferToVesting1_1Tx", transferToVesting1_1Tx);
failIfTxStatusError(transferToVesting1_1Tx, transferToVesting1_Message + " - transfer 150 tokens to vesting contract");
printVestingContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("vesting.startFrom()", vesting.startFrom(), 15);


// -----------------------------------------------------------------------------
var releaseVesting0_Message = "Release Vesting #0";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + releaseVesting0_Message + " ----------");
var releaseVesting0_1Tx = vesting.release({from: contractOwnerAccount, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("releaseVesting0_1Tx", releaseVesting0_1Tx);
passIfTxStatusError(releaseVesting0_1Tx, releaseVesting0_Message + " - Expecting failure - 0 tokens released");
printVestingContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("vesting.startFrom()+45", vesting.startFrom(), 45);


// -----------------------------------------------------------------------------
var releaseVesting1_Message = "Release Vesting #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + releaseVesting1_Message + " ----------");
var releaseVesting1_1Tx = vesting.release({from: vestingBeneficiary, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("releaseVesting1_1Tx", releaseVesting1_1Tx);
failIfTxStatusError(releaseVesting1_1Tx, releaseVesting1_Message + " - Expecting 100 tokens released, executed by beneficiary");
printVestingContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("vesting.startFrom()+75", vesting.startFrom(), 75);


// -----------------------------------------------------------------------------
var releaseVesting2_Message = "Release Vesting #2";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + releaseVesting2_Message + " ----------");
var releaseVesting2_1Tx = vesting.release({from: contractOwnerAccount, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("releaseVesting2_1Tx", releaseVesting2_1Tx);
failIfTxStatusError(releaseVesting2_1Tx, releaseVesting2_Message + " - Expecting 50 tokens released, executed by another account");
printVestingContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("vesting.startFrom()+105", vesting.startFrom(), 105);


// -----------------------------------------------------------------------------
var releaseVesting3_Message = "Release Vesting #3";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + releaseVesting3_Message + " ----------");
console.log("RESULT: ");
var releaseVesting3_1Tx = vesting.release({from: contractOwnerAccount, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("releaseVesting3_1Tx", releaseVesting3_1Tx);
passIfTxStatusError(releaseVesting3_1Tx, releaseVesting3_Message + " - Expecting failure");
printVestingContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
