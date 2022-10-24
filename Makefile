.PHONY: setup test

TAG ?= 2.4.0

init: init-racetrack-submodule setup

setup:
	python3 -m venv venv &&\
	. venv/bin/activate &&\
	pip install --upgrade pip setuptools &&\
	cd python3-job-type &&\
	( cd python_wrapper && make setup ) &&\
	( cd racetrack/racetrack_client && make setup ) &&\
	( cd racetrack/racetrack_commons && make setup ) &&\
	( cd racetrack/utils/plugin_bundler && make setup )
	@echo Activate your venv:
	@echo . venv/bin/activate

test:
	(cd python3-job-type/python_wrapper && make test)

test-build:
	cd python3-job-type &&\
	DOCKER_BUILDKIT=1 docker build \
		-t racetrack/fatman-base/python3:latest \
		-f base.Dockerfile .

bundle:
	cd python3-job-type &&\
	racetrack plugin bundle --plugin-version=${TAG} --out=..

init-racetrack-submodule:
	git submodule update --init --recursive

update-racetrack-submodule:
	git submodule update --remote
