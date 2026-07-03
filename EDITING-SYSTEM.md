# Zhi Reels — Editing System

The locked style + process for every short-form video on this account.
Format: 1080x1920 (9:16), 30fps, Instagram Reels / TikTok. Editor: Claude. Talent: Zhi.

**APPROVED REFERENCE:** `videos/claude-books-flights.mp4` is the signed-off
gold standard for the full edit (structure, motion, b-roll, captions, ending).
`pipeline/` contains its exact source files. Video 73 set the color grade;
video 75 set everything else. Match them.

---

## 1. Hard rules — never break these

1. **NO emojis. Ever.** Not in captions, pills, mockups, or graphics.
2. **The VO clip is audio-only.** It's a shoulder shot. Never show its video.
3. **Never park graphics over his face.** Pills go above his head, captions in the lower third band. If a graphic needs the middle of the frame, cut to full-screen b-roll instead.
4. **Real app UI only.** Mockups must look like the actual product (real Claude spark icon from claude.ai, real chrome, real layout). No fake status bars, no invented icons, no "symmetrical" redrawn logos.
   **Before building b-roll for any product, ask Nathan/Zhi for real screenshots of the actual flow** (walking it on a phone takes minutes) and rebuild screen-for-screen: same questions, copy, icons, colors, buttons, progress indicators. Only the device status bar / browser chrome gets simplified to the clean URL-pill treatment.
