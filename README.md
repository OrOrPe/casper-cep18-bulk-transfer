# Casper rewards sender

This script sends bulk transfers on the Casper blockchain network reading the recipients and amounts from a CSV file in the format ```recipient_public_key,amount_in_motes```. 

## Usage

```
./sendrewards.sh --file=~/rewards.csv --keys-path=~/my-casper-keys
```

Triple check everything, as there is no failsafe once you start sending.

## Disclaimer

Provided as is and with no warranties, or guarantees to be bug-free.
