# Allora Node with Worker 1 & 2 - UPDATED v2

![669800d234dc45d9775cacc3_testnetv2-announcement](https://github.com/user-attachments/assets/e71bd95c-725a-4f9f-b196-364468d974fe)

 
- You must need to buy a VPS for running Allora Worker
- You can buy from : Contabo
- You should buy VPS which is fulfilling all these requirements : 
```bash
Operating System : Ubuntu 22.04
CPU: Minimum of 1/2 core.
Memory: 2 to 4 GB.
Storage: SSD or NVMe with at least 5GB of space.
```

### Deployment - Read Carefully! 
#### Step 1: 
```bash
rm -rf allora.sh allora-chain/ basic-coin-prediction-node/
```

#### Step 2: 
```bash
apt install wget
```

#### Step 3: Install Allora ( This will take time )
```bash
wget https://raw.githubusercontent.com/0xtnpxsgt/alloranode/main/allora-oneclickguide.sh && chmod +x allora-oneclickguide.sh && ./allora-oneclickguide.sh
```
- In the middle of the command execution, it will ask for keyring phrase, Here you need write a password (example : 12345678)
- During pasting `HEAD_ID` , Don't use `Ctrl+C` to copy and `Ctrl+V` to paste, instead just select the whole `KEY_ID` and Press Right Click


#### Step 4: 
---------------------------------------------------------------

- Copy & Paste the following code. - to exit `Ctrl+X Y Enter` to save YML FILE
- Replace `head-id` & `WALLET_SEED_PHRASE` in worker-1 and worker-2 containers

----------------------------------------------------------------
```bash
version: '3'

services:
  inference:
    container_name: inference
    build:
      context: .
    command: python -u /app/app.py
    ports:
      - "8000:8000"
    networks:
      eth-model-local:
        aliases:
          - inference
        ipv4_address: 172.22.0.4
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/inference/ETH"]
      interval: 10s
      timeout: 10s
      retries: 12
    volumes:
      - ./inference-data:/app/data
  
  updater:
    container_name: updater
    build: .
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
    command: >
      sh -c "
      while true; do
        python -u /app/update_app.py;
        sleep 24h;
      done
      "
    depends_on:
      inference:
        condition: service_healthy
    networks:
      eth-model-local:
        aliases:
          - updater
        ipv4_address: 172.22.0.5
  
  head:
    container_name: head
    image: alloranetwork/allora-inference-base-head:latest
    environment:
      - HOME=/data
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        allora-node --role=head --peer-db=/data/peerdb --function-db=/data/function-db  \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9010 --rest-api=:6000 \
          --boot-nodes=/dns/head-0-p2p.testnet-1.testnet.allora.network/tcp/32130/p2p/12D3KooWLBhsSucVVcyVCaM9pvK8E7tWBM9L19s7XQHqqejyqgEC,/dns/head-1-p2p.testnet-1.testnet.allora.network/tcp/32131/p2p/12D3KooWEUNWg7YHeeCtH88ju63RBfY5hbdv9hpv84ffEZpbJszt,/dns/head-2-p2p.testnet-1.testnet.allora.network/tcp/32132/p2p/12D3KooWATfUSo95wtZseHbogpckuFeSvpL4yks6XtvrjVHcCCXk
    ports:
      - "6000:6000"
    volumes:
      - ./head-data:/data
    working_dir: /data
    networks:
      eth-model-local:
        aliases:
          - head
        ipv4_address: 172.22.0.100

  worker-1:
    container_name: worker-1
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        # Change boot-nodes below to the key advertised by your head
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9011 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/head-id \
          --topic=allora-topic-1-worker --allora-chain-worker-mode=worker \
          --allora-chain-restore-mnemonic='WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=https://allora-rpc.testnet-1.testnet.allora.network \
          --allora-chain-key-name=worker-1 \
          --allora-chain-topic-id=1
    volumes:
      - ./workers/worker-1:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker1
        ipv4_address: 172.22.0.12

  worker-2:
    container_name: worker-2
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        # Change boot-nodes below to the key advertised by your head
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9013 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/head-id \
          --topic=allora-topic-2-worker --allora-chain-worker-mode=worker \
          --allora-chain-restore-mnemonic='WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=https://allora-rpc.testnet-1.testnet.allora.network \
          --allora-chain-key-name=worker-2 \
          --allora-chain-topic-id=2
    volumes:
      - ./workers/worker-2:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker1
        ipv4_address: 172.22.0.13
  
networks:
  eth-model-local:
    driver: bridge
    ipam:
      config:
        - subnet: 172.22.0.0/24

volumes:
  inference-data:
  workers:
  head-data:
```

#### Step 6: Build.
- 1 
```bash
cd allora-chain/basic-coin-prediction-node/
```
- 2
```bash
docker compose up -d --build
```
------------------------------------------------------------------------------

#### Check your node status
```bash
# Check worker 2 logs
docker compose logs -f worker-2

# Check worker 1 logs
docker compose logs -f worker-1
```

#### Check your worker logs and test the inferences using curl

```bash
# Download Checker
wget -O checkyourworker.sh https://raw.githubusercontent.com/casual1st/alloraworkersetup/main/checkyourworker.sh && chmod +x checkyourworker.sh && ./checkyourworker.sh
```

#### Run Checker
```bash
./checkyourworker.sh
```
- #### input to test worker 1 
```bash
 allora-topic-1-worker
```
- #### input to test worker 2
```bash
 allora-topic-2-worker
```








