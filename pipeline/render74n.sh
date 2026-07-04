#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
R="newraw/Raw Short Form/Video 74"
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
# hook: open punch-out, punch-in leading into the wipe at 2.18
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,2.08),1.0,1.0+0.5*($T-2.08)))"
# main (local T = raw-0.47): punches on hundreds/categories/example/connect/real-time/summary/CTA
ZM="if(lt($T,1.43),1.0,if(lt($T,1.68),1.0+0.32*($T-1.43),if(lt($T,3.77),1.08,if(lt($T,4.02),1.08-0.32*($T-3.77),if(lt($T,8.95),1.0,if(lt($T,9.20),1.0+0.24*($T-8.95),if(lt($T,11.51),1.06,if(lt($T,11.76),1.06-0.24*($T-11.51),if(lt($T,14.99),1.0,if(lt($T,15.24),1.0+0.24*($T-14.99),if(lt($T,16.09),1.06,if(lt($T,16.34),1.06-0.24*($T-16.09),if(lt($T,21.39),1.0,if(lt($T,21.64),1.0+0.4*($T-21.39),1.10))))))))))))))"
ZP="x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30"
ffmpeg -y -v error \
 -i "$R/DJI_20260702_160024_209_video.MP4" -i "$R/DJI_20260702_155922_175_video.MP4" \
 -framerate 30 -i pop_i74/f%04d.png -framerate 30 -i pop74n/f%04d.png -framerate 30 -i caps74/f%04d.png \
 -i bed74.wav \
 -filter_complex "
[0:v]trim=0.16:2.60,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':$ZP,format=yuv420p[vh0];
[2:v]setpts=PTS-STARTPTS[ipill];
[vh0][ipill]overlay=0:0:eof_action=repeat[vh];
[1:v]trim=0.47:23.95,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZM':$ZP,format=yuv420p[vm0];
[3:v]setpts=PTS-STARTPTS[mpop];
[vm0][mpop]overlay=0:0:eof_action=pass[vm];
[vh][vm]xfade=transition=circleopen:duration=0.2:offset=2.18[x1];
[4:v]setpts=PTS-STARTPTS[ocap];
[x1][ocap]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=25.10:d=0.3,tpad=stop_mode=clone:stop_duration=0.25[vout];
[0:a]atrim=0.16:2.32,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.08[ah];
[1:a]atrim=0.45:24.10,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.20[am];
[ah][am]concat=n=2:v=0:a=1,apad=whole_dur=25.91,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=44100,afade=t=out:st=25.42:d=0.39[vc];
[5:a]volume=0.65,aresample=44100[bed];
[vc][bed]amix=inputs=2:duration=first:normalize=0,afade=t=out:st=25.60:d=0.28,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart free-apis-github.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 free-apis-github.mp4
