Copy the bash script into Synology NAS. Schedule run on start.

Prerequisites:

- build dvmkv2mp4 (https://github.com/JustasBud/dvmkv2mp4) locally and deploy image to Synology
- docker pull linuxserver/ffmpeg

Logic:
watchfolder - script used to check if new files added. If yes - execute either dvmkv2mp4 (if name of the file ends with .mkv and has DV/DolbyVision/DoVi keyword) or extract_subtitles.sh (if mkv) 

Config:
Adjust docker flags as needed for dvmkv2mp4 (check the repo for details). [extract specific sub languages, remove source, etc.]..


To kill the process in Synology - ssh as root, run **ps aux** to find the process executing the bash script (watchfolderV2.sh). Copy the PID and paste into below:


> kill -15 PID
> or if  stubborn:
> kill -9 PID
