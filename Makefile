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
URL_PATH_NETDATA_MASTER1  := "http://bosslab-master-01.$(DNSMASQ_DOMAIN):19999"
URL_PATH_NETDATA_WORKER1  := "http://bosslab-worker-01.$(DNSMASQ_DOMAIN):19999"
URL_PATH_NETDATA_WORKER2  := "http://bosslab-worker-02.$(DNSMASQ_DOMAIN):19999"
URL_PATH_NETDATA_PROXY1   := "http://bosslab-proxy-01.$(DNSMASQ_DOMAIN):19999"

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

# rsync -avz --dry-run --exclude 'README.md' --exclude '*.log' --exclude '.git' --exclude '.vscode' --exclude '.vagrant' --exclude '.gitignore' --exclude '.retry' ~/dev/bossjones/boss-ansible-homelab/.[^.]* ~/dev/bossjones/bosslab-playbooks
# rsync -avz --dry-run --exclude 'README.md' --exclude '*.log' --exclude '.git' --exclude '.vscode' --exclude '.vagrant'  ~/dev/bossjones/boss-ansible-homelab/{inventory-vagrant,inventory-homelab,decrypt_all.sh,encrypt_all.sh,vars,git_hooks,vault_password,group_vars} ~/dev/bossjones/bosslab-playbooks

# SOURCE: https://github.com/wk8838299/bullcoin/blob/8182e2f19c1f93c9578a2b66de6a9cce0506d1a7/LMN/src/makefile.osx
HAVE_BREW=$(shell brew --prefix >/dev/null 2>&1; echo $$? )

.PHONY: list help default all check fail-when-git-dirty

.PHONY: FORCE_MAKE

PR_SHA                := $(shell git rev-parse HEAD)

define ASCILOGO
bosslab-playbooks
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

list_allowed_args := product ip command role tier cluster

default: all

all: galaxy

check: all fail-when-git-dirty

fail-when-git-dirty:
	git diff --quiet && git diff --cached --quiet

galaxy: galaxy/requirements
	@echo 'You need to `git add` all files in order for this script to pick up the changes!'

galaxy/requirements: galaxy/requirements.yml

galaxy/requirements.yml: scripts/get_all_referenced_roles FORCE_MAKE
ifeq (${DETECTED_OS}, Darwin)
	"$<" | gsed --regexp-extended 's/^(.*)$$/- src: \1\n/' > "$@"
else
	"$<" | sed --regexp-extended 's/^(.*)$$/- src: \1\n/' > "$@"
endif

list:
	@$(MAKE) -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

download-roles:
	ansible-galaxy install -r galaxy/requirements.yml --roles-path ./roles/

download-roles-force:
	ansible-galaxy --force install -r galaxy/requirements.yml --roles-path ./roles/

download-roles-global:
	ansible-galaxy install -r galaxy/requirements.yml --roles-path=/etc/ansible/roles

download-roles-global-force:
	ansible-galaxy install --force -r galaxy/requirements.yml --roles-path=/etc/ansible/roles

raw:
	$(call check_defined, product, Please set product)
	$(call check_defined, command, Please set command)
	@ansible localhost -i inventory-$(product)/ ${PROXY_COMMAND} -m raw -a "$(command)" -f 10

get-ansible-modules:
	ansible-doc --list | peco

list-ansible-modules: get-ansible-modules

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

pre_commit_install:
	cp git_hooks/pre-commit .git/hooks/pre-commit

bootstrap:
	echo bootstrap

travis:
	tox

.PHONY: pip-tools
pip-tools:
ifeq (${DETECTED_OS}, Darwin)
	ARCHFLAGS="-arch x86_64" LDFLAGS="-L/usr/local/opt/openssl/lib" CFLAGS="-I/usr/local/opt/openssl/include" pip install pip-tools pipdeptree
else
	pip install pip-tools pipdeptree
endif


.PHONY: pip-tools-osx
pip-tools-osx: pip-tools

