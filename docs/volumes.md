# Volumes
https://akomljen.com/kubernetes-persistent-volumes-with-deployment-and-statefulset/

To have persistence in Kuberntes, you need to create a Persistent Volume Claim or PVC which is later consumed by a pod. Also, you can get confused here because there is also a Persistent Volume or PV. If you have a default Storage Class or you specify which storage class to use when creating a PVC, PV creation is automatic. PV holds information about physical storage. PVC is just a request for PV. Another way and less desirable is to create a PV manually and attach PVC to it, skipping storage class altogether.
