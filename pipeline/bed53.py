import numpy as np, subprocess

SR = 44100
DUR = 28.73
bed = np.zeros(int(DUR * SR), dtype=np.float64)

def load(path):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-ac", "1", "-ar", str(SR),
                          "-f", "f32le", "-"], capture_output=True).stdout
    return np.frombuffer(raw, dtype=np.float32).astype(np.float64)

def onset(x, thresh=0.12):
    env = np.abs(x)
    k = int(0.002 * SR)
    env = np.convolve(env, np.ones(k) / k, mode="same")
    return np.argmax(env > thresh * env.max()) / SR

def place(sample, t, peak, onset_lead):
    s = sample / (np.abs(sample).max() + 1e-9) * peak
    start = int((t - onset_lead) * SR)
    if start < 0: s = s[-start:]; start = 0
    end = min(start + len(s), len(bed))
    bed[start:end] += s[:end - start]

ding = load("sfx2/2356.wav");  d_on = onset(ding)
whoosh = load("sfx3/1478.mp3"); w_on = onset(whoosh)
thump = load("sfx4/2299.mp3")
thump = thump[:int(0.55 * SR)]
fade = np.linspace(1, 0, int(0.15 * SR)); thump[-len(fade):] *= fade
t_on = onset(thump)

DINGS = [0.25, 16.85, 19.47, 23.69, 27.25]
WHOOSHES = [3.67, 16.67, 19.17, 20.45]
THUMPS = [7.17, 17.07, 27.25]
for t in DINGS: place(ding, t, 0.5, d_on)
for t in WHOOSHES: place(whoosh, t, 0.45, w_on)
for t in THUMPS: place(thump, t, 0.5, t_on)

# creamy passage: continuous untouched 9.15s window of cr00 (found at 23.35s), placed at typing start
cr = load("sfx6/cr00.mp3")
NEED = 9.15
ST = 23.35
seg = cr[int(ST * SR): int((ST + NEED) * SR)].copy()
seg = seg / (np.abs(seg).max() + 1e-9) * 0.4
fi = np.linspace(0, 1, int(0.12 * SR)); seg[:len(fi)] *= fi
fo = np.linspace(1, 0, int(0.30 * SR)); seg[-len(fo):] *= fo
s0 = int(7.07 * SR)
bed[s0:s0 + len(seg)] += seg

m = np.abs(bed).max()
if m > 0.98: bed *= 0.98 / m
subprocess.run(["ffmpeg", "-y", "-v", "error", "-f", "f32le", "-ar", str(SR), "-ac", "1",
                "-i", "-", "bed53.wav"], input=bed.astype(np.float32).tobytes())

env2 = np.abs(bed)
k2 = int(0.005 * SR)
env2 = np.convolve(env2, np.ones(k2) / k2, mode="same")
for name, ts in [("ding", DINGS), ("whoosh", WHOOSHES), ("thump", THUMPS)]:
    for t in ts:
        a, b = int((t - 0.05) * SR), int((t + 0.08) * SR)
        print(f"{name}@{t}: peak {env2[a:b].max():.3f}")
for hs in np.arange(7.0, 16.5, 0.5):
    a, b = int(hs * SR), int((hs + 0.5) * SR)
    print(f"typing {hs:.1f}: rms {np.sqrt((bed[a:b]**2).mean()):.4f}")
