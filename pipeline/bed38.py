import numpy as np, subprocess, json

SR = 44100
DUR = 24.22
bed = np.zeros(int(DUR * SR), dtype=np.float64)

def load(path):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-ac", "1", "-ar", str(SR),
                          "-f", "f32le", "-"], capture_output=True).stdout
    return np.frombuffer(raw, dtype=np.float32).astype(np.float64)

def onset(x, thresh=0.12):
    env = np.abs(x)
    k = int(0.002 * SR)
    env = np.convolve(env, np.ones(k) / k, mode="same")
    idx = np.argmax(env > thresh * env.max())
    return idx / SR

def place(sample, t, peak, onset_lead):
    s = sample / (np.abs(sample).max() + 1e-9) * peak
    start = int((t - onset_lead) * SR)
    if start < 0:
        s = s[-start:]; start = 0
    end = min(start + len(s), len(bed))
    bed[start:end] += s[:end - start]

ding = load("sfx2/2356.wav");  d_on = onset(ding)
whoosh = load("sfx3/1478.mp3"); w_on = onset(whoosh)
thump = load("sfx4/2299.mp3")
thump = thump[:int(0.55 * SR)]
fade = np.linspace(1, 0, int(0.15 * SR)); thump[-len(fade):] *= fade
t_on = onset(thump)
print(f"onsets ding={d_on:.3f} whoosh={w_on:.3f} thump={t_on:.3f}")

for t in [0.25, 18.05, 22.22]: place(ding, t, 0.5, d_on)
for t in [2.52, 9.72, 20.37]:  place(whoosh, t, 0.45, w_on)
for t in [3.02, 11.72, 15.82, 21.99]: place(thump, t, 0.5, t_on)

# --- creamy typing passage: continuous UNTOUCHED window from cr00 ---
cr = load("sfx6/cr00.mp3")
NEED = 9.25 - 2.72  # 6.53s
env = np.abs(cr)
k = int(0.004 * SR)
env = np.convolve(env, np.ones(k) / k, mode="same")
th = 0.25 * env.max()
above = env > th
# onset times: rising edges with 60ms refractory
ons = []
i = 0
while i < len(above):
    if above[i]:
        ons.append(i / SR)
        i += int(0.06 * SR)
    else:
        i += 1
ons = np.array(ons)
best = None
step = 0.05
for st in np.arange(0.0, len(cr) / SR - NEED - 0.05, step):
    en = st + NEED
    w = ons[(ons >= st) & (ons <= en)]
    if len(w) < 8: continue
    first = w[0] - st
    last = en - w[-1]
    gaps = np.diff(np.concatenate([[st], w, [en]]))
    maxgap = gaps.max()
    if first > 0.2 or maxgap > 0.55: continue
    score = -last - 0.5 * maxgap + 0.02 * len(w)
    if best is None or score > best[0]:
        best = (score, st, first, last, maxgap, len(w))
if best is None:
    raise SystemExit("no valid passage window found in cr00")
_, st, first, last, maxgap, n = best
print(f"passage: start={st:.2f}s first_key={first:.3f} last_gap={last:.3f} maxgap={maxgap:.3f} keys={n}")
seg = cr[int(st * SR): int((st + NEED) * SR)].copy()
seg = seg / (np.abs(seg).max() + 1e-9) * 0.4
fi = np.linspace(0, 1, int(0.12 * SR)); seg[:len(fi)] *= fi
fo = np.linspace(1, 0, int(0.30 * SR)); seg[-len(fo):] *= fo
s0 = int(2.72 * SR)
bed[s0:s0 + len(seg)] += seg

m = np.abs(bed).max()
if m > 0.98: bed *= 0.98 / m
bed32 = bed.astype(np.float32)
subprocess.run(["ffmpeg", "-y", "-v", "error", "-f", "f32le", "-ar", str(SR), "-ac", "1",
                "-i", "-", "bed38.wav"], input=bed32.tobytes())

# verify transient positions in the built bed
env2 = np.abs(bed)
k2 = int(0.005 * SR)
env2 = np.convolve(env2, np.ones(k2) / k2, mode="same")
for name, t in [("ding", 0.25), ("whoosh", 2.52), ("thump", 3.02), ("cut", 9.72),
                ("thump", 11.72), ("thump", 15.82), ("ding", 18.05), ("whoosh", 20.37),
                ("thump", 21.99), ("ding", 22.22)]:
    a, b = int((t - 0.05) * SR), int((t + 0.08) * SR)
    print(f"{name}@{t}: local peak {env2[a:b].max():.3f}")
# typing energy per half second across window
for hs in np.arange(2.5, 9.5, 0.5):
    a, b = int(hs * SR), int((hs + 0.5) * SR)
    print(f"typing {hs:.1f}-{hs+0.5:.1f}: rms {np.sqrt((bed[a:b]**2).mean()):.4f}")
