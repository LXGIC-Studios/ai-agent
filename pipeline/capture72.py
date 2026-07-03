import pathlib
from playwright.sync_api import sync_playwright
BASE = pathlib.Path(__file__).parent
FPS = 30
SCENES = {"S1": 14.8, "S2": 11.55}
with sync_playwright() as p:
    browser = p.chromium.launch(executable_path="/opt/pw-browsers/chromium")
    page = browser.new_page(viewport={"width": 1080, "height": 1920})
    page.goto(f"file://{BASE}/broll72.html")
    page.wait_for_timeout(400)
    for scene, dur in SCENES.items():
        outdir = BASE / f"b72_{scene}"
        outdir.mkdir(exist_ok=True)
        n = round(dur * FPS)
        for i in range(n):
            page.evaluate(f"seek('{scene}', {i/FPS})")
            page.screenshot(path=str(outdir / f"f{i:04d}.png"))
        print(f"{scene}: {n}")
    browser.close()
