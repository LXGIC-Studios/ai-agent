#!/bin/bash
set -e
cd /tmp/claude-0/-home-user-ai-agent/25354de5-8d91-5325-8956-ee4d69120f27/scratchpad
G73="curves=master='0/0 0.25/0.222 0.5/0.505 0.75/0.788 1/1',eq=saturation=1.10:contrast=1.03,colorbalance=rm=0.015:bm=-0.015:rh=0.008:bh=-0.012,unsharp=5:5:0.3"
T="(on/30)"
ZH="if(lt($T,0.25),1.10-0.4*$T,if(lt($T,4.64),1.0,if(lt($T,4.89),1.0+0.32*($T-4.64),if(lt($T,8.54),1.08,if(lt($T,8.79),1.08-0.24*($T-8.54),if(lt($T,13.26),1.02,if(lt($T,13.51),1.02+0.32*($T-13.26),if(lt($T,20.21),1.10,1.10+0.3*($T-20.21)))))))))"
ZAPP="if(lt($T,2.96),1.04,if(lt($T,3.21),1.04+0.32*($T-2.96),if(lt($T,5.40),1.12,if(lt($T,5.65),1.12-0.4*($T-5.40),1.02))))"
ZO="if(lt($T,4.55),1.0,1.0+0.28*($T-4.55))"
ffmpeg -y -v error \
 -i "/root/.claude/uploads/25354de5-8d91-5325-8956-ee4d69120f27/c7dc6ef3-IMG_7591.MP4" -i "/root/.claude/uploads/25354de5-8d91-5325-8956-ee4d69120f27/37b9f574-IMG_7595.MP4" \
 -framerate 30 -i b76n/f%04d.png -framerate 30 -i caps76n/f%04d.png \
 -framerate 30 -i pop_i76n/f%04d.png -framerate 30 -i pop_e1/f%04d.png -framerate 30 -i pop_e2/f%04d.png \
 -framerate 30 -i pop_e3/f%04d.png -framerate 30 -i pop_x2/f%04d.png -framerate 30 -i pop_x1/f%04d.png \
 -framerate 30 -i pop_cta76/f%04d.png -i clicks76_real.wav \
 -filter_complex "
[0:v]trim=0.50:21.16,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZH':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vh0];
[4:v]setpts=PTS-STARTPTS[p0];[vh0][p0]overlay=0:0:eof_action=pass[vh1];
[5:v]setpts=PTS-STARTPTS[p1];[vh1][p1]overlay=0:0:eof_action=pass[vh2];
[6:v]setpts=PTS-STARTPTS[p2];[vh2][p2]overlay=0:0:eof_action=pass[vh3];
[7:v]setpts=PTS-STARTPTS[p3];[vh3][p3]overlay=0:0:eof_action=pass[vhim];
[2:v]fps=30,setsar=1,scale=3240:5760,zoompan=z='$ZAPP':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.45':d=1:s=1080x1920:fps=30,format=yuv420p[app0];
[8:v]setpts=PTS-STARTPTS[px2];[app0][px2]overlay=0:0:eof_action=pass[app1];
[9:v]setpts=PTS-STARTPTS[px1];[app1][px1]overlay=0:0:eof_action=pass[app2];
[app2]tpad=stop_mode=clone:stop_duration=0.25[bapp];
[vhim][bapp]xfade=transition=circleopen:duration=0.2:offset=20.46[x1];
[x1]tpad=stop_mode=clone:stop_duration=0.20[x1p];
[1:v]trim=0.26:5.45,setpts=PTS-STARTPTS,fps=30,scale=1080:1920,setsar=1,$G73,scale=3240:5760,zoompan=z='$ZO':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*0.33':d=1:s=1080x1920:fps=30,format=yuv420p[vo0];
[10:v]setpts=PTS-STARTPTS[pcta];[vo0][pcta]overlay=0:0:eof_action=pass[voc];
[x1p][voc]xfade=transition=radial:duration=0.25:offset=27.05[x2];
[3:v]setpts=PTS-STARTPTS[ocap];[x2][ocap]overlay=0:1440:eof_action=pass,format=yuv420p,fade=t=out:st=31.85:d=0.3,tpad=stop_mode=clone:stop_duration=0.10[vout];
[0:a]atrim=0.50:27.55,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.10[am];
[1:a]atrim=0.26:5.55,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.06[ao];
[am][ao]concat=n=2:v=0:a=1,loudnorm=I=-14:TP=-1.5:LRA=11[vc];
[11:a]lowpass=f=6500,highpass=f=150,volume=0.55[clk];
[vc][clk]amix=inputs=2:duration=first:normalize=0,afade=t=out:st=32.10:d=0.24,aresample=44100[aout]
" -map "[vout]" -map "[aout]" \
 -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
 -c:a aac -b:a 256k -ac 2 -movflags +faststart claude-money-prompts.mp4
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 claude-money-prompts.mp4
