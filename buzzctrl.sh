#!/bin/bash
# led is not neopixel, so use the python lib for that
BUTTONPIN=25
SHOWLEDPRG="sudo python /home/pi/doorbuzz/setneocolor.py"
BUZZERURL="$(cat "$(dirname "$0")"/secret.txt)/state.xml?relay1State=2&pulseTime1=5"
BUZZERSTATUSURL="$(cat "$(dirname "$0")"/secret.txt)/state.xml"
ATTENUATION=4
# file secret.txt should contain username:password

# install by putting into /etc/rc.local
# su pi -c '/home/pi/doorbuzz/buzzctrl.sh' &

echo "Initializing hardware"
# the button
gpio -g mode $BUTTONPIN up  
gpio -g mode $BUTTONPIN in

pulseon() {
  red=$1
  green=$2
  blue=$3
  $SHOWLEDPRG pulse $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION)) </dev/null >/dev/null 2>&1 &
  echo $!
}
pulseoff() {
  if [ $(ps -edf | grep pulse | grep "$1"|wc -l) -gt 0 ]
  then
    sudo kill "$1"
  fi
}
ledcolor() {
  red=$1
  green=$2
  blue=$3
  $SHOWLEDPRG set $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION))
}
declare -a morse
morse[0]="-----"
morse[1]=".----"
morse[2]="..---"
morse[3]="...--"
morse[4]="....-"
morse[5]="....."
morse[6]="-...."
morse[7]="--..."
morse[8]="---.."
morse[9]="----."
morseled() {
  message=$1
echo $message
  msglen=${#message}
  pos=0
  morsecode=""
  while [ $pos -lt $msglen ]
  do
    morsecode="$morsecode ${morse[${message:${pos}:1}]}"
    pos=$((pos+1))
echo $morsecode  
  done
  red=$2
  green=$3
  blue=$4
  $SHOWLEDPRG morse $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION)) "$morsecode"

echo
}

echo "morsing IP"
ledcolor 255 255 255
sleep 3
ledcolor 0 0 0
sleep 1
morseled "$(hostname -I|awk -F. '{sub(" ","",$NF);printf $NF}')" 255 0 0
ledcolor 255 255 255
sleep 1
echo "Main loop"
while true
do
  ledcolor 0 255 255
  pulsepid=$(pulseon 0 0 255 )
  trap "pulseoff $pulsepid;ledcolor 0 0 0;exit" 1 2 3
  gpio -g wfi $BUTTONPIN falling
  while [ $(gpio -g read $BUTTONPIN) != 0 ]
  do
    gpio -g wfi $BUTTONPIN falling
  done
  pulseoff $pulsepid
  ledcolor 0 255 255
  echo "Pushiii"
  wget -O - -S --timeout=1 --tries=1 "$BUZZERURL" 2>&1
  ret=$?
  if [ $ret -ne 0 ] 
  then
    morseled "$ret" 255 0 0
  else
    while wget -O - --timeout=1 --tries=1 $BUZZERSTATUSURL|grep '<relay1state>1</relay1state>'
    do
      ledcolor 0 255 0
      sleep 0.9
      ledcolor 0 255 255
      sleep 0.1
    done
  fi
  echo "DOOONE"
done


