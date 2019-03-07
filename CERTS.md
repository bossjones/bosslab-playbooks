* https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
* https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/

# kubeadmin ( on host )

*  - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
* - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
* - --root-ca-file=/etc/kubernetes/pki/ca.crt


# certs management


`/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`


# Current thought

* https://docs.cert-manager.io/en/latest/tasks/issuers/setup-ca.html

Let's grab the ca-key-pair kubeadm generated on the master host, upload it as a secret, and create an ClusterIssuer

scp MASTER:/etc/kubernetes/pki/ca.crt .
scp MASTER:/etc/kubernetes/pki/ca.crt .
