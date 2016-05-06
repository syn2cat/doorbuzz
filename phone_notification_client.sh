#!/bin/bash

url=http://10.2.113.137
run_file="/var/run/phone_ringing_status"
pidor=root@10.2.113.2
old_status=0
new_status=0
cd $(dirname "$0")


while true # empty pipe
do
  sleep 1
  while true
  do 
    read -t 1 status <&"${COPROC[0]}" 2>/dev/null
    ret=$?
    if [ $ret -eq 1 ]  # no more coprocess
    then
      logger $0 "connecting to pidor"
      coproc ssh -i ~/.ssh/doorbuzz $pidor
      sleep 10
      logger $0 "connected"
      echo "flashoff" >&"${COPROC[1]}"
      ret=0
    fi
    if [ $ret -ne 0 ] 
    then
      break
    fi
    logger $0 "$status"
  done
  ocounter="$counter"
  echo "peoplecounter" >&"${COPROC[1]}"
  read counter <&"${COPROC[0]}"
  if [ "$counter" != "$ocounter" ]
  then
    logger $0 peoplecounter=$counter
    echo "neocounter=$counter" | ./redi.sh
  fi 
  echo "spacestatus" >&"${COPROC[1]}"
  read status <&"${COPROC[0]}"
  if ! [ "$status" = "open" ]; then   # do nothing if space is closed
	continue
  else
#    if ! [ -e "$run_file" ]; then
#        touch $run_file
#    fi

    curl -q "$url" 2>/dev/null | grep Ringing
    new_status=$?
#    old_status=$(cat ${run_file})

    if [ "$new_status" -eq "$old_status" ]; then
        continue
    fi
    logger $0 "phone status change detected"
    if [ "$new_status" -eq 0 ]; then
      printf "neoaction=flash\nvalid=yes\n" | ./redi.sh 
      echo "flashon" >&"${COPROC[1]}"
    else
      printf "neoaction=pulse\nvalid=yes\n" | ./redi.sh 
      echo "flashoff" >&"${COPROC[1]}"
    fi
#    echo $new_status > ${run_file}
    old_status=$new_status
  fi
done
