FROM python:3.9-slim-bullseye

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    dnsutils \
    vim &&\
    rm -rf /var/lib/apt/lists/*
# apt cache is cleaned automatically, see /etc/apt/apt.conf.d/docker-clean
WORKDIR /src/fatman

COPY racetrack/racetrack_client/setup.py racetrack/racetrack_client/requirements.txt racetrack/racetrack_client/README.md /src/racetrack_client/
COPY racetrack/racetrack_commons/setup.py racetrack/racetrack_commons/requirements.txt /src/racetrack_commons/
COPY python_wrapper/setup.py python_wrapper/requirements.txt /src/python_wrapper/
RUN pip install -r /src/racetrack_client/requirements.txt \
  -r /src/racetrack_commons/requirements.txt \
  -r /src/python_wrapper/requirements.txt

COPY racetrack/racetrack_client/racetrack_client/. /src/racetrack_client/racetrack_client/
COPY racetrack/racetrack_commons/racetrack_commons/. /src/racetrack_commons/racetrack_commons/
COPY python_wrapper/fatman_wrapper/. /src/python_wrapper/fatman_wrapper/
RUN cd /src/racetrack_client && python setup.py develop &&\
  cd /src/racetrack_commons && python setup.py develop &&\
  cd /src/python_wrapper && python setup.py develop

RUN python -m venv /src/fat-venv &&\
	. /src/fat-venv/bin/activate &&\
	pip install --upgrade pip setuptools

ENV PYTHONPATH "/src/fatman/"
ENV VENV_PACKAGES_PATH "/src/fat-venv/lib/python3.9/site-packages"
LABEL racetrack-component="fatman"
