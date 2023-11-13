import asyncio
import time
import logging


def switch_to_async_context():
    logging.info('calling async function from non-async context')
    return asyncio.run(something_async())


async def something_async():
    logging.info('async context')
    return await switch_to_sync_context()


async def switch_to_sync_context():
    logging.info('calling blocking operation without blocking async context')
    return await asyncio.to_thread(blocking_operation)


def blocking_operation() -> str:
    logging.info('sync (blocking) context')
    time.sleep(5)
    return 'done'


class JobEntrypoint:
    def perform(self) -> str:
        return switch_to_async_context()
