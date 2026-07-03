"""Captions for Video 73 (times local to trimmed segments)."""

INTRO = [  # trim 0.35-3.55
    ("LET'S MAKE YOU", 0.17, 0.55, False),
    ("SOME MONEY", 0.55, 0.87, True),
    ("BY BUILDING YOU", 0.87, 1.37, False),
    ("A COMPLETE GAME", 1.37, 1.93, True),
    ("WITH CLAUDE", 1.93, 2.37, True),
    ("IN JUST", 2.37, 2.57, False),
    ("60 SECONDS", 2.57, 3.20, True),
]
MIDDLE = [  # VO trim 0.65-18.1167, offset 3.20
    ("FIRST, OPEN", 0.35, 0.71, False),
    ("CLAUDE", 0.71, 1.21, True),
    ("GO TO ARTIFACTS", 1.21, 1.87, True),
    ("AND CREATE", 1.87, 2.31, False),
    ("A NEW ARTIFACT", 2.31, 3.09, True),
    ("DESCRIBE THE GAME", 3.09, 3.67, False),
    ("YOU WANT TO BUILD", 3.67, 4.43, False),
    ("FOR EXAMPLE", 4.43, 4.99, False),
    ("CREATE A FULLY", 4.99, 5.51, False),
    ("PLAYABLE TETRIS GAME", 5.51, 6.49, True),
    ("WITH A PREMIUM", 6.49, 6.95, False),
    ("PURPLE THEME", 6.95, 8.09, True),
    ("CLAUDE WILL FIRST", 8.09, 8.57, False),
    ("SHOW YOU ITS PLAN", 8.57, 9.61, True),
    ("SIMPLY TELL IT", 9.61, 10.13, False),
    ("TO CONTINUE", 10.13, 10.57, True),
    ("AND IN ABOUT", 10.57, 11.05, False),
    ("60 SECONDS", 11.05, 11.73, True),
    ("YOU'LL HAVE", 11.73, 12.05, False),
    ("A FULLY PLAYABLE GAME", 12.05, 12.89, True),
    ("DIRECTLY BUILT", 12.89, 13.77, False),
    ("INSIDE CLAUDE'S", 13.77, 14.55, False),
    ("BUILT-IN PREVIEW", 14.55, 15.59, True),
    ("NO CODING", 15.59, 16.33, True),
    ("NO SEPARATE IDE", 16.33, 17.05, True),
    ("NEEDED", 17.05, 17.45, False),
]
OUTRO = [  # trim 0.30-9.90, offset 20.67
    ("NOW THE NEXT THING", 0.19, 0.60, False),
    ("YOU WANT TO DO", 0.60, 0.98, False),
    ("IS GO AHEAD", 0.98, 1.40, False),
    ("AND PUBLISH THAT GAME", 1.40, 2.18, True),
    ("ON STEAM", 2.18, 2.72, True),
    ("OR THE APP STORE", 2.72, 3.54, True),
    ("AND YOU CAN START", 3.54, 3.92, False),
    ("RUNNING SOME MARKETING", 3.92, 4.58, True),
    ("TOWARDS IT", 4.58, 5.12, False),
    ("AND START MAKING", 5.12, 5.60, False),
    ("SOME MONEY", 5.60, 6.04, True),
    ("I HOPE THIS VIDEO", 6.04, 6.92, False),
    ("HELPED YOU OUT", 6.92, 7.42, False),
    ("AND OF COURSE", 7.42, 7.70, False),
    ("FOLLOW ALONG", 7.70, 8.14, True),
    ("FOR MORE WAYS", 8.14, 8.58, False),
    ("TO MAKE MONEY", 8.58, 9.02, True),
    ("WITH AI", 9.02, 9.60, True),
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
for chunks, off in [(INTRO, 0.0), (MIDDLE, 3.20), (OUTRO, 20.67)]:
    for text, s, e, acc in chunks:
        style = "CapAcc" if acc else "Cap"
        lines.append(f"Dialogue: 0,{ts(max(0, s+off))},{ts(max(0, e+off))},{style},0,0,0,,{POP}{text}")

with open("reel73.ass", "w") as f:
    f.write(HEADER + "\n".join(lines) + "\n")
print(f"reel73.ass written, {len(lines)} caption events")
