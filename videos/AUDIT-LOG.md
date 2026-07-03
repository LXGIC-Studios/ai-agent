# Audit Log

Every video in this folder passed the full [REVIEW-CHECKLIST](../REVIEW-CHECKLIST.md)
on the exact file committed. No video gets committed without an entry here.

| Video | Audited | Result | Notes |
|---|---|---|---|
| claude-books-flights.mp4 | 2026-07-03 | PASS | 30fps contact sheets: intro J-cut boundary clean (eyes-up through wipe), outro tail clean, true black from 32.95. Audio: "websites"/"Tips" ring-outs intact (silencedetect), fade after speech. Holds pixel-still. |
| china-open-source-ai.mp4 | 2026-07-03 | PASS (after fix) | First render FAILED tail audit — look-down began raw 7.43, cut was 7.60. Re-cut to 7.42, black by 36.15. 30fps sheets: outro head + tail clean, intro boundary clean. Audio ring-outs verified. B-roll static-gap fixes applied (bar pulses, strike retimed to "Nvidia's"). |
| local-chatgpt.mp4 | 2026-07-03 | PASS (re-edited) | v1 FAILED (look-away second-angle segment, old grade, clipped "videos"/"free?" tails, no pill, drift zooms). Re-edit: segment replaced with Google→ollama.com b-roll, G73 grade, pill, punch zooms per scene, hook video re-cut at raw 3.20 (hand-reach), outro re-cut 0.42–7.55 (settle + clipped word), fade-to-black ending. First re-render FAILED boundary audit twice (faded reach in wipe, settle after radial) — fixed and verified with 30fps sheets. |
| free-apis-github.mp4 | 2026-07-03 | PASS | 30fps sheets: hook J-cut clean, radial return to camera clean (natural blink only), tail true black by 25.65 with CTA pill above head. Audio: 'link' ring-out intact, fade after speech. Two-clip format: hook + main talking head with b-roll insert. |
| ocoya-auto-poster.mp4 | 2026-07-03 | PASS | Clip tails contact-sheeted BEFORE cutting (hook end 4.60, outro end 5.70, both pre-dip). Render audit: 30fps sheets at hook wipe, radial return, tail — all eyes-up, true black by 40.73. Audio: tips. ring-out intact, fade after. B-roll beats on VO words (4 connects, generate, visual, schedule confirm). |
| five-grand-websites.mp4 | 2026-07-03 | PASS (v2, real-UI rebuild) | B-roll rebuilt screen-for-screen from 10 real durable.com screenshots: quiz steps (type/name/location/details) with per-step icon trios + progress dots, mad-libs summary, foundation checklist, AI-agents assembly, generated BrightSmile site in editor. Beat-sync verified (site on "few minutes", popover on "customizing", outreach on "outdated websites"). His footage/audio identical to audited v1; tail re-verified true black. |
