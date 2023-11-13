import os
from typing import Dict, Any, Optional, Union

import httpx

from racetrack_job_wrapper.entrypoint import JobEntrypoint


def call_job(
    entrypoint: JobEntrypoint,
    job_name: str,
    path: str = '/api/v1/perform',
    payload: Optional[Dict] = None,
    version: str = 'latest',
    method: str = 'POST',
) -> Any:
    """
    Call another job's endpoint.
    :param entrypoint: entrypoint object of the job that calls another job
    :param job_name: name of the job to call
    :param path: endpoint path to call, default is /api/v1/perform
    :param payload: payload to send: dictionary with parameters or None
    :param version: version of the job to call. Use exact version or alias, like "latest"
    :param method: HTTP method: GET, POST, PUT, DELETE, etc.
    :return: result object returned by the called job
    """
    src_job = os.environ.get('JOB_NAME')
    try:
        with httpx.Client() as client:
            request: httpx.Request = _prepare_request(client, entrypoint, job_name, path, payload, version, method)
            response = client.send(request)
        response.raise_for_status()
        return response.json()

    except httpx.HTTPStatusError as e:
        raise RuntimeError(f'failed to call job "{job_name} {version}" by {src_job}: {e}: {e.response.text}') from e
    except BaseException as e:
        raise RuntimeError(f'failed to call job "{job_name} {version}" by {src_job}: {e}') from e


async def call_job_async(
    entrypoint: JobEntrypoint,
    job_name: str,
    path: str = '/api/v1/perform',
    payload: Optional[Dict] = None,
    version: str = 'latest',
    method: str = 'POST',
) -> Any:
    """
    Call another job's endpoint in async context.
    :param entrypoint: entrypoint object of the job that calls another job
    :param job_name: name of the job to call
    :param path: endpoint path to call, default is /api/v1/perform
    :param payload: payload to send: dictionary with parameters or None
    :param version: version of the job to call. Use exact version or alias, like "latest"
    :param method: HTTP method: GET, POST, PUT, DELETE, etc.
    :return: result object returned by the called job
    """
    src_job = os.environ.get('JOB_NAME')
    try:
        async with httpx.AsyncClient() as client:
            request: httpx.Request = _prepare_request(client, entrypoint, job_name, path, payload, version, method)
            response = await client.send(request)
        response.raise_for_status()
        return response.json()

    except httpx.HTTPStatusError as e:
        raise RuntimeError(f'failed to call job "{job_name} {version}" by {src_job}: {e}: {e.response.text}') from e
    except BaseException as e:
        raise RuntimeError(f'failed to call job "{job_name} {version}" by {src_job}: {e}') from e


def _prepare_request(
    http_client: Union[httpx.Client, httpx.AsyncClient],
    entrypoint: JobEntrypoint,
    job_name: str,
    path: str,
    payload: Optional[Dict],
    version: str,
    method: str,
) -> httpx.Request:
    src_job = os.environ.get('JOB_NAME')
    assert src_job, 'JOB_NAME env var is not set'
    assert 'PUB_URL' in os.environ, 'PUB_URL env var is not set'
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

    request: httpx.Request = http_client.build_request(method.upper(), url, json=payload, headers={
        'X-Racetrack-Auth': os.environ['AUTH_TOKEN'],
        tracing_header: tracing_id,
        caller_header: caller_name,
    })
    return request
