.PHONY: setup test run

setup:
	pip install -r requirements.txt

# Run local server wrapping sample model (outside docker)
run:
	JOB_NAME=adder JOB_VERSION=0.0.1 \
	racetrack_job_wrapper run tests/sample/adder_model.py
