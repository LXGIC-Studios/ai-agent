# Zhi Reels Studio

Short-form video editing system for the AI-tips account. Claude edits, Zhi talks.

Raw footage in (intro / VO / outro clips + script) → finished 1080x1920 reel out,
with captions, b-roll, grading, and beat-synced motion — ready to post.

**Start here: [EDITING-SYSTEM.md](EDITING-SYSTEM.md)** — the locked style rules,
edit formula, and step-by-step process every video follows.

## Layout

| Path | What |
|---|---|
| [`EDITING-SYSTEM.md`](EDITING-SYSTEM.md) | The bible: style, rules, process, QC |
| [`ASSETS.md`](ASSETS.md) | Raw footage + Drive asset inventory |
| [`examples/`](examples/) | Finished, named, ready-to-post reels |
| [`pipeline/`](pipeline/) | Canonical working set (video 75 = reference implementation) |
| [`archive/`](archive/) | Earlier outputs and pipeline history from the test sessions |

## The pipeline in one line

transcribe words → plan the timeline off word timestamps → render deterministic
HTML b-roll frame-by-frame with Playwright → assemble one ffmpeg filter graph
(grade, punch zooms, wipes, bubble captions, loudnorm) → QC checklist → deliver.
