#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="drive73/Testing/Raw53"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
# intro: settle-in, zoom-in into the wipe at local 3.67 (starts 0.2 early)
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,3.47),1.0,1.0+0.5*($T-3.47)))"
# outro (8.03s from raw 0.1): punch on 'follow along' (local 6.80), slow push into the fade (local 7.69)
ZO="if(lt($T,6.80),1.0,if(lt($T,7.05),1.0+0.24*($T-6.80),if(lt($T,7.69),1.06,1.06+0.4*($T-7.69))))"
ZP="x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30"
ffmpeg -y -v error \
 -i "$R/DJI_20260628_155737_790_video.MP4" -i "$R/DJI_20260628_160011_880_video.MP4" -i "$R/DJI_20260628_160217_479_video.MP4" \
 -framerate 30 -i frames53_Az/f%04d.png -framerate 30 -i frames53_Bz/f%04d.png -framerate 30 -i frames53_C/f%04d.png \
 -framerate 30 -i pop53/f%04d.png -framerate 30 -i caps53/f%04d.png -i bed53.wav \
 -filter_complex "
[0:v]trim=0.55:4.42,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':$ZP,format=yuv420p[vh];
[3:v]setsar=1,format=yuv420p[ba];
[4:v]setsar=1,format=yuv420p[bb];
[5:v]setsar=1,format=yuv420p[bc];
[ba][bb][bc]concat=n=3:v=1:a=0,tpad=stop_mode=clone:stop_duration=0.30,settb=AVTB,fps=30[br];
[vh]settb=AVTB,fps=30[vhs];
[vhs][br]xfade=transition=circleopen:duration=0.2:offset=3.67[x1];
[2:v]trim=0.1:8.13,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZO':$ZP,format=yuv420p,settb=AVTB,fps=30[vo];
[x1]settb=AVTB,fps=30[x1s];
[x1s][vo]xfade=transition=radial:duration=0.25:offset=20.45[x2];
[6:v]setpts=PTS-STARTPTS[pops];
[x2][pops]overlay=0:0:eof_action=pass[y1];
[7:v]setpts=PTS-STARTPTS[caps];
[y1][caps]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=28.14:d=0.30,tpad=stop_mode=clone:stop_duration=0.25[vout];
[0:a]atrim=0.55:4.22,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.05,afade=t=out:st=3.64:d=0.03[a1];
[1:a]atrim=0:16.78,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.03,afade=t=out:st=16.75:d=0.03[a2];
[2:a]atrim=0.1:8.13,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.03[a3];
[a1][a2][a3]concat=n=3:v=0:a=1,apad=whole_dur=28.73,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=44100,afade=t=out:st=28.45:d=0.25[vc];
[8:a]volume=0.65,aresample=44100[bed];
[vc][bed]amix=inputs=2:duration=first:normalize=0,afade=t=out:st=28.50:d=0.20,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart 53-ai-business-plan.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 53-ai-business-plan.mp4
