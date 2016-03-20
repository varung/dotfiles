#!/bin/bash
gotgz="https://storage.googleapis.com/golang/go1.5.2.linux-amd64.tar.gz"
wget $gotgz
tar -C /usr/local -xzf $(basename $gotgz)
mkdir -p $HOME/go
echo "export GOPATH=$HOME/go" >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
vim +GoInstallBinaries +qall
