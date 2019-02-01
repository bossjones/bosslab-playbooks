debug-cluster:
	@printf "debug-cluster:\n"
	@printf "=======================================\n"
	@printf "$$GREEN kubectl -n kube-system get pods:$$NC\n"
	@printf "=======================================\n"
	kubectl -n kube-system get pods | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN kubectl get pods --all-namespaces:$$NC\n"
	@printf "=======================================\n"
	kubectl get pods --all-namespaces | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN kubectl get ingress,services -n=kube-system:$$NC\n"
	@printf "=======================================\n"
	kubectl get ingress,services -n=kube-system | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN kubectl -n kube-system get po -o wide --sort-by=.spec.nodeName:$$NC\n"
	@printf "=======================================\n"
	kubectl -n kube-system get po -o wide --sort-by=.spec.nodeName | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN list all services in a cluster and their nodeports:$$NC\n"
	@printf "=======================================\n"
	kubectl get --all-namespaces svc -o json | jq -r '.items[] | [.metadata.name,([.spec.ports[].nodePort | tostring ] | join("|"))] | @csv'
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN kubectl get pods -o wide --all-namespaces --show-all=true --show-labels=true --show-kind=true:$$NC\n"
	@printf "=======================================\n"
	kubectl get pods -o wide --all-namespaces --show-all=true --show-labels=true --show-kind=true | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN kubectl get nodes --no-headers | grep -v -w 'Ready':$$NC\n"
	@printf "=======================================\n"
	kubectl get nodes --no-headers | grep -v -w 'Ready' | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN kubectl advance pod status conditions:$$NC\n"
	@printf "=======================================\n"
	kubectl get pods --all-namespaces -o json  | jq -r '.items[] | select(.status.phase != "Running" or ([ .status.conditions[] | select(.type == "Ready" and .state == false) ] | length ) == 1 ) | .metadata.namespace + "/" + .metadata.name'
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN List all not-full-Ready pods:$$NC\n"
	@printf "=======================================\n"
	kubectl get po --all-namespaces | grep -vE '1/1|2/2|3/3' | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN List all pods without status 'Running':$$NC\n"
	@printf "=======================================\n"
	@kubectl get po --all-namespaces --field-selector status.phase!=Running | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN List pv,pvc 'Running':$$NC\n"
	@printf "=======================================\n"
	kubectl get pv,pvc | highlight
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN List pv,pvc -n kube-system 'Running':$$NC\n"
	kubectl -n kube-system get pv,pvc | highlight
	@echo ""
	@echo ""


	kubectl get pv,pvc

debug: debug-cluster

# SOURCE: https://github.com/kubernetes/kubernetes/issues/49387
debug-pod-status:
	@kubectl get pods --all-namespaces -o json  | jq -r '.items[] | select(.status.phase != "Running" or ([ .status.conditions[] | select(.type == "Ready" and .state == false) ] | length ) == 1 ) | .metadata.namespace + "/" + .metadata.name'

get-pod-status: debug-pod-status

show-all-pods-not-running:
	@kubectl get pods --all-namespaces --field-selector=status.phase!=Running | highlight

# SOURCE: https://github.com/kubernetes/kubernetes/issues/49387
get-not-ready-pods:
	@kubectl get po --all-namespaces | grep -vE '1/1|2/2|3/3' | highlight


apply-certs-dashboard:
	$(call check_defined, cluster, Please set cluster)
	@printf "kubectl apply secret generic kubernetes-dashboard-certs:\n"
	@printf "=======================================\n"
	@printf "$$GREEN kubectl apply secret generic kubernetes-dashboard-certs --from-file=dashboard-ssl/certs -n kube-system $$NC\n"
	@printf "=======================================\n"
	kubectl apply secret generic kubernetes-dashboard-certs --from-file=dist/manifests/$(cluster)-manifests/dashboard-ssl/certs -n kube-system | highlight
	@printf "apply-certs-dashboard:\n"
	@printf "=======================================\n"
	@printf "$$GREEN apply-certs-dashboard role $$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/dashboard-ssl/ | highlight

generate-htpasswd:
	$(call check_defined, cluster, Please set cluster)
	@htpasswd -nb ${_HTPASSWD_USER} ${_HTPASSWD_PASS}

