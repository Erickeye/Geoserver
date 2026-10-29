"""便民地圖的本機開發伺服器：提供 app/ 靜態檔，並把 /geoserver/* 轉送到 GeoServer。

前端與 GeoServer 因此同源，不需要在 GeoServer 設定 CORS。
用法：python app/serve.py [埠號]   （預設 5600）
"""
import sys
import urllib.request
import urllib.error
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

GEOSERVER = "http://localhost:8080"
ROOT = Path(__file__).parent


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def do_GET(self):
        if self.path.startswith("/geoserver/"):
            self.proxy()
        else:
            super().do_GET()

    def proxy(self):
        try:
            with urllib.request.urlopen(GEOSERVER + self.path, timeout=60) as r:
                status, headers, body = r.status, r.headers, r.read()
        except urllib.error.HTTPError as e:
            status, headers, body = e.code, e.headers, e.read()
        except Exception as e:
            self.send_error(502, str(e))
            return
        self.send_response(status)
        for k in ("Content-Type", "Content-Disposition"):
            if headers.get(k):
                self.send_header(k, headers[k])
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5600
    print(f"http://localhost:{port}/  (proxy /geoserver -> {GEOSERVER})")
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
