#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="drive73/Testing/Raw38"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
# intro: settle-in, then zoom-in into the wipe at 2.52 (starts 0.2 early)
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,2.32),1.0,1.0+0.5*($T-2.32)))"
# outro (3.60s from raw 0.1): punch on 'follow along' (global 21.99 = local 1.62), slow push into the fade
ZO="if(lt($T,1.62),1.0,if(lt($T,1.87),1.0+0.24*($T-1.62),if(lt($T,3.26),1.06,1.06+0.4*($T-3.26))))"
ZP="x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30"
ffmpeg -y -v error \
 -i "$R/Intro.MP4" -i "$R/DJI_20260624_163152_503_video.mp4" -i "$R/Outro.MP4" \
 -framerate 30 -i frames38_Az/f%04d.png -framerate 30 -i frames38_Bz/f%04d.png \
 -framerate 30 -i pop38/f%04d.png -framerate 30 -i caps38/f%04d.png -i bed38.wav \
 -filter_complex "
[0:v]trim=0.05:2.92,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':$ZP,format=yuv420p[vh];
[3:v]setsar=1,format=yuv420p[ba];
[4:v]setsar=1,format=yuv420p[bb];
[ba][bb]concat=n=2:v=1:a=0,tpad=stop_mode=clone:stop_duration=0.93,settb=AVTB,fps=30[br];
[vh]settb=AVTB,fps=30[vhs];
[vhs][br]xfade=transition=circleopen:duration=0.2:offset=2.52[x1];
[2:v]trim=0.1:3.70,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZO':$ZP,format=yuv420p,settb=AVTB,fps=30[vo];
[x1]settb=AVTB,fps=30[x1s];
[x1s][vo]xfade=transition=radial:duration=0.25:offset=20.37[x2];
[5:v]setpts=PTS-STARTPTS[pops];
[x2][pops]overlay=0:0:eof_action=pass[y1];
[6:v]setpts=PTS-STARTPTS[caps];
[y1][caps]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=23.63:d=0.30,tpad=stop_mode=clone:stop_duration=0.25[vout];
[0:a]atrim=0.05:2.77,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.05,afade=t=out:st=2.69:d=0.03[a1];
[1:a]atrim=0.95:18.60,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.03,afade=t=out:st=17.62:d=0.03[a2];
[2:a]atrim=0.1:3.70,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.03[a3];
[a1][a2][a3]concat=n=3:v=0:a=1,apad=whole_dur=24.22,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=44100,afade=t=out:st=23.93:d=0.25[vc];
[7:a]volume=0.65,aresample=44100[bed];
[vc][bed]amix=inputs=2:duration=first:normalize=0,afade=t=out:st=24.00:d=0.20,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart 38-chatgpt-marketing-angles.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 38-chatgpt-marketing-angles.mp4
