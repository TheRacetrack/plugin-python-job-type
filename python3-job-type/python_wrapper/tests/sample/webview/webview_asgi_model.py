from typing import List

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates


class FatmanEntrypoint:
    def perform(self, numbers: List[float]) -> float:
        """Return sum of given numbers"""
        return sum(numbers)

    def webview_app(self, base_url: str):
        """
        Create ASGI app serving custom UI pages
        :param base_url Base URL prefix where WSGI app is deployed.
        """
        app = FastAPI()

        templates = Jinja2Templates(directory="templates")

        @app.get('/')
        async def index(request: Request):
            return templates.TemplateResponse("index.html", {
                "request": request,
                "base_url": base_url,
            })

        return app
