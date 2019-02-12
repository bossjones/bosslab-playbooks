```
# IP PLAN VIA - https://medium.com/@carlosedp/multiple-traefik-ingresses-with-letsencrypt-https-certificates-on-kubernetes-b590550280cf
Network: 192.168.1.0/24
Gateway: 192.168.1.1
DNS: 192.168.1.1 (running dnsmasq on DD-WRT Router)
Router DHCP range: 192.168.1.101 - 192.168.1.200
Reserved: 192.168.1.2 - 192.168.1.15
* 192.168.1.1 - Router
* 192.168.1.3 - Managed Switch
* 192.168.1.4 - RPi3 (media server)
Kubernetes Nodes:
    - Master1: 192.168.1.50
    - Node1: 192.168.1.55
    - Node2: 192.168.1.56
MetalLB CIDR: 192.168.1.16/28
    - 192.168.1.17 - 192.168.1.30
Traefik Internal Ingress IP: 192.168.1.20
Traefik External Ingress IP: 192.168.1.21



# My IP Plan
Network: 192.168.1.1/24
Gateway: 192.168.1.1
DNS: 192.168.1.1 (running dhcp on Unifi Gateway)
Router DHCP range: 192.168.1.6 - 192.168.1.254
Reserved: 192.168.1.2 - 192.168.1.5
* 192.168.1.1   - UniFiSecurityGateway3P
* 192.168.1.6   - UniFiSwitch16POE-150W.localdomain
* 192.168.1.7   - UniFiAP-AC-Pro.localdomain
* 192.168.1.8   - UniFi-CloudKey.localdomain
* 192.168.1.8   - UniFi Cloud Key/ Unifi Controller
* 192.168.1.10  - HyenaWhite.localdomain
* 192.168.1.14  - Philips-hue.localdomain
* 192.168.1.15  - UniFiSwitch8POE-150WRPiCluster.localdomain
* 192.168.1.15  - UniFi Switch 8 POE-150W RPi Cluster
* 192.168.1.16  - hyenatop
* 192.168.1.21  - dev7-behance-5
* 192.168.1.22  - scarlett-k8-node-02
* 192.168.1.23  - scarlett-k8-node-03
* 192.168.1.101 - scarlett-k8-node-04
* 192.168.1.114 - hyena-family-room
* 192.168.1.153 - SonosZP.localdomain
* 192.168.1.172 - borg-queen-01.localdomain
* 192.168.1.173 - borg-worker-01.localdomain
* 192.168.1.174 - borg-worker-02.localdomain
* 192.168.1.184 - scarlett-k8-node-01
* 192.168.1.189 - Kristis-iPhone.localdomain
* 192.168.1.200 - Bedroomappletv.localdomain
* 192.168.1.201 - KristispleWatch.localdomain
* 192.168.1.212 - darktop
* 192.168.1.216 - HyenaBlack.localdomain
* 192.168.1.217 - scarlett-k8-master-01
* 192.168.1.218 - pine64-ubuntu
* 192.168.1.221 - esxi.scarlettlab.home
Kubernetes Nodes(borg):
* 192.168.1.172 - borg-queen-01.localdomain ( MASTER )
* 192.168.1.173 - borg-worker-01.localdomain ( NODE )
* 192.168.1.174 - borg-worker-02.localdomain ( NODE )
MetalLB CIDR(borg): 192.168.1.30-192.168.1.40
    - 192.168.1.30-192.168.1.40
Traefik Internal Ingress IP: 192.168.1.30
Traefik External Ingress IP: 192.168.1.31

Kubernetes Nodes(scarlett-k8):
* 192.168.1.217 - scarlett-k8-master-01
* 192.168.1.184 - scarlett-k8-node-01
* 192.168.1.22  - scarlett-k8-node-02
* 192.168.1.23  - scarlett-k8-node-03
* 192.168.1.101 - scarlett-k8-node-04
MetalLB CIDR(scarlett-k8): 192.168.1.50-192.168.1.60
    - 192.168.1.50-192.168.1.60
Traefik Internal Ingress IP: 192.168.1.50
Traefik External Ingress IP: 192.168.1.51
```
