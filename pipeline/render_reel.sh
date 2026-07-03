#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="newraw/Raw Short Form/Video 75"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,1.25),1.0,1.0+0.5*($T-1.25)))"
ZA="if(lt($T,0.6),1.0+0.25*$T,1.15)"
ZBC="if(lt($T,0.5),1.04+0.32*$T,if(lt($T,2.0),1.20,if(lt($T,2.25),1.20-0.8*($T-2.0),if(lt($T,4.1),1.0,if(lt($T,4.35),1.0+0.48*($T-4.1),if(lt($T,8.3),1.12,if(lt($T,8.55),1.12-0.4*($T-8.3),if(lt($T,11.0),1.02,if(lt($T,11.25),1.02+0.48*($T-11.0),if(lt($T,14.2),1.14,if(lt($T,14.45),1.14-0.48*($T-14.2),if(lt($T,15.8),1.02,if(lt($T,16.05),1.0+0.24*($T-15.8),1.06)))))))))))))"
YBC="if(lt($T,2.25),0.62,0.45)"
ZO="if(lt($T,8.80),1.0,1.0+0.28*($T-8.80))"
ffmpeg -y -v error \
 -i "$R/DJI_20260702_160147_685_video.MP4" -i "$R/DJI_20260702_160211_302_video.MP4" -i "$R/DJI_20260702_160314_026_video.MP4" \
 -framerate 30 -i b75_A/f%04d.png -framerate 30 -i b75_BC/f%04d.png \
 -framerate 30 -i caps75/f%04d.png -framerate 30 -i pop_i75/f%04d.png \
 -filter_complex "
[0:v]trim=0.17:1.72,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vh0];
[6:v]setpts=PTS-STARTPTS[opill];
[vh0][opill]overlay=0:0:eof_action=pass[vh];
[3:v]fps=30,setsar=1,scale=3240:5760,zoompan=z='$ZA':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.55':d=1:s=1080x1920:fps=30,format=yuv420p[ba];
[4:v]fps=30,setsar=1,scale=3240:5760,zoompan=z='$ZBC':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*($YBC)':d=1:s=1080x1920:fps=30,format=yuv420p[bbc];
[2:v]trim=0.25:9.60,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZO':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vo];
[vh][ba]xfade=transition=circleopen:duration=0.2:offset=1.35[x1];
[x1]tpad=stop_mode=clone:stop_duration=0.45[x1p];
[x1p][bbc]xfade=transition=slideleft:duration=0.25:offset=5.65[x2];
[x2]tpad=stop_mode=clone:stop_duration=0.55[x2p];
[x2p][vo]xfade=transition=radial:duration=0.3:offset=23.90[x3];
[5:v]setpts=PTS-STARTPTS[ocap]; [x3][ocap]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=32.95:d=0.3,tpad=stop_mode=clone:stop_duration=0.2[vout];
[0:a]atrim=0.17:1.72,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.08[ah];
[1:a]atrim=0.65:23.00,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.25[am];
[2:a]atrim=0.25:9.80,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.06[ao];
[ah][am][ao]concat=n=3:v=0:a=1,loudnorm=I=-14:TP=-1.5:LRA=11,afade=t=out:st=33.10:d=0.35,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart claude-books-flights-v10.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 claude-books-flights-v10.mp4
