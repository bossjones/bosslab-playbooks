#!/usr/bin/env bash

echo "TRY THIS: https://github.com/ReSearchITEng/kubeadm-playbook/blob/fea83b68b8035f946bfa138c4cad25a35d34f6a7/roles/common/tasks/iptables.yml"

for i in $(kubectl get pods --all-namespaces | grep weave | awk '{print $2}' | xargs); do
    echo "---------------------------------------------------------------------------------------------------"
    echo "[running] kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave --local status connections"
    kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave --local status connections
    echo "---------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
done;


for i in $(kubectl get pods --all-namespaces | grep weave | awk '{print $2}' | xargs); do
    echo "---------------------------------------------------------------------------------------------------"
    echo "[running] kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave --local report"
    kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave --local report
    echo "---------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
done;

echo "---------------------------------------------------------------------------------------------------"
echo "[running] weave status connections"
weave status connections
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""

echo "---------------------------------------------------------------------------------------------------"
echo "[running] weave status peers"
weave status peers
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""

echo "---------------------------------------------------------------------------------------------------"
echo "[running] weave report -f '' weave.local."
weave report -f '' weave.local.
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""


echo "---------------------------------------------------------------------------------------------------"
echo "[running] weave status dns"
weave status dns
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""


echo "---------------------------------------------------------------------------------------------------"
echo "[running] weave ps"
weave ps
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""

echo "---------------------------------------------------------------------------------------------------"
echo "[running] weave version"
weave version
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""


echo "---------------------------------------------------------------------------------------------------"
echo "[running] docker version"
docker version
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""


echo "---------------------------------------------------------------------------------------------------"
echo "[running] uname -a"
uname -a
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""


echo "---------------------------------------------------------------------------------------------------"
echo "[running] kubectl version"
kubectl version
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""



for i in $(kubectl get pods --all-namespaces | grep weave | awk '{print $2}' | xargs); do
    echo "---------------------------------------------------------------------------------------------------"
    echo "[running] kubectl -n kube-system logs ${i} weave"
    kubectl -n kube-system logs ${i} weave
    echo "---------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
done;


echo "---------------------------------------------------------------------------------------------------"
echo "[running] ip route"
ip route
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""


echo "---------------------------------------------------------------------------------------------------"
echo "[running] ip -4 -o addr"
ip -4 -o addr
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""

echo "---------------------------------------------------------------------------------------------------"
echo "[running] iptables-save"
iptables-save
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""

echo "---------------------------------------------------------------------------------------------------"
echo "[running] weave --local status ipam"
weave --local status ipam
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""

echo "---------------------------------------------------------------------------------------------------"
echo "[running] weave --local status connections"
weave --local status connections
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""

echo "---------------------------------------------------------------------------------------------------"
echo "[running] kubectl get configmap -n=kube-system -oyaml weave-net"
kubectl get configmap -n=kube-system -oyaml weave-net
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo ""