.PHONY: pip-tools-upgrade
pip-tools-upgrade:
ifeq (${DETECTED_OS}, Darwin)
	ARCHFLAGS="-arch x86_64" LDFLAGS="-L/usr/local/opt/openssl/lib" CFLAGS="-I/usr/local/opt/openssl/include" pip install pip-tools pipdeptree --upgrade
else
	pip install pip-tools pipdeptree --upgrade
endif


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

.PHONY: pip-compile-rebuild
pip-compile-rebuild: pip-tools
	pip-compile --rebuild --output-file requirements.txt requirements.in
	pip-compile --rebuild --output-file requirements-dev.txt requirements-dev.in
	pip-compile --rebuild --output-file requirements-test.txt requirements-test.in

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
	@ansible-playbook -i inventory.ini playbooks/vagrant_playbook.yml -v

run-ansible-nfs:
	@ansible-playbook -i inventory.ini playbooks/vagrant_nfs.yml -v

run-ansible-influxdb:
	@ansible-playbook -i inventory.ini playbooks/vagrant_influxdb_opentsdb.yml -v

run-ansible-list-tags:
	@ansible-playbook -i inventory.ini playbooks/vagrant_playbook.yml -v --list-tasks

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
	@ansible-playbook -i inventory.ini playbooks/vagrant_playbook.yml -v --tags docker-provision --flush-cache

run-ansible-master:
	@ansible-playbook -i inventory.ini vagrant_playbook.yml -v --tags primary_master

run-ansible-timezone:
	@ansible-playbook -i inventory.ini timezone.yml -v

converge: up run-ansible

ping:
	@ansible-playbook -v -i inventory.ini ping.yml -v

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

# pip install graphviz
graph-inventory:
	ansible-inventory-grapher -i inventory.ini -d static/graphs/bosslab --format "bosslab-{hostname}.dot" -a "rankdir=LR; splines=ortho; ranksep=2; node [ width=5 style=filled fillcolor=lightgrey ]; edge [ dir=back arrowtail=empty ];" bosslab-master-01.hyenalab.home
# for f in static/graphs/bosslab/*.dot ; do dot -Tpng -o static/graphs/bosslab/`basename $f .dot`.png $f; done

graph-inventory-view:
	ansible-inventory-grapher -i inventory.ini -d static/graphs/bosslab --format "bosslab-{hostname}.dot" -a "rankdir=LR; splines=ortho; ranksep=2; node [ width=5 style=filled fillcolor=lightgrey ]; edge [ dir=back arrowtail=empty ];" bosslab-master-01.hyenalab.home |prod-web-server-1a | dot -Tpng | display png:-

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

open-netdata-vagrant:
	./scripts/open-browser.py $(URL_PATH_NETDATA_MASTER1)
	./scripts/open-browser.py $(URL_PATH_NETDATA_WORKER1)
	./scripts/open-browser.py $(URL_PATH_NETDATA_WORKER2)
	./scripts/open-browser.py $(URL_PATH_NETDATA_PROXY1)

open: open-netdata-registry open-netdata-node

open-vagrant: open-netdata-vagrant

# # https://docs.debops.org/en/latest/ansible/roles/debops.core/getting-started.html
# # To see what facts are configured on a host, run command:
# ansible <hostname> -s -m setup -a 'filter=ansible_local'
# The list of Ansible Controller IP addresses is accessible as ansible_local.core.ansible_controllers for other roles to use as needed.
# https://github.com/debops/debops-playbooks

get-local-facts:
	@echo "To see what facts are configured on a host"
	ansible servers -i inventory.ini -s -m setup -a 'filter=ansible_local'


###########################################################
# Pyenv initilization - 12/23/2018 -- START
# SOURCE: https://github.com/MacHu-GWU/learn_datasette-project/blob/120b45363aa63bdffe2f1933cf2d4e20bb6cbdb8/make/python_env.mk
###########################################################

#--- User Defined Variable ---
PACKAGE_NAME="bosslab-playbooks"

# Python version Used for Development
PY_VER_MAJOR="2"
PY_VER_MINOR="7"
PY_VER_MICRO="14"

