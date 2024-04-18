FROM python:3.11-slim-bullseye

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    dnsutils \
    vim &&\
    rm -rf /var/lib/apt/lists/*
# apt cache is cleaned automatically, see /etc/apt/apt.conf.d/docker-clean

RUN python -m venv /src/job-venv &&\
	. /src/job-venv/bin/activate &&\
	pip install --upgrade pip setuptools

WORKDIR /src/job
# Include Racetrack job wrapper source code
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

{% for env_key, env_value in env_vars.items() %}
ENV {{ env_key }} "{{ env_value }}"
{% endfor %}

{% if manifest.system_dependencies and manifest.system_dependencies|length > 0 %}
RUN mkdir -p /usr/share/man/man1 && apt-get update -y && apt-get install -y \
    {{ manifest.system_dependencies | join(' ') }}
{% endif %}

{% if manifest_jobtype_extra.requirements_path %}
COPY "{{ manifest_jobtype_extra.requirements_path }}" /src/job/
# Install job's requirements in isolated environment
RUN . /src/job-venv/bin/activate &&\
    cd /src/job/ &&\
    pip install -r "{{ manifest_jobtype_extra.requirements_path }}"
    {%- if manifest_jobtype_extra.get('check_requirements', true) in [true, 'true'] %}
# check for dependency conflicts
RUN . /src/job-venv/bin/activate && pip check
    {%- endif %}
{% endif %} \

COPY . /src/job/
RUN chmod -R a+rw /src/job/ &&\
    rm -rf /root/.cache/pip

STOPSIGNAL SIGTERM
ENV PYTHONPATH "/src/job/:/src/python_wrapper:/usr/local/lib/python311.zip:/usr/local/lib/python3.11:/usr/local/lib/python3.11/site-packages:/src/job-venv/lib/python3.11/site-packages"
ENV VENV_PACKAGES_PATH "/src/job-venv/lib/python3.11/site-packages"
LABEL racetrack-component="job"
ENV JOB_NAME "{{ manifest.name }}"
ENV JOB_VERSION "{{ manifest.version }}"
ENV GIT_VERSION "{{ git_version }}"
ENV DEPLOYED_BY_RACETRACK_VERSION "{{ deployed_by_racetrack_version }}"
ENV JOB_TYPE_VERSION "{{ job_type_version }}"

CMD ["bash", "-c", "python -u -m racetrack_job_wrapper run '{{ manifest_jobtype_extra.entrypoint_path }}' '{{ manifest_jobtype_extra.entrypoint_class }}'"]
