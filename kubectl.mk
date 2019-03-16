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

# VIA instructions - https://github.com/kubernetes/dashboard/wiki/Certificate-management
generate-certs-dashboard:
	$(call check_defined, cluster, Please set cluster)
	-mkdir -p dist/manifests/$(cluster)-manifests/dashboard-ssl/certs
	openssl genrsa -des3 -passout pass:x -out dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.pass.key 2048
	openssl rsa -passin pass:x -in dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.pass.key -out dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.key
# Writing RSA key
	rm dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.pass.key
	tree dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/
	openssl req -new -key dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.key -out dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.csr
	openssl x509 -req -sha256 -days 365 -in dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.csr -signkey dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.key -out dist/manifests/$(cluster)-manifests/dashboard-ssl/certs/dashboard.crt
	@printf "=======================================\n"
	@printf "$$GREEN The dashboard.crt file is your certificate suitable for use with Dashboard along with the dashboard.key private key. $$NC\n"
	@printf "=======================================\n"

apply-mkcert-certs-dashboard:
	$(call check_defined, cluster, Please set cluster)
	@printf "kubectl apply secret generic kubernetes-dashboard-certs:\n"
	@printf "=======================================\n"
	@printf "$$GREEN kubectl create secret generic kubernetes-dashboard-certs --from-file=dist/manifests/$(cluster)-manifests/dashboard-ssl/certs -n kube-system $$NC\n"
	kubectl create secret generic kubernetes-dashboard-certs --from-file=dist/manifests/$(cluster)-manifests/dashboard-ssl/certs -n kube-system

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

redeploy-registry:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete registry:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete registry$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/registry/

	@printf "render registry manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render registry manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_registry.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-registry:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy registry$$NC\n"
	@printf "=======================================\n"
	# kubectl create -f dist/manifests/$(cluster)-manifests/registry/
	-kubectl create -f dist/manifests/$(cluster)-manifests/registry/99registry-from-helm.yml
	@echo ""
	@echo ""


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
	kubectl apply -f dist/manifests/$(cluster)-manifests/registry/99registry-from-helm.yml
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
	-curl -v -L -u admin:admin123 'https://registry.hyenalab.home/v2/_catalog'
	-curl -v -L 'http://registry.hyenalab.home/v2'
	-curl -v -L 'http://registry.hyenalab.home/v2_catalog'

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

ls-efk-fluentd:
	$(call check_defined, cluster, Please set cluster)
	@printf "ls-efk-fluentd:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/efk/* -type f -name '*fluentd*y*ml' -print0 | xargs -I FILE -t -0 -n1 ls FILE"
	@echo ""
	@echo ""

apply-efk-fluentd:
	$(call check_defined, cluster, Please set cluster)
	@printf "apply-fluentd-efk:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/efk/* -type f -name '*fluentd*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl apply -f FILE"
	@echo ""
	@echo ""

