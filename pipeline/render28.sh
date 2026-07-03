#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="newraw/Raw Short Form/Video 28"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,3.99),1.0,1.0+0.5*($T-3.99)))"
ZS="if(lt($T,0.15),1.04,if(lt($T,0.4),1.04+0.24*($T-0.15),if(lt($T,5.51),1.10,if(lt($T,5.76),1.10-0.32*($T-5.51),if(lt($T,8.45),1.02,if(lt($T,8.70),1.02+0.32*($T-8.45),if(lt($T,15.2),1.10,if(lt($T,15.45),1.10-0.32*($T-15.2),if(lt($T,17.85),1.02,if(lt($T,18.10),1.02+0.32*($T-17.85),if(lt($T,23.0),1.10,if(lt($T,23.25),1.10-0.32*($T-23.0),if(lt($T,25.5),1.02,if(lt($T,25.75),1.02+0.32*($T-25.5),if(lt($T,29.0),1.10,if(lt($T,29.25),1.10-0.32*($T-29.0),1.02))))))))))))))))"
ZO="if(lt($T,4.78),1.0,1.0+0.28*($T-4.78))"
ffmpeg -y -v error \
 -i "$R/DJI_20260619_175057_609_video.MP4" -i "$R/DJI_20260619_174620_944_video.MP4" -i "$R/DJI_20260619_174757_557_video.MP4" \
 -framerate 30 -i b28_S/f%04d.png -framerate 30 -i caps28/f%04d.png -framerate 30 -i pop_i28/f%04d.png \
 -filter_complex "
[0:v]trim=0.31:4.60,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vh0];
[5:v]setpts=PTS-STARTPTS[opill];
[vh0][opill]overlay=0:0:eof_action=pass[vh];
[3:v]fps=30,setsar=1,scale=3240:5760,zoompan=z='$ZS':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.45':d=1:s=1080x1920:fps=30,format=yuv420p[b1];
[2:v]trim=0.30:5.70,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZO':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vo];
[vh][b1]xfade=transition=circleopen:duration=0.2:offset=4.09[x1];
[x1]tpad=stop_mode=clone:stop_duration=0.25[x1p];
[x1p][vo]xfade=transition=radial:duration=0.25:offset=35.39[x2];
[4:v]setpts=PTS-STARTPTS[ocap]; [x2][ocap]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=40.42:d=0.3,tpad=stop_mode=clone:stop_duration=0.40[vout];
[0:a]atrim=0.31:4.60,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.08[ah];
[1:a]atrim=0.65:31.75,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.20[am];
[2:a]atrim=0.30:6.10,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.06[ao];
[ah][am][ao]concat=n=3:v=0:a=1,loudnorm=I=-14:TP=-1.5:LRA=11,afade=t=out:st=40.98:d=0.21,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart ocoya-auto-poster.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 ocoya-auto-poster.mp4