create-ingress-traefik:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-ingress-traefik:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy ingress-traefik$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/ingress-traefik/
	@echo ""
	@echo ""
	-kubectl -n kube-system create secret tls traefik-ui-tls-cert --key dist/manifests/$(cluster)-manifests/ingress-traefik/certs/tls.key --cert dist/manifests/$(cluster)-manifests/ingress-traefik/certs/tls.crt

redeploy-ingress-traefik:
	$(call check_defined, cluster, Please set cluster)
	@printf "=======================================\n"
	@printf "$$GREEN RUNNING - redeploy-ingress-traefik$$NC\n"
	@printf "=======================================\n"
	@printf "delete-ingress-traefik:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete ingress-traefik$$NC\n"
	@printf "=======================================\n"
	@echo ""
	@echo ""
	-kubectl delete -f dist/manifests/$(cluster)-manifests/ingress-traefik/
	@printf "create-ingress-traefik:\n"
	@printf "=======================================\n"
	@printf "$$GREEN create ingress-traefik$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/ingress-traefik/
	@echo ""
	@echo ""
	-kubectl -n kube-system create secret tls traefik-ui-tls-cert --key dist/manifests/$(cluster)-manifests/ingress-traefik/certs/tls.key --cert dist/manifests/$(cluster)-manifests/ingress-traefik/certs/tls.crt


# kubectl get pods --all-namespaces -l app=ingress-traefik --watch | highlight

apply-ingress-traefik:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-ingress-traefik:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy ingress-traefik$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/ingress-traefik/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=ingress-traefik --watch

delete-ingress-traefik:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/ingress-traefik/

describe-ingress-traefik:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/ingress-traefik/ | highlight

debug-ingress-traefik: describe-ingress-traefik
	kubectl -n kube-system get pod -l app=ingress-traefik --output=yaml | highlight

allow-scheduling-on-master:
	$(call check_defined, cluster, Please set cluster)
	kubectl taint node borg-queen-01 node-role.kubernetes.io/master:NoSchedule-

# apk --no-cache add curl
# How to test traefik
# curl -k -H "Authorization: Bearer $token" https://10.100.0.1/version

# NOTE: This is the ip of the master node
add-etc-hosts-cheeses:
	$(call check_defined, cluster, Please set cluster)
	@echo "192.168.1.172 stilton.hyenaclan.org cheddar.hyenaclan.org wensleydale.hyenaclan.org" | sudo tee -a /etc/hosts

show-node-labels:
	$(call check_defined, cluster, Please set cluster)
	kubectl get nodes --show-labels | highlight

create-nfs-server:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-nfs-server:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy nfs-server$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/nfs-server/
	@echo ""
	@echo ""

apply-nfs-server:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-nfs-server:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy nfs-server$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/nfs-server/
	@echo ""
	@echo ""

delete-nfs-server:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/nfs-server/

describe-nfs-server:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/nfs-server/ | highlight

debug-nfs-server: describe-nfs-server
	kubectl -n kube-system get pod -l app=nfs-server --output=yaml | highlight



create-nfs-client:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-nfs-client:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy nfs-client$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/nfs-client/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-nfs-client:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-nfs-client:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy nfs-client$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/nfs-client/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

delete-nfs-client:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/nfs-client/

describe-nfs-client:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/nfs-client/ | highlight

debug-nfs-client: describe-nfs-client
	kubectl -n kube-system get pod -l app=nfs-client --output=yaml | highlight

create-registry:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-registry:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy registry$$NC\n"
	@printf "=======================================\n"
	# kubectl create -f dist/manifests/$(cluster)-manifests/registry/
	kubectl create -f dist/manifests/$(cluster)-manifests/registry/99registry-from-helm.yml
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=registry --watch | highlight

apply-registry:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-registry:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy registry$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/registry/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=registry --watch

delete-registry:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/registry/

describe-registry:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/registry/ | highlight

debug-registry: describe-registry
	kubectl -n kube-system get pod -l app=registry --output=yaml | highlight

test-registry-curl:
	curl -u admin:admin123 'https://registry.hyenalab.home/v2/_catalog'


create-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-metrics-server:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metrics-server$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/metrics-server/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-metrics-server:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metrics-server$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/metrics-server/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

delete-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/metrics-server/

describe-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/metrics-server/ | highlight