delete-efk-fluentd:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete-efk:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/efk/* -type f -name '*fluentd.*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl delete -f FILE"
	@echo ""
	@echo ""

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-efk-ingress:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-efk:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/efk/* -type f -name '*ingress.*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl apply -f FILE"
	@echo ""
	@echo ""


ls-efk-elasticsearch:
	$(call check_defined, cluster, Please set cluster)
	@printf "ls-efk-elasticsearch:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy efk$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/efk/* -type f -name '*elasticsearch*y*ml' -print0 | xargs -I FILE -t -0 -n1 ls FILE"
	@echo ""
	@echo ""


apply-efk-elasticsearch:
	$(call check_defined, cluster, Please set cluster)
	@printf "apply-efk-elasticsearch:\n"
	@printf "=======================================\n"
	@printf "$$GREEN apply-efk-elasticsearch$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/efk/* -type f -name '*elasticsearch*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl apply -f FILE"
	@echo ""
	@echo ""

apply-efk-kibana:
	$(call check_defined, cluster, Please set cluster)
	@printf "apply-efk-kibana:\n"
	@printf "=======================================\n"
	@printf "$$GREEN apply-efk-kibana$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/efk/* -type f -name '*kibana*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl apply -f FILE"
	@echo ""
	@echo ""

delete-efk-kibana:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete-efk-kibana:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete-efk-kibana$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/efk/* -type f -name '*kibana*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl delete -f FILE"
	@echo ""
	@echo ""

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

create-registry-ui:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-registry-ui:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy registry-ui$$NC\n"
	@printf "=======================================\n"
	# kubectl create -f dist/manifests/$(cluster)-manifests/registry-ui/
	kubectl create -f dist/manifests/$(cluster)-manifests/registry-ui/99registry-ui-from-helm.yml
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=registry-ui --watch | highlight

apply-registry-ui:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-registry-ui:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy registry-ui$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/registry-ui/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=registry-ui --watch

delete-registry-ui:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/registry-ui/

describe-registry-ui:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/registry-ui/ | highlight

debug-registry-ui: describe-registry-ui
	kubectl -n kube-system get pod -l app=registry-ui --output=yaml | highlight

test-registry-ui-curl:
	curl -u admin:admin123 'https://registry-ui.hyenalab.org/v2/_catalog'






redeploy-jenkins:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete jenkins:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete jenkins$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/jenkins-k8/

	@printf "render jenkins manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render jenkins manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_jenkins.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-jenkins:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy jenkins$$NC\n"
	@printf "=======================================\n"
	# kubectl create -f dist/manifests/$(cluster)-manifests/jenkins-k8/
	-kubectl create -f dist/manifests/$(cluster)-manifests/jenkins-k8/99jenkins-from-helm.yaml
	@echo ""
	@echo ""


create-jenkins:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-jenkins:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy jenkins$$NC\n"
	@printf "=======================================\n"
	# kubectl create -f dist/manifests/$(cluster)-manifests/jenkins-k8/
	kubectl create -f dist/manifests/$(cluster)-manifests/jenkins-k8/99jenkins-from-helm.yaml
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=jenkins --watch | highlight

apply-jenkins:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-jenkins:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy jenkins$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/jenkins-k8/99jenkins-from-helm.yaml
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=jenkins --watch

delete-jenkins:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/jenkins-k8/

describe-jenkins:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/jenkins-k8/ | highlight

debug-jenkins: describe-jenkins
	kubectl -n kube-system get pod -l app=jenkins --output=yaml | highlight

test-jenkins-curl:
	-curl -v -L 'http://jenkins.hyenaclan.org'



redeploy-heapster2:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete heapster:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete heapster$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/heapster2/

	@printf "render heapster manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render heapster manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_heapster2.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-heapster2:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy heapster$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/heapster2/
	@echo ""
	@echo ""


create-heapster2:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-heapster2:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy heapster$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/heapster2/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=heapster --watch | highlight

apply-heapster2:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-heapster2:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy heapster2$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/heapster2/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=heapster --watch

delete-heapster2:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/heapster2/

describe-heapster2:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/heapster2/ | highlight

debug-heapster2: describe-heapster2
	kubectl -n kube-system get pod -l app=heapster --output=yaml | highlight

test-heapster2-curl:
	-curl -v -L 'http://heapster.hyenaclan.org'


redeploy-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete metrics-server:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete metrics-server$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/metrics-server/

	@printf "render metrics-server manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render metrics-server manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_metrics_server.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-metrics-server:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metrics-server$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/metrics-server/
	@echo ""
	@echo ""


create-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-metrics-server:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metrics-server$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/metrics-server/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=metrics-server --watch | highlight

apply-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-metrics-server:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metrics-server$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/metrics-server/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=metrics-server --watch

delete-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/metrics-server/

describe-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/metrics-server/ | highlight

debug-metrics-server: describe-metrics-server
	kubectl -n kube-system get pod -l app=metrics-server --output=yaml | highlight

test-metrics-server-curl:
	-curl -v -L 'http://metrics-server.hyenaclan.org'

lint-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/metrics-server -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"



redeploy-external-dns:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete external-dns:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete external-dns$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/external-dns/

	@printf "render external-dns manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render external-dns manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_external_dns.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-external-dns:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy external-dns$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/external-dns/
	@echo ""
	@echo ""


create-external-dns:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-external-dns:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy external-dns$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/external-dns/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=external-dns --watch | highlight

apply-external-dns:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-external-dns:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy external-dns$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/external-dns/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=external-dns --watch

delete-external-dns:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/external-dns/

describe-external-dns:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/external-dns/ | highlight

debug-external-dns: describe-external-dns
	kubectl -n kube-system get pod -l app=external-dns --output=yaml | highlight

test-external-dns-curl:
	-curl -v -L 'http://external-dns.hyenaclan.org'

lint-external-dns:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/external-dns -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"



redeploy-helm:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete helm:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete helm$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/helm/

	@printf "render helm manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render helm manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_helm.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-helm:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy helm$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/helm/
	@echo ""
	@echo ""


create-helm:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-helm:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy helm$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/helm/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=helm --watch | highlight

apply-helm:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-helm:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy helm$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/helm/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=helm --watch

delete-helm:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/helm/

describe-helm:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/helm/ | highlight

debug-helm: describe-helm
	kubectl -n kube-system get pod -l app=helm --output=yaml | highlight

test-helm-curl:
	-curl -v -L 'http://helm.hyenaclan.org'

lint-helm:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/helm -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

bootstrap-helm-init:
	@printf "create-helm:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy helm$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/helm/
	@echo ""
	@echo ""
	helm init --service-account tiller

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	-helm repo add banzaicloud-stable http://kubernetes-charts.banzaicloud.com/branch/master
	helm repo list



redeploy-metallb:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete metallb:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete metallb$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/metallb/00metallb_kube.yaml
	-kubectl delete -f dist/manifests/$(cluster)-manifests/metallb/metallb-config.yaml

	@printf "render metallb manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render metallb manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_metallb.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-metallb:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metallb$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/metallb/00metallb_kube.yaml
	-kubectl create -f dist/manifests/$(cluster)-manifests/metallb/metallb-config.yaml
	@echo ""
	@echo ""


create-metallb:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-metallb:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metallb$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/metallb/00metallb_kube.yaml
	kubectl create -f dist/manifests/$(cluster)-manifests/metallb/metallb-config.yaml
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=metallb --watch | highlight

apply-metallb:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-metallb:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metallb$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/metallb/00metallb_kube.yaml
	kubectl apply -f dist/manifests/$(cluster)-manifests/metallb/metallb-config.yaml
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=metallb --watch

delete-metallb:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/metallb/00metallb_kube.yaml
	kubectl delete -f dist/manifests/$(cluster)-manifests/metallb/metallb-config.yaml

describe-metallb:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/metallb/00metallb_kube.yaml | highlight
	kubectl describe -f dist/manifests/$(cluster)-manifests/metallb/metallb-config.yaml | highlight

debug-metallb: describe-metallb
	kubectl -n kube-system get pod -l app=metallb --output=yaml | highlight

test-metallb-curl:
	-curl -v -L 'http://metallb.hyenaclan.org'

lint-metallb:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/metallb -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

create-metallb-tutorial:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-metallb-tutorial:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metallb$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/metallb/99metallb_tutorial.yaml
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=metallb --watch | highlight

apply-metallb-tutorial:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-metallb-tutorial:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy metallb$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/metallb/99metallb_tutorial.yaml
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=metallb --watch

delete-metallb-tutorial:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/metallb/99metallb_tutorial.yaml

describe-metallb-tutorial:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/metallb/99metallb_tutorial.yaml | highlight

debug-metallb-tutorial: describe-metallb-tutorial
	kubectl get pod -l app=metalnginx-metallblb --output=yaml | highlight


redeploy-ingress-nginx:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete ingress-nginx:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete ingress-nginx$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/ingress-nginx/

	@printf "render ingress-nginx manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render ingress-nginx manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_ingress-nginx.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "lint ingress-nginx manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN lint ingress-nginx manifest$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/ingress-nginx -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-ingress-nginx:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy ingress-nginx$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/ingress-nginx/
	@echo ""
	@echo ""


create-ingress-nginx:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-ingress-nginx:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy ingress-nginx$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/ingress-nginx/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=ingress-nginx --watch | highlight

apply-ingress-nginx:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-ingress-nginx:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy ingress-nginx$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/ingress-nginx/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=ingress-nginx --watch

delete-ingress-nginx:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/ingress-nginx/

describe-ingress-nginx:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/ingress-nginx/ | highlight

debug-ingress-nginx: describe-ingress-nginx
	kubectl -n kube-system get pod -l app=ingress-nginx --output=yaml | highlight

test-ingress-nginx-curl:
	-curl -v -L 'http://ingress-nginx.hyenaclan.org'

lint-ingress-nginx:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/ingress-nginx -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"




redeploy-markdownrender:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete markdownrender:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete markdownrender$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/markdownrender/

	@printf "render markdownrender manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render markdownrender manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_markdownrender.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "lint markdownrender manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN lint markdownrender manifest$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/markdownrender -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-markdownrender:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy markdownrender$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/markdownrender/
	@echo ""
	@echo ""


create-markdownrender:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-markdownrender:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy markdownrender$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/markdownrender/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=markdownrender --watch | highlight

apply-markdownrender:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-markdownrender:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy markdownrender$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/markdownrender/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=markdownrender --watch

delete-markdownrender:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/markdownrender/

describe-markdownrender:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/markdownrender/ | highlight

debug-markdownrender: describe-markdownrender
	kubectl -n kube-system get pod -l app=markdownrender --output=yaml | highlight

test-markdownrender-curl:
	-curl -v -L 'http://markdownrender.hyenaclan.org'

lint-markdownrender:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/markdownrender -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"



redeploy-traefik-internal:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete traefik-internal:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete traefik-internal$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/traefik-internal/

	@printf "render traefik-internal manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render traefik-internal manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_traefik_internal.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "lint traefik-internal manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN lint traefik-internal manifest$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/traefik-internal -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-traefik-internal:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy traefik-internal$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/traefik-internal/
	@echo ""
	@echo ""


create-traefik-internal:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-traefik-internal:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy traefik-internal$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/traefik-internal/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=traefik-internal --watch | highlight

apply-traefik-internal:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-traefik-internal:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy traefik-internal$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/traefik-internal/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=traefik-internal --watch

delete-traefik-internal:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/traefik-internal/

describe-traefik-internal:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/traefik-internal/ | highlight

debug-traefik-internal: describe-traefik-internal
	kubectl -n kube-system get pod -l app=traefik-internal --output=yaml | highlight

test-traefik-internal-curl:
	-curl -v -L 'http://traefik-internal.hyenaclan.org'

lint-traefik-internal:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/traefik-internal -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"


redeploy-weave-scope:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete weave-scope:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete weave-scope$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/weave-scope/

	@printf "render weave-scope manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render weave-scope manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_weave_scope.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "lint weave-scope manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN lint weave-scope manifest$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/weave-scope -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-weave-scope:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy weave-scope$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/weave-scope/
	@echo ""
	@echo ""


create-weave-scope:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-weave-scope:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy weave-scope$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/weave-scope/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=weave-scope --watch | highlight

apply-weave-scope:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-weave-scope:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy weave-scope$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/weave-scope/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=weave-scope --watch

delete-weave-scope:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/weave-scope/

describe-weave-scope:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/weave-scope/ | highlight

debug-weave-scope: describe-weave-scope
	kubectl -n kube-system get pod -l app=weave-scope --output=yaml | highlight

test-weave-scope-curl:
	-curl -v -L 'http://weave-scope.hyenaclan.org'

lint-weave-scope:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/weave-scope -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"


redeploy-echoserver:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete echoserver:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete echoserver$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/echoserver/

	@printf "render echoserver manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render echoserver manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_echoserver.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "lint echoserver manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN lint echoserver manifest$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/echoserver -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-echoserver:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy echoserver$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/echoserver/
	@echo ""
	@echo ""


create-echoserver:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-echoserver:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy echoserver$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/echoserver/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=echoserver --watch | highlight

apply-echoserver:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-echoserver:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy echoserver$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/echoserver/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=echoserver --watch

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-echoserver-ingress:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-echoserver:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy echoserver$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/echoserver/* -type f -name '*ingress.*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl apply -f FILE"
	@echo ""
	@echo ""

delete-echoserver:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/echoserver/

describe-echoserver:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/echoserver/ | highlight

debug-echoserver: describe-echoserver
	kubectl -n kube-system get pod -l app=echoserver --output=yaml | highlight

test-echoserver-curl:
	-curl -v -L 'http://echoserver.hyenaclan.org'

lint-echoserver:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/echoserver -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

redeploy-prometheus-operator:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete prometheus-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete prometheus-operator$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/

	@printf "render prometheus-operator manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render prometheus-operator manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_prometheus_operator.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "lint prometheus-operator manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN lint prometheus-operator manifest$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/prometheus-operator -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-prometheus-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy prometheus-operator$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/
	@echo ""
	@echo ""

	@printf "Post deployment steps:\n"
	@printf "=======================================\n"
	@printf "$$GREEN A NOTE ABOUT - Prometheus kubelet metrics server returned HTTP status 403 Forbidden$$NC\n"
	@printf "=======================================\n"
	@printf "READ MORE: https://github.com/coreos/prometheus-operator/blob/9468bf9f1f1219dfd996364f8aa496fce5dbd5fb/Documentation/troubleshooting.md\n"
	@echo ""
	@echo ""
	@printf "$$GREEN Prometheus is installed, all looks good, however the Targets are all showing as down. All permissions seem to be good, yet no joy. Prometheus pulling metrics from all namespaces expect kube-system, and Prometheus has access to all namespaces including kube-system.$$NC\n"
	@printf "$$RED Did you check the webhooks?$$NC\n"
	@printf "$$GREEN Issue has been resolved by amending the webhooks to use 0.0.0.0 instead of 127.0.0.1. Follow the below commands and it will update the webhooks which allows connections to all clusterIP's in all namespaces and not just 127.0.0.1.$$NC\n"
	@echo ""
	@echo ""
	@printf "$$GREEN RUN THIS: sed -e \"s/--authentication-token-webhook=true/--authentication-token-webhook=true --authorization-mode=Webhook/\" -i /etc/default/kubelet $$NC\n"

post-deployment-prometheus-operator:
	@printf "Post deployment steps:\n"
	@printf "=======================================\n"
	@printf "$$GREEN A NOTE ABOUT - Prometheus kubelet metrics server returned HTTP status 403 Forbidden$$NC\n"
	@printf "=======================================\n"
	@printf "READ MORE: https://github.com/coreos/prometheus-operator/blob/9468bf9f1f1219dfd996364f8aa496fce5dbd5fb/Documentation/troubleshooting.md\n"
	@echo ""
	@echo ""
	@printf "$$GREEN Prometheus is installed, all looks good, however the Targets are all showing as down. All permissions seem to be good, yet no joy. Prometheus pulling metrics from all namespaces expect kube-system, and Prometheus has access to all namespaces including kube-system.$$NC\n"
	@printf "$$RED Did you check the webhooks?$$NC\n"
	@printf "$$GREEN Issue has been resolved by amending the webhooks to use 0.0.0.0 instead of 127.0.0.1. Follow the below commands and it will update the webhooks which allows connections to all clusterIP's in all namespaces and not just 127.0.0.1.$$NC\n"
	@echo ""
	@echo ""
	@printf "=======================================\n"
	@printf "$$GREEN RUN THIS ON ALL NODES$$NC\n"
	@printf "=======================================\n"
	@printf "$$BLUE RUN THIS: sed -e \"s/--authentication-token-webhook=true/--authentication-token-webhook=true --authorization-mode=Webhook/\" -i /etc/default/kubelet $$NC\n"
	@printf "$$BLUE RUN THIS: systemctl daemon-reload;systemctl restart kubelet$$NC\n"
	@printf "=======================================\n"
	@printf "$$GREEN RUN THIS ON ALL MASTERS$$NC\n"
	@printf "=======================================\n"
	@printf "$$BLUE sed -e \"s/- --address=127.0.0.1/- --address=0.0.0.0/\" -i /etc/kubernetes/manifests/kube-controller-manager.yaml$$NC\n"
	@printf "$$BLUE sed -e \"s/- --address=127.0.0.1/- --address=0.0.0.0/\" -i /etc/kubernetes/manifests/kube-scheduler.yaml$$NC\n"


create-prometheus-operator:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-prometheus-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy prometheus-operator$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=prometheus-operator --watch | highlight

apply-prometheus-operator:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-prometheus-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy prometheus-operator$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=prometheus-operator --watch

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-prometheus-operator-ingress:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-prometheus-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy prometheus-operator$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/* -type f -name '*ingress*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl apply -f FILE"
	@echo ""
	@echo ""


# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-prometheus-operator-alertmanager:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-prometheus-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy prometheus-operator$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/* -type f -name '*alertmanager*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl apply -f FILE"
	@echo ""
	@echo ""

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
delete-prometheus-operator-alertmanager:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-prometheus-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy prometheus-operator$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/* -type f -name '*alertmanager*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl delete -f FILE"
	@echo ""
	@echo ""

delete-prometheus-operator:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/

describe-prometheus-operator:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/prometheus-operator-v0-27-0/ | highlight

debug-prometheus-operator: describe-prometheus-operator
	kubectl -n kube-system get pod -l app=prometheus-operator --output=yaml | highlight

test-prometheus-operator-curl:
	-curl -v -L 'http://prometheus-operator.hyenaclan.org'

lint-prometheus-operator:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/prometheus-operator -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"



redeploy-unifi-exporter:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete unifi-exporter:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete unifi-exporter$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/unifi-exporter/

	@printf "render unifi-exporter manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render unifi-exporter manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_unifi_exporter.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause" --vault-password-file ./vault_password
	@echo ""
	@echo ""

	@printf "lint unifi-exporter manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN lint unifi-exporter manifest$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/unifi-exporter -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-unifi-exporter:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy unifi-exporter$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/unifi-exporter/
	@echo ""
	@echo ""

create-unifi-exporter:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-unifi-exporter:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy unifi-exporter$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/unifi-exporter/
	@echo ""
	@echo ""

apply-unifi-exporter:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-unifi-exporter:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy unifi-exporter$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/unifi-exporter/
	@echo ""
	@echo ""

delete-unifi-exporter:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/unifi-exporter/

describe-unifi-exporter:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/unifi-exporter/ | highlight

debug-unifi-exporter: describe-unifi-exporter
	kubectl -n kube-system get pod -l app=unifi-exporter --output=yaml | highlight

test-unifi-exporter-curl:
	-curl -v -L 'http://unifi-exporter.hyenaclan.org'

lint-unifi-exporter:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/unifi-exporter -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"


redeploy-influxdb-operator:
	$(call check_defined, cluster, Please set cluster)
	@printf "delete influxdb-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN delete influxdb-operator$$NC\n"
	@printf "=======================================\n"
	-kubectl delete -f dist/manifests/$(cluster)-manifests/influxdb-operator/

	@printf "render influxdb-operator manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN render influxdb-operator manifest$$NC\n"
	@printf "=======================================\n"
	-ansible-playbook -c local -vvvvv playbooks/render_influxdb_operator.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo ""
	@echo ""

	@printf "lint influxdb-operator manifest:\n"
	@printf "=======================================\n"
	@printf "$$GREEN lint influxdb-operator manifest$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/influxdb-operator -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

	@printf "quick sleep:\n"
	@printf "=======================================\n"
	@printf "$$GREEN quick sleep$$NC\n"
	@printf "=======================================\n"
	sleep 10
	@echo ""
	@echo ""

	@printf "create-influxdb-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy influxdb-operator$$NC\n"
	@printf "=======================================\n"
	-kubectl create -f dist/manifests/$(cluster)-manifests/influxdb-operator/
	@echo ""
	@echo ""



create-influxdb-operator:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-influxdb-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy influxdb-operator$$NC\n"
	@printf "=======================================\n"
	kubectl create -f dist/manifests/$(cluster)-manifests/influxdb-operator/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=influxdb-operator --watch | highlight

apply-influxdb-operator:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-influxdb-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy influxdb-operator$$NC\n"
	@printf "=======================================\n"
	kubectl apply -f dist/manifests/$(cluster)-manifests/influxdb-operator/
	@echo ""
	@echo ""
# kubectl get pods --all-namespaces -l app=influxdb-operator --watch

# https://github.com/kubernetes/kubernetes/blob/3d7d35ee8f099f4611dca06de4453f958b4b8492/cluster/addons/storage-class/local/default.yaml
apply-influxdb-operator-ingress:
	$(call check_defined, cluster, Please set cluster)
	@printf "create-influxdb-operator:\n"
	@printf "=======================================\n"
	@printf "$$GREEN deploy influxdb-operator$$NC\n"
	@printf "=======================================\n"
	bash -c "find dist/manifests/$(cluster)-manifests/influxdb-operator/* -type f -name '*ingress.*y*ml' -print0 | xargs -I FILE -t -0 -n1 kubectl apply -f FILE"
	@echo ""
	@echo ""

delete-influxdb-operator:
	$(call check_defined, cluster, Please set cluster)
	kubectl delete -f dist/manifests/$(cluster)-manifests/influxdb-operator/

describe-influxdb-operator:
	$(call check_defined, cluster, Please set cluster)
	kubectl describe -f dist/manifests/$(cluster)-manifests/influxdb-operator/ | highlight

debug-influxdb-operator: describe-influxdb-operator
	kubectl -n kube-system get pod -l app=influxdb-operator --output=yaml | highlight

test-influxdb-operator-curl:
	-curl -v -L 'http://influxdb-operator.hyenaclan.org'

lint-influxdb-operator:
	$(call check_defined, cluster, Please set cluster)
	bash -c "find dist/manifests/$(cluster)-manifests/influxdb-operator -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"
