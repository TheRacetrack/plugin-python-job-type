import threading
from typing import Optional

from fatman_wrapper.api import create_health_app
from fatman_wrapper.health import HealthState
from fatman_wrapper.wrapper import create_entrypoint_app
from racetrack_client.log.exception import short_exception_details
from racetrack_client.log.logs import get_logger
from racetrack_commons.api.asgi.asgi_reloader import ASGIReloader
from racetrack_commons.api.asgi.asgi_server import serve_asgi_app

logger = get_logger(__name__)


def run_configured_entrypoint(
    http_port: int,
    entrypoint_path: str,
    entrypoint_classname: Optional[str] = None,
):
    """
    Load entrypoint class and run it embedded in a HTTP server with given configuration.
    First, start simple health monitoring server at once.
    Next, do the late init in background and serve proper entrypoint endpoints eventually.
    """
    health_state = HealthState()
    health_app = create_health_app(health_state)

    app_reloader = ASGIReloader()
    app_reloader.mount(health_app)

    thread = threading.Thread(
        target=_late_init,
        args=(entrypoint_path, entrypoint_classname, health_state, app_reloader),
        daemon=True,
    )
    thread.start()

    serve_asgi_app(
        app_reloader, http_addr='0.0.0.0', http_port=http_port,
    )


def _late_init(
    entrypoint_path: str,
    entrypoint_classname: Optional[str],
    health_state: HealthState,
    app_reloader: ASGIReloader,
):
    try:
        fastapi_app = create_entrypoint_app(
            entrypoint_path, class_name=entrypoint_classname, health_state=health_state,
        )
        app_reloader.mount(fastapi_app)

    except BaseException as e:
        error_message = short_exception_details(e)
        health_state.set_error(error_message)
        logger.error(f'Initialization error: {error_message}')
    else:
        health_state.set_ready()
        logger.info('Server is ready')
