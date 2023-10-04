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
	JOB_NAME=adder JOB_VERSION=0.0.1 \
	racetrack_job_wrapper run tests/sample/adder_model.py
