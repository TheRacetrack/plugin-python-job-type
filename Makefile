.PHONY: setup test

setup:
	python3 -m venv venv &&\
	. venv/bin/activate &&\
	pip install --upgrade pip setuptools &&\
	(cd python3-job-type/python_wrapper && make setup)
	@echo Activate your venv:
	@echo . venv/bin/activate

test:
	(cd python3-job-type/python_wrapper && make test)

test-build-base:
	cd python3-job-type &&\
	DOCKER_BUILDKIT=1 docker build \
		-t racetrack/fatman-base/python3:latest \
		-f base.Dockerfile .

bundle:
	cd python3-job-type &&\
	racetrack plugin bundle --out=..

install:
	racetrack plugin install *.zip
