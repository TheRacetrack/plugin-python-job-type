from pathlib import Path
from typing import Optional, Dict, Any

import yaml
from fastapi import FastAPI

from racetrack_job_wrapper.api import create_api_app
from racetrack_job_wrapper.health import HealthState
from racetrack_job_wrapper.loader import instantiate_class_entrypoint
from racetrack_job_wrapper.validate import validate_entrypoint


def create_entrypoint_app(
    model_path: str,
    class_name: Optional[str] = None,
    health_state: HealthState = None,
    manifest_dict: Optional[Dict[str, Any]] = None,
) -> FastAPI:
    """Load entrypoint from a Python module and embed it in a FastAPI app"""
    entrypoint = instantiate_class_entrypoint(model_path, class_name)
    validate_entrypoint(entrypoint)
    if health_state is None:
        health_state = HealthState(live=True, ready=True)
    if manifest_dict is None:
        manifest_dict = _read_job_manifest()
    return create_api_app(entrypoint, health_state, manifest_dict)


def _read_job_manifest() -> Dict[str, Any]:
    manifest_path = Path('job.yaml')
    assert manifest_path.is_file(), f'manifest file not found at {manifest_path}'
    with manifest_path.open() as file:
        return yaml.load(file, Loader=yaml.FullLoader) or {}
