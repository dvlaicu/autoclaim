#!/usr/bin/env bash
# I recommend to use this script outside your BP node. If so I fully recommend
# to do it over a secured connection since you have to send your wallet's pass
# to your BP (or any other BP) node to be processed. Make sure you have a local
# wallet defined with your BP key imported.
# This script was inspired by the one created by AnsenYu
# https://github.com/AnsenYu/ENUAvengers/tree/master/scripts/bpclaim
# Dragos Vlaicu - 07/05/2018 - BP - dragosvlaicu
# Version: 1.0

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Check if the two needed variables were given
# expected: wallet's password followed by BPUsername
if [ $# -ne 2 ]; then
  echo "You're missing a few arguments"
  echo "Please use the script like this: $0 BPWalletPwd BPUsername"
  exit 1
fi

# enucli wallet shortcut if the binaries were not installed after the build
# followed by the BP http(s) server
enucli='/home/dragos/enu/build/programs/enucli/enucli -u https://enu.hopto.org'
# The ammount of coins you want to leave in your wallet. The rest will be staked
# it should be an integer from 0 to whatever you want
# WARNING: The rest of the coins will be staked
keep=0
passwd=$1
BP=$2
logfile='/home/dragos/enuclaim.log'
echo ${passwd} | ${enucli} wallet unlock -n acasa
st=1
while [[ ${st} -ne 0 ]]; do
  # try to claim your stakes
  ${enucli} system claimrewards ${BP}
  st=$?
  if [[ ${st} -ne 0 ]]; then
    # Wait two seconds between retries.
    sleep 2
  else
    TS="$(date '+[%Y-%m-%d %H:%M:%S]')"
    echo "${TS} claimed successfully" >> ${logfile}
    # Get the coins out of your wallet. WARNING: It will use all your coins from
    # your wallet. IF you want to keep some aside please configure the variable keep
    walletcoins=$(${enucli} get currency balance enu.token ${BP} | awk '{print $1}')
    echo "${TS} enu gained last claim: ${walletcoins}" >> ${logfile}
    # split wallet's coins in two to stake them evenly. It will get rounded down
    tostake=$(bc <<< "(${walletcoins} - ${keep}) / 2")
    # Stake your coins
    ${enucli} system delegatebw ${BP} ${BP} "${tostake} ENU" "${tostake} ENU"
  fi
done
# Lock your wallet.
${enucli} wallet lock -n acasa
