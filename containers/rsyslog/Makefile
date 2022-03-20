# .PHONY:	build push

# PREFIX = staging-k8s.gcr.io
# IMAGE = rsyslog
# TAG = v2.0.4

# build:
# 	docker build --pull -t $(PREFIX)/$(IMAGE):$(TAG) .

# push:
# 	docker push $(PREFIX)/$(IMAGE):$(TAG)

# possibilities to grep from
# image: image: k8s.gcr.io/rsyslog:v2.2.0
# image: gcr.io/google-containers/rsyslog:v2.0.1


username := index.docker.io/bossjones
container_name := rsyslog

GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION     ?= $(shell grep "alpine:3.15.1" Dockerfile | head -1 | cut -d":" -f2)

TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

bash:
	DOCKER_BUILDKIT=1 docker run \
	-it \
	--rm \
	--name rsyslog.bash \
	-w / \
	-h $(shell hostname) \
	-v /etc/localtime:/etc/localtime:ro \
	-p "5140:5140" \
	-p "5140:5140/udp" \
	-p "1601:1601" \
	-e "_IMTCP_PORT=5140" \
	-e "_IMUDP_PORT=5140" \
	-e "_IMRELP_PORT=1601" \
	--entrypoint "/bin/bash" \
	$(username)/$(container_name):$(TAG) \
	-l

run:
	DOCKER_BUILDKIT=1 docker run \
	-it \
	--rm \
	--name rsyslog.service \
	-w / \
	-v /etc/localtime:/etc/localtime:ro \
	-p "5140:5140" \
	-p "5140:5140/udp" \
	-p "1601:1601" \
	-e "_IMTCP_PORT=5140" \
	-e "_IMUDP_PORT=5140" \
	-e "_IMRELP_PORT=1601" \
	-h $(shell hostname) \
	$(username)/$(container_name):$(TAG)

build:
	DOCKER_BUILDKIT=1 docker buildx build \
	--build-arg VCS_REF=$(GIT_SHA) \
	--build-arg BUILD_DATE=$(VERSION) \
	--build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') \
	--tag $(username)/$(container_name):$(GIT_SHA) .
	DOCKER_BUILDKIT=1 docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	DOCKER_BUILDKIT=1 docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

build-force:
	DOCKER_BUILDKIT=1 docker buildx build --rm \
	--force-rm \
	--pull \
	--no-cache \
	-t $(username)/$(container_name):$(GIT_SHA) .

build-tag: build tag

tag:
	DOCKER_BUILDKIT=1 docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	DOCKER_BUILDKIT=1 docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

build-push: build tag
	DOCKER_BUILDKIT=1 docker push $(username)/$(container_name):latest
	DOCKER_BUILDKIT=1 docker push $(username)/$(container_name):$(GIT_SHA)
	DOCKER_BUILDKIT=1 docker push $(username)/$(container_name):$(TAG)

build-push-version: build tag
	DOCKER_BUILDKIT=1 docker push $(username)/$(container_name):$(TAG)

build-push-version-force: build-force tag
	DOCKER_BUILDKIT=1 docker push $(username)/$(container_name):$(TAG)

build-push-version-dump: build tag
	echo docker push $(username)/$(container_name):$(TAG)

push:
	DOCKER_BUILDKIT=1 docker push $(username)/$(container_name):latest
	DOCKER_BUILDKIT=1 docker push $(username)/$(container_name):$(GIT_SHA)
	DOCKER_BUILDKIT=1 docker push $(username)/$(container_name):$(TAG)

push-force: build-force push

dc-up:
	docker-compose up

dc-build:
	docker-compose build

dc-stop:
	docker-compose stop

dc-pull:
	docker-compose pull

cleanup:
	bash scripts/cleanup-docker
