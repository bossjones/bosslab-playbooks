# SOURCE: https://github.com/autopilotpattern/jenkins/blob/master/makefile
MAKEFLAGS += --warn-undefined-variables
# .SHELLFLAGS := -eu -o pipefail

DNSMASQ_DOMAIN         := hyenalab.home
# URL_PATH_MONGO_EXPRESS := 8081
# URL_PATH_FLASK_APP     := 8888
# URL_PATH_UWSGI_STATS   := 9191
# URL_PATH_LOCUST_MASTER := 8089
# URL_PATH_CONSUL        := 8500
# URL_PATH_TRAEFIK       := 80
# URL_PATH_TRAEFIK_API   := 8080
URL_PATH_NETDATA_REGISTRY  := "http://rsyslogd-master-01.$(DNSMASQ_DOMAIN):19999"
URL_PATH_NETDATA_NODE      := "http://rsyslogd-worker-01.$(DNSMASQ_DOMAIN):19999"
URL_PATH_WHOAMI            := "http://whoami.$(DNSMASQ_DOMAIN)"
URL_PATH_ECHOSERVER        := "http://echoserver.$(DNSMASQ_DOMAIN)"
URL_PATH_ELASTICSEARCH     := "http://elasticsearch.$(DNSMASQ_DOMAIN)"
URL_PATH_KIBANA            := "http://kibana.$(DNSMASQ_DOMAIN)"
URL_PATH_PROMETHEUS        := "http://prometheus.$(DNSMASQ_DOMAIN)"
URL_PATH_GRAFANA           := "http://grafana.$(DNSMASQ_DOMAIN)"
URL_PATH_ALERTMANAGER      := "http://alertmanager.$(DNSMASQ_DOMAIN)"
URL_PATH_DASHBOARD         := "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

.PHONY: list help

PR_SHA                := $(shell git rev-parse HEAD)

define ASCILOGO
boss-ansible-role-rsyslogd
=======================================
endef

export ASCILOGO

# http://misc.flogisoft.com/bash/tip_colors_and_formatting

