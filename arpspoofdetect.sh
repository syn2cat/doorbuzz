#!/bin/bash
# led is not neopixel, so use the python lib for that
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
    neomorse=$5
EOF
}
pulseon() {
  red=$1
  green=$2
  blue=$3
  showleds pulse $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION)) </dev/null >/dev/null 2>&1 &
  echo $!
}

echo "Initializing hardware"
# the button

ledcolor() {
  red=$1
  green=$2
  blue=$3
  showleds set $((red/ATTENUATION)) $((green/ATTENUATION)) $((blue/ATTENUATION))
}
echo "Main loop"
while true
do
if [ $(arp -a | awk '{arp[$2]=$4;ip[$4]=ip[$4]" "$2}END{print ip[arp["(10.2.113.1)"]]}' | wc -w) -gt 1 ]
then
  ledcolor 255 50 50
  sleep 1
  pulseon 255 255 255
  sleep 60
fi
done

