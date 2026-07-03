import pathlib
from playwright.sync_api import sync_playwright

BASE = pathlib.Path(__file__).parent
FPS = 30
DUR = 25.81

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path="/opt/pw-browsers/chromium")
    page = browser.new_page(viewport={"width": 1080, "height": 400})
    page.goto(f"file://{BASE}/captions74.html")
    page.wait_for_timeout(400)
    outdir = BASE / "caps74"
    outdir.mkdir(exist_ok=True)
    n = round(DUR * FPS)
    for i in range(n):
        page.evaluate(f"seek({i/FPS})")
        page.screenshot(path=str(outdir / f"f{i:04d}.png"), omit_background=True)
    print(f"caps: {n} frames")
    browser.close()
