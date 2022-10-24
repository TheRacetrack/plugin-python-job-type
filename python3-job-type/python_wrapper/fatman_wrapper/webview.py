from typing import Optional, Callable
import os
from pathlib import Path
from inspect import signature

import fastapi
from fastapi import APIRouter, FastAPI, Request
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from a2wsgi import WSGIMiddleware
from a2wsgi.types import ASGIApp, WSGIApp
from werkzeug.middleware.shared_data import SharedDataMiddleware

from racetrack_commons.api.asgi.proxy import TrailingSlashForwarder, mount_at_base_path
from racetrack_client.log.logs import get_logger
from fatman_wrapper.entrypoint import FatmanEntrypoint

logger = get_logger(__name__)


def setup_webview_endpoints(
    entrypoint: FatmanEntrypoint,
    base_url: str,
    fastapi_app: FastAPI,
    api: APIRouter,
):
    webview_base_url = base_url + '/api/v1/webview'

    webview_app = instantiate_webview_app(entrypoint, webview_base_url)
    if webview_app is None:
        return

    # Determine whether webview app is WSGI or ASGI
    sig = signature(webview_app)
    if len(sig.parameters) == 2:
        logger.debug(f'Webview app recognized as a WSGI app')
       
        # serve static resources
        static_path = Path(os.getcwd()) / 'static'
        if static_path.is_dir():
            webview_app = SharedDataMiddleware(webview_app, {
                webview_base_url + '/static': str(static_path)
            })

        wsgi_app = PathPrefixerWSGIMiddleware(webview_app, webview_base_url)
        fastapi_app.mount('/api/v1/webview', WSGIMiddleware(wsgi_app))
        TrailingSlashForwarder.mount_path('/api/v1/webview')

        @api.get('/webview/{path:path}')
        def _fatman_webview_endpoint(path: Optional[str] = fastapi.Path(None)):
            """Call custom Webview UI pages"""
            pass  # just register endpoint in swagger, it's handled by ASGI

    else:
        assert len(sig.parameters) == 3, 'ASGI app should have 3 arguments: Scope, Receive, Send'
        logger.debug(f'Webview app recognized as an ASGI app')

        # serve static resources
        static_path = Path(os.getcwd()) / 'static'
        if static_path.is_dir():
            fastapi_app.mount('/api/v1/webview/static', StaticFiles(directory=str(static_path)), name="webview_static")
            logger.debug(f'Static Webview directory found and mounted at /api/v1/webview/static')

        webview_app = mount_at_base_path(webview_app, webview_base_url)

        # @fastapi_app.get('/api/v1/webview')
        # async def _base_path_redirect(request: Request):
        #     return RedirectResponse(f"{request.url.path}/")

        # fastapi_app.mount('/api/v1/webview', webview_asgi_app)

        fastapi_app.mount('/api/v1/webview', webview_app)

        # fastapi_app.mount('/api/v1/webview', webview_asgi_app)
        TrailingSlashForwarder.mount_path(webview_base_url)

    logger.info(f'Webview app mounted at {webview_base_url}')

    # @api.get('/webview{path:path}')
    # def _fatman_webview_endpoint(path: Optional[str] = fastapi.Path(None)):
    #     """Call custom Webview UI pages"""
    #     pass  # just register endpoint in swagger, it's handled by ASGI


def instantiate_webview_app(entrypoint: FatmanEntrypoint, base_url: str) -> Optional[ASGIApp]:
    if not hasattr(entrypoint, 'webview_app'):
        return None
    webview_app_function = getattr(entrypoint, 'webview_app')
    webview_app: Callable = webview_app_function(base_url)
    if webview_app is None:
        return None

    # # Determine whether webview app is WSGI or ASGI
    # sig = signature(webview_app)
    # if len(sig.parameters) == 2:
    #     logger.debug(f'Webview app recognized as a WSGI app')
    #     return WSGIMiddleware(webview_app)

    # assert len(sig.parameters) == 3, 'ASGI app should have 3 arguments: Scope, Receive, Send'
    # logger.debug(f'Webview app recognized as an ASGI app')
    return webview_app


class PathPrefixerWSGIMiddleware:
    def __init__(self, app, base_path: str):
        self.app = app
        self.base_path = base_path

    def __call__(self, environ, start_response):
        path = environ.get("PATH_INFO", "")
        if not path.startswith(self.base_path):
            path = self.base_path + path

            environ['PATH_INFO'] = path
            environ['REQUEST_URI'] = path
            environ['RAW_URI'] = path

        return self.app(environ, start_response)
