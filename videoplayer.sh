#!/bin/bash
if [ ! -f black.png ]
then
convert -size 1920x1080 xc:#000000 black.png
fi
killall feh
trap "killall feh; killall omxplayer" 1 2 3 15
feh -x black.png &
while true
do
  if [ "$(python ./spacestatus.py)" = "False" ]
  then # test on false, so in case of network fail, it defaults to playing
    sleep 60
  else
    ls *mp4 |
    while read video
    do
      omxplayer "$video" </dev/null 
    done
  fi
done