#  Other Python Version You Want to Test With
# (Only useful when you use tox locally)
# TEST_PY_VER3="3.4.6"
# TEST_PY_VER4="3.5.3"
# TEST_PY_VER5="3.6.2"

# If you use pyenv-virtualenv, set to "Y"
USE_PYENV="Y"

#--- Derive Other Variable ---

# Virtualenv Name
VENV_NAME="${PACKAGE_NAME}${PY_VER_MAJOR}"

# Project Root Directory
GIT_ROOT_DIR=${shell git rev-parse --show-toplevel}
PROJECT_ROOT_DIR=${shell pwd}

ifeq (${OS}, Windows_NT)
    DETECTED_OS := Windows
else
    DETECTED_OS := $(shell uname -s)
endif


# ---------

# Windows
ifeq (${DETECTED_OS}, Windows)
    USE_PYENV="N"

    VENV_DIR_REAL="${PROJECT_ROOT_DIR}/${VENV_NAME}"
    BIN_DIR="${VENV_DIR_REAL}/Scripts"
    SITE_PACKAGES="${VENV_DIR_REAL}/Lib/site-packages"
    SITE_PACKAGES64="${VENV_DIR_REAL}/Lib64/site-packages"

    GLOBAL_PYTHON="/c/Python${PY_VER_MAJOR}${PY_VER_MINOR}/python.exe"
    OPEN_COMMAND="start"
endif


# MacOS
ifeq (${DETECTED_OS}, Darwin)

ifeq ($(USE_PYENV), "Y")
    ARCHFLAGS="-arch x86_64"
    LDFLAGS="-L/usr/local/opt/openssl/lib"
    CFLAGS="-I/usr/local/opt/openssl/include"
    VENV_DIR_REAL="${HOME}/.pyenv/versions/${PY_VERSION}/envs/${VENV_NAME}"
    VENV_DIR_LINK="${HOME}/.pyenv/versions/${VENV_NAME}"
    BIN_DIR="${VENV_DIR_REAL}/bin"
    SITE_PACKAGES="${VENV_DIR_REAL}/lib/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"
    SITE_PACKAGES64="${VENV_DIR_REAL}/lib64/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"
else
    ARCHFLAGS="-arch x86_64"
    LDFLAGS="-L/usr/local/opt/openssl/lib"
    CFLAGS="-I/usr/local/opt/openssl/include"
    VENV_DIR_REAL="${PROJECT_ROOT_DIR}/${VENV_NAME}"
    VENV_DIR_LINK="./${VENV_NAME}"
    BIN_DIR="${VENV_DIR_REAL}/bin"
    SITE_PACKAGES="${VENV_DIR_REAL}/lib/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"
    SITE_PACKAGES64="${VENV_DIR_REAL}/lib64/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"
endif
    ARCHFLAGS="-arch x86_64"
    LDFLAGS="-L/usr/local/opt/openssl/lib"
    CFLAGS="-I/usr/local/opt/openssl/include"

    GLOBAL_PYTHON="python${PY_VER_MAJOR}.${PY_VER_MINOR}"
    OPEN_COMMAND="open"
endif


# Linux
ifeq (${DETECTED_OS}, Linux)
    USE_PYENV="N"

    VENV_DIR_REAL="${PROJECT_ROOT_DIR}/${VENV_NAME}"
    VENV_DIR_LINK="${PROJECT_ROOT_DIR}/${VENV_NAME}"
    BIN_DIR="${VENV_DIR_REAL}/bin"
    SITE_PACKAGES="${VENV_DIR_REAL}/lib/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"
    SITE_PACKAGES64="${VENV_DIR_REAL}/lib64/python${PY_VER_MAJOR}.${PY_VER_MINOR}/site-packages"

    GLOBAL_PYTHON="python${PY_VER_MAJOR}.${PY_VER_MINOR}"
    OPEN_COMMAND="open"
endif


BASH_PROFILE_FILE = "${HOME}/.bash_profile"

