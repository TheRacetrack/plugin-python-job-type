FROM python:3.9-slim-bullseye

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    dnsutils \
    vim &&\
    rm -rf /var/lib/apt/lists/*
# apt cache is cleaned automatically, see /etc/apt/apt.conf.d/docker-clean
WORKDIR /src/job

COPY --from=jobtype python_wrapper/racetrack_client/requirements.txt /src/python_wrapper/racetrack_client/
COPY --from=jobtype python_wrapper/racetrack_commons/requirements.txt /src/python_wrapper/racetrack_commons/
COPY --from=jobtype python_wrapper/setup.py python_wrapper/requirements.txt /src/python_wrapper/
RUN pip install -r /src/python_wrapper/racetrack_client/requirements.txt \
  -r /src/python_wrapper/racetrack_commons/requirements.txt \
  -r /src/python_wrapper/requirements.txt

COPY --from=jobtype python_wrapper/racetrack_client/. /src/python_wrapper/racetrack_client/
COPY --from=jobtype python_wrapper/racetrack_commons/. /src/python_wrapper/racetrack_commons/
COPY --from=jobtype python_wrapper/racetrack_job_wrapper/. /src/python_wrapper/racetrack_job_wrapper/
RUN cd /src/python_wrapper && python setup.py develop

RUN python -m venv /src/job-venv &&\
	. /src/job-venv/bin/activate &&\
	pip install --upgrade pip setuptools

STOPSIGNAL SIGTERM
ENV PYTHONPATH "/src/job/:/src/python_wrapper:/usr/local/lib/python39.zip:/usr/local/lib/python3.9:/usr/local/lib/python3.9/site-packages:/src/job-venv/lib/python3.9/site-packages"
ENV VENV_PACKAGES_PATH "/src/job-venv/lib/python3.9/site-packages"
LABEL racetrack-component="job"


{% for env_key, env_value in env_vars.items() %}
ENV {{ env_key }} "{{ env_value }}"
{% endfor %}

{% if manifest.system_dependencies and manifest.system_dependencies|length > 0 %}
RUN mkdir -p /usr/share/man/man1 && apt-get update -y && apt-get install -y \
    {{ manifest.system_dependencies | join(' ') }}
{% endif %}


{% if manifest.get_jobtype_extra().requirements_path %}
COPY "{{ manifest.get_jobtype_extra().requirements_path }}" /src/job/
RUN . /src/job-venv/bin/activate &&\
    cd /src/job/ &&\
    pip install -r "{{ manifest.get_jobtype_extra().requirements_path }}"
{% endif %}

COPY . /src/job/
RUN chmod -R a+rw /src/job/

CMD ["bash", "-c", "python -u -m racetrack_job_wrapper run '{{ manifest.get_jobtype_extra().entrypoint_path }}' '{{ manifest.get_jobtype_extra().entrypoint_class }}'"]

ENV JOB_NAME "{{ manifest.name }}"
ENV JOB_VERSION "{{ manifest.version }}"
ENV GIT_VERSION "{{ git_version }}"
ENV DEPLOYED_BY_RACETRACK_VERSION "{{ deployed_by_racetrack_version }}"
ENV JOB_TYPE_VERSION "{{ job_type_version }}"
