#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="newraw/Raw Short Form/Video 34"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,5.82),1.0,1.0+0.5*($T-5.82)))"
ZS1="if(lt($T,0.45),1.04,if(lt($T,0.70),1.04+0.24*($T-0.45),if(lt($T,2.2),1.10,if(lt($T,2.45),1.10-0.32*($T-2.2),if(lt($T,7.0),1.02,if(lt($T,7.25),1.02+0.32*($T-7.0),if(lt($T,8.9),1.10,if(lt($T,9.15),1.10-0.32*($T-8.9),if(lt($T,12.2),1.02,if(lt($T,12.45),1.02+0.32*($T-12.2),if(lt($T,14.3),1.10,if(lt($T,14.55),1.10-0.32*($T-14.3),if(lt($T,19.8),1.02,if(lt($T,20.05),1.02+0.32*($T-19.8),if(lt($T,22.8),1.10,if(lt($T,23.05),1.10-0.32*($T-22.8),1.02))))))))))))))))"
ZO="if(lt($T,8.05),1.0,1.0+0.28*($T-8.05))"
ffmpeg -y -v error \
 -i "$R/DJI_20260622_133455_451_video.MP4" -i "$R/DJI_20260622_140331_397_video.MP4" -i "$R/DJI_20260622_140930_722_video.MP4" \
 -framerate 30 -i b34_S/f%04d.png \
 -framerate 30 -i caps34/f%04d.png -framerate 30 -i pop_i34/f%04d.png \
 -filter_complex "
[0:v]trim=0.28:6.60,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vh0];
[5:v]setpts=PTS-STARTPTS[opill];
[vh0][opill]overlay=0:0:eof_action=pass[vh];
[3:v]fps=30,setsar=1,scale=3240:5760,zoompan=z='$ZS1':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.45':d=1:s=1080x1920:fps=30,format=yuv420p[b1];
[2:v]trim=0.31:9.20,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZO':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vo];
[vh][b1]xfade=transition=circleopen:duration=0.2:offset=6.12[x1];
[x1]tpad=stop_mode=clone:stop_duration=0.25[x1p];
[x1p][vo]xfade=transition=radial:duration=0.25:offset=33.85[x3];
[4:v]setpts=PTS-STARTPTS[ocap]; [x3][ocap]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=42.29:d=0.3,tpad=stop_mode=clone:stop_duration=0.15[vout];
[0:a]atrim=0.28:6.60,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.08[ah];
[1:a]atrim=0.62:28.15,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.25[am];
[2:a]atrim=0.31:9.35,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.06[ao];
[ah][am][ao]concat=n=3:v=0:a=1,loudnorm=I=-14:TP=-1.5:LRA=11,afade=t=out:st=42.73:d=0.16,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart five-grand-websites.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 five-grand-websites.mp4
