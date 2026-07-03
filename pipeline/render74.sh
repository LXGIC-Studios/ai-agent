#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="newraw/Raw Short Form/Video 74"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,1.86),1.0,1.0+0.5*($T-1.86)))"
ZS1="if(lt($T,1.65),1.04,if(lt($T,1.90),1.04+0.32*($T-1.65),if(lt($T,3.23),1.12,if(lt($T,3.48),1.12-0.4*($T-3.23),if(lt($T,9.17),1.02,if(lt($T,9.42),1.02+0.32*($T-9.17),if(lt($T,13.13),1.10,if(lt($T,13.38),1.10+0.24*($T-13.13),1.16))))))))"
ZM="if(lt($T,5.60),1.0,if(lt($T,5.85),1.0+0.4*($T-5.60),1.10))"
ffmpeg -y -v error \
 -i "$R/DJI_20260702_160024_209_video.MP4" -i "$R/DJI_20260702_155922_175_video.MP4" \
 -framerate 30 -i b74_S1/f%04d.png -framerate 30 -i caps74/f%04d.png \
 -framerate 30 -i pop_i74/f%04d.png -framerate 30 -i pop_cta74/f%04d.png \
 -filter_complex "
[0:v]trim=0.16:2.32,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vh0];
[4:v]setpts=PTS-STARTPTS[opill];
[vh0][opill]overlay=0:0:eof_action=pass[vh];
[2:v]fps=30,setsar=1,scale=3240:5760,zoompan=z='$ZS1':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.45':d=1:s=1080x1920:fps=30,format=yuv420p[b1];
[1:v]trim=16.26:23.95,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZM':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vm0];
[5:v]setpts=PTS-STARTPTS[ocpill];
[vm0][ocpill]overlay=0:0:eof_action=pass[vm];
[vh][b1]xfade=transition=circleopen:duration=0.2:offset=1.96[x1];
[x1]tpad=stop_mode=clone:stop_duration=0.25[x1p];
[x1p][vm]xfade=transition=radial:duration=0.25:offset=17.97[x2];
[3:v]setpts=PTS-STARTPTS[ocap]; [x2][ocap]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=25.30:d=0.3,tpad=stop_mode=clone:stop_duration=0.15[vout];
[0:a]atrim=0.16:2.32,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.08[ah];
[1:a]atrim=0.45:24.10,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.20[am];
[ah][am]concat=n=2:v=0:a=1,loudnorm=I=-14:TP=-1.5:LRA=11,afade=t=out:st=25.42:d=0.39,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart free-apis-github.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 free-apis-github.mp4
