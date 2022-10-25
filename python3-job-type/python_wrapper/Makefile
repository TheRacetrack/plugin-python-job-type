.PHONY: setup test run

setup:
	pip install -r requirements.txt -r requirements-dev.txt
	python setup.py develop

test:
	cd tests && python -m pytest -vv --tb=short -ra $(test)

# Run local server wrapping sample model (outside docker)
run:
	FATMAN_NAME=adder FATMAN_VERSION=0.0.1 \
	fatman_wrapper run tests/sample/adder_model.py

run-waiter:
	FATMAN_NAME=waiter FATMAN_VERSION=0.0.1 \
	fatman_wrapper run tests/sample/waiter_model.py
