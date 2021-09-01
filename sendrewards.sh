#!/bin/bash

FILE="./sampledata.csv"
PRIVATE_KEY="/etc/casper/validator_keys/secret_key.pem"

TRANSFER_ID=1

while IFS="," read address motes ; do
    echo Transfer $TRANSFER_ID - $address is getting $motes motes

    set -x #echo on
    sudo -u casper casper-client transfer \
        --chain-name "casper-test" \
        --node-address "http://127.0.0.1:7777" \
        --secret-key $PRIVATE_KEY \
        --transfer-id "$TRANSFER_ID" \
        -a $motes \
        -t "$address" \
        -p 10000
    set +x

    ((TRANSFER_ID++))

done < $FILE