BIN_ACTIVATE="${BIN_DIR}/activate"
BIN_PYTHON="${BIN_DIR}/python"
BIN_PIP="${BIN_DIR}/pip"
BIN_ISORT="${BIN_DIR}/isort"
BIN_JINJA="${BIN_DIR}/jinja2"

PY_VERSION="${PY_VER_MAJOR}.${PY_VER_MINOR}.${PY_VER_MICRO}"

.PHONY: help
help: ## ** Show this help message
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#--- Make Commands ---
.PHONY: info
info: ## ** Show information about python, pip in this environment
	@printf "Info:\n"
	@printf "=======================================\n"
	@printf "$$GREEN venv:$$NC                               ${VENV_DIR_REAL}\n"
	@printf "$$GREEN python executable:$$NC                  ${BIN_PYTHON}\n"
	@printf "$$GREEN pip executable:$$NC                     ${BIN_PIP}\n"
	@printf "$$GREEN site-packages:$$NC                      ${SITE_PACKAGES}\n"
	@printf "$$GREEN site-packages64:$$NC                    ${SITE_PACKAGES64}\n"
	@printf "$$GREEN venv-dir-real:$$NC                      ${VENV_DIR_REAL}\n"
	@printf "$$GREEN venv-dir-link:$$NC                      ${VENV_DIR_LINK}\n"
	@printf "$$GREEN venv-bin-dir:$$NC                       ${BIN_DIR}\n"
	@printf "$$GREEN bash-profile-file:$$NC                  ${BASH_PROFILE_FILE}\n"
	@printf "$$GREEN bash-activate:$$NC                      ${BIN_ACTIVATE}\n"
	@printf "$$GREEN bin-python:$$NC                         ${BIN_PYTHON}\n"
	@printf "$$GREEN bin-isort:$$NC                          ${BIN_ISORT}\n"
	@printf "$$GREEN py-version:$$NC                         ${PY_VERSION}\n"
	@printf "$$GREEN use-pyenv:$$NC                          ${USE_PYENV}\n"
	@printf "$$GREEN venv-name:$$NC                          ${VENV_NAME}\n"
	@printf "$$GREEN git-root-dir:$$NC                       ${GIT_ROOT_DIR}\n"
	@printf "$$GREEN project-root-dir:$$NC                   ${PROJECT_ROOT_DIR}\n"
	@printf "$$GREEN brew-is-installed:$$NC                  ${HAVE_BREW}\n"
	@printf "\n"

#--- Virtualenv ---
.PHONY: brew_install_pyenv
brew_install_pyenv: ## ** Install pyenv and pyenv-virtualenv
	-brew install pyenv
	-brew install pyenv-virtualenv

.PHONY: setup_pyenv
setup_pyenv: brew_install_pyenv enable_pyenv ## ** Do some pre-setup for pyenv and pyenv-virtualenv
	pyenv install ${PY_VERSION} -s
	pyenv rehash

.PHONY: bootstrap_venv
bootstrap_venv: pre_commit_install init_venv dev_dep show_venv_activate_cmd ## ** Create virtual environment, initialize it, install packages, and remind user to activate after make is done
# bootstrap_venv: init_venv dev_dep ## ** Create virtual environment, initialize it, install packages, and remind user to activate after make is done

.PHONY: init_venv
init_venv: ## ** Initiate Virtual Environment
ifeq (${USE_PYENV}, "Y")
	# Install pyenv
	#-brew install pyenv
	#-brew install pyenv-virtualenv

	# # Edit Config File
	# if ! grep -q 'export PYENV_ROOT="$$HOME/.pyenv"' "${BASH_PROFILE_FILE}" ; then\
	#     echo 'export PYENV_ROOT="$$HOME/.pyenv"' >> "${BASH_PROFILE_FILE}" ;\
	# fi
	# if ! grep -q 'export PATH="$$PYENV_ROOT/bin:$$PATH"' "${BASH_PROFILE_FILE}" ; then\
	#     echo 'export PATH="$$PYENV_ROOT/bin:$$PATH"' >> "${BASH_PROFILE_FILE}" ;\
	# fi
	# if ! grep -q 'eval "$$(pyenv init -)"' "${BASH_PROFILE_FILE}" ; then\
	#     echo 'eval "$$(pyenv init -)"' >> "${BASH_PROFILE_FILE}" ;\
	# fi
	# if ! grep -q 'eval "$$(pyenv virtualenv-init -)"' "${BASH_PROFILE_FILE}" ; then\
	#     echo 'eval "$$(pyenv virtualenv-init -)"' >> "${BASH_PROFILE_FILE}" ;\
	# fi

	# pyenv install ${PY_VERSION} -s
	# pyenv rehash

	-pyenv virtualenv ${PY_VERSION} ${VENV_NAME}
	@printf "FINISHED:\n"
	@printf "=======================================\n"
	@printf "$$GREEN Run to activate virtualenv:$$NC                               pyenv activate ${VENV_NAME}\n"
