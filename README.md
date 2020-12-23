[//]: # (SPDX-License-Identifier: CC-BY-4.0)

## Hyperledger Fabric Samples

Please visit the [installation instructions](http://hyperledger-fabric.readthedocs.io/en/latest/install.html)
to ensure you have the correct prerequisites installed. Please use the
version of the documentation that matches the version of the software you
intend to use to ensure alignment.

## Build Binaries and Docker Images
refers to https://github.com/hjun007/fabric-gm-2.0.0 or https://github.com/hjun007/fabric-gm-2.0.0-dsvs

## How to use bjca-sm2-certs-2.0.0
```bash
$ git clone https://github.com/hjun007/fabric-samples-bjca.git
$ cd fabric-samples-bjca && mkdir bin
# build fabric refers to https://github.com/hjun007/fabric-gm-2.0.0
$ cp $GOPATH/src/github.com/hyperledger/fabric/release/linux-amd64/* bin/
cd bjca-sm2-certs-2.0.0
然后按流程执行cmd-bjca.txt里面的命令
```

## How to use bjca-sm2-dsvs-2.0.0
```bash
$ git clone https://github.com/hjun007/fabric-samples-bjca.git
$ cd fabric-samples-bjca && mkdir bin
# build fabric refers to https://github.com/hjun007/fabric-gm-2.0.0-dsvs
$ cp $GOPATH/src/github.com/hyperledger/fabric/release/linux-amd64/* bin/
$ cd bjca-sm2-dsvs-2.0.0
然后按流程执行cmd.txt里面的命令
```