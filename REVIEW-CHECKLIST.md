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
- [ ] **Full-video GAZE SCRUB on the final render** — dense face-crop contact
      sheets (every 2nd frame, cropped to the face) across the WHOLE video,
      not just boundaries. Every sustained (>0.3s) lowered/away gaze must be
      covered by a graphic beat (big near-opaque center card / cascade panel)
      that fills the face zone at the current zoom. Boundary-only checks
      missed four mid-take dips once — Nathan caught them, not QC.
- [ ] **Crop the scrub tiles TO EYE LEVEL** (his eyes fill the tile) — small
      whole-face tiles hid down-drifting eyes twice; Nathan: "LOOK AT HIS
      EYES WHEN EVALUATING." Every b-roll RETURN frame must land on verified
      eyes-on-lens footage; if the take drifts again within ~1s of the
      return, extend the b-roll instead of cutting back ("we can use the
      b-roll more"). On-camera beats between covers are ≥1s, never less.
- [ ] Cover graphics must hide the EYES specifically — check the final render
      for eyes peeking above a card/pill (a low-placed CTA card exposed
      down-drifting eyes once). Panels near-opaque (≥0.985).
- [ ] Dead air / getting-ready trimmed from the start of every clip.
- [ ] The VO clip's video (shoulder shot) never appears.
- [ ] Ending not cut "a hair too soon" — video extends to cover his voice.
- [ ] End-fade math uses the TRUE video end: xfade DROPS the first stream's
      tail beyond offset+duration — output ends at offset + second stream
      length. A fade computed against the assumed end left a held 90%-faded
      frame once. Verify YMAX=16 on the actual final frames, not the plan.

## 2. Audio

- [ ] Audio is present, synced, and part of the video (day one...).
- [ ] The last word of every section fully rings out — check with
      `silencedetect`: speech energy runs ~0.2s past the transcript timestamp.
- [ ] Fades start AFTER the ring-out, never on a word.
- [ ] No click/pop at the switch into b-roll audio (fade-ins on every atrim).
- [ ] loudnorm I=-14 applied once, on the full concat. loudnorm OUTPUTS 192kHz —
      ALWAYS aresample=44100 immediately after it, and before any amix (rate
      mismatch at amix silently truncated 3s of outro audio once).
- [ ] ffprobe the AUDIO STREAM duration of the final file — it must equal the
      video duration. A silent tail is a cut outro.
- [ ] Every SFX transient lands ON its visual event's measured frame — pop
      frames come from the overlay track's alpha / render frame-diff, never
      from planned punch times. On xfaded scenes, global = xfade OFFSET +
      local t (offset+duration put two dings 0.2s late — Nathan heard it).
      Subtract the sample's own onset lead. Verify positions in the bed wav.
- [ ] Every pop-like visual event HAS a sound (pill pops ding, expands swish);
      AI text streaming itself stays silent.
- [ ] Quality layer present and verified in the mix: pulse ring on every pop,
      whoosh under every transition, sub-bass thump on punch-INs. Verify by
      band-limited RMS at each event (sub 30–130Hz for thumps).
- [ ] NO chimes/bells anywhere — "rings" means the visual pulse ring (chime
      rejected by Nathan). No tonal extras on the CTA.
- [ ] Chip grids pop IN PLACE — scrub the pop sequence; no sideways jumps from
      flex re-centering (render all slots from frame one, visibility-hidden).

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
- [ ] Chat copy under ~30MB — 37MB failed silently twice; if the master is bigger,
      send a crf-23 lite encode and note the master lives in videos/. A send without
      a file_uuid in the tool result DID NOT ATTACH — always check and re-send lite.
- [ ] 1080x1920, 30fps, faststart.
- [ ] Frame checks on finals use frame-number `select` (decode from start),
      never `-ss` — seeking these renders landed ~4s off once and produced a
      "verification" sheet of the wrong section.

## Sign-off

Only send when every box above passes on the exact file being delivered.
If Nathan flags something anyway: fix it, add the new gate to this list, re-run
everything.
