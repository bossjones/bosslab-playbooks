#!/usr/bin/env bash

# SOURCE: https://github.com/kubernetes/dashboard/issues/2474#issuecomment-365704926

# Not really sure why no one is posting this in the docs... Use the 'clusterrole-aggregation-controller' token to access your dashboard as 'root':
# Just kind of silly to not include a root account as a part of the dashboard deployment.

kubectl -n kube-system describe secrets \
   `kubectl -n kube-system get secrets | awk '/clusterrole-aggregation-controller/ {print $1}'` \
       | awk '/token:/ {print $2}'
