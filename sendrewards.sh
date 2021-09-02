#!/bin/bash

print_usage () {
  echo "USAGE:"
  echo "  sendrewards.sh [ARGUMENTS]"
  echo
  echo "ARGUMENTS:"
  echo "  --node-address  Casper node to run RPC requests against (default: 127.0.0.1)"
  echo "  --file          CSV file in format <recipient_public_key>,<rewards_in_motes>"
  echo "  --keys-path     Path to the directory with Casper keys of the sender account"
  echo
  echo "EXAMPLE:"
  echo "  sendrewards.sh --file=~/rewards.csv --keys-path=~/casper-keys"
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
    --node-address=*)
      NODE_ADDRESS="${1#*=}"
      ;;
    --file=*)
      FILE="${1#*=}"
      ;;
    --keys-path=*)
      KEYS_PATH="${1#*=}"
      ;;
    *)
      print_usage; exit 1
      ;;
  esac
  shift
done

if [ -z ${NODE_ADDRESS+x} ]; then NODE_ADDRESS=127.0.0.1; fi
if [ -z ${FILE+x} ]; then print_usage; exit 1; fi
if [ -z ${KEYS_PATH+x} ]; then print_usage; exit 1; fi

CHAIN_NAME=$(curl -s http://$NODE_ADDRESS:8888/status | jq -r '.chainspec_name')

# Validate the input
LINE=1
while IFS="," read PUBLIC_KEY MOTES ; do
  if (( ${#PUBLIC_KEY} != 66 )) && (( ${#PUBLIC_KEY} != 68 )); then
    echo "Please check if you put a valid recipient public key on the line $LINE"
    exit 2
  fi

  if (( ${#MOTES} < 9 )); then
    echo "Please check if you put a correct rewards amount on the line $LINE. It is not possible to send less than 2.5 CSPR."
    exit 2
  fi

  ((LINE++))
done < $FILE

# Send rewards
TRANSFER_ID=1
while IFS="," read PUBLIC_KEY MOTES ; do
    echo Transfer $TRANSFER_ID - $PUBLIC_KEY is getting $MOTES motes

    sudo -u casper casper-client transfer \
        --chain-name "$CHAIN_NAME" \
        --node-address http://$NODE_ADDRESS:7777 \
        --secret-key "$KEYS_PATH/secret_key.pem" \
        --transfer-id "$TRANSFER_ID" \
        -a $MOTES \
        -t "$PUBLIC_KEY" \
        -p 10000

    ((TRANSFER_ID++))
done < $FILE
