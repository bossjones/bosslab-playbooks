set -x

# docker run \
# 	--rm \
# 	-v `pwd`:`pwd` \
# 	--workdir `pwd` \
# 	po-jsonnet jb init


# docker run \
# 	--rm \
# 	-v `pwd`:`pwd` \
# 	--workdir `pwd` \
# 	po-jsonnet jb install github.com/coreos/prometheus-operator/contrib/kube-prometheus/jsonnet/kube-prometheus/@v0.27.0




docker run \
	--rm \
	-v `pwd`:`pwd` \
	--workdir `pwd` \
	po-jsonnet ./build.sh example.jsonnet
