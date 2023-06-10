# Casper Bulk Transfer

This script creates multiple transfers on the Casper blockchain network reading the recipients and amounts from a CSV file formatted as ```recipient_public_key,amount_in_motes```. 

## Usage

The script was tested on Ubuntu 20.04.2 LTS.

1. Download the script:
```
wget https://raw.githubusercontent.com/OrOrPe/casper-cep18-bulk-transfer/blob/master/bulk-transfer.sh
```

2. Make it executable

```
sudo chmod +x bulk-transfer.sh
```

3. Prepare the input CSV file in the ```recipient_hash_key,amount_in_motes``` format


4. If CSV done in windows use dos2unix on the input.csv
```
dos2unix sample-input.csv
```

5. In the bulk-transfer.sh script set your ```CEP18_CONTRACT_HASH``` for test and prod enviornments


6. Execute the script saving the output to the ```results.csv```

```
./bulk-transfer.sh --env=test --keys-path=../SRT/secret_key.pem --in=./sample-input.csv --out=./results.csv
```

 > **Note:** Triple check everything, as there is no failsafe once you start sending.

## Disclaimer

Provided as is and with no warranties, or guarantees to be bug-free.
