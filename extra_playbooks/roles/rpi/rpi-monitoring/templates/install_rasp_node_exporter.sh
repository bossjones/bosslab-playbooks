version={{boss__prometheus__operator__node_exporter_version}}

uname -m | grep v7
if [ $? -eq 0 ]; then
  file=node_exporter-{{boss__prometheus__operator__node_exporter_version | regex_replace('^v','') }}.linux-armv7
else
  file=node_exporter-{{boss__prometheus__operator__node_exporter_version | regex_replace('^v','') }}.linux-armv6
fi


wget https://github.com/prometheus/node_exporter/releases/download/$version/$file.tar.gz \
  -O /tmp/$file.tar.gz

cd /tmp
tar xvf /tmp/$file.tar.gz

cp -a /tmp/$file/node_exporter /usr/local/bin/node_exporter
# TimeoutStartSec

mkdir -p /usr/lib/systemd/system/
tee /usr/lib/systemd/system/node_exporter.service << EOS
[Unit]
Description=Node Exporter
After=local-fs.target network-online.target network.target
Wants=local-fs.target network-online.target network.target

[Service]
# ExecStart=/usr/local/bin/node_exporter  --collector.textfile.directory="/tmp/node_exporter"
ExecStart=/usr/local/bin/node_exporter --web.listen-address=0.0.0.0:9100 --path.procfs=/proc --path.sysfs=/sys --collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/) --collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$
Restart=on-failure


[Install]
WantedBy=default.target
EOS


systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

cd -

