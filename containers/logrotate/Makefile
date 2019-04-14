username := bossjones
container_name := logrotate

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
	--name logrotate.bash \
	-h $(shell hostname) \
	-v /etc/localtime:/etc/localtime:ro \
	--entrypoint "/bin/bash" \
	$(username)/$(container_name):latest \
	-l

run:
	docker run \
	-it \
	--rm \
	--name logrotate.service \
	-v /etc/localtime:/etc/localtime:ro \
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
