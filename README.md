# bosslab-playbooks
bosslab homelab playbooks for the entire boss ansible suite


# ruby

```
sudo apt-add-repository ppa:brightbox/ruby-ng -y
sudo apt-get update

gem install bundler pry-byebug byebug pry pry-inline pry-state pry-theme pry-stack_explorer

sudo apt-get install ruby2.4 ruby2.4-dev

```


# mkcert

```
root@scarlett-k8-master-01  ~   mkcert -install                                                                                                                                                                                4.17 Dur  21:55:09
Created a new local CA at "/root/.local/share/mkcert" 💥
The local CA is now installed in the system trust store! ⚡️

Time: 0h:00m:18s

root@scarlett-k8-master-01  ~  mkcert example.com "*.example.org" myapp.dev localhost 127.0.0.1 ::1 scarlettlab.com "*.scarlettlab.org" bosslab.com "*.bosslab.org" rpilab.com "*.rpilab.org"
```


# Set static routes dhcp (never want these ips to change) !

https://kubecloud.io/setting-up-a-kubernetes-1-11-raspberry-pi-cluster-using-kubeadm-952bbda329c8


# netdata alerts / events ( making bcc-tools run on error )

* These are the variables that are available to us in the script - https://github.com/netdata/netdata/blob/eb551d2c19c2fbbc5d702fd8d01f4c1e78b4f990/plugins.d/alarm-notify.sh#L124-L143

* https://docs.netdata.cloud/health/

* https://docs.netdata.cloud/health/notifications/

* https://github.com/netdata/netdata/blob/master/health/notifications/alarm-notify.sh.in


# Long term metrics storage

* https://docs.netdata.cloud/backends/


# Git Issues

### Prometheus-operator
- https://github.com/coreos/prometheus-operator/issues/2409
- https://github.com/coreos/prometheus-operator/pull/2371
- https://github.com/helm/charts/issues/11447

### Metrics-server
- https://github.com/kubernetes-incubator/metrics-server/issues/144
- https://github.com/Azure/AKS/issues/832
