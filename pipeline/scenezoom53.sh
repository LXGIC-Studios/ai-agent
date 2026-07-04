#!/bin/bash
# camera passes for Video 53 (fast punches, dead-still holds). Scene C stays full-frame (scroll is the motion).
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
T="(on/30)"
# A (13.0s): punch composer as typing starts (3.50) -> out (12.40) before send lands
ZA="if(lt($T,3.50),1.0,if(lt($T,3.75),1.0+0.88*($T-3.50),if(lt($T,12.40),1.22,if(lt($T,12.65),1.22-0.88*($T-12.40),1.0))))"
XA="if(lt($T,3.50),0.5,if(lt($T,3.75),0.5-1.0*($T-3.50),if(lt($T,12.40),0.25,if(lt($T,12.65),0.25+1.0*($T-12.40),0.5))))"
YA="if(lt($T,3.50),0.5,if(lt($T,3.75),0.5+0.48*($T-3.50),if(lt($T,12.40),0.62,if(lt($T,12.65),0.62-0.48*($T-12.40),0.5))))"
# B (2.5s): punch onto the streaming plan (0.40), hold to the cut.
# z capped at 1.10 centered: view spans x 49-1031, full text column (52-1032) stays unclipped
ZB="if(lt($T,0.40),1.0,if(lt($T,0.65),1.0+0.4*($T-0.40),1.10))"
XB="0.5"
YB="if(lt($T,0.40),0.5,if(lt($T,0.65),0.5-1.52*($T-0.40),0.12))"
for S in A B; do
  Z=$(eval echo \$Z$S); X=$(eval echo \$X$S); Y=$(eval echo \$Y$S)
  rm -rf frames53_${S}z && mkdir frames53_${S}z
  ffmpeg -y -v error -framerate 30 -i frames53_${S}/f%04d.png -vf "scale=3240:5760,zoompan=z='$Z':x='(iw-iw/zoom)*($X)':y='(ih-ih/zoom)*($Y)':d=1:s=1080x1920:fps=30" -start_number 0 frames53_${S}z/f%04d.png
  echo "$S: $(ls frames53_${S}z | wc -l)"
done
