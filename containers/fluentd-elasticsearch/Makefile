# # Copyright 2017 The Kubernetes Authors.
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #     http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.

# .PHONY:	build push

# PREFIX = staging-k8s.gcr.io
# IMAGE = fluentd-elasticsearch
# TAG = v2.0.4

# build:
# 	docker build --pull -t $(PREFIX)/$(IMAGE):$(TAG) .

# push:
# 	docker push $(PREFIX)/$(IMAGE):$(TAG)

# possibilities to grep from
# image: image: k8s.gcr.io/fluentd-elasticsearch:v2.2.0
# image: gcr.io/google-containers/fluentd-elasticsearch:v2.0.1


username := bossjones
container_name := fluentd-elasticsearch

GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION  ?= $(shell grep "k8s.gcr.io/fluentd-elasticsearch" Dockerfile | head -1 | cut -d":" -f2)

TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

bash:
	docker run \
	-it \
	--rm \
	--name fluentd.bash \
	-h $(shell hostname) \
	-v /etc/localtime:/etc/localtime:ro \
	-p "5140:5140" \
	-p "5140:5140/udp" \
	-p "5160:5160" \
	-p "5160:5160/udp" \
	-p "5170:5170" \
	-p "24231:24231" \
	-p "24220:24220" \
	--entrypoint "/bin/bash" \
	$(username)/$(container_name):latest \
	-l

run:
	docker run \
	-it \
	--rm \
	--name fluentd.service \
	-w /home/appliance \
	-v /etc/localtime:/etc/localtime:ro \
	-p "5140:5140" \
	-p "5140:5140/udp" \
	-p "5160:5160" \
	-p "5160:5160/udp" \
	-p "5170:5170" \
	-p "24231:24231" \
	-p "24220:24220" \
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
