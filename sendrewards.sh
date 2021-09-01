#!/bin/bash

FILE="./sampledata.csv"
PRIVATE_KEY="/etc/casper/validator_keys/secret_key.pem"
CHAINSPEC="casper-test"
NODE_ADDRESS="http://127.0.0.1:7777"

TRANSFER_ID=1

while IFS="," read address motes ; do
    echo Transfer $TRANSFER_ID - $address is getting $motes motes

    sudo -u casper casper-client transfer \
        --chain-name "$CHAINSPEC" \
        --node-address "$NODE_ADDRESS" \
        --secret-key $PRIVATE_KEY \
        --transfer-id "$TRANSFER_ID" \
        -a $motes \
        -t "$address" \
        -p 10000

    ((TRANSFER_ID++))

done < $FILE