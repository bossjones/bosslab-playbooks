# create extra_playbooks dir

```
mkdir -p  ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/{calico,calico-ui,cert-manager,cfs-go,cheeses,contrib,dashboard,dashboard-admin,dashboard-ssl,echoserver,efk,efk2,elasticsearch,elasticsearch-head,elasticsearch-head-docker,elasticsearch-hq,es-curator,etcdkeeper,fluentd-elasticsearch,galaxy,heapster2,ingress,ingress-nginx,ingress-nginx2,ingress-traefik,ingress-traefik2,istio,jenkins,jenkins-k8,kibana,metallb,metrics-server,mysql,nfs-client,nfs-server,npd,playbooks,prometheus-operator,prometheus-operator-v0-27-0,registry,roles,scripts,vistio,whoami}/{tasks,templates,defaults,meta,vars}
```


```
kube_apps_array=(calico calico-ui cert-manager cfs-go cheeses contrib dashboard dashboard-admin dashboard-ssl echoserver efk efk2 elasticsearch elasticsearch-head elasticsearch-head-docker elasticsearch-hq es-curator etcdkeeper fluentd-elasticsearch galaxy heapster2 ingress ingress-nginx ingress-nginx2 ingress-traefik ingress-traefik2 istio jenkins jenkins-k8 kibana metallb metrics-server mysql nfs-client nfs-server npd playbooks prometheus-operator prometheus-operator-v0-27-0 registry roles scripts vistio whoami)

# kube_apps_array=(calico)

for i in "${kube_apps_array[@]}"; do
  echo "This is: $i"
  echo "cp -rv ~/dev/bossjones/kubernetes-cluster/${i}/* ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/"
done

```
