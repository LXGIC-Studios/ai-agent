import sys, os, pathlib
from playwright.sync_api import sync_playwright

BASE = pathlib.Path(__file__).parent
FPS = 30
SCENES = {"A": 3.6, "B": 9.4, "C": 3.9}

probe = len(sys.argv) > 1 and sys.argv[1] == "probe"

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path="/opt/pw-browsers/chromium"
        if os.path.exists("/opt/pw-browsers/chromium") else None)
    page = browser.new_page(viewport={"width": 1080, "height": 1920})
    page.goto(f"file://{BASE}/scenes.html")
    page.wait_for_timeout(500)  # font load

    if probe:
        shots = [("A", 0.4), ("A", 2.0), ("A", 3.4), ("B", 0.5), ("B", 5.0), ("B", 9.2), ("C", 2.5)]
        for scene, t in shots:
            page.evaluate(f"seek('{scene}', {t})")
            page.screenshot(path=str(BASE / f"probe_{scene}_{t}.png"))
        print("probe done")
    else:
        for scene, dur in SCENES.items():
            outdir = BASE / f"frames_{scene}"
            outdir.mkdir(exist_ok=True)
            n = round(dur * FPS)
            for i in range(n):
                t = i / FPS
                page.evaluate(f"seek('{scene}', {t})")
                page.screenshot(path=str(outdir / f"f{i:04d}.png"))
            print(f"scene {scene}: {n} frames")
    browser.close()
