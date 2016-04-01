# doorbuzz

raspberry Pi opening the front door and playing videos the button has an RGB led to show status features:

* button to push to open the door
* LED ring of 60 neopixels showing the current clock
* video player showing some default videos while the space is open
* a shutdown button for a clean shutdown
* watchdog

how to install
==============

* The basics

```
sudo apt-get install vim tmux
```

* If you want to chroot into the image have a look at [this script](https://github.com/CIRCL/Circlean/blob/master/proper_chroot.sh)

* Remove screensaver from `/etc/xdg/lxsession/LXDE/autostart`

``` bash
sudo vi /etc/xdg/lxsession/LXDE/autostart
```

* Copy the files present in `root_files` accordingly on the file system
* Set the hostname: replace the content of `/etc/hostname` with door-buzz

* Install the suff

``` bash
sudo apt-get install unclutter xdotool git-core screen imagemagick x11-xserver-utils
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build

git clone https://github.com/syn2cat/doorbuzz
cat > /home/pi/.config/lxsession/LXDE-pi/autostart <<"EOF"
@xset s off
@xset -dpms
@xset s noblank
@unclutter -display :0 -noevents -grab
@sudo python ./doorbuzz/setneocolor.py
@./doorbuzz/buzzctrl.sh
@./doorbuzz/videoplayer.sh
@./doorbuzz/arpspoofdetect.sh
@sudo python ./doorbuzz/shutdownbutton.py
@./doorbuzz/phone_notification_client.sh
EOF
```

* connect the button and LED to pins as shown in `buzzctrl.sh`
* create a file "secret.txt" containing the http://user:pass@10.1.1.xx part of the URL
* adapt the URL in buzzctrl.sh
* adapt spaceapi URL in spacestatus.py
* put .mp4 videos into ~pi/ and they will show when your hackerspace is open you can add videos and they will be taken into account automatically

when booting, the button led uses morsecode to send the low byte of the IP adress in decimal

`phone_notification_client.sh` communicates with pidor's `doorbuzz_wrapper.sh` to command the flash light

# new: using redis to manage the 60 led circle

```
sudo apt-get install python-pip redis-server python-redis
```

* redi.sh comes from here: https://github.com/crypt1d/redi.sh

```
cd ~
git clone https://github.com/jgarff/rpi_ws281x.git
cd rpi_ws281x
sudo apt-get install scons swig python-dev
scons
cd python
sudo python setup.py install
```

# setup watchdog

```
sudo modprobe bcm2708_wdog
echo "bcm2708_wdog" | sudo tee -a /etc/modules


sudo apt-get install watchdog
sudo update-rc.d watchdog defaults

sudo sed -i 's/#\(watchdog-device\)/\1/
             s/#\(max-load-1\s\)/\1/
            ' /etc/watchdog.conf

sudo service watchdog start
```


Note: `projectionscreen.sh` is a standalone program called remotely by pidor because pidor knows the IP adress of the projector but doorbuzz has the RF remote connected.
The remote command works with ssh, so install pidor's root pub key into `~pi/.ssh/authorized_keys`

todo
====

* create a config file
* put more of the hardcoded values from code into parameters
* make code resilient against missing commands (e.g. gpio not in PATH)
* move script to run in screen instead starting from rc.local
