# doorbuzz
raspberry Pi opening the front door and playing videos
the button has an RGB led to show status

how to install
==============

sudo vi /etc/xdg/lxsession/LXDE/autostart
remove screensaver
sudo apt-get install unclutter xdotool git-core screen imagemagick
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build

mkdir -p /home/pi/.config/lxsession/LXDE/
cat > /home/pi/.config/lxsession/LXDE/autostart <<"EOF"
@xset s off
@xset -dpms
@xset s noblank
@unclutter -display :0 -noevents -grab
@./doorbuzz/buzzctrl.sh
@./doorbuzz/videoplayer.sh
@sudo python ./doorbuzz/shutdownbutton.py
EOF


connect the button and LED to pins as shown in buzzctrl.sh
create a file "secret.txt" containing the http://user:pass@10.1.1.xx part of the URL
adapt the URL in buzzctrl.sh
adapt spaceapi URL in spacestatus.py
put .mp4 videos into ~pi/ and they will show when your hackerspace is open
you can add videos and they will be taken into account automatically

when booting, the button led uses morsecode to send the low byte of the 
IP adress in decimal

todo
====
create a config file
put more of the hardcoded values from code into parameters
make code resilient against missing commands (e.g. gpio not in PATH)
move script to run in screen instead starting from rc.local
