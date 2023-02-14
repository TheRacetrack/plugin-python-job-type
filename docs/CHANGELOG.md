# Changelog
All **user-facing**, notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.5.7] - 2022-12-01
### Fixed
- `python3` base image has now `git` and `build-essential` installed (again).
- User-defined requirements, coming from `python3` jobs,
  are better isolated from the core job dependencies to avoid conflicts.

## Older versions
Older changes are included in the [Racetrack's Changelog](https://github.com/TheRacetrack/racetrack/blob/master/docs/CHANGELOG.md)
when `python3` wrapper was part of the Racetrack repository.
