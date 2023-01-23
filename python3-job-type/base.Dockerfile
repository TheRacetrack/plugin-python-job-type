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

COPY python_wrapper/racetrack_client/requirements.txt /src/python_wrapper/racetrack_client/
COPY python_wrapper/racetrack_commons/requirements.txt /src/python_wrapper/racetrack_commons/
COPY python_wrapper/setup.py python_wrapper/requirements.txt /src/python_wrapper/
RUN pip install -r /src/python_wrapper/racetrack_client/requirements.txt \
  -r /src/python_wrapper/racetrack_commons/requirements.txt \
  -r /src/python_wrapper/requirements.txt

COPY python_wrapper/racetrack_client/. /src/python_wrapper/racetrack_client/
COPY python_wrapper/racetrack_commons/. /src/python_wrapper/racetrack_commons/
COPY python_wrapper/fatman_wrapper/. /src/python_wrapper/fatman_wrapper/
RUN cd /src/python_wrapper && python setup.py develop

RUN python -m venv /src/fat-venv &&\
	. /src/fat-venv/bin/activate &&\
	pip install --upgrade pip setuptools

ENV PYTHONPATH "/src/fatman/:/src/python_wrapper:/usr/local/lib/python39.zip:/usr/local/lib/python3.9:/usr/local/lib/python3.9/site-packages:/src/fat-venv/lib/python3.9/site-packages"
ENV VENV_PACKAGES_PATH "/src/fat-venv/lib/python3.9/site-packages"
LABEL racetrack-component="fatman"
