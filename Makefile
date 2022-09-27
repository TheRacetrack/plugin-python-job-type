TAG ?= 2.3.0

-include .env

setup:
	python3 -m venv venv &&\
	. venv/bin/activate &&\
	pip install --upgrade pip setuptools &&\
	cd python3-job-type &&\
	( cd python_wrapper && make setup ) &&\
	( cd racetrack/racetrack_client && make setup ) &&\
	( cd racetrack/racetrack_commons && make setup )
	@echo Activate your venv:
	@echo . venv/bin/activate

build:
	cd python3-job-type &&\
	DOCKER_BUILDKIT=1 docker build \
		-t racetrack/fatman-base/python3:latest \
		-f base.Dockerfile .

push-local: build
	docker tag racetrack/fatman-base/python3:latest localhost:5000/racetrack/fatman-base/python3:$(TAG)
	docker push localhost:5000/racetrack/fatman-base/python3:$(TAG)

push-private: build
	docker login ${REGISTRY}
	docker tag racetrack/fatman-base/python3:latest ${REGISTRY}/fatman-base/python3:$(TAG)
	docker push ${REGISTRY}/fatman-base/python3:$(TAG)

push-public: build
	docker login ghcr.io
	docker tag racetrack/fatman-base/python3:latest ghcr.io/theracetrack/racetrack/fatman-base/python3:$(TAG)
	docker push ghcr.io/theracetrack/racetrack/fatman-base/python3:$(TAG)

# Use it if you want to change the default settings
env-template:
	cp -n .env.dist .env
	@echo "Now fill in the .env file with your settings"

bundle:
	cd python3-job-type &&\
	racetrack-plugin-bundler bundle --plugin-version=${TAG} --out=..

release: push-local push-private push-public bundle
