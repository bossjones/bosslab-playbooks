# SOURCE: https://github.com/zaftzaft/prometheus_install_scripts/blob/993248ddf4dd929c6b0b43c3f5dd309f0159ea94/install_node_exporter.sh

v={{boss__prometheus__operator__node_exporter_version}}

version=$v
file=node_exporter-${v}.linux-amd64
service=node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/${version}/${file}.tar.gz \
  -O /tmp/$file.tar.gz


systemctl is-enabled $service
if [ $? -eq 0 ]; then
  systemctl stop $service
fi


cd /tmp
tar xvf /tmp/$file.tar.gz

cp /tmp/$file/node_exporter /usr/local/bin/node_exporter

if [ -d /usr/lib/systemd/system/ ]; then
  unit_dir=/usr/lib/systemd/system
else
  unit_dir=/etc/systemd/system
fi


tee ${unit_dir}/${service}.service << EOS
[Unit]
Description=Node Exporter

[Service]
ExecStart=/usr/local/bin/node_exporter  --collector.textfile.directory="/tmp/node_exporter"
Restart=always

[Install]
WantedBy=default.target
EOS


systemctl daemon-reload
systemctl enable $service
systemctl start $service


cd -

