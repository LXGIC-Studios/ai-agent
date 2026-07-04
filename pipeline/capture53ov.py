import os, pathlib
from playwright.sync_api import sync_playwright

BASE = pathlib.Path(__file__).parent
FPS = 30
N = 862  # 28.73s
TRACKS = [("pops53.html", "pop53", 1920), ("captions53n.html", "caps53", 400)]

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path="/opt/pw-browsers/chromium"
        if os.path.exists("/opt/pw-browsers/chromium") else None)
    for html, outname, h in TRACKS:
        page = browser.new_page(viewport={"width": 1080, "height": h})
        page.goto(f"file://{BASE}/{html}")
        page.wait_for_timeout(500)
        outdir = BASE / outname
        outdir.mkdir(exist_ok=True)
        for i in range(N):
            page.evaluate(f"seek({i / FPS})")
            page.screenshot(path=str(outdir / f"f{i:04d}.png"), omit_background=True)
        print(outname, "done")
        page.close()
    browser.close()
