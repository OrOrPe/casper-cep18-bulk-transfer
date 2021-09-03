# Casper Bulk Transfer

This script creates multiple transfers on the Casper blockchain network reading the recipients and amounts from a CSV file formatted as ```recipient_public_key,amount_in_motes```. 

## Usage

The script was tested on Ubuntu 20.04.2 LTS.

1. Download the script:
```
wget https://raw.githubusercontent.com/mssteuer/casper-bulk-transfer/master/bulk-transfer.sh
```

2. Make it executable

```
sudo chmod +x bulk-transfer.sh
```

3. Prepare the input CSV file in the ```recipient_public_key,amount_in_motes``` format


4. Execute the script saving the output to the ```bulk-transfer-results.csv```

```
./bulk-transfer.sh --keys-path=~/my-casper-keys --in=input.csv --out=bulk-transfer-results.csv
```

 > **Note:** Triple check everything, as there is no failsafe once you start sending.

## Disclaimer

Provided as is and with no warranties, or guarantees to be bug-free.
