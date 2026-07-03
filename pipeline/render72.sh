#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="newraw/Raw Short Form/Video 72"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,2.61),1.0,1.0+0.5*($T-2.61)))"
ZS1="if(lt($T,0.74),1.04,if(lt($T,0.99),1.04+0.32*($T-0.74),if(lt($T,3.14),1.12,if(lt($T,3.39),1.12-0.4*($T-3.14),if(lt($T,9.46),1.02,if(lt($T,9.71),1.02+0.32*($T-9.46),if(lt($T,11.6),1.10,if(lt($T,11.85),1.10+0.32*($T-11.6),1.18))))))))"
ZS2="if(lt($T,4.02),1.04,if(lt($T,4.27),1.04+0.32*($T-4.02),if(lt($T,7.66),1.12,if(lt($T,7.91),1.12-0.4*($T-7.66),if(lt($T,9.40),1.02,if(lt($T,9.65),1.02+0.48*($T-9.40),1.14))))))"
ZO="if(lt($T,6.80),1.0,1.0+0.28*($T-6.80))"
ffmpeg -y -v error \
 -i "$R/DJI_20260702_153524_485_video.MP4" -i "$R/DJI_20260702_153748_241_video.MP4" -i "$R/DJI_20260702_153952_376_video.MP4" \
 -framerate 30 -i b72_S1/f%04d.png -framerate 30 -i b72_S2/f%04d.png \
 -framerate 30 -i caps72/f%04d.png -framerate 30 -i pop_i72/f%04d.png \
 -filter_complex "
[0:v]trim=0.38:3.29,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vh0];
[6:v]setpts=PTS-STARTPTS[opill];
[vh0][opill]overlay=0:0:eof_action=pass[vh];
[3:v]fps=30,setsar=1,scale=3240:5760,zoompan=z='$ZS1':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.45':d=1:s=1080x1920:fps=30,format=yuv420p[b1];
[4:v]fps=30,setsar=1,scale=3240:5760,zoompan=z='$ZS2':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.45':d=1:s=1080x1920:fps=30,format=yuv420p[b2];
[2:v]trim=0.30:7.60,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZO':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vo];
[vh][b1]xfade=transition=circleopen:duration=0.2:offset=2.71[x1];
[x1]tpad=stop_mode=clone:stop_duration=0.25[x1p];
[x1p][b2]xfade=transition=slideleft:duration=0.25:offset=17.51[x2];
[x2]tpad=stop_mode=clone:stop_duration=0.3[x2p];
[x2p][vo]xfade=transition=radial:duration=0.3:offset=29.06[x3];
[5:v]setpts=PTS-STARTPTS[ocap]; [x3][ocap]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=36.00:d=0.3,tpad=stop_mode=clone:stop_duration=0.05[vout];
[0:a]atrim=0.38:3.29,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.08[ah];
[1:a]atrim=0.90:27.05,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.25[am];
[2:a]atrim=0.30:7.65,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.06[ao];
[ah][am][ao]concat=n=3:v=0:a=1,loudnorm=I=-14:TP=-1.5:LRA=11,afade=t=out:st=36.12:d=0.29,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart china-open-source-ai.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 china-open-source-ai.mp4