else

ifeq ($(HAVE_BREW), 0)
	DEPSDIR='ARCHFLAGS="-arch x86_64" LDFLAGS="-L/usr/local/opt/openssl/lib" CFLAGS="-I/usr/local/opt/openssl/include"'
	$(DEPSDIR) virtualenv -p ${GLOBAL_PYTHON} ${VENV_NAME}
endif

	virtualenv -p ${GLOBAL_PYTHON} ${VENV_NAME}
endif


.PHONY: up
up: init_venv ## ** Set Up the Virtual Environment


.PHONY: clean_venv
clean_venv: ## ** Clean Up Virtual Environment
ifeq (${USE_PYENV}, "Y")
	-pyenv uninstall -f ${VENV_NAME}
else
	test -r ${VENV_DIR_REAL} || echo "DIR exists: ${VENV_DIR_REAL}" || rm -rv ${VENV_DIR_REAL}
endif


#--- Install ---

.PHONY: uninstall
uninstall: ## ** Uninstall This Package
	# -${BIN_PIP} uninstall -y ${PACKAGE_NAME}
	-${BIN_PIP} uninstall -y requirements.txt

.PHONY: install
# install: uninstall ## ** Install This Package via setup.py
install: ## ** Install This Package via setup.py
ifeq ($(HAVE_BREW), 0)
	DEPSDIR='ARCHFLAGS="-arch x86_64" LDFLAGS="-L/usr/local/opt/openssl/lib" CFLAGS="-I/usr/local/opt/openssl/include"'
	$(DEPSDIR) ${BIN_PIP} install -r requirements.txt
else
	${BIN_PIP} install -r requirements.txt
endif


.PHONY: dev_dep
dev_dep: ## ** Install Development Dependencies

ifeq ($(HAVE_BREW), 0)
	( \
		cd ${PROJECT_ROOT_DIR}; \
		ARCHFLAGS="-arch x86_64" LDFLAGS="-L/usr/local/opt/openssl/lib" CFLAGS="-I/usr/local/opt/openssl/include" ${BIN_PIP} install -r requirements.txt; \
	)
else
	( \
		cd ${PROJECT_ROOT_DIR}; \
		${BIN_PIP} install -r requirements.txt; \
	)
endif


.PHONY: show_venv_activate_cmd
show_venv_activate_cmd: ## ** Show activate command when finished
	@printf "Don't forget to run this activate your new virtualenv:\n"
	@printf "=======================================\n"
	@echo
	@printf "$$GREEN pyenv activate $(VENV_NAME)$$NC\n"
	@echo
	@printf "=======================================\n"

# Frequently used make command:
#
# - make up
# - make clean
# - make install
# - make test
# - make tox
# - make build_doc
# - make view_doc
# - make deploy_doc
# - make reformat
# - make publish

###########################################################
# Pyenv initilization - 12/23/2018 -- END
# SOURCE: https://github.com/MacHu-GWU/learn_datasette-project/blob/120b45363aa63bdffe2f1933cf2d4e20bb6cbdb8/make/python_env.mk
###########################################################

borg-inventory-ini-to-yaml:
	@scripts/ini2yaml <${PROJECT_ROOT_DIR}/contrib/inventory_builder/inventory/borg/inventory.ini >${PROJECT_ROOT_DIR}/contrib/inventory_builder/cluster_configs/borg.yaml
	@cat ${PROJECT_ROOT_DIR}/contrib/inventory_builder/cluster_configs/borg.yaml | highlight

