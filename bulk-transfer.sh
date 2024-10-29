#!/usr/bin/bash

print_usage () {
  echo "Sends bulk of CEP-18 transfers on the Casper blockchain network reading the recipients and amounts from a CSV file formatted as ``recipient_hash_key,amount_in_motes``"
  echo
  echo "USAGE:"
  echo "  bulk-transfer.sh [ARGUMENTS]"
  echo
  echo "ARGUMENTS:"
  echo "  --env           Casper environment test/prod  (optional, default is test)"
  echo "  --keys-path     Path to the directory with Casper keys of the sender account"
  echo "  --in            Input CSV file in the <recipient_hash_key>,<amount_in_motes> format"
  echo "  --out           Output CSV file (optional)"
  echo
  echo "EXAMPLE:"
  echo "  ./bulk-transfer.sh --env=test --keys-path=../SRT/secret_key.pem --in=./sample-input.csv --out=./results.csv"
  echo
  echo "DEPENDENCIES:"
  echo "  casper-client   To make RPC requests to the network"
  echo "  jq              To parse RPC responses"
  echo
  echo "DISCLAIMER:"
  echo "Provided as is and with no warranties, or guarantees to be bug-free."
}

ensure_has_installed () {
  HAS_INSTALLED=$(which "$1")
  if [ "$HAS_INSTALLED" = "" ]; then
    echo "Please install $1"
    exit 1
  fi
}

ensure_has_installed "casper-client"
ensure_has_installed "jq"

while [ $# -gt 0 ]; do
  case "$1" in
    #--node-address=*)
    #  NODE_ADDRESS="${1#*=}"
    #  ;;
    --env=*)
      CASPER_ENV="${1#*=}"
      ;;
    --keys-path=*)
      KEYS_PATH="${1#*=}"
      ;;
    --in=*)
      IN="${1#*=}"
      ;;
    --out=*)
      OUT="${1#*=}"
      ;;
    *)
      print_usage; exit 1
      ;;
  esac
  shift
done

# if [ -z ${NODE_ADDRESS+x} ]; then NODE_ADDRESS=https://rpc.testnet.casperlabs.io/; fi
if [ -z ${CASPER_ENV+x} ]; then CASPER_ENV=test; fi
if [ -z ${KEYS_PATH+x} ]; then print_usage; exit 1; fi
if [ -z ${IN+x} ]; then print_usage; exit 1; fi
if [ -z ${OUT+x} ]; then OUT=/dev/null; fi

if [ "$CASPER_ENV" = "test" ]; then
  # Test Astro
  CEP18_CONTRACT_HASH=49a58229b7776eb337834feccda0c840fb8e88705837f5aa7ab03d88bc07252b
  CHAIN_NAME="casper-test"
  NODE_ADDRESS=https://rpc.testnet.casperlabs.io/
elif [ "$CASPER_ENV" = "prod" ]; then
  # Mainnet
  CEP18_CONTRACT_HASH=87314a3cbbf8092b402fcc04a5bd5010fed288ee2727b8d2c84f87ebe4868f4e
  CHAIN_NAME="casper"
  NODE_ADDRESS=http://18.235.240.32:7777/
else
  echo "env can be test or prod only"; exit 1;
fi
# CHAIN_NAME=$(curl -s http://$NODE_ADDRESS:8888/status | jq -r '.chainspec_name')

# Validate the input
LINE=1
while IFS="," read PUBLIC_KEY MOTES ; do
  if (( ${#PUBLIC_KEY} != 64 )); then
    echo "Please check if you put a valid recipient hash key(NOT public key) on the line $LINE"
    exit 2
  fi

 # Remove this test to have "0" transactions also in results summary
 # if (( ${#MOTES} < 9 )); then
 #   echo "Please check if you put a correct rewards amount on the line $LINE. It is not possible to send less than 0.000000001 BOIN."
 #   exit 2
 # fi

  ((LINE++))
done < $IN

# Send rewards
echo "public_key,motes,deploy_hash,transfer_id" > $OUT

TRANSFER_ID=1
while IFS="," read PUBLIC_KEY MOTES ; do
  if (($MOTES > 0 )) ; then
    RESULT=$(casper-client put-deploy \
      --chain-name "$CHAIN_NAME" \
      --node-address "$NODE_ADDRESS" \
      --secret-key "$KEYS_PATH" \
      --session-hash "hash-$CEP18_CONTRACT_HASH" \
      --session-entry-point "transfer" \
      --session-arg "recipient:key='account-hash-$PUBLIC_KEY'" \
      --session-arg "transfer-id:u256='$TRANSFER_ID'" \
      --session-arg "amount:u256='$MOTES'" \
      --payment-amount "5000000000");
    DEPLOY_HASH=$(echo "$RESULT" | jq -r '.result | .deploy_hash')
    LOG_RESULT=$(echo "$RESULT" | jq -c '.')
  else
    DEPLOY_HASH="Zero Deal"
    LOG_RESULT=""
  fi

  if [ "$DEPLOY_HASH" = "null" ]; then
    echo "ERROR on transfer $MOTES motes to $PUBLIC_KEY (deploy hash $DEPLOY_HASH, transfer id $TRANSFER_ID)";
    echo "ERROR_LOG: $LOG_RESULT";
  else
    echo "Transferred $MOTES motes to $PUBLIC_KEY (deploy hash $DEPLOY_HASH, transfer id $TRANSFER_ID)";
  fi

  echo "$PUBLIC_KEY,$MOTES,$DEPLOY_HASH,$TRANSFER_ID,$LOG_RESULT" >> $OUT
  ((TRANSFER_ID++))
done < $IN
