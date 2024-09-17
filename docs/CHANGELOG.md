# Changelog
All **user-facing**, notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.15.0] - 2024-09-17
### Changed
- Use mounted secrets when building the image. This hides the secret
  environment variables, so they can't be accessed after the build.

## [2.14.5] - 2024-06-05
### Changed
- Job type format updated to new Racetrack interface for defining job types.

## [2.14.2] - 2024-04-04
### Fixed
- FastAPI dependency has been upgraded to solve memory leaks.

## [2.14.0] - 2024-03-25
### Added
- Maximum number of concurrent requests can be limited by `max_concurrency` field in a manifest:
  ```yaml
  jobtype_extra:
    max_concurrency: 1
  ```
  By default, concurrent requests are unlimited. Setting `max_concurrency` to `1` will make the job
  process requests one by one. Overdue requests will be queued and processed in order.

  Having such concurrency limits may cause some requests to wait in a queue.
  If an average throughput is higher than the job can handle, the queue will grow indefinitely.
  To prevent that, you can set `jobtype_extra.max_concurrency_queue` to limit the queue size.
  When the queue is full, the job will return `429 Too Many Requests` status code.

  See the [Python job type](https://github.com/TheRacetrack/plugin-python-job-type/blob/master/docs/job_python3.md)

## [2.13.2] - 2024-02-22
### Fixed
- Use ExceptionGroups from Python 3.11 properly.
- Hide ANSI color characters in logs if not in TTY mode.

## [2.13.1] - 2024-02-14
### Changed
- `pydantic` package has been upgraded to version 2.

## [2.13.0] - 2024-02-02
### Added
- A job can configure its own logging formatter, for instance structured logging formatter.
  Check out [python-logging-format sample](../sample/python-logging-format).

## [2.12.0] - 2024-01-11
### Changed
- Base Dockerfile has been merged with a job template,
  according to new job type interface for building images. 

## [2.11.2] - 2023-12-12
### Fixed
- Python 3.11 jobs no longer conflict with "typeguard" package.

## [2.11.1] - 2023-11-28
### Fixed
- Graceful shutdown on SIGTERM signal

## [2.11.0] - 2023-11-13
### Added
- Function `racetrack_job_wrapper.call.call_job_async` allows you to make chain calls inside a job
  within an `async` context in Python:
  ```python
  from racetrack_job_wrapper.call import call_job_async
  
  async def do_it_async(self):
      response = await call_job_async(self, job_name='job_name', path='/api/v1/perform', payload={}, version='latest')
  ```
  See [example](../sample/python-chain/entrypoint.py).

## [2.10.0] - 2023-10-12
### Added
- New Prometheus metrics coming from `racetrack_commons` module.

### Changed
- Third-party libraries have been upgraded to newer versions.

### Fixed
- Better handling of asynchronous calls. It no longer freezes the server.
  
## [2.9.2] - 2023-09-29
### Changed
- Python module `job_wrapper` has been renamed to `racetrack_job_wrapper`.
  Therefore, if you want to import chain call function, you have to use:
  ```python
  from racetrack_job_wrapper.call import call_job
  ```

## [2.9.1] - 2023-08-08
### Added
- This plugin manifests itself with category "job-type".

## [2.9.0] - 2023-05-31
### Added
- You can configure the home page of your job.
  Home page is the one you see when opening a job through the Dashboard or at the root endpoint.
  By default, it shows the SwaggerUI page. Now you can change it, for instance, to a webview endpoint:
  ```yaml
  jobtype_extra:
    home_page: '/api/v1/webview'
  ```
  ([#22](https://github.com/TheRacetrack/plugin-python-job-type/issues/22))

## [2.8.0] - 2023-05-31
### Added
- Chain calls to the jobs can be made by importing the `call_job` function from a package provided by the job type plugin
  `from job_wrapper.call import call_job`.
  See the [example](../sample/python-chain/entrypoint.py) and
  the [function](../src/python_wrapper/job_wrapper/call.py) for more details.

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
