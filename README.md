# Racetrack Plugin: Python Job Type

This is a plugin for [Racetrack](https://github.com/TheRacetrack/racetrack)
which extends it with Python 3 Job Type.
It's a language wrapper converting your code written in Python to a Fatman web service.

## Setup
1. Make sure you have cloned the racetrack submodule. If not run: `git submodule update --init --recursive`

2. Make sure that current version of language wrapper docker image
  (provided by plugin) is pushed to your Docker registry,
  which is used by your Racetrack instance. 
  - Do it by pushing to public registry: `make push-public`  
  - or if you want to use private registry, run `make env-template`,
  fill in `.env` file and run `make push-private`.
  - If you wish to work on that locally, also run `make push-local`.

3. [Install racetrack-plugin-bundler](https://github.com/TheRacetrack/racetrack/blob/master/utils/plugin_bundler/README.md)
  and generate ZIP plugin by running `make bundle`.

4. Activate the plugin in Racetrack Dashboard Admin page
  by uploading the zipped plugin file.

## Usage
You can deploy sample Python3 job by running:
```bash
racetrack deploy sample/python-class <RACETRACK_URL>
```

# Development
Setup & activate Python venv (this is required for local development):

```bash
# in a project-root directory
make setup
. venv/bin/activate
```
