import asyncio
from typing import List

from racetrack_job_wrapper.call import call_job, call_job_async


class JobEntrypoint:
    def perform(self, numbers: List[float], asynchronous: bool = False) -> float:
        """Round result from another model"""
        if asynchronous:
            partial_result = asyncio.run(self._call_job_async(numbers))
        else:
            partial_result = call_job(self, 'python-class', '/api/v1/perform', {'numbers': numbers})

        return round(partial_result)

    async def _call_job_async(self, numbers: List[float]) -> float:
        return await call_job_async(self, 'python-class', '/api/v1/perform', {'numbers': numbers})

    def docs_input_example(self) -> dict:
        """Return example input values for this model"""
        return {
            'numbers': [0.2, 0.9],
            'asynchronous': False,
        }