RED=\033[0;31m
GREEN=\033[0;32m
ORNG=\033[38;5;214m
BLUE=\033[38;5;81m
NC=\033[0m

export RED
export GREEN
export NC
export ORNG
export BLUE

# verify that certain variables have been defined off the bat
check_defined = \
    $(foreach 1,$1,$(__check_defined))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $(value 2), ($(strip $2)))))


export PATH := ./venv/bin:$(PATH)

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
MAKE := make

list_allowed_args := product ip command role tier

help:
	@printf "\033[1m$$ASCILOGO $$NC\n"
	@printf "\033[21m\n\n"
	@printf "=======================================\n"
	@printf "\n"

list:
	@$(MAKE) -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

download-roles:
	ansible-galaxy install -r requirements.yml --roles-path ./roles/

download-roles-global:
	ansible-galaxy install -r requirements.yml --roles-path=/etc/ansible/roles

download-roles-global-force:
	ansible-galaxy install --force -r requirements.yml --roles-path=/etc/ansible/roles

raw:
	$(call check_defined, product, Please set product)
	$(call check_defined, command, Please set command)
	@ansible localhost -i inventory-$(product)/ ${PROXY_COMMAND} -m raw -a "$(command)" -f 10

# Compile python modules against homebrew openssl. The homebrew version provides a modern alternative to the one that comes packaged with OS X by default.
# OS X's older openssl version will fail against certain python modules, namely "cryptography"
# Taken from this git issue pyca/cryptography#2692
install-virtualenv-osx:
	ARCHFLAGS="-arch x86_64" LDFLAGS="-L/usr/local/opt/openssl/lib" CFLAGS="-I/usr/local/opt/openssl/include" pip install -r requirements.txt

docker-run:
	@virtualization/docker/docker-run.sh

molecule-destroy:
	molecule destroy

install-cidr-brew:
	pip install cidr-brewer

install-test-deps-pre:
	pip install docker-py
	pip install molecule --pre

install-test-deps:
	pip install docker-py
	pip install molecule

ci:
	molecule test

test:
	molecule test --destroy=always

bootstrap:
	echo bootstrap

travis:
	tox

pip-tools-osx:
	ARCHFLAGS="-arch x86_64" LDFLAGS="-L/usr/local/opt/openssl/lib" CFLAGS="-I/usr/local/opt/openssl/include" pip install pip-tools pipdeptree

pip-tools:
	pip install pip-tools pipdeptree

.PHONY: pip-compile-upgrade-all
pip-compile-upgrade-all: pip-tools
	pip-compile --output-file requirements.txt requirements.in --upgrade
	pip-compile --output-file requirements-dev.txt requirements-dev.in --upgrade
	pip-compile --output-file requirements-test.txt requirements-test.in --upgrade

.PHONY: pip-compile
pip-compile: pip-tools
	pip-compile --output-file requirements.txt requirements.in
	pip-compile --output-file requirements-dev.txt requirements-dev.in
	pip-compile --output-file requirements-test.txt requirements-test.in

.PHONY: install-deps-all
install-deps-all:
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

provision:
	@bash ./scripts/up.sh
	vagrant sandbox commit
	vagrant reload
	ansible-playbook -i inventory.ini vagrant_playbook.yml -v

up:
	@bash ./scripts/up.sh

rollback:
	@bash ./scripts/rollback.sh

commit:
	vagrant sandbox commit

reload:
	@vagrant reload

destroy:
	@vagrant halt -f
	@vagrant destroy -f

run-ansible:
	@ansible-playbook -i inventory.ini vagrant_playbook.yml -v

run-ansible-rsyslogd:
	@ansible-playbook -i inventory.ini rsyslogd_playbook.yml -v

run-ansible-etckeeper:
	@ansible-playbook -i inventory.ini vagrant_playbook.yml -v -f 10 --tags etckeeper

run-ansible-rvm:
	@ansible-playbook -i inventory.ini vagrant_playbook.yml -v -f 10 --tags 'ruby'

run-ansible-ruby: run-ansible-rvm

# For performance tuning/measuring
run-ansible-netdata:
	@ansible-playbook -i inventory.ini netdata.yml -v

# For performance tuning/measuring
run-ansible-tuning:
	@ansible-playbook -i inventory.ini tuning.yml -v

run-ansible-perf: run-ansible-tuning

run-ansible-tools:
	@ansible-playbook -i inventory.ini tools.yml -v -f 10

run-ansible-goss:
	@ansible-playbook -i inventory.ini tools.yml -v -f 10 --tags goss

run-ansible-docker:
	@ansible-playbook -i inventory.ini vagrant_playbook.yml -v --tags docker-provision --flush-cache

run-ansible-master:
	@ansible-playbook -i inventory.ini vagrant_playbook.yml -v --tags primary_master

run-ansible-timezone:
	@ansible-playbook -i inventory.ini timezone.yml -v

converge: up run-ansible

ping:
	@ansible-playbook -v -i inventory.ini ping.yml -vvvvv

ansible-run-dynamic-debug:
	@ansible-playbook -v -i inventory.ini dynamic_vars.yml

# [ANSIBLE0013] Use shell only when shell functionality is required
ansible-lint-role:
	bash -c "find .* -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 ansible-lint -x ANSIBLE0006,ANSIBLE0007,ANSIBLE0010,ANSIBLE0013 FILE"

yamllint-role:
	bash -c "find .* -type f -name '*.y*ml' ! -name '*.venv' -print0 | xargs -I FILE -t -0 -n1 yamllint FILE"

install-ip-cmd-osx:
	brew install iproute2mac

flush-cache:
	@sudo killall -HUP mDNSResponder

bridge-up:
	./vagrant_bridged_demo.sh --full --bridged_adapter auto

bridge-restart:
	./vagrant_bridged_demo.sh --restart

bridge-start:
	./vagrant_bridged_demo.sh --start

bridge-halt:
	vagrant halt

ssh-bridge-master:
	ssh -vvvv -F ./ssh_config rsyslogd-master-01.scarlettlab.home

ssh-bridge-worker:
	ssh -vvvv -F ./ssh_config rsyslogd-worker-01.scarlettlab.home

ping-bridge:
	@ansible-playbook -v -i hosts ping.yml

run-bridge-ansible:
	@ansible-playbook -i hosts vagrant_playbook.yml -v

run-bridge-test-ansible:
	@ansible-playbook -i hosts test.yml -v

run-bridge-tools-ansible:
	@ansible-playbook -i hosts tools.yml -v

run-bridge-ping-ansible:
	@ansible-playbook -i hosts ping.yml -v

run-bridge-log-iptables-ansible:
	@ansible-playbook -i hosts log_iptables.yml -v

run-bridge-ansible-no-slow:
	@ansible-playbook -i hosts vagrant_playbook.yml -v --skip-tags "slow"

run-bridge-debug-ansible:
	@ansible-playbook -i hosts debug.yml -v

dummy-web-server:
	python dummy-web-server.py

rebuild: destroy flush-cache bridge-up sleep ping-bridge run-bridge-ansible run-bridge-tools-ansible

# nvm-install:
# 	nvm install stable ;
# 	nvm use stable ;
# 	npm install npm@latest -g ;
# 	npm install -g docker-loghose ;
# 	npm install -g docker-enter ;

# hostnames-pod:
# 	kubectl run hostnames --image=k8s.gcr.io/serve_hostname \
# 	--labels=app=hostnames \
#     --port=9376 \
#     --replicas=3 ; \
# 	kubectl get pods -l app=hostnames ; \
# 	kubectl expose deployment hostnames --port=80 --target-port=9376 ; \

pip-install-pygments:
	pip install Pygments



open-netdata-registry:
	./scripts/open-browser.py $(URL_PATH_NETDATA_REGISTRY)

open-netdata-node:
	./scripts/open-browser.py $(URL_PATH_NETDATA_NODE)

open: open-netdata-registry open-netdata-node

# # https://docs.debops.org/en/latest/ansible/roles/debops.core/getting-started.html
# # To see what facts are configured on a host, run command:
# ansible <hostname> -s -m setup -a 'filter=ansible_local'
# The list of Ansible Controller IP addresses is accessible as ansible_local.core.ansible_controllers for other roles to use as needed.
# https://github.com/debops/debops-playbooks

get-local-facts:
	@echo "To see what facts are configured on a host"
	ansible servers -i inventory.ini -s -m setup -a 'filter=ansible_local'
