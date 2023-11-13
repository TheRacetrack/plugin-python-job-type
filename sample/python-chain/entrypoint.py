import asyncio
from typing import List, Dict, Callable

from racetrack_job_wrapper.call import call_job, call_job_async


class JobEntrypoint:
    def perform(self, numbers: List[float]) -> float:
        """Round result from another model"""
        partial_result = call_job(self, 'python-class', '/api/v1/perform', {'numbers': numbers})
        return round(partial_result)

    def async_chain_call(self, numbers: List[float]) -> float:
        """Round result from another model by making chain call in async context"""
        partial_result = asyncio.run(self._call_job_async(numbers))
        return partial_result

    async def _call_job_async(self, numbers: List[float]) -> float:
        return await call_job_async(self, 'python-class', '/api/v1/perform', {'numbers': numbers})

    def auxiliary_endpoints(self) -> Dict[str, Callable]:
        """Dict of custom endpoint paths (besides "/perform") handled by Entrypoint methods"""
        return {
            '/async_chain_call': self.async_chain_call,
        }

    def docs_input_examples(self) -> Dict[str, Dict]:
        """Return mapping of Job's endpoints to corresponding exemplary inputs."""
        return {
            '/perform': {
                'numbers': [0.2, 0.9],
            },
            '/async_chain_call': {
                'numbers': [0.2, 0.9],
            },
        }
