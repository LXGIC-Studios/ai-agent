#!/bin/bash
# camera passes over the three Claude scenes (punch-ins on beats, dead-still holds)
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
T="(on/30)"
# A (8.0s): greeting -> punch artifacts (1.5) -> out (2.85) -> punch composer/typing (5.15) -> out (7.72)
ZA="if(lt($T,1.50),1.0,if(lt($T,1.75),1.0+0.88*($T-1.50),if(lt($T,2.85),1.22,if(lt($T,3.10),1.22-0.88*($T-2.85),if(lt($T,5.15),1.0,if(lt($T,5.40),1.0+1.0*($T-5.15),if(lt($T,7.72),1.25,if(lt($T,7.97),1.25-1.0*($T-7.72),1.0))))))))"
YA="if(lt($T,1.50),0.5,if(lt($T,1.75),0.5-0.8*($T-1.50),if(lt($T,2.85),0.30,if(lt($T,3.10),0.30+0.8*($T-2.85),if(lt($T,5.15),0.5,if(lt($T,5.40),0.5+0.4*($T-5.15),if(lt($T,7.72),0.60,if(lt($T,7.97),0.60-0.4*($T-7.72),0.5))))))))"
# B (3.6s): punch plan text (0.35) -> out (3.30)
ZB="if(lt($T,0.35),1.0,if(lt($T,0.60),1.0+0.6*($T-0.35),if(lt($T,3.30),1.15,if(lt($T,3.55),1.15-0.6*($T-3.30),1.0))))"
YB="if(lt($T,0.35),0.5,if(lt($T,0.60),0.5-0.4*($T-0.35),if(lt($T,3.30),0.40,if(lt($T,3.55),0.40+0.4*($T-3.30),0.5))))"
# C (5.867s): punch board (0.76) -> out (3.95) before chips pop
ZC="if(lt($T,0.76),1.0,if(lt($T,1.01),1.0+0.72*($T-0.76),if(lt($T,3.95),1.18,if(lt($T,4.20),1.18-0.72*($T-3.95),1.0))))"
YC="if(lt($T,0.76),0.5,if(lt($T,1.01),0.5-0.32*($T-0.76),if(lt($T,3.95),0.42,if(lt($T,4.20),0.42+0.32*($T-3.95),0.5))))"
XA="if(lt($T,1.50),0.5,if(lt($T,1.75),0.5-1.4*($T-1.50),if(lt($T,7.72),0.15,if(lt($T,7.97),0.15+1.4*($T-7.72),0.5))))"
XB="if(lt($T,0.35),0.5,if(lt($T,0.60),0.5-1.2*($T-0.35),if(lt($T,3.30),0.20,if(lt($T,3.55),0.20+1.2*($T-3.30),0.5))))"
XC="0.5"
for S in A B C; do
  Z=$(eval echo \$Z$S); Y=$(eval echo \$Y$S); X=$(eval echo \$X$S)
  rm -rf frames73_${S}z && mkdir frames73_${S}z
  ffmpeg -y -v error -framerate 30 -i frames73_${S}/f%04d.png -vf "scale=3240:5760,zoompan=z='$Z':x='(iw-iw/zoom)*($X)':y='(ih-ih/zoom)*($Y)':d=1:s=1080x1920:fps=30" -start_number 0 frames73_${S}z/f%04d.png
  echo "$S: $(ls frames73_${S}z | wc -l)"
done
