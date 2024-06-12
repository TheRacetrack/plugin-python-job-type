from typing import Dict, Any, Optional

from fastapi import Request

from racetrack_job_wrapper.entrypoint import JobEntrypoint

RK_PREDECESSOR_ID_HEADER = 'X-Recordkeeper-Predecessor-Id'


def remember_predecessor_id(entrypoint: JobEntrypoint, value: str):
    if not hasattr(entrypoint, 'request_extra'):
        return
    request_extra: Dict[str, Any] = getattr(entrypoint, 'request_extra').get()
    request_extra[RK_PREDECESSOR_ID_HEADER] = value


def read_predecessor_id(entrypoint: JobEntrypoint) -> Optional[str]:
    """
    Take predecessor ID associated with this request.
    Predecessor is saved inside request_extra dictionary, but after making the chain call
    it's passed between jobs by means of request_context headers.
    """
    if hasattr(entrypoint, 'request_extra'):
        request_extra: Dict[str, Any] = getattr(entrypoint, 'request_extra').get()
        predecessor_id = request_extra.get(RK_PREDECESSOR_ID_HEADER)
        if predecessor_id:
            return predecessor_id

    if hasattr(entrypoint, 'request_context'):
        request: Request = getattr(entrypoint, 'request_context').get()
        predecessor_id = request.headers.get(RK_PREDECESSOR_ID_HEADER)
        if predecessor_id:
            return predecessor_id

    return None
