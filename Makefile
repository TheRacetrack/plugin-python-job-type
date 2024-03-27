.PHONY: setup test

setup:
	python3 -m venv venv &&\
	. venv/bin/activate &&\
	pip install --upgrade pip setuptools &&\
	(cd src/python_wrapper && make setup)
	@echo Activate your venv:
	@echo . venv/bin/activate

setup-install:
	. venv/bin/activate &&\
	(cd src/python_wrapper && make setup)

test:
	(cd src/python_wrapper && make test)

bundle:
	cd src &&\
	racetrack plugin bundle --out=.. &&\
	racetrack plugin bundle --out=.. --out-filename=latest.zip

install:
	racetrack plugin install --replace latest.zip
