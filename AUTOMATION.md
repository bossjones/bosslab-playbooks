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



#####

```
host_vars[i[:name]] = {
  "ip": i[:ip],
  "subnet": "#{$subnet}",
  "nfs_server": $nfs_server,
  "count_nodes": $kube_node_instances,
  "ansible_host": i[:ip],
  "bootstrap_os": SUPPORTED_OS[$os][:bootstrap_os],
  "ansible_port": 22,
  "ansible_user": 'vagrant',
  "ansible_connection": 'ssh',
  "ansible_ssh_user": 'vagrant',
  "ansible_ssh_pass": 'vagrant',
  "local_release_dir" => $local_release_dir,
  "download_run_once": "False",
  "kube_network_plugin": $network_plugin
}
```



# Add this to jenkins Dockerfile

```
# SOURCE: https://github.com/hello-k8s/hello-k8s/blob/a6705bb5d889b5bfcf93caf312af9f8034f388bd/config/jenkins/Dockerfile


FROM jenkins/jenkins:lts
USER root
#ENV JENKINS_OPTS="--prefix=/jenkins"

#Pre-Install Jenkins Plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

#Installing Docker
RUN apt-get update && apt-get install software-properties-common apt-transport-https ca-certificates -y; \
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -;\
add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/debian  $(lsb_release -cs) stable";\
apt-get update && apt-get install docker-ce -y

#Installing kubectl from Docker
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -;\
touch /etc/apt/sources.list.d/kubernetes.list;\
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list;\
apt-get update && apt-get install -y kubectl

# Grant jenkins user group access to /var/run/docker.sock
RUN addgroup --gid 1001 dsock
RUN gpasswd -a jenkins dsock
USER jenkins
```
