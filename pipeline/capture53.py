import sys, os, pathlib
from playwright.sync_api import sync_playwright

BASE = pathlib.Path(__file__).parent
FPS = 30
SCENES = {"A": 13.0, "B": 2.5, "C": 1.7}

probe = len(sys.argv) > 1 and sys.argv[1] == "probe"

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path="/opt/pw-browsers/chromium"
        if os.path.exists("/opt/pw-browsers/chromium") else None)
    page = browser.new_page(viewport={"width": 1080, "height": 1920})
    page.goto(f"file://{BASE}/scenes53.html")
    page.wait_for_timeout(500)

    if probe:
        shots = [("A", 0.9), ("A", 5.0), ("A", 12.3), ("A", 12.9), ("B", 1.2), ("B", 2.4), ("C", 0.6), ("C", 1.5)]
        for scene, t in shots:
            page.evaluate(f"seek('{scene}', {t})")
            page.screenshot(path=str(BASE / f"probe53_{scene}_{t}.png"))
        print("probe done")
    else:
        for scene, dur in SCENES.items():
            outdir = BASE / f"frames53_{scene}"
            outdir.mkdir(exist_ok=True)
            n = round(dur * FPS)
            for i in range(n):
                t = i / FPS
                page.evaluate(f"seek('{scene}', {t})")
                page.screenshot(path=str(outdir / f"f{i:04d}.png"))
            print(f"scene {scene}: {n} frames")
    browser.close()
