SOURCE: https://unix.stackexchange.com/questions/345595/how-to-set-ulimits-on-service-with-systemd

SOURCE: https://phpsolved.com/ubuntu-16-increase-maximum-file-open-limit-ulimit-n/

SOURCE: https://blog.confirm.ch/sysctl-tuning-linux/

SOURCE: https://github.com/kubernetes/ingress-nginx/blob/29c5d770688b04d0a8beedf70aebd76990332d56/docs/examples/customization/sysctl/patch.json

SOURCE: https://lzone.de/cheat-sheet/ulimit

SOURCE: https://blog.openai.com/scaling-kubernetes-to-2500-nodes/

### Lets say I want my new 'ulimit -n' to read 131072.

```
echo "fs.file-max=131072" > /etc/sysctl.d/max.conf
sysctl -p
```

###

```
echo "* soft     nproc          90000" > /etc/security/limits.d/perf.conf
echo "* hard     nproc          90000" >> /etc/security/limits.d/perf.conf
echo "* soft     nofile         90000" >> /etc/security/limits.d/perf.conf
echo "* hard     nofile         90000"  >> /etc/security/limits.d/perf.conf
echo "root soft     nproc          90000" >> /etc/security/limits.d/perf.conf
echo "root hard     nproc          90000" >> /etc/security/limits.d/perf.conf
echo "root soft     nofile         90000" >> /etc/security/limits.d/perf.conf
echo "root hard     nofile         90000" >> /etc/security/limits.d/perf.conf
sed -i '/pam_limits.so/d' /etc/pam.d/sshd
echo "session    required   pam_limits.so" >> /etc/pam.d/sshd
sed -i '/pam_limits.so/d' /etc/pam.d/su
echo "session    required   pam_limits.so" >> /etc/pam.d/su
sed -i '/session required pam_limits.so/d' /etc/pam.d/common-session
echo "session required pam_limits.so" >> /etc/pam.d/common-session
sed -i '/session required pam_limits.so/d' /etc/pam.d/common-session-noninteractive
echo "session required pam_limits.so" >> /etc/pam.d/common-session-noninteractive
```


### The mappings of systemd limits to ulimit

```
Directive        ulimit equivalent     Unit
LimitCPU=        ulimit -t             Seconds
LimitFSIZE=      ulimit -f             Bytes
LimitDATA=       ulimit -d             Bytes
LimitSTACK=      ulimit -s             Bytes
LimitCORE=       ulimit -c             Bytes
LimitRSS=        ulimit -m             Bytes
LimitNOFILE=     ulimit -n             Number of File Descriptors
LimitAS=         ulimit -v             Bytes
LimitNPROC=      ulimit -u             Number of Processes
LimitMEMLOCK=    ulimit -l             Bytes
LimitLOCKS=      ulimit -x             Number of Locks
LimitSIGPENDING= ulimit -i             Number of Queued Signals
LimitMSGQUEUE=   ulimit -q             Bytes
LimitNICE=       ulimit -e             Nice Level
LimitRTPRIO=     ulimit -r             Realtime Priority
LimitRTTIME=     No equivalent
If a ulimit is set to 'unlimited' set it to 'infinity' in the systemd config

ulimit -c unlimited = LimitCORE=infinity
ulimit -v unlimited = LimitAS=infinity
ulimit -m unlimited = LimitRSS=infinity
```

### So a final config would look like

```
[Unit]
Description=Apache Solr
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
WorkingDirectory=/opt/solr/server
User=solr
Group=solr
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=65536
ExecStart=/opt/solr/bin/solr-foo
Restart=on-failure
SuccessExitStatus=143 0
SyslogIdentifier=solr


[Install]
WantedBy=multi-user.target
```
