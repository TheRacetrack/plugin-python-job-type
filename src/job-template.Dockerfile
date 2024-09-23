{% set python_version = manifest_jobtype_extra.python_version or '3.11' %}
{% set debian_version = manifest_jobtype_extra.debian_version or 'slim-bullseye' %}
{% set memray_profiler = manifest_jobtype_extra.get('memray_profiler', false) in [true, 'true'] %}

FROM python:{{python_version}}-{{debian_version}}

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    dnsutils \
    vim \
    procps &&\
    rm -rf /var/lib/apt/lists/*
# apt cache is cleaned automatically, see /etc/apt/apt.conf.d/docker-clean

{% if manifest_jobtype_extra.get('debian_backports', false) in [true, 'true'] %}
# Turn on Debian Backports packages
RUN printf "deb http://deb.debian.org/debian bullseye-backports main contrib non-free\ndeb-src http://deb.debian.org/debian bullseye-backports main contrib non-free" > /etc/apt/sources.list.d/backports.list
{% endif %}

RUN python -m venv /src/job-venv &&\
	. /src/job-venv/bin/activate &&\
	pip install --upgrade pip setuptools

# Include Racetrack job wrapper source code
WORKDIR /src/job
COPY --from=jobtype python_wrapper/setup.py python_wrapper/requirements.txt /src/python_wrapper/
RUN pip install -r /src/python_wrapper/requirements.txt && rm -rf /root/.cache/pip

COPY --from=jobtype python_wrapper/. /src/python_wrapper/
RUN cd /src/python_wrapper && pip install -e .

{% for env_key, env_value in env_vars.items() %}
ENV {{ env_key }} "{{ env_value }}"
{% endfor %}

{% if manifest.system_dependencies and manifest.system_dependencies|length > 0 %}
RUN mkdir -p /usr/share/man/man1 && apt-get update -y &&\
    apt-get install -y {{ manifest.system_dependencies | join(' ') }} &&\
    rm -rf /var/lib/apt/lists/*
{% endif %}

{% if manifest_jobtype_extra.requirements_path %}
COPY "{{ manifest_jobtype_extra.requirements_path }}" /src/job/
# Install job's requirements in isolated environment
RUN --mount=type=secret,id=build_secrets,target=/run/secrets/build_secrets.env \
    . /src/job-venv/bin/activate &&\
    cd /src/job/ &&\
    env $(cat /run/secrets/build_secrets.env | xargs) pip install -r "{{ manifest_jobtype_extra.requirements_path }}" &&\
    rm -rf /root/.cache/pip
    {%- if manifest_jobtype_extra.get('check_requirements', true) in [true, 'true'] %}
# check for dependency conflicts
RUN . /src/job-venv/bin/activate && pip check
    {%- endif %}
{% endif %}

{% if memray_profiler %}
RUN pip install memray && rm -rf /root/.cache/pip
COPY --from=jobtype wrapper-utils/memray-trap.sh /src/wrapper-utils/memray-trap.sh
{% endif %}

COPY . /src/job/
RUN chmod -R a+rw /src/job/

STOPSIGNAL SIGTERM
ENV PYTHONPATH "/src/job/:/src/python_wrapper:/usr/local/lib/python{{python_version.replace('.', '')}}.zip:/usr/local/lib/python{{python_version}}:/usr/local/lib/python{{python_version}}/site-packages:/src/job-venv/lib/python{{python_version}}/site-packages"
ENV VENV_PACKAGES_PATH "/src/job-venv/lib/python{{python_version}}/site-packages"
LABEL racetrack-component="job"
ENV JOB_NAME "{{ manifest.name }}"
ENV JOB_VERSION "{{ manifest.version }}"
ENV GIT_VERSION "{{ git_version }}"
ENV DEPLOYED_BY_RACETRACK_VERSION "{{ deployed_by_racetrack_version }}"
ENV JOB_TYPE_VERSION "{{ job_type_version }}"

{% if memray_profiler %}
CMD ["bash", "/src/wrapper-utils/memray-trap.sh", "racetrack_job_wrapper run '{{ manifest_jobtype_extra.entrypoint_path }}' '{{ manifest_jobtype_extra.entrypoint_class }}'"]
{% else %}
CMD ["bash", "-c", "python -u -m racetrack_job_wrapper run '{{ manifest_jobtype_extra.entrypoint_path }}' '{{ manifest_jobtype_extra.entrypoint_class }}'"]
{% endif %}