5. **Real AI responses.** When a mockup shows an AI answer, generate the answer with the actual AI (or have Nathan paste a real one). Never write fake-sounding filler.
6. **Claude app specifics:** greeting is "Evening, Zhi" (never a real name that isn't his), typed composer text is WHITE (`#f0efea`), placeholder text is gray (`#8a867d`).

## 2. The look (locked)

### Color grade — "G73" (gold standard, from video 73)
Applied to talking-head footage ONLY. Never grade the b-roll screens.

```
curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3
```

Do NOT use the warm/teal "premium" grade — it reads too yellow/tan. G73 is final.

### Captions — bubble style
- Rounded dark glass bubble: `rgba(16,15,17,0.88)`, 2px `rgba(255,255,255,0.16)` border, 30px radius, heavy drop shadow.
- Montserrat 800, 60px, white, centered; accent words in orange `#F0A13C` (marked `|word|` in the chunk table).
- Rendered as a 1080x400 transparent PNG band, overlaid at **y=1440** (lower third, below his face, above UI edges).
- Chunks of 2–6 words, cut on the word timestamps. Accent the payoff words (product names, numbers, benefits).
- Pop-in: 0.12s scale 0.78→1.06→1.0 with fast fade.

### Intro pill
- One pill above his head (never on his face) stating what the video is about, e.g. "USING CLAUDE TO BOOK FLIGHTS".
- Dark glass style matching captions, Archivo 900, uppercase, key word in orange.
- On screen for the whole intro, exits with the transition.

### Encode
```
libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p
aac 256k, 44.1kHz, loudnorm I=-14:TP=-1.5:LRA=11, -movflags +faststart
```

## 3. Edit formula (structure of every reel)

1. **Hook (1.5–2.5s):** intro clip, trimmed hard. Zoom-out punch on the first frame (1.10→1.0 in 0.25s). Intro pill above his head.
2. **J-cut into b-roll:** the transition (circleopen, 0.2s) starts ~0.2s BEFORE his hook line ends, so the b-roll opens while he's still talking. His video ends at the exact cut — never freeze-frame him (reads creepy), never show him reaching for the camera.
3. **B-roll walkthrough (bulk of the video):** app screens driven by the VO. Section-to-section transitions: slideleft / circleopen / radial, 0.2–0.3s.
4. **Radial wipe to outro** exactly when the VO's last word finishes ringing out.
5. **Outro (CTA):** static camera, end zoom punch-in on the last 0.5s, then **fade to black** (0.3s) with the audio ring-out under it.
   The outro video ends on his **last clean eyes-up frame** (find it frame-by-frame;
   the look-down starts ~0.1s later than you think). The fade must reach TRUE black
   at least one frame before the video ends — a held 90%-faded frame still shows him.
   Audio continues under black until the ring-out finishes, then the audio fade.

## 4. Motion rules

- **Zooms are fast punches only:** 0.2–0.3s, rate ≈ 0.3–0.5 zoom/s. Punch on beats: send, results landing, highlight, link, scene cut.
- **Dead-still between punches.** No slow drift zooms — sub-pixel crawl reads as micro-shake. The in-app animation supplies life between punches.
- **Every punch lands on a VO word.** Map word timestamps first, then place camera moves.
- **zoompan recipe:** supersample to `scale=3240:5760` before `zoompan` (kills shimmer), `d=1:s=1080x1920:fps=30`, x centered, y anchor ~0.33 for face, 0.45–0.62 for UI focus. Only change the y anchor while zoom = 1.0 (no visible jump).

## 5. B-roll rules (app screens)

- Built as deterministic HTML pages: every frame is a pure function of time via `window.seek(scene, t)`. No CSS animations/transitions (they break frame capture). Captured frame-by-frame with Playwright at 30fps.
- **Something new must happen every 1–2 seconds.** Never sit on a still screen.
- **Typing is fast:** the whole prompt in ≤1.5s, keyboard visible, keys highlighting.
- **AI "thinking" is fast:** status chips ≤1.6s total. If the script says "in seconds", results appear in seconds.
- **Stagger everything:** result cards land one at a time (0.25s fade+rise each, ~0.6s apart).
- Fill VO beats with UI reactions: summary line types out, cards pulse on "compares", sublines brighten on "details", highlight ring + tag on "cheapest", button pops on "link".
- **Payoff ending:** finish the b-roll on the real-world result (e.g. tap the button → the actual booking website loads). A light-mode page after dark UI is a deliberate contrast pop.
- Statuses/labels are plain text, no spinners longer than the beat, no emojis.

## 6. Audio rules

- Word-level timestamps first: faster-whisper ('small', int8) on every clip → correct mishears against the script → this map drives ALL timing (cuts, captions, punches).
- Trim into silence, never through a word. Verify with `silencedetect` — speech energy often runs ~0.2s past the whisper end timestamp (ring-out). Leave it.
- The end fade (`afade=t=out`) starts AFTER the last word's ring-out ends, never on it.
- Audio chain: per-clip `atrim` + tiny fade-ins (0.06–0.25s to kill switch clicks) → concat → loudnorm I=-14 → end fade → aresample 44100.
- J-cut audio is the norm: audio of one section runs under the visuals of the next.

## 7. Raw footage handling

Every video arrives as 3 clips: **intro** (hook), **VO** (shoulder shot — audio only), **outro** (CTA).
Always trim out:
- Dead air / "getting ready" at the start of every clip (~0.2–0.7s).
- The camera reach / look-down at the END of every clip (starts ~0.2–0.5s before the clip ends). If audio needs to run longer than the clean video, J-cut or fade to black — never show the reach, never freeze his face.

## 8. Process (per video)

1. **Ingest:** pull raw clips + script from Drive (`gdown`). Identify intro / VO / outro by content (VO = shoulder shot).
2. **Transcribe:** faster-whisper word timestamps per clip; fix mishears against the script; save `wordsNN.json`.
3. **Plan the timeline:** on paper first — clip trims from silencedetect + word map, section boundaries, transition offsets, zoom punch times, caption chunks. All numbers derive from the word map.
4. **Build b-roll:** HTML page with `seek(scene, t)`; capture PNG sequences with Playwright (`pipeline/capture75bc.py` pattern).
5. **Build captions + pill:** chunk table in `captions75.html` pattern; capture transparent 1080x400 band; pill via `popups76_i75.html` pattern.
6. **Assemble:** single ffmpeg filter graph (`pipeline/render_reel.sh` is the canonical reference): grade+zoompan per segment → xfades (tpad clone to preserve offsets) → caption overlay at y=1440 → audio chain.
7. **QC (checklist below), fix, re-render.**
8. **Deliver:** named file (not numbered) → `videos/` on the repo branch + send in chat (<40MB; ~50MB silently fails).

## 9. QC — run the full checklist

Before every delivery, run **[REVIEW-CHECKLIST.md](REVIEW-CHECKLIST.md)** — every
note Nathan has ever given, as pass/fail gates. Two non-negotiables:

- Check the **final render**, frame-by-frame at every boundary and through every
  fade — never sign off from the plan or the raw clips.
- After ANY fix, re-run the whole checklist: fixing one thing can reintroduce
  another.

## 10. Repo layout

```
EDITING-SYSTEM.md      this file — the bible
ASSETS.md              raw footage / Drive asset inventory
videos/                audited finals only — every video passes REVIEW-CHECKLIST first
pipeline/              canonical working set (video 75 = reference implementation)
  render_reel.sh         final assembly command (the v10 render)
  broll75.html           Claude-app b-roll scenes (seek(scene,t) pattern)
  captions75.html        bubble caption chunk table
  popups76_i75.html      intro pill
  capture*.py            Playwright frame-capture scripts
  claude_spark.png       real Claude spark icon (pulled from claude.ai)

```

## 11. Known numbers that keep working

| Thing | Value |
|---|---|
| Intro hook length | ~1.55s of speech |
| Intro→b-roll wipe | circleopen 0.2s, offset = hook end − 0.2 |
| Section transitions | slideleft / radial, 0.25–0.3s |
| Typing a full prompt | 1.3s |
| Thinking/status chips | ≤1.6s, max 2 statuses |
| Card stagger | 0.6s apart, 0.25s entrance |
| Zoom punch | 0.2–0.3s, ±0.10–0.16 zoom delta |
| Caption chunk | 2–6 words, pop-in 0.12s |
| End fade (video) | 0.3s, reaching true black ≥1 frame before video end |
| End fade (audio) | 0.35s, starting after last word ring-out |
| Speech ring-out past transcript end | ~0.2s — always leave it |
| Loudness | −14 LUFS integrated |
