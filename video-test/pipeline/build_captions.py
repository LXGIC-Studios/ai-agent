"""Build styled ASS captions from corrected word-timing chunks."""

# (text, start, end, accent) — times local to each part, offsets applied below
INTRO = [  # clip1, offset 0.0
    ("I RECENTLY BUILT", 0.00, 1.16, False),
    ("AN ENTIRE", 1.16, 1.74, False),
    ("BUSINESS PLAN", 1.74, 2.12, True),
    ("WITH AI", 2.12, 2.50, True),
    ("IN JUST", 2.50, 2.96, False),
    ("15 MINUTES", 2.96, 3.38, True),
    ("HERE'S HOW", 3.38, 3.64, False),
    ("TO GET STARTED", 3.64, 4.05, False),
]
MIDDLE = [  # clip2 audio, offset 4.30
    ("FIRST, OPEN", 0.00, 1.24, False),
    ("CHATGPT, CLAUDE,", 1.24, 2.12, True),
    ("OR WHATEVER AI", 2.12, 2.78, False),
    ("YOU'RE USING", 2.78, 3.36, False),
    ("AND DESCRIBE", 3.36, 3.78, False),
    ("YOUR BUSINESS IDEA", 3.78, 4.66, True),
    ("ASK IT TO CREATE", 4.66, 5.40, False),
    ("A COMPLETE", 5.40, 5.86, False),
    ("BUSINESS PLAN", 5.86, 6.50, True),
    ("WITH AN", 6.50, 6.96, False),
    ("EXECUTIVE SUMMARY", 6.96, 7.78, True),
    ("MARKET ANALYSIS", 7.78, 8.82, True),
    ("COMPETITIVE RESEARCH", 8.82, 9.84, True),
    ("REVENUE MODEL", 9.84, 10.74, True),
    ("MARKETING STRATEGY", 10.74, 11.74, True),
    ("AND A", 11.74, 12.04, False),
    ("12-MONTH ROADMAP", 12.04, 13.12, True),
    ("IN SECONDS", 13.12, 13.58, False),
    ("IT'LL GENERATE", 13.58, 13.94, False),
    ("A POLISHED PLAN", 13.94, 14.64, True),
    ("THAT YOU CAN COPY", 14.64, 15.32, False),
    ("INTO ANY DOCUMENT", 15.32, 16.10, False),
    ("AND CUSTOMIZE", 16.10, 16.90, True),
]
OUTRO = [  # clip3, offset 21.20
    ("THIS IS A", 0.00, 0.76, False),
    ("GREAT TOOL", 0.76, 1.48, False),
    ("TO CREATE ANY", 1.48, 1.88, False),
    ("BUSINESS PLAN", 1.88, 2.40, True),
    ("SO YOU CAN START", 2.40, 2.90, False),
    ("PITCHING", 2.90, 3.36, True),
    ("TO INVESTORS", 3.36, 4.16, True),
    ("OR JUST GETTING", 4.16, 4.68, False),
    ("YOUR IDEA", 4.68, 5.22, False),
    ("OUT THERE", 5.22, 5.74, False),
    ("I HOPE THIS VIDEO", 5.74, 6.28, False),
    ("HELPED YOU OUT", 6.28, 6.90, False),
    ("FOLLOW ALONG", 6.90, 7.38, True),
    ("FOR MY AI TIPS", 7.38, 7.95, True),
]

def ts(t):
    h = int(t // 3600); m = int(t % 3600 // 60); s = t % 60
    return f"{h}:{m:02d}:{s:05.2f}"

HEADER = """[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
WrapStyle: 2
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Cap,Montserrat ExtraBold,74,&H00FFFFFF,&H00FFFFFF,&H00000000,&H96000000,-1,0,0,0,100,100,1,0,1,9,3,2,60,60,470,1
Style: CapAcc,Montserrat ExtraBold,74,&H007DC319,&H00FFFFFF,&H00000000,&H96000000,-1,0,0,0,100,100,1,0,1,9,3,2,60,60,470,1

[Events]
Format: Layer, Start, End, Style, MarginL, MarginR, MarginV, Effect, Text
"""

POP = r"{\fscx82\fscy82\t(0,80,\fscx100\fscy100)}"

lines = []
for chunks, off in [(INTRO, -0.45), (MIDDLE, 3.60), (OUTRO, 20.50)]:
    for text, s, e, acc in chunks:
        style = "CapAcc" if acc else "Cap"
        lines.append(f"Dialogue: 0,{ts(max(0, s+off))},{ts(max(0, e+off))},{style},0,0,0,,{POP}{text}")

with open("reel.ass", "w") as f:
    f.write(HEADER + "\n".join(lines) + "\n")
print(f"reel.ass written, {len(lines)} caption events")
