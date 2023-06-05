# Changelog
All **user-facing**, notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.8.0] - 2023-05-31
### Added
- Chain calls to the jobs can be made by importing the `call_job` function from a package provided by the job type plugin
  `from job_wrapper.call import call_job`.
  See the [example](../sample/python-chain/entrypoint.py) and
  the [function](../python3-job-type/python_wrapper/job_wrapper/call.py) for more details.

## [2.6.2] - 2023-05-18
### Added
- Setting `LOG_CALLER_NAME: 'true'` env var in a manifest allows you
  to keep record of a caller in the job's logs.
  This will add caller identity (username or ESC name) to every log entry.
  Exemplary Manifest snippet:
  ```yaml
  runtime_env:
    LOG_CALLER_NAME: 'true'
  ```

## [2.5.7] - 2022-12-01
### Fixed
- `python3` base image has now `git` and `build-essential` installed (again).
- User-defined requirements, coming from `python3` jobs,
  are better isolated from the core job dependencies to avoid conflicts.

## Older versions
Older changes are included in the [Racetrack's Changelog](https://github.com/TheRacetrack/racetrack/blob/master/docs/CHANGELOG.md)
when `python3` wrapper was part of the Racetrack repository.
