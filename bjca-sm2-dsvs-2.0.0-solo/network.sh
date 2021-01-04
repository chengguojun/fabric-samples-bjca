#!/bin/bash

networkUp() {
    set -e

    echo "container up..."
    docker-compose -f docker-compose-cli.yaml up -d
    docker ps -a

    export CHANNEL_NAME=mychannel
    export CHAINCODE_NAME=mycc
    export CHAINCODE_VERSION=1.0

    echo "create channel..."
    docker exec -it cli \
peer channel create -o orderer1.org0.bjca.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CHANNEL_NAME}.tx

    echo "peer0.org1 join channel..."
    docker exec -it cli \
peer channel join -b mychannel.block

    echo "peer1.org1 join channel..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org1/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org1/msp \
-e CORE_PEER_ADDRESS=peer1.org1.bjca.com:8051 \
-e CORE_PEER_LOCALMSPID="Org1MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer1.org1/tls/ca.crt \
cli \
peer channel join -b mychannel.block

    echo "peer0.org2 join channel..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org2/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org2/msp \
-e CORE_PEER_ADDRESS=peer0.org2.bjca.com:9051 \
-e CORE_PEER_LOCALMSPID="Org2MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org2/tls/ca.crt \
cli \
peer channel join -b mychannel.block

    echo "peer1.org2 join channel..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org2/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org2/msp \
-e CORE_PEER_ADDRESS=peer1.org2.bjca.com:10051 \
-e CORE_PEER_LOCALMSPID="Org2MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer1.org2/tls/ca.crt \
cli \
peer channel join -b mychannel.block

    echo "update anchor peer for org1..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org1/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org1/msp \
-e CORE_PEER_ADDRESS=peer0.org1.bjca.com:7051 \
-e CORE_PEER_LOCALMSPID="Org1MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org1/tls/ca.crt \
cli \
peer channel update -o orderer1.org0.bjca.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx

    echo "update anchor peer for org2..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org2/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org2/msp \
-e CORE_PEER_ADDRESS=peer0.org2.bjca.com:9051 \
-e CORE_PEER_LOCALMSPID="Org2MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org2/tls/ca.crt \
cli \
peer channel update -o orderer1.org0.bjca.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx

    echo "fetch chaincode dependencies..."
    cd ../chaincode/abstore/go
    export GOPROXY=https://mirrors.aliyun.com/goproxy/
    GO111MODULE=on go mod vendor
    cd -

    echo "package chaincode..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org1/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org1/msp \
-e CORE_PEER_ADDRESS=peer0.org1.bjca.com:7051 \
-e CORE_PEER_LOCALMSPID="Org1MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org1/tls/ca.crt \
cli \
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ \
--lang golang --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION}

    echo "peer0.org1 install chaincode..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org1/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org1/msp \
-e CORE_PEER_ADDRESS=peer0.org1.bjca.com:7051 \
-e CORE_PEER_LOCALMSPID="Org1MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org1/tls/ca.crt \
cli \
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

    echo "peer1.org1 install chaincode..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org1/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org1/msp \
-e CORE_PEER_ADDRESS=peer1.org1.bjca.com:8051 \
-e CORE_PEER_LOCALMSPID="Org1MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer1.org1/tls/ca.crt \
cli \
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

    echo "peer0.org2 install chaincode..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org2/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org2/msp \
-e CORE_PEER_ADDRESS=peer0.org2.bjca.com:9051 \
-e CORE_PEER_LOCALMSPID="Org2MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org2/tls/ca.crt \
cli \
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

    echo "peer1.org2 install chaincode..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org2/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org2/msp \
-e CORE_PEER_ADDRESS=peer1.org2.bjca.com:10051 \
-e CORE_PEER_LOCALMSPID="Org2MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer1.org2/tls/ca.crt \
cli \
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

    docker exec -it cli peer lifecycle chaincode queryinstalled >&log.txt
    PACKAGE_ID=$(sed -n "/${CHAINCODE_NAME}_${CHAINCODE_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)

    echo "chaincode approve for org1..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org1/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org1/msp \
-e CORE_PEER_ADDRESS=peer0.org1.bjca.com:7051 \
-e CORE_PEER_LOCALMSPID="Org1MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org1/tls/ca.crt \
cli \
peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} \
--init-required --package-id $PACKAGE_ID --sequence 1

    echo "chaincode approve for org2..."
    docker exec -it \
-e DSVS_CONFIG_FILE=/usr/dsvs/admin1.org2/BJCA_SVS_Config.ini \
-e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/admin1.org2/msp \
-e CORE_PEER_ADDRESS=peer0.org2.bjca.com:9051 \
-e CORE_PEER_LOCALMSPID="Org2MSP" \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org2/tls/ca.crt \
cli \
peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} \
--init-required --package-id $PACKAGE_ID --sequence 1

    echo "check approvals..."
    docker exec -it cli \
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} \
--init-required --sequence 1 --output json

    echo "chaincode commit..."
    docker exec -it cli \
peer lifecycle chaincode commit -o orderer1.org0.bjca.com:7050 --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} \
--sequence 1 --init-required \
--peerAddresses peer0.org1.bjca.com:7051 \
--peerAddresses peer1.org1.bjca.com:8051 \
--peerAddresses peer0.org2.bjca.com:9051 \
--peerAddresses peer1.org2.bjca.com:10051

    echo "chaincode init..."
    docker exec -it cli \
peer chaincode invoke -o orderer1.org0.bjca.com:7050 --isInit \
-C $CHANNEL_NAME -n ${CHAINCODE_NAME} \
--peerAddresses peer0.org1.bjca.com:7051 \
--peerAddresses peer0.org2.bjca.com:9051 \
-c '{"Args":["Init","a","100","b","200"]}' --waitForEvent

    echo "chaincode query..."
    docker exec -it cli \
peer chaincode query -C $CHANNEL_NAME -n ${CHAINCODE_NAME} -c '{"Args":["query","a"]}'

    echo "chaincode invoke..."
    docker exec -it cli \
peer chaincode invoke -o orderer1.org0.bjca.com:7050 \
-C $CHANNEL_NAME -n ${CHAINCODE_NAME} \
--peerAddresses peer0.org1.bjca.com:7051 \
--peerAddresses peer0.org2.bjca.com:9051 \
-c '{"Args":["invoke","a","b","1"]}' --waitForEvent

    echo "chaincode query..."
    docker exec -it cli \
peer chaincode query -C $CHANNEL_NAME -n ${CHAINCODE_NAME} -c '{"Args":["query","a"]}'

}

networkDown() {

    set +e
    docker-compose -f docker-compose-cli.yaml down -v
    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)
    docker volume rm $(docker volume ls -q)
    docker rmi $(docker images dev-* -aq)

}

if [ "$1" == "up" ]; then
    networkUp
elif [ "$1" == "down" ]; then
    networkDown
else
    echo "./network.sh up"
    echo "./network.sh down"
fi
