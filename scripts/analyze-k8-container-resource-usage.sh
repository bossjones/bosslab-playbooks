#!/usr/bin/env bash

# SOURCE: https://dzone.com/articles/kubernetes-resource-usage-how-do-you-manage-and-mo

kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} sh -c 'echo {}; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo'
