# Review Checklist

Every note Nathan has given, turned into a gate. Run EVERY item on the **final
render** — scrub actual output frames and measure actual output audio. Never
sign off from the plan, the raw clips, or an intermediate file.

**The meta rule:** after ANY fix, re-run the whole checklist on the new render.
Fixing one thing can silently reintroduce another (extending the outro audio for
a clipped word pulled the look-down back into frame — caught by Nathan, not QC).

## 1. His footage

- [ ] **No look-down / camera-reach visible anywhere** — make a 30fps CONTACT
      SHEET (`fps=30,tile=`) of every talking-head boundary IN THE FINAL RENDER:
      from the last spoken word to full black, and around every transition.
      Spot-checking every 0.2s is NOT enough — the dip develops in ~0.3s and
      slipped between samples twice. A 60%-faded look-down is still a look-down.
      The gaze leaves the lens ~0.1s earlier than it "looks like" at a glance:
      cut at the last frame where his eyes are clearly on camera.
- [ ] **No freeze-frames of him.** A cloned frame reads as a creepy pause.
      If audio must outlast clean video: J-cut into b-roll, or fade to black.
- [ ] Dead air / getting-ready trimmed from the start of every clip.
- [ ] The VO clip's video (shoulder shot) never appears.
- [ ] Ending not cut "a hair too soon" — video extends to cover his voice.

## 2. Audio

- [ ] Audio is present, synced, and part of the video (day one...).
- [ ] The last word of every section fully rings out — check with
      `silencedetect`: speech energy runs ~0.2s past the transcript timestamp.
- [ ] Fades start AFTER the ring-out, never on a word.
- [ ] No click/pop at the switch into b-roll audio (fade-ins on every atrim).
- [ ] loudnorm I=-14 applied once, on the full concat.

## 3. Motion

- [ ] Zooms are fast punches (0.2–0.3s). If in doubt, faster.
- [ ] Holds are pixel-still — diff two frames inside a hold; only codec noise
      allowed. No slow drifts (they read as micro-shake).
- [ ] No repeated shake / rubber-banding between punches.
- [ ] Every punch lands on its VO word (check against the word map).

## 4. B-roll screens

- [ ] Real app UI only: real Claude spark, real chrome, no invented status bars.
- [ ] Cropped real-screenshot assets are stripped of baked-in UI (labels, badges,
      watermarks) before the page draws its own — check for DOUBLED text/icons
      wherever a real image sits under rendered chrome (the double-ORIGINAL bug).
- [ ] AI responses are real AI output, not written filler.
- [ ] Claude greeting is "Evening, Zhi"; typed composer text is WHITE.
- [ ] Typing bursts in ≤1.5s. Watching typing is boring.
- [ ] "Thinking"/statuses ≤2s — if the VO says "in seconds", the screen shows seconds.
- [ ] Nothing on screen is static for more than ~2s; every VO beat has a UI reaction.

## 5. Graphics

- [ ] **ZERO emojis.** Captions, pills, mockups, everywhere.
- [ ] Nothing parked over his face — pills above the head, captions in the
      lower third, big graphics get a full-screen b-roll cutaway instead.
- [ ] Intro pill states what the video is about ("USING CLAUDE TO BOOK FLIGHTS").
- [ ] Captions: bubble style, readable, orange accents on the payoff words.
- [ ] Popups/pills are not repetitive or redundant — each one earns its place,
      placed where it makes sense, not willy-nilly.

## 6. Grade

- [ ] G73 gold standard on talking head only. Not too yellow/tan. B-roll ungraded.

## 7. Delivery

- [ ] Named file (not numbered) in `videos/` on the branch — ONLY after the full audit passes; log it in videos/AUDIT-LOG.md.
- [ ] Chat copy under 40MB (~50MB fails silently).
- [ ] 1080x1920, 30fps, faststart.

## Sign-off

Only send when every box above passes on the exact file being delivered.
If Nathan flags something anyway: fix it, add the new gate to this list, re-run
everything.
