#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="newraw/Raw Short Form/Video 19"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,2.70),1.0,1.0+0.5*($T-2.70)))"
ZG="if(lt($T,1.3),1.02,if(lt($T,1.55),1.02+0.32*($T-1.3),1.10))"
ZT1="if(lt($T,4.3),1.02,if(lt($T,4.55),1.02+0.32*($T-4.3),1.10))"
ZDK="if(lt($T,2.6),1.02,if(lt($T,2.85),1.02+0.24*($T-2.6),1.08))"
ZT2="if(lt($T,5.7),1.02,if(lt($T,5.95),1.02+0.32*($T-5.7),1.10))"
ZDK2="if(lt($T,2.3),1.02,if(lt($T,2.55),1.02+0.32*($T-2.3),1.10))"
ZWB="if(lt($T,1.9),1.02,if(lt($T,2.15),1.02+0.32*($T-1.9),1.10))"
ZO="if(lt($T,6.43),1.0,1.0+0.28*($T-6.43))"
ZP() { echo "zoompan=z='$1':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.45':d=1:s=1080x1920:fps=30"; }
ffmpeg -y -v error \
 -i "$R/IMG_5460.MOV" -i "$R/IMG_5473.MOV" -i "$R/IMG_5475.MOV" \
 -framerate 30 -i b19_G/f%04d.png -framerate 30 -i b19_T1/f%04d.png -framerate 30 -i b19_DK/f%04d.png \
 -framerate 30 -i b19_T2/f%04d.png -framerate 30 -i b19_DK2/f%04d.png -framerate 30 -i b19_WB/f%04d.png \
 -framerate 30 -i caps19/f%04d.png -framerate 30 -i pop_i19/f%04d.png \
 -filter_complex "
[0:v]trim=0.25:3.20,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vh0];
[10:v]setpts=PTS-STARTPTS[opill];
[vh0][opill]overlay=0:0:eof_action=pass[vh];
[3:v]fps=30,setsar=1,scale=3240:5760,$(ZP "$ZG"),format=yuv420p[g];
[4:v]fps=30,setsar=1,scale=3240:5760,$(ZP "$ZT1"),format=yuv420p[t1];
[5:v]fps=30,setsar=1,scale=3240:5760,$(ZP "$ZDK"),format=yuv420p[dk];
[6:v]fps=30,setsar=1,scale=3240:5760,$(ZP "$ZT2"),format=yuv420p[t2];
[7:v]fps=30,setsar=1,scale=3240:5760,$(ZP "$ZDK2"),format=yuv420p[dk2];
[8:v]fps=30,setsar=1,scale=3240:5760,$(ZP "$ZWB"),format=yuv420p[wb];
[2:v]trim=0.42:7.55,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZO':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vo0];
[vo0]copy[vo];
[vh][g]xfade=transition=circleopen:duration=0.2:offset=2.75[x1];
[x1][t1][dk][t2][dk2][wb]concat=n=6:v=1:a=0[mid];
[mid]tpad=stop_mode=clone:stop_duration=0.25,settb=AVTB[midp];
[vo]settb=AVTB[vos];
[midp][vos]xfade=transition=radial:duration=0.25:offset=29.95[x2];
[9:v]setpts=PTS-STARTPTS[ocap]; [x2][ocap]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=36.63:d=0.3[vout];
[0:a]atrim=0.25:3.30,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.08[ah];
[1:a]atrim=0:26.9,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.10[am];
[2:a]atrim=0.42:7.55,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.06[ao];
[ah][am][ao]concat=n=3:v=0:a=1,loudnorm=I=-14:TP=-1.5:LRA=11,afade=t=out:st=36.97:d=0.11,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart local-chatgpt-v2.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 local-chatgpt-v2.mp4
