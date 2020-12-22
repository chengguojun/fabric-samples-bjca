[//]: # (SPDX-License-Identifier: CC-BY-4.0)

## Hyperledger Fabric Samples

Please visit the [installation instructions](http://hyperledger-fabric.readthedocs.io/en/latest/install.html)
to ensure you have the correct prerequisites installed. Please use the
version of the documentation that matches the version of the software you
intend to use to ensure alignment.

## Build Binaries and Docker Images


```bash
$ cd $GOPATH/src/github.com/hyperledger
$ git clone https://github.com/hjun007/fabric-2.0.0-dsvs.git
$ mv fabric-2.0.0-dsvs fabric && cd fabric
$ cp lib/libsvscc.so /usr/lib/
$ make release
$ make docker
```

## How to Use
```bash
$ git clone https://github.com/hjun007/fabric-samples-dsvs.git
$ cd fabric-samples-dsvs && mkdir bin
$ cp $GOPATH/src/github.com/hyperledger/fabric/release/linux-amd64/* bin/
$ cd bjca-sm2-dsvs-2.0.0
然后一条一条执行cmd.txt里面的命令
```