"""Authenticated real-UI capture — logged-in flows, not just public pages.

Extends capture_site.py: Chromium renders while a persistent requests.Session
does ALL network through the agent proxy — every method, POST bodies, and
cookies included. That means signups, logins, and in-app dashboards work:
fill the form in the page, the session keeps the auth cookies, capture every
screen.

Email verification is fully self-service: MailTM creates a disposable inbox
over pure HTTPS (IMAP is blocked by the proxy; personal Google accounts are
never used). One fresh inbox per site signup:

    mb = MailTM()                      # creates zhireelsXXXXX@<domain>
    ...sign up on the site with mb.address...
    link = mb.wait_link()              # polls for the verification URL
    b.goto(link)                       # verified; session now logged in

If a site rejects disposable domains, fall back to phone screenshots per
EDITING-SYSTEM.md rule 4.

Interactive use from a driver script:
    from capture_app import Browser
    b = Browser()
    b.goto("https://app.example.com/login")
    b.page.fill("input[type=email]", EMAIL); b.page.fill("input[type=password]", PW)
    b.page.click("button[type=submit]"); b.page.wait_for_timeout(4000)
    b.shot("ref_example/logged-in.png")

Known limit: sites behind CAPTCHA / bot-walls won't sign up headlessly —
those fall back to phone screenshots per EDITING-SYSTEM.md rule 4.
"""
import email as email_lib
import imaplib
import os
import re

import requests
from playwright.sync_api import sync_playwright

UA = ("Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) "
      "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1")
FWD_HEADERS = ["content-type", "accept", "origin", "referer", "x-requested-with", "authorization"]


class Browser:
    def __init__(self, viewport=(390, 844)):
        self.s = requests.Session()
        self.s.verify = "/root/.ccr/ca-bundle.crt"
        self.s.headers["User-Agent"] = UA
        self._pw = sync_playwright().start()
        self._b = self._pw.chromium.launch(executable_path="/opt/pw-browsers/chromium")
        ctx = self._b.new_context(viewport={"width": viewport[0], "height": viewport[1]},
                                  device_scale_factor=2, user_agent=UA)
        self.page = ctx.new_page()
        self.page.route("**/*", self._route)

    def _route(self, route, request):
        try:
            hdrs = {k: v for k, v in request.headers.items() if k.lower() in FWD_HEADERS}
            r = self.s.request(request.method, request.url,
                               data=request.post_data_buffer, headers=hdrs, timeout=25)
            self.s.headers["Referer"] = request.url
            route.fulfill(status=r.status_code,
                          headers={"content-type": r.headers.get("content-type", "")},
                          body=r.content)
        except Exception:
            route.abort()

    def goto(self, url, wait=4000):
        self.page.goto(url, timeout=60000, wait_until="domcontentloaded")
        self.page.wait_for_timeout(wait)

    def shot(self, path):
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        self.page.screenshot(path=path)
        return path

    def close(self):
        self._b.close(); self._pw.stop()


def poll_verification_link(subject_hint="verif", timeout_s=120):
    """Poll the burner inbox (env: EMAIL_ADDR/EMAIL_PASS/EMAIL_IMAP_HOST) for
    the newest message and return the first http(s) link in it."""
    import time
    host, addr, pw = os.environ["EMAIL_IMAP_HOST"], os.environ["EMAIL_ADDR"], os.environ["EMAIL_PASS"]
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        m = imaplib.IMAP4_SSL(host)
        m.login(addr, pw); m.select("INBOX")
        _, data = m.search(None, "UNSEEN")
        ids = data[0].split()
        for mid in reversed(ids):
            _, msg_data = m.fetch(mid, "(RFC822)")
            msg = email_lib.message_from_bytes(msg_data[0][1])
            body = ""
            for part in msg.walk():
                if part.get_content_type() in ("text/html", "text/plain"):
                    body += part.get_payload(decode=True).decode(errors="ignore")
            links = re.findall(r'https?://[^\s"\'<>]+', body)
            good = [l for l in links if subject_hint.lower() in l.lower() or "confirm" in l.lower() or "verify" in l.lower()]
            if good or links:
                m.logout()
                return (good or links)[0]
        m.logout()
        time.sleep(8)
    raise TimeoutError("no verification mail arrived")


class MailTM:
    """Disposable HTTPS inbox (api.mail.tm) — no IMAP, no personal accounts."""
    API = "https://api.mail.tm"

    def __init__(self):
        import json, random, string
        self.s = requests.Session(); self.s.verify = "/root/.ccr/ca-bundle.crt"
        dom = self.s.get(f"{self.API}/domains", timeout=20).json()["hydra:member"][0]["domain"]
        self.address = "zhireels" + "".join(random.choices(string.digits, k=5)) + "@" + dom
        self.password = "Zr-" + "".join(random.choices(string.ascii_letters + string.digits, k=14))
        assert self.s.post(f"{self.API}/accounts", json={"address": self.address, "password": self.password}, timeout=20).status_code == 201
        tok = self.s.post(f"{self.API}/token", json={"address": self.address, "password": self.password}, timeout=20).json()["token"]
        self.s.headers["Authorization"] = "Bearer " + tok

    def wait_link(self, timeout_s=180):
        import time
        deadline = time.time() + timeout_s
        while time.time() < deadline:
            msgs = self.s.get(f"{self.API}/messages", timeout=20).json().get("hydra:member", [])
            for m in msgs:
                full = self.s.get(f"{self.API}/messages/{m['id']}", timeout=20).json()
                body = (full.get("html") or [""])[0] + full.get("text", "")
                links = re.findall(r'https?://[^\s"\'<>]+', body)
                good = [l for l in links if any(k in l.lower() for k in ("verify", "confirm", "activate", "token"))]
                if good or links:
                    return (good or links)[0]
            time.sleep(8)
        raise TimeoutError("no verification mail arrived")
