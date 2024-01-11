.PHONY: setup test

setup:
	python3 -m venv venv &&\
	. venv/bin/activate &&\
	pip install --upgrade pip setuptools &&\
	(cd src/python_wrapper && make setup)
	@echo Activate your venv:
	@echo . venv/bin/activate

test:
	(cd src/python_wrapper && make test)

test-build-base:
	cd src &&\
	DOCKER_BUILDKIT=1 docker build \
		-t racetrack/job-base/python3:latest \
		-f base.Dockerfile .

bundle:
	cd src &&\
	racetrack plugin bundle --out=.. &&\
	racetrack plugin bundle --out=.. --out-filename=latest.zip

install:
	racetrack plugin install --replace latest.zip
