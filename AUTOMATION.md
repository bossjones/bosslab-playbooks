# create extra_playbooks dir

```
mkdir -p  ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/{calico,calico-ui,cert-manager,cfs-go,cheeses,contrib,dashboard,dashboard-admin,dashboard-ssl,echoserver,efk,efk2,elasticsearch,elasticsearch-head,elasticsearch-head-docker,elasticsearch-hq,es-curator,etcdkeeper,fluentd-elasticsearch,galaxy,heapster2,ingress,ingress-nginx,ingress-nginx2,ingress-traefik,ingress-traefik2,istio,jenkins,jenkins-k8,kibana,metallb,metrics-server,mysql,nfs-client,nfs-server,npd,playbooks,prometheus-operator,prometheus-operator-v0-27-0,registry,scripts,vistio,whoami}/{tasks,templates,defaults,meta,vars}
```


```
kube_apps_array=(calico calico-ui cert-manager cfs-go cheeses contrib dashboard dashboard-admin dashboard-ssl echoserver efk efk2 elasticsearch elasticsearch-head elasticsearch-head-docker elasticsearch-hq es-curator etcdkeeper fluentd-elasticsearch galaxy heapster2 ingress ingress-nginx ingress-nginx2 ingress-traefik ingress-traefik2 istio jenkins jenkins-k8 kibana metallb metrics-server mysql nfs-client nfs-server npd playbooks prometheus-operator prometheus-operator-v0-27-0 registry scripts vistio whoami)

# kube_apps_array=(calico)

for i in "${kube_apps_array[@]}"; do
  echo "This is: $i"
  echo "cp -rv ~/dev/bossjones/kubernetes-cluster/${i}/* ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/"
done

```


# rename everything to .j2 in template folder
```
kube_apps_array=(calico calico-ui cert-manager cfs-go cheeses contrib dashboard dashboard-admin dashboard-ssl echoserver efk efk2 elasticsearch elasticsearch-head elasticsearch-head-docker elasticsearch-hq es-curator etcdkeeper fluentd-elasticsearch galaxy heapster2 ingress ingress-nginx ingress-nginx2 ingress-traefik ingress-traefik2 istio jenkins jenkins-k8 kibana metallb metrics-server mysql nfs-client nfs-server npd playbooks prometheus-operator prometheus-operator-v0-27-0 registry roles scripts vistio whoami)


# DRY RUN
# kube_apps_array=(calico)

# for i in "${kube_apps_array[@]}"; do
#     echo "This is: $i"
#     gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "*.yml" -print0 | xargs -0 /usr/local/bin/rename -n -s yml yml.j2 {}

#     gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "*.yaml" -print0 | xargs -0 /usr/local/bin/rename -n -s yaml yaml.j2 {}
# done



for i in "${kube_apps_array[@]}"; do
    echo "This is: $i"
    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "*.yml" -print0 | xargs -0 /usr/local/bin/rename -s yml yml.j2 {}

    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "*.yaml" -print0 | xargs -0 /usr/local/bin/rename -s yaml yaml.j2 {}

    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "*.json" -print0 | xargs -0 /usr/local/bin/rename -s json json.j2 {}

    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "*.sh$" -print0 | xargs -0 /usr/local/bin/rename -s sh sh.j2 {}


    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "Dockerfile" -print0 | xargs -0 /usr/local/bin/rename -s Dockerfile Dockerfile.j2 {}


    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "Makefile" -print0 | xargs -0 /usr/local/bin/rename -s Makefile Makefile.j2 {}


    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "Gemfile" -print0 | xargs -0 /usr/local/bin/rename -s Gemfile Gemfile.j2 {}

    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "jvm.opts" -print0 | xargs -0 /usr/local/bin/rename -s jvm.opts jvm.opts.j2 {}

    gfind ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/ -type f -iname "*.gpg" -print0 | xargs -0 /usr/local/bin/rename -s gpg gpg.j2 {}

    tree ~/dev/bossjones/bosslab-playbooks/extra_playbooks/roles/kubernetes-apps/${i}/templates/
done

```
