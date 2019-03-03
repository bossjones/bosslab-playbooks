v=0.13.0


version=$v
file=snmp_exporter-$v.linux-amd64
service=snmp_exporter


wget https://github.com/prometheus/snmp_exporter/releases/download/$version/$file.tar.gz \
  -O /tmp/$file.tar.gz

systemctl is-enabled $service
if [ $? -eq 0 ]; then
  systemctl stop $service
fi

cd /tmp
tar xvf /tmp/$file.tar.gz

cp /tmp/$file/snmp_exporter /usr/local/bin/snmp_exporter

if [ -d /usr/lib/systemd/system/ ]; then
  unit_dir=/usr/lib/systemd/system
else
  unit_dir=/etc/systemd/system
fi


tee ${unit_dir}/${service}.service << EOS
[Unit]
Description=SNMP Exporter

[Service]
Restart=always
ExecStart=/usr/local/bin/snmp_exporter --config.file /etc/prometheus/snmp.yml

[Install]
WantedBy=default.target
EOS


systemctl daemon-reload
systemctl enable snmp_exporter
systemctl start snmp_exporter

cd -

