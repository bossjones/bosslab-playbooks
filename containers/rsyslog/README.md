# rsyslog-docker

* https://docs.vmware.com/en/VMware-NSX-T-Data-Center/2.2/com.vmware.nsxt.ncp_kubernetes.doc/GUID-876D73A8-67E8-4A7C-9486-A00D679932ED.html
* https://github.com/kincl/kubernetes-logging-syslog
* https://docs.vmware.com/en/VMware-NSX-T-Data-Center/2.2/com.vmware.nsxt.ncp_kubernetes.doc/GUID-BCE9FEEE-EC44-4948-8070-6A08C74CC9C4.html
* https://docs.vmware.com/en/VMware-NSX-T-Data-Center/2.2/com.vmware.nsxt.ncp_kubernetes.doc/GUID-872D7A73-EA42-44F6-B15D-E17664B91622.html
* https://docs.vmware.com/en/VMware-NSX-T-Data-Center/2.2/com.vmware.nsxt.ncp_kubernetes.doc/GUID-AC96C51A-052B-403F-9670-67E55C4C9170.html
* https://github.com/kincl/kubernetes-logging-syslog
* https://github.com/effertzdv/elasticstack/blob/92c6332265f1d83dfc282b30d415bcd4f8917846/logstash/pipeline/logstash.conf
* https://github.com/jrxFive/groktoregex/blob/master/parser.go


```
# time regex without comma
(?<time>(?!<[0-9])(?:2[0123]|[01]?[0-9]):(?:[0-5][0-9])(?::(?:(?:[0-5]?[0-9]|60)(?:[^:.,][0-9]+)?))(?![0-9]))
```

```
Log: [20:52:27,075] <inform-707> INFO inform - from [f0:9f:c2:33:bd:71](UniFi AP-AC-Pro, U7PG2, 4.0.21.9965): state=CONNECTED, last_inform=31, ext/stun_ip=192.168.1.7, dev_ip=192.168.1.7, up=4666650

(?<time>(?!<[0-9])(?:2[0123]|[01]?[0-9]):(?:[0-5][0-9])(?::(?:(?:[0-5]?[0-9]|60))))(?:[:.,][0-9]+)(?:\]) (?:<)(?<msg-type>\b\w+\b)-(?<msg-pri>\b\w+\b)(?:>)



Match group:

time | 20:52:27
msg-type | inform
msg-pri | 707


```