debug-metrics-server: describe-metrics-server
	kubectl -n kube-system get pod -l app=metrics-server --output=yaml | highlight


create-efk:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-efk:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/efk/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-efk:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-efk:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/efk/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

delete-efk:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/efk/

describe-efk:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/efk/ | highlight

debug-efk: describe-efk
	kubectl -n kube-system get pod -l app=efk --output=yaml | highlight

create-efk2:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-efk:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/efk2/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-efk2:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-efk:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/efk2/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

delete-efk2:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/efk2/

describe-efk2:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/efk2/ | highlight

debug-efk2: describe-efk2
	kubectl -n kube-system get pod -l app=efk --output=yaml | highlight

# SOURCE: https://github.com/projectcalico/calico/blob/v3.1.3/v3.1/getting-started/kubernetes/tutorials/stars-policy/index.md
#
create-calico-ui:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-calico-ui:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy calico-ui$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/calico-ui/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=calico-ui --watch | highlight

apply-calico-ui:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-calico-ui:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy calico-ui$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/calico-ui/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=calico-ui --watch

delete-calico-ui:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/calico-ui/

describe-calico-ui:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/calico-ui/ | highlight

debug-calico-ui: describe-calico-ui
	kubectl -n kube-system get pod -l app=calico-ui --output=yaml | highlight

# SOURCE: https://github.com/projectcalico/calico/blob/v3.1.3/v3.1/getting-started/kubernetes/tutorials/stars-policy/index.md
#
create-calico:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-calico:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy calico$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/calico/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=calico --watch | highlight

apply-calico:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-calico:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy calico$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/calico/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=calico --watch

delete-calico:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/calico/

describe-calico:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/calico/ | highlight

debug-calico: describe-calico
	kubectl -n kube-system get pod -l app=calico --output=yaml | highlight


create-elasticsearch-hq:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-elasticsearch-hq:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy elasticsearch-hq$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/elasticsearch-hq/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=elasticsearch-hq --watch | highlight

apply-elasticsearch-hq:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-elasticsearch-hq:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy elasticsearch-hq$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/elasticsearch-hq/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=elasticsearch-hq --watch

delete-elasticsearch-hq:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/elasticsearch-hq/

describe-elasticsearch-hq:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/elasticsearch-hq/ | highlight

debug-elasticsearch-hq: describe-elasticsearch-hq
	kubectl -n kube-system get pod -l app=elasticsearch-hq --output=yaml | highlight


create-elasticsearch-head:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-elasticsearch-head:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy elasticsearch-head$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/elasticsearch-head/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=elasticsearch-head --watch | highlight

apply-elasticsearch-head:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-elasticsearch-head:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy elasticsearch-head$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/elasticsearch-head/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=elasticsearch-head --watch

delete-elasticsearch-head:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/elasticsearch-head/

describe-elasticsearch-head:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/elasticsearch-head/ | highlight

debug-elasticsearch-head: describe-elasticsearch-head
	kubectl -n kube-system get pod -l app=elasticsearch-head --output=yaml | highlight



create-cert-manager:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-cert-manager:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy cert-manager$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/cert-manager/
	@echo ""
	@echo ""
	kubectl describe storageclass | highlight

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-cert-manager:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-cert-manager:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy cert-manager$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/cert-manager/
	@echo ""
	@echo ""

delete-cert-manager:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/cert-manager/

describe-cert-manager:
	$(call check_defined, cluster, Please set cluster)
	-kubectl describe -f dist/manifests/$(cluster)-manifests/cert-manager/ | highlight
	-kubectl --namespace=cert-manager describe -f dist/manifests/$(cluster)-manifests/cert-manager/ | highlight
	-kubectl --namespace=default describe -f dist/manifests/$(cluster)-manifests/cert-manager/ | highlight
	-kubectl --namespace=kube-system describe -f dist/manifests/$(cluster)-manifests/cert-manager/ | highlight
	-kubectl --namespace=cert-manager get secret example-com-tls -o yaml | highlight
	-kubectl get pods --show-all --namespace cert-manager | highlight
	-kubectl get cronjob --namespace cert-manager | hightlight

debug-cert-manager: describe-cert-manager
	kubectl --namespace=cert-manager  get pod -l app=cert-manager --output=yaml | highlight


