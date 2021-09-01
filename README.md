# sendrewards

## How to use

1. Replace `sampledata.csv` with your own CSV file containing lines of recipients and amounts in `motes`, following the same structure (`address,motes`) -- IMPORTANT: amounts should be provided in `motes`, not `CSPR` with decimals. 
2. In `sendrewards.sh`, replace the path to your private key with the path to the private key belonging to the account you plan to send your tokens from
3. In `sendrewards.sh`, replace the CHAINSPEC value with the name of the network you're sending on, e.g. `casper`
4. In `sendrewards.sh`, replace the NODE_ADDRESS value with the URL to the Casper Node you're sending your deploys too (can leave as is if sending to localhost)
5. `chmod +x sendrewards.sh` to ensure it's executable
6. Triple check everything, as there is no failsafe once you start sending.

Provided as is and with no warranties, or guarantees to be bug-free.