borg-kube-facts:
	env ANSIBLE_STRATEGY=debug KUBECONFIG=~/dev/bossjones/kubernetes-cluster/borg-admin.conf ansible-playbook -v -i contrib/inventory_builder/inventory/borg/inventory.ini get_k8_facts.yml -v

run-ansible-describe-borg-cluster:
	env ANSIBLE_STRATEGY=debug KUBECONFIG=~/dev/bossjones/kubernetes-cluster/borg-admin.conf ansible-playbook  -i contrib/inventory_builder/inventory/borg/inventory.ini playbooks/describe_k8_cluster.yml -vvvvvv

run-ansible-module-kube-facts-pdb:
	python -m pdb ./library/kube_facts.py ./test-kube-facts-args.json

run-ansible-module-kube-facts:
	python ./library/kube_facts.py ./test-kube-facts-args.json | jq


generate-ssh-config:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/generate_ssh_config.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest-echoserver:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_echoserver.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest-calico:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_calico.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest-dashboard:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_dashboard.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"


render-manifest-dashboard-admin:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_dashboard_admin.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest-efk:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_efk.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"


render-manifest-registry:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_registry.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest-registry-ui:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_registry_ui.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest-registry-all:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_registry.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_registry_ui.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest-cert-manager:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_cert_manager.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest-jenkins:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_jenkins.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"


render-manifest-heapster2:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_heapster2.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"


render-manifest-metrics-server:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_metrics_server.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	@echo 'FIXME: USE THIS GUY HERE - https://github.com/kubernetes-incubator/metrics-server/issues/77'
	@echo 'FIXME: USE THIS GUY HERE - https://github.com/kubernetes-incubator/metrics-server/issues/77'
	@echo 'FIXME: USE THIS GUY HERE - https://github.com/kubernetes-incubator/metrics-server/issues/77'
	@echo 'FIXME: USE THIS GUY HERE - https://github.com/kubernetes-incubator/metrics-server/issues/77'
	@echo 'FIXME: USE THIS GUY HERE - https://github.com/kubernetes-incubator/metrics-server/issues/77'
	@echo 'FIXME: USE THIS GUY HERE - https://github.com/kubernetes-incubator/metrics-server/issues/77'


render-manifest-external-dns:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_external_dns.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

render-manifest:
	$(call check_defined, cluster, Please set cluster)
	ansible-playbook -c local -vvvvv playbooks/render_echoserver.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_calico.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_dashboard.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_dashboard_admin.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_efk.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_registry.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_cert_manager.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_registry_ui.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_jenkins.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_heapster2.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"
	ansible-playbook -c local -vvvvv playbooks/render_metrics_server.yaml -i contrib/inventory_builder/inventory/$(cluster)/inventory.ini --extra-vars "cluster=$(cluster)" --skip-tags "pause"

tmp-shell-default:
	kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash

tmp-shell-kube-system:
	kubectl -n kube-system run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash

tmp-shell-monitoring:
	kubectl -n monitoring run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash

zsh-tmp-shell-default:
	kubectl run zsh-tmp-shell --rm -i --tty --image bossjones/k8s-zsh-debugger -- /bin/zsh

zsh-tmp-shell-kube-system:
	kubectl -n kube-system run zsh-tmp-shell --rm -i --tty --image bossjones/k8s-zsh-debugger -- /bin/zsh

zsh-tmp-shell-monitoring:
	kubectl -n monitoring run zsh-tmp-shell --rm -i --tty --image bossjones/k8s-zsh-debugger -- /bin/zsh

# bossjones/k8s-zsh-debugger:

# SOURCE: https://stackoverflow.com/questions/46419163/what-will-happen-to-evicted-pods-in-kubernetes
delete-evicted-pods:
	kubectl get po -a --all-namespaces -o json | jq  '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | "kubectl delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 bash -c

include *.mk
