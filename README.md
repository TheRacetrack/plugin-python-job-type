# Racetrack Plugin: Python Job Type

This is a plugin for [Racetrack](https://github.com/TheRacetrack/racetrack)
which extends it with Python 3 Job Type.
It's a language wrapper converting your code written in Python to a Fatman web service.

## Setup
1. Install `racetrack` client and generate ZIP plugin by running `make bundle`.

2. Activate the plugin in Racetrack Dashboard Admin page
  by uploading the zipped plugin file.

## Usage
You can deploy sample Python3 job by running:
```bash
racetrack deploy sample/python-class <RACETRACK_URL>
```

# Changelog
Check out [Changelog](./docs/CHANGELOG.md) to find out about notable changes.

# Development
Setup & activate Python venv (this is required for local development):

```bash
# in a project-root directory
make setup
. venv/bin/activate
```

# Releasing a new version
1. Make sure you have latest `racetrack` client.
2. Change the current version in a [plugin-manifest.yaml](./python3-job-type/plugin-manifest.yaml)
3. Create ZIP plugin: `make bundle`
