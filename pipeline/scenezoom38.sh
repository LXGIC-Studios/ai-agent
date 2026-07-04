#!/bin/bash
# camera passes over the two ChatGPT scenes (fast punches, dead-still holds)
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
T="(on/30)"
# A (7.2s): punch composer (0.50) while prompt types -> out (5.90) before send lands
ZA="if(lt($T,0.50),1.0,if(lt($T,0.75),1.0+1.0*($T-0.50),if(lt($T,5.90),1.25,if(lt($T,6.15),1.25-1.0*($T-5.90),1.0))))"
XA="if(lt($T,0.50),0.5,if(lt($T,0.75),0.5-1.0*($T-0.50),if(lt($T,5.90),0.25,if(lt($T,6.15),0.25+1.0*($T-5.90),0.5))))"
YA="if(lt($T,0.50),0.5,if(lt($T,0.75),0.5+0.6*($T-0.50),if(lt($T,5.90),0.65,if(lt($T,6.15),0.65-0.6*($T-5.90),0.5))))"
# B (10.2s): punch list as angles land (2.00) -> push onto green pick (6.10) -> out (8.00) before chip pops
ZB="if(lt($T,2.00),1.0,if(lt($T,2.25),1.0+0.8*($T-2.00),if(lt($T,6.10),1.2,if(lt($T,6.35),1.2+0.4*($T-6.10),if(lt($T,8.00),1.3,if(lt($T,8.25),1.3-1.2*($T-8.00),1.0))))))"
XB="0.5"
YB="if(lt($T,2.00),0.5,if(lt($T,2.25),0.5-1.6*($T-2.00),if(lt($T,6.10),0.10,if(lt($T,6.35),0.10-0.32*($T-6.10),if(lt($T,8.00),0.02,if(lt($T,8.25),0.02+1.92*($T-8.00),0.5))))))"
for S in A B; do
  Z=$(eval echo \$Z$S); X=$(eval echo \$X$S); Y=$(eval echo \$Y$S)
  rm -rf frames38_${S}z && mkdir frames38_${S}z
  ffmpeg -y -v error -framerate 30 -i frames38_${S}/f%04d.png -vf "scale=3240:5760,zoompan=z='$Z':x='(iw-iw/zoom)*($X)':y='(ih-ih/zoom)*($Y)':d=1:s=1080x1920:fps=30" -start_number 0 frames38_${S}z/f%04d.png
  echo "$S: $(ls frames38_${S}z | wc -l)"
done
