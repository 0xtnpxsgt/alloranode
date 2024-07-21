# alloranode


## Rivalz rClint CLi Ultimate Guide 
 
- You must need to buy a VPS for running Rivalz rClient
- You can buy from : Contabo
- You should buy VPS which is fulfilling all these requirements : 
```bash
Operating System : Ubuntu 22.04
CPU : Minimum of 4 cores
RAM : 4 GB
Storage : SSD or NVMe with at least 50GB of space
```

## Deployment - Read Carefully! 
Step1: 
```bash
rm -rf allora.sh allora-chain/ basic-coin-prediction-node/
```

Step2: 
```bash
apt install wget
```

Step3: Install Allora
```bash
wget https://raw.githubusercontent.com/dxzenith/allora-worker-node/main/allora.sh && chmod +x allora.sh && ./allora.sh
```
- In the middle of the command execution, it will ask for keyring phrase, Here you need write a password (example : 12345678)
- During pasting HEAD_ID , Don't use Ctrl+C to copy and Ctrl+V to paste, instead just select the whole KEY_ID and Press Right Click

Step3: Stop Docker
```bash
screen -S rivalz
```
docker stop $(docker ps -aq)



