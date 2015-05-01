# doorbuzz
raspberry Pi opening the front door and playing videos
the button has an RGB led to show status

how to install
==============
# login as user pi
sudo apt-get install unclutter xdotool git-core screen imagemagick
cd ~
git clone https://github.com/syn2cat/doorbuzz.git

put into /etc/rc.local the following line:
su pi -c '/home/pi/doorbuzz/buzzctrl.sh' &

sudo vi /etc/xdg/lxsession/LXDE/autostart
remove screensaver
cd ~
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build
cd ~

mkdir -p /home/pi/.config/lxsession/LXDE/
cat > /home/pi/.config/lxsession/LXDE/autostart <<"EOF"
@xset s off
@xset -dpms
@xset s noblank
@unclutter -display :0 -noevents -grab
@./doorbuzz/videoplayer.sh
EOF

https://learn.adafruit.com/neopixels-on-raspberry-pi/software
sudo apt-get install build-essential python-dev git scons swig
git clone https://github.com/jgarff/rpi_ws281x.git
cd rpi_ws281x
scons
cd python
sudo python setup.py install

cd doorbuzz

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
