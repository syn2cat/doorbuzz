#!/bin/bash
BUTTONPIN=25
BUZZERURL="$(cat "$(dirname "$0")"/secret.txt)/state.xml?relay1State=2&pulseTime1=5"
BUZZERSTATUSURL="$(cat "$(dirname "$0")"/secret.txt)/state.xml"
ATTENUATION=4
# file secret.txt should contain username:password
cd $(dirname "$0")

showleds() {
  ./redi.sh <<EOF
    neoaction=$1
    neored=$2
    neogreen=$3
    neoblue=$4
    neovalue=$5
    valid=yes
EOF
#  sudo kill $(ps -edf| awk '/[s]etneocolor.py/{print $2}' ) 2>/dev/null
#  sudo python /home/pi/doorbuzz/setneocolor.py $1 $2 $3 $4
}
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
  showleds pulse $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION)) </dev/null >/dev/null 2>&1 &
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
  showleds set $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION))
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
  logger $0 morseled $message
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
  showleds morse $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION)) "$morsecode"

echo
}
dialcode() {
# shows number code on clock dial
  message=$1
  logger $0 dialcode $message
  msglen=${#message}
  pos=0
  while [ $pos -lt $msglen ]
  do
    dcode="${message:${pos}:1}"
    dcode=$((dcode*5))   # convert numbers into clock values 
    pos=$((pos+1))
echo $dcode
    red=$2
    green=$3
    blue=$4
    showleds set 0 0 0
    showleds number $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION)) "$dcode"
    sleep 1
  done
  showleds set 0 0 0
}

logger $0 "morsing IP"
#morseled "$(hostname -I|awk -F. '{sub(" ","",$NF);printf $NF}')" 255 0 0
dialcode "$(hostname -I|awk -F. '{sub(" ","",$NF);printf $NF}')" 255 0 0
sleep 1
logger $0 "Main loop"
while true
do
  #ledcolor 0 255 255
  pulsepid=$(pulseon 0 0 255 )
  trap "ledcolor 0 0 0;exit" 1 2 3
  gpio -g wfi $BUTTONPIN falling
  while [ $(gpio -g read $BUTTONPIN) != 0 ]
  do
    gpio -g wfi $BUTTONPIN falling
  done
  ledcolor 0 255 255
  logger $0 "Big Red Button pushed"
  wget -O - -S --timeout=1 --tries=1 "$BUZZERURL" 2>&1
  ret=$?
  if [ $ret -ne 0 ] 
  then
    #morseled "$ret" 255 0 0
    dialcode "$ret" 255 0 0
    sleep 5
  else
    while wget -O - --timeout=1 --tries=1 $BUZZERSTATUSURL|grep '<relay1state>1</relay1state>'
    do
      ledcolor 0 255 0 
#      sleep 0.2
      ledcolor 0 255 255 
#      sleep 0.2
    done
  fi
  logger $0 "button push action finished"
done


