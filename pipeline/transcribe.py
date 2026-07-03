"""Word-level timestamps for every raw clip -> words.json.

Usage: python3 transcribe.py "Raw Short Form/Video 75" words75.json
Fix mishears against the script by hand before using the map for timing.
"""
import json, pathlib, sys

from faster_whisper import WhisperModel

src = pathlib.Path(sys.argv[1])
out = sys.argv[2]
model = WhisperModel("small", compute_type="int8")

result = {}
for clip in sorted(src.glob("*.MP4")) + sorted(src.glob("*.MOV")):
    segments, _ = model.transcribe(str(clip), word_timestamps=True)
    words = [{"w": w.word.strip(), "s": round(w.start, 2), "e": round(w.end, 2)}
             for seg in segments for w in seg.words]
    result[clip.name] = words
    print(clip.name, len(words), "words")

json.dump(result, open(out, "w"))
print("wrote", out)
