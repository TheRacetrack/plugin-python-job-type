.PHONY: setup test run

setup:
	pip install \
		-r requirements.txt \
		-r requirements-dev.txt \
		-r racetrack_client/requirements.txt \
		-r racetrack_commons/requirements.txt
	python setup.py develop

test:
	cd tests && python -m pytest -vv --tb=short -ra $(test)

# Run local server wrapping sample model (outside docker)
run:
	FATMAN_NAME=adder FATMAN_VERSION=0.0.1 \
	fatman_wrapper run tests/sample/adder_model.py
