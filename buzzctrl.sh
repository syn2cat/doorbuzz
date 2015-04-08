#!/bin/bash
BUTTONPIN=25
REDLEDPIN=23
GREENLEDPIN=18
BLUELEDPIN=24
BUZZERURL="$(cat "$(dirname "$0")"/secret.txt)/state.xml?relay1State=2&pulseTime1=5"
BUZZERSTATUSURL="$(cat "$(dirname "$0")"/secret.txt)/state.xml"

# file secret.txt should contain username:password

# install by putting into /etc/rc.local
# su pi -c '/home/pi/buzzctrl.sh' &

echo "Initializing hardware"
# the button
gpio -g mode $BUTTONPIN up  
gpio -g mode $BUTTONPIN in
# R
gpio -g mode $REDLEDPIN out
# G
gpio -g mode $GREENLEDPIN out
# B
gpio -g mode $BLUELEDPIN out

pulseon() {
  pin=$1
  value=0
  valueinc=64
  gpio -g mode $pin pwm
  while true
  do
    gpio -g pwm $pin $value
    value=$((value+valueinc))
    if [ $value -gt 1023 ] || [ $value -lt 0 ]
    then
      valueinc=$((0-valueinc))
      value=$((value+valueinc))
    fi 
    sleep 0.2
  done
}
pulseoff() {
  pin=$1
  kill $2
  gpio -g mode $pin out
  gpio -g write $pin 0
}
ledcolor() {
  red=$1
  green=$2
  blue=$3
  gpio -g write $REDLEDPIN $red 
  gpio -g write $GREENLEDPIN $green 
  gpio -g write $BLUELEDPIN $blue 
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
  while [ $pos -lt $msglen ]
  do
    morsecode=${morse[${message:${pos}:1}]}
    pos=$((pos+1))
echo $morsecode  
    morselen=${#morsecode} 
    morsepos=0
    while [ $morsepos -lt $morselen ]
    do
      ledcolor $2 $3 $4
#echo "c($morsepos)=${morsecode:${morsepos}:1}"
      if [ "${morsecode:${morsepos}:1}" = "." ]
      then
#echo "."
        sleep 0.1
      else
#echo "-"
        sleep 0.2
      fi
      ledcolor 0 0 0
      sleep 0.1
      morsepos=$((morsepos+1))
    done
    sleep 0.2
echo
  done
}

echo "morsing IP"
ledcolor 1 1 1
sleep 3
ledcolor 0 0 0
sleep 1
morseled "$(hostname -I|awk -F. '{sub(" ","",$NF);printf $NF}')" 1 0 0
ledcolor 1 1 1
sleep 1
echo "Main loop"
while true
do
  ledcolor 0 1 1
  pulseon $GREENLEDPIN &
  pulsepid=$!
  trap "pulseoff $GREENLEDPIN $pulsepid;ledcolor 0 0 0;exit" 1 2 3
  gpio -g wfi $BUTTONPIN falling
  while [ $(gpio -g read $BUTTONPIN) != 0 ]
  do
    gpio -g wfi $BUTTONPIN falling
  done
  pulseoff $GREENLEDPIN $pulsepid
  ledcolor 0 1 1
  echo "Pushiii"
  wget -O - -S --timeout=1 --tries=1 "$BUZZERURL" 2>&1
  ret=$?
  if [ $ret -ne 0 ] 
  then
    morseled "$ret" 1 0 0
  else
    while wget -O - --timeout=1 --tries=1 $BUZZERSTATUSURL|grep '<relay1state>1</relay1state>'
    do
      ledcolor 0 1 0
      sleep 0.9
      ledcolor 0 1 1
      sleep 0.1
    done
  fi
  echo "DOOONE"
done


