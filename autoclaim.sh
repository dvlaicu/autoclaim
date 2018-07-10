#!/usr/bin/env bash
# I recommend to use this script outside your BP node. If so I fully recommend
# to do it over a secured connection since you have to send your wallet's pass
# to your BP (or any other BP) node to be processed. You can install a reverse
# proxy like nginx (check:). Make sure you have a local  wallet defined with your
# BP key imported.
# This script was inspired by the one created by AnsenYu
# https://github.com/AnsenYu/ENUAvengers/tree/master/scripts/bpclaim
# Dragos Vlaicu - 07/05/2018 - ENU BP - dragosvlaicu
# Version: 1.1

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Check if the two needed variables were given
# expected: wallet's password followed by BPUsername
if [ $# -ne 2 ]; then
  echo "You're missing a few arguments"
  echo "Please use the script like this: $0 BPWalletPwd BPUsername"
  exit 1
fi


# IF you are not using the default wallet you can mention it here
wallet='acasa'
# one day in seconds
day=86400

# enucli wallet shortcut if the binaries were not installed after the build
# followed by the BP http(s) server
enucli='/home/dragos/enu/build/programs/enucli/enucli -u https://enu.hopto.org'
# The ammount of coins you want to leave in your wallet. The rest will be staked
# it should be an integer from 0 to whatever you want
# WARNING: The rest of the coins will be staked
keep=0
passwd=$1
BP=$2
#script working directory
script="$(readlink -f $0)"
wd="$(dirname ${script})"
# log file
logfile="${wd}/enuclaim.log"

# Validate the password format
if [[ ! $passwd =~ ^PW5.* ]]; then
  echo "Invalid wallet password"
  exit 2
fi

# Check last claimed time
last_claim_time=$(${enucli} get table enumivo enumivo producers -l 10000 | grep -A 6 "${BP}" | awk -F '"' '$2 == "last_claim_time" {print $4}')
if [[ $? -ne 0 || ${last_claim_time} -eq 0 ]]; then
    echo "Invalid last claim time, claim manually to set a relevant time"
    exit 3
fi
# calculate how much time it passed from last claim. if it's under a day we'll wait a bit more.
last_claimed=$((${last_claim_time} / 1000000))

function last() {
  now_epoch=$(date +"%s")
  time_diff=$((${now_epoch}-$1))
  echo ${time_diff}
}

st=1
while [[ ${st} -ne 0 ]]; do
  if [[ $(last ${last_claimed}) -lt ${day} ]]; then
    sleep 2
  else
    # unlock the wallet
    ${enucli} wallet unlock -n ${wallet} --password ${passwd}
    # Check if the wallet gets unlocked successfully
    if [[ $? -ne 0 ]]; then
      echo "Unable to unlock your wallet with given password. Please check."
      exit 4
    fi
    TS="$(date '+[%Y-%m-%d %H:%M:%S]')"
    # try to claim your stakes
    claim=$(${enucli} system claimrewards ${BP} 2>&1)
    if [[ $? -ne 0 ]]; then
      ${enucli} wallet lock_all
      echo "${TS} Error wile claiming. Please do it manually" >> ${logfile}
      echo "${claim}" >> ${logfile}
      exit 5
    else
      echo "${TS} claimed successfully" >> ${logfile}
      # Get the coins out of your wallet. WARNING: It will use all your coins from
      # your wallet. IF you want to keep some aside please configure the variable keep
      walletcoins=$(${enucli} get currency balance enu.token ${BP} | awk '{print $1}')
      echo "${TS} enu gained last claim: ${walletcoins}" >> ${logfile}
      echo "${claim}" >> ${logfile}
      # split wallet's coins in two to stake them evenly. It will get rounded down
      tostake=$(bc <<< "(${walletcoins} - ${keep}) / 2")
      # Stake your coins
      ${enucli} system delegatebw ${BP} ${BP} "${tostake} ENU" "${tostake} ENU"
      # Lock your wallet.
      ${enucli} wallet lock_all
    fi
    st=0
  fi
done
