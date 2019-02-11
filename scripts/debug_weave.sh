#!/usr/bin/env bash


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
    echo "[running] kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave status connections"
    kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave status connections
    echo "---------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
done;


for i in $(kubectl get pods --all-namespaces | grep weave | awk '{print $2}' | xargs); do
    echo "---------------------------------------------------------------------------------------------------"
    echo "[running] kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave status peers"
    kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave status peers
    echo "---------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
done;


for i in $(kubectl get pods --all-namespaces | grep weave | awk '{print $2}' | xargs); do
    echo "---------------------------------------------------------------------------------------------------"
    echo "[running] kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave report -f '' weave.local."
    kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave report -f '' weave.local.
    echo "---------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
done;


for i in $(kubectl get pods --all-namespaces | grep weave | awk '{print $2}' | xargs); do
    echo "---------------------------------------------------------------------------------------------------"
    echo "[running] kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave status dns"
    kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave status dns
    echo "---------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
done;

for i in $(kubectl get pods --all-namespaces | grep weave | awk '{print $2}' | xargs); do
    echo "---------------------------------------------------------------------------------------------------"
    echo "[running] kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave ps"
    kubectl exec -n kube-system ${i} -c weave -- /home/weave/weave ps
    echo "---------------------------------------------------------------------------------------------------"
    echo ""
    echo ""
done;

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
