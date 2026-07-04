#!/bin/bash
# big-board tour: full view -> KPI sweep -> big chart -> products -> donut -> hours -> orders -> full
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
T="(on/30)"
Z="if(lt($T,1.50),1.0,if(lt($T,1.80),1.0+3.333*($T-1.50),if(lt($T,7.15),2.0,if(lt($T,7.50),2.0-2.857*($T-7.15),1.0))))"
CX="if(lt($T,1.80),0.0,if(lt($T,2.70),0.0+1.111*($T-1.80),if(lt($T,2.70),1.0,if(lt($T,3.00),1.0-2.653*($T-2.70),if(lt($T,3.80),0.204,if(lt($T,4.10),0.204-0.37*($T-3.80),if(lt($T,4.70),0.093,if(lt($T,5.00),0.093+3.023*($T-4.70),if(lt($T,5.60),1.0,if(lt($T,5.90),1.0-3.023*($T-5.60),if(lt($T,6.60),0.093,if(lt($T,6.90),0.093+3.023*($T-6.60),1.0))))))))))))"
CY="if(lt($T,1.80),0.05,if(lt($T,2.70),0.05,if(lt($T,3.00),0.05-0.0567*($T-2.70),if(lt($T,3.80),0.033,if(lt($T,4.10),0.033+1.0767*($T-3.80),if(lt($T,5.60),0.356,if(lt($T,5.90),0.356+1.0133*($T-5.60),if(lt($T,7.15),0.66,if(lt($T,7.50),0.66-1.8857*($T-7.15),0.0)))))))))"
rm -rf dash74zoom && mkdir dash74zoom
ffmpeg -y -v error -framerate 30 -i dashbig74cap/f%03d.png -vf "zoompan=z='$Z':x='(iw-iw/zoom)*($CX)':y='(ih-ih/zoom)*($CY)':d=1:s=1080x1920:fps=30" -start_number 0 dash74zoom/f%03d.png
ls dash74zoom | wc -l
