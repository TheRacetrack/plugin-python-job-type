FROM {{ base_image }}

{% for env_key, env_value in env_vars.items() %}
ENV {{ env_key }} "{{ env_value }}"
{% endfor %}

{% if manifest.system_dependencies and manifest.system_dependencies|length > 0 %}
RUN mkdir -p /usr/share/man/man1 && apt-get update -y && apt-get install -y \
    {{ manifest.system_dependencies | join(' ') }}
{% endif %}

{% if manifest.python.requirements_path %}
COPY "{{ manifest.python.requirements_path }}" /src/job/
RUN . /src/job-venv/bin/activate &&\
    cd /src/job/ &&\
    pip install -r "{{ manifest.python.requirements_path }}"
{% endif %}

COPY . /src/job/
RUN chmod -R a+rw /src/job/

CMD python -u -m job_wrapper run "{{ manifest.python.entrypoint_path }}" "{{ manifest.python.entrypoint_class }}" < /dev/null
ENV JOB_NAME "{{ manifest.name }}"
ENV JOB_VERSION "{{ manifest.version }}"
ENV GIT_VERSION "{{ git_version }}"
ENV DEPLOYED_BY_RACETRACK_VERSION "{{ deployed_by_racetrack_version }}"
ENV JOB_TYPE_VERSION "{{ job_type_version }}"
