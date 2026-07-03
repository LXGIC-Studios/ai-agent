# Audit Log

Every video in this folder passed the full [REVIEW-CHECKLIST](../REVIEW-CHECKLIST.md)
on the exact file committed. No video gets committed without an entry here.

| Video | Audited | Result | Notes |
|---|---|---|---|
| claude-books-flights.mp4 | 2026-07-03 | PASS | 30fps contact sheets: intro J-cut boundary clean (eyes-up through wipe), outro tail clean, true black from 32.95. Audio: "websites"/"Tips" ring-outs intact (silencedetect), fade after speech. Holds pixel-still. |
| china-open-source-ai.mp4 | 2026-07-03 | PASS (after fix) | First render FAILED tail audit — look-down began raw 7.43, cut was 7.60. Re-cut to 7.42, black by 36.15. 30fps sheets: outro head + tail clean, intro boundary clean. Audio ring-outs verified. B-roll static-gap fixes applied (bar pulses, strike retimed to "Nvidia's"). |
| local-chatgpt.mp4 | 2026-07-03 | **FAIL — pulled from repo** | Second-angle segment (~3.5–5.5s) shows him looking away/down on "Ollama… download it"; predates locked rules. Needs re-edit: replace that segment with Google-search → ollama.com b-roll. Source assets preserved in session scratchpad. |
