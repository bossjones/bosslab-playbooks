#!/usr/bin/env bash

for f in $(find ./group_vars -name *.vault -print)
do
  ansible-vault encrypt --vault-password-file=./vault_password $f
done

for f in $(find ./vars -name *.vault -print)
do
  ansible-vault encrypt --vault-password-file=./vault_password $f
done
