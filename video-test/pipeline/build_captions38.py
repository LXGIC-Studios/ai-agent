"""Captions for Video 38 (times local to each trimmed segment)."""

INTRO = [  # trim 0.30-2.70, offset 0.0
    ("THIS IS HOW", 0.16, 0.46, False),
    ("YOU CAN EASILY", 0.46, 0.82, False),
    ("SELL ANY PRODUCT", 0.82, 1.62, True),
    ("IN SOCIAL MEDIA", 1.62, 2.40, True),
]
MIDDLE = [  # VO trim 1.05-18.45, offset 2.40
    ("FIRST, OPEN", 0.37, 0.77, False),
    ("CHATGPT", 0.77, 1.49, True),
    ("AND TYPE:", 1.49, 1.67, False),
    ("GIVE ME 10", 1.67, 2.25, True),
    ("DIFFERENT", 2.25, 2.45, False),
    ("MARKETING ANGLES", 2.45, 3.05, True),
    ("TO SELL PRODUCTS", 3.05, 3.79, False),
    ("FOR ANY AUDIENCE", 3.79, 4.85, False),
    ("FOR EACH", 4.85, 5.35, False),
    ("GIVE THE ANGLE", 5.35, 5.85, False),
    ("IN A ONE-LINE", 5.85, 6.49, False),
    ("HEADLINE", 6.49, 7.31, True),
    ("SO I TRIED IT", 7.31, 7.75, False),
    ("WITH PROTEIN POWDER", 7.75, 8.45, True),
    ("FOR GYM BEGINNERS", 8.45, 9.07, True),
    ("AND IT GAVE ME", 9.07, 9.91, False),
    ("10 COMPLETELY", 9.91, 10.51, False),
    ("DIFFERENT", 10.51, 10.85, False),
    ("SELLING IDEAS", 10.85, 11.45, True),
    ("IN SECONDS", 11.45, 12.55, True),
    ("NOW JUST PICK", 12.55, 12.93, False),
    ("THE BEST ANGLE", 12.93, 13.89, True),
    ("TEST IT", 13.89, 14.35, False),
    ("AND YOU BASICALLY GOT", 14.35, 15.21, False),
    ("FREE AD IDEAS", 15.21, 16.11, True),
    ("THAT CAN ACTUALLY", 16.11, 16.75, False),
    ("MAKE YOU MONEY", 16.75, 17.40, True),
]
OUTRO = [  # trim 0.30-3.75, offset 19.80
    ("I HOPE THAT VIDEO", 0.00, 0.66, False),
    ("HELPED YOU OUT", 0.66, 1.06, False),
    ("WITH YOUR SALES", 1.06, 1.42, True),
    ("AND FOLLOW ALONG", 1.42, 2.02, True),
    ("FOR MORE WAYS", 2.02, 2.44, False),
    ("TO MAKE MONEY", 2.44, 2.90, True),
    ("WITH AI", 2.90, 3.60, True),
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
for chunks, off in [(INTRO, 0.0), (MIDDLE, 2.60), (OUTRO, 20.00)]:
    for text, s, e, acc in chunks:
        style = "CapAcc" if acc else "Cap"
        lines.append(f"Dialogue: 0,{ts(max(0, s+off))},{ts(max(0, e+off))},{style},0,0,0,,{POP}{text}")

with open("reel38.ass", "w") as f:
    f.write(HEADER + "\n".join(lines) + "\n")
print(f"reel38.ass written, {len(lines)} caption events")
