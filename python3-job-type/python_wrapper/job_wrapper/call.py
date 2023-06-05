import os
from typing import Dict, Any, Optional

import httpx

from job_wrapper.entrypoint import JobEntrypoint


def call_job(
    entrypoint: JobEntrypoint,
    job_name: str,
    path: str = '/api/v1/perform',
    payload: Optional[Dict] = None,
    version: str = 'latest',
) -> Any:
    """
    Call another job's endpoint.
    :param entrypoint: entrypoint object of the job that calls another job
    :param job_name: name of the job to call
    :param path: endpoint path to call, default is /api/v1/perform
    :param payload: payload to send: dictionary with parameters or None
    :param version: version of the job to call. Use exact version or alias, like "latest"
    :return: result object returned by the called job
    """
    src_job = os.environ.get('JOB_NAME')
    try:
        assert src_job, 'JOB_NAME env var is not set'
        internal_pub_url = os.environ['PUB_URL']
        url = f'{internal_pub_url}/job/{job_name}/{version}{path}'

        tracing_header = os.environ.get('REQUEST_TRACING_HEADER', 'X-Request-Tracing-Id')
        caller_header = os.environ.get('CALLER_NAME_HEADER', 'X-Caller-Name')
        if hasattr(entrypoint, 'request_context'):
            request = getattr(entrypoint, 'request_context').get()
            tracing_id = request.headers.get(tracing_header) or ''
            caller_name = request.headers.get(caller_header) or ''
        else:
            tracing_id = ''
            caller_name = ''

        r = httpx.post(url, json=payload, headers={
            'X-Racetrack-Auth': os.environ['AUTH_TOKEN'],
            tracing_header: tracing_id,
            caller_header: caller_name,
        })
        r.raise_for_status()
        return r.json()

    except httpx.HTTPStatusError as e:
        raise RuntimeError(f'failed to call job "{job_name} {version}" by {src_job}: {e}: {e.response.text}') from e
    except BaseException as e:
        raise RuntimeError(f'failed to call job "{job_name} {version}" by {src_job}: {e}') from e
