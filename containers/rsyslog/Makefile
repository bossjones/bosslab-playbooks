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


username := bossjones
container_name := rsyslog

GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION     ?= $(shell grep "alpine:3.7" Dockerfile | head -1 | cut -d":" -f2)

TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

bash:
	docker run \
	-it \
	--rm \
	--name rsyslog.bash \
	-w /home/appliance \
	-h $(shell hostname) \
	-v /etc/localtime:/etc/localtime:ro \
	-p "514:514" \
	-p "514:514/udp" \
	-p "1601:1601" \
	-e "_IMTCP_PORT=5140" \
	-e "_IMUDP=5140" \
	-e "_IMRELP_PORT=1601" \
	--entrypoint "/bin/bash" \
	$(username)/$(container_name):latest \
	-l

run:
	docker run \
	-it \
	--rm \
	--name rsyslog.service \
	-w /home/appliance \
	-v /etc/localtime:/etc/localtime:ro \
	-p "514:514" \
	-p "514:514/udp" \
	-p "1601:1601" \
	-e "_IMTCP_PORT=5140" \
	-e "_IMUDP=5140" \
	-e "_IMRELP_PORT=1601" \
	-h $(shell hostname) \
	$(username)/$(container_name):latest

build:
	docker build \
	--build-arg VCS_REF=$(GIT_SHA) \
	--build-arg BUILD_DATE=$(VERSION) \
	--build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') \
	--tag $(username)/$(container_name):$(GIT_SHA) .

build-force:
	docker build --rm \
	--force-rm \
	--pull \
	--no-cache \
	-t $(username)/$(container_name):$(GIT_SHA) .

build-tag: build tag

tag:
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

build-push: build tag
	docker push $(username)/$(container_name):latest
	docker push $(username)/$(container_name):$(GIT_SHA)
	docker push $(username)/$(container_name):$(TAG)

build-push-version: build tag
	docker push $(username)/$(container_name):$(TAG)

build-push-version-force: build-force tag
	docker push $(username)/$(container_name):$(TAG)

build-push-version-dump: build tag
	echo docker push $(username)/$(container_name):$(TAG)

push:
	docker push $(username)/$(container_name):latest
	docker push $(username)/$(container_name):$(GIT_SHA)
	docker push $(username)/$(container_name):$(TAG)

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
