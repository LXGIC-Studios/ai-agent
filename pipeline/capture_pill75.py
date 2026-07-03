import sys, pathlib
from playwright.sync_api import sync_playwright

BASE = pathlib.Path(__file__).parent
FPS = 30
# style test needs one pill + one card; full video will use all
ITEMS = {"p1": 3.4, "c1": 4.0}
if len(sys.argv) > 1 and sys.argv[1] != "probe":
    ITEMS = {k: float(v) for k, v in (a.split('=') for a in sys.argv[1:])}

probe = len(sys.argv) > 1 and sys.argv[1] == "probe"

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path="/opt/pw-browsers/chromium")
    page = browser.new_page(viewport={"width": 1080, "height": 1920})
    page.goto(f"file://{BASE}/popups76_i75.html")
    page.wait_for_timeout(400)
    if probe:
        for k, t in [("p1", 1.0), ("c1", 1.0), ("c3", 1.0)]:
            page.evaluate(f"seek('{k}', {t})")
            page.screenshot(path=str(BASE / f"probe_pop_{k}.png"), omit_background=True)
        print("probe done")
    else:
        for kind, dur in ITEMS.items():
            outdir = BASE / f"pop_{kind}"
            outdir.mkdir(exist_ok=True)
            n = round(dur * FPS)
            for i in range(n):
                page.evaluate(f"seek('{kind}', {i/FPS}, {dur})")
                page.screenshot(path=str(outdir / f"f{i:04d}.png"), omit_background=True)
            print(f"{kind}: {n} frames")
    browser.close()
