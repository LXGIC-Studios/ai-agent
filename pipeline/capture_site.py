"""Self-service real-UI reference capture.

Screenshots real product websites at mobile viewport for b-roll reference
(EDITING-SYSTEM.md rule 4). Chromium renders; python `requests` does all
fetching through the agent proxy (Chromium's own TLS gets reset by the
proxy, so every request is intercepted and fulfilled via requests).

Usage:
  python3 capture_site.py https://durable.co durable       # -> ref_durable/00.png, scrolled states
  python3 capture_site.py https://www.ocoya.com ocoya 5    # 5 scroll states

Login-walled flows can't be captured this way — ask Nathan/Zhi for phone
screenshots of those.
"""
import pathlib, sys

import requests
from playwright.sync_api import sync_playwright

URL, NAME = sys.argv[1], sys.argv[2]
STATES = int(sys.argv[3]) if len(sys.argv) > 3 else 3
OUT = pathlib.Path(f"ref_{NAME}"); OUT.mkdir(exist_ok=True)

S = requests.Session()
S.verify = "/root/.ccr/ca-bundle.crt"
S.headers["User-Agent"] = ("Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) "
                           "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1")

def handler(route, request):
    try:
        r = S.get(request.url, timeout=20)
        route.fulfill(status=r.status_code,
                      headers={"content-type": r.headers.get("content-type", "")},
                      body=r.content)
    except Exception:
        route.abort()

with sync_playwright() as p:
    b = p.chromium.launch(executable_path="/opt/pw-browsers/chromium")
    ctx = b.new_context(viewport={"width": 390, "height": 844}, device_scale_factor=2)
    pg = ctx.new_page()
    pg.route("**/*", handler)
    pg.goto(URL, timeout=60000, wait_until="domcontentloaded")
    pg.wait_for_timeout(6000)
    for i in range(STATES):
        pg.screenshot(path=str(OUT / f"{i:02d}.png"))
        pg.mouse.wheel(0, 800)
        pg.wait_for_timeout(1200)
    print(f"{OUT}/: {STATES} states captured from {URL}")
    b.close()
