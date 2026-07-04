#!/bin/bash
# camera work over the dashboard: open tight on revenue KPI, sweep the KPI row,
# glide to the chart, punch to products, pan to donut, out, punch to goal, out.
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
T="(on/30)"
Z="if(lt($T,1.55),1.45,if(lt($T,1.85),1.45-0.9*($T-1.55),if(lt($T,2.95),1.18,if(lt($T,3.25),1.18+0.5667*($T-2.95),if(lt($T,5.10),1.35,if(lt($T,5.35),1.35-1.4*($T-5.10),if(lt($T,5.65),1.0,if(lt($T,5.90),1.0+0.6*($T-5.65),if(lt($T,7.15),1.15,if(lt($T,7.40),1.15-0.6*($T-7.15),1.0))))))))))"
CX="if(lt($T,0.45),0.15,if(lt($T,1.55),0.15+0.6364*($T-0.45),if(lt($T,1.85),0.85-1.1667*($T-1.55),if(lt($T,2.95),0.5,if(lt($T,3.25),0.5-0.9333*($T-2.95),if(lt($T,4.00),0.22,if(lt($T,4.30),0.22+2.0*($T-4.00),if(lt($T,5.10),0.82,if(lt($T,5.35),0.82-1.28*($T-5.10),0.5)))))))))"
CY="if(lt($T,1.55),0.10,if(lt($T,1.85),0.10+0.6667*($T-1.55),if(lt($T,2.95),0.30,if(lt($T,3.25),0.30+0.8167*($T-2.95),if(lt($T,5.10),0.545,if(lt($T,5.35),0.545-0.18*($T-5.10),if(lt($T,5.65),0.5,if(lt($T,5.90),0.5+0.62*($T-5.65),if(lt($T,7.15),0.655,if(lt($T,7.40),0.655-0.62*($T-7.15),0.5))))))))))"
rm -rf dash74zoom && mkdir dash74zoom
ffmpeg -y -v error -framerate 30 -i dash74cap/f%03d.png -vf "scale=3240:5760,zoompan=z='$Z':x='(iw-iw/zoom)*($CX)':y='(ih-ih/zoom)*($CY)':d=1:s=1080x1920:fps=30" -start_number 0 dash74zoom/f%03d.png
ls dash74zoom | wc -l
