STOPBUTTON=8
UPBUTTON=7
DOWNBUTTON=23
gpio -g mode $STOPBUTTON out
gpio -g mode $UPBUTTON out
gpio -g mode $DOWNBUTTON out
function rollstop() {
gpio -g write $STOPBUTTON 1
sleep 0.2
gpio -g write $STOPBUTTON 0
}
function rollup() {
gpio -g write $UPBUTTON 1
sleep 0.2
gpio -g write $UPBUTTON 0
}
function rolldown() {
gpio -g write $DOWNBUTTON 1
sleep 0.2
gpio -g write $DOWNBUTTON 0
}

logger "$0 action $1"
case "$1" in
  up) rollup
      ;;
  down) rolldown
      ;;
  stop) rollstop
      ;;
  *) echo "usage: $0 {up|down|stop}"
esac
