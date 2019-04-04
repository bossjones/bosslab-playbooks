#!/usr/bin/env bash

export KUBETEST_VERSION="0.1.1"

wget "https://github.com/garethr/kubetest/releases/download/${KUBETEST_VERSION}/kubetest-darwin-amd64.tar.gz"
tar zxf kubetest-darwin-amd64.tar.gz
mv kubetest ./bin/
export PATH=$PATH:$PWD/bin/

rm kubetest-darwin-amd64.tar.gz
