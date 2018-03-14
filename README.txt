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
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install vim tmux
# now you get funky errors: "unexpected end of file or stream"
# fix it:
sudo apt-get clean
sudo apt-get --fix-broken install

* sometimes you ask yourself why the locales are not generated as needed
sudo sed -i "$(locale | awk -F= '$2!=""{gsub("\"","");if(!a[$2]++){print "s/# *" $2 "/" $2 "/;"}}' )" /etc/locale.gen
sudo locale-gen
```
* authorize boorduzz to connect to pidor and vice versa

```
mkdir /home/pi/.ssh
chmod go= /home/pi/.ssh /home/pi/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTVHK+yXSXHm42vr1RZ4sgKBFdkL3vi1u8BXYD/zkcbJkDSyWWRlU5q/qzEQYVk2zae870jcSQ5oTeoLZ99ujkuGltTCdzcCin24Aoig8ATyztFXoSHIfdUPCw5dbjhQXGWRPIkk1lSGU6mtLJRmVwLeY0rzVSQKdlspQlKBLwFBeIuACZQZfUzbIB2XiHIaoxcUja9fRfsZpo9TsWiqCMbseAj926qUgV2iotTQF7XLF/f+H8j2MR3iltKHqc35y/PiWy2doxRFHjW9I66Bit+ddOBtrsL6AzjxZP1DyoAc7jqhRpVazeXkMeNPMigpsV4rhLMEeVi2OqgTO7d3Jv root@pidor" >> /home/pi/.ssh/authorized_keys
```
copy the doorbuzz private key to /home/pi/.ssh/doorbuzz (backup of the key located on pidor at /root/.ssh/doorbuzz)

* get the package
cd /home/pi
git clone https://github.com/syn2cat/doorbuzz

cd doorbuzz
  git config --global user.email "infolevel2.lu"
  git config --global user.name "Door Buzz"
  git remote set-url origin git@github.com:syn2cat/doorbuzz.git



* If you want to chroot into the image have a look at [this script](https://github.com/CIRCL/Circlean/blob/master/proper_chroot.sh)

* Remove screensaver from `/etc/xdg/lxsession/LXDE/autostart `

``` bash
sudo vi /etc/xdg/lxsession/LXDE/autostart
```

* Copy the files present in `root_files` accordingly on the file system
** sets IP without using dhcp
** sets hostname (replace the content of `/etc/hostname` with door-buzz)
** sets localhost alias
** removes screensaver in /etc/xdg/lxsession/LXDE/autostart
** configures lirc

* Install the stuff

``` bash
sudo apt-get install unclutter xdotool git-core screen imagemagick x11-xserver-utils
cd /home/pi
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build

cat > /home/pi/.config/lxsession/LXDE-pi/autostart <<"EOF"
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
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

* new: using redis to manage the 60 led circle

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

* setup watchdog

```
sudo modprobe bcm2835_wdt
echo "bcm2835_wdt" | sudo tee -a /etc/modules


sudo apt-get install watchdog
sudo update-rc.d watchdog defaults

sudo sed -i 's/#\(watchdog-device\)/\1/
             s/#\(max-load-1\s\)/\1/
            ' /etc/watchdog.conf

sudo service watchdog start
```


Note: `projectionscreen.sh` is a standalone program called remotely by pidor because pidor knows the IP adress of the projector but doorbuzz has the RF remote connected.
The remote command works with ssh, so install pidor's root pub key into `~pi/.ssh/authorized_keys`

* setup lirc for AV-receiver remote control

```
sudo apt-get install lirc
sudo /bin/su -c "echo 'dtoverlay=lirc-rpi,gpio_out_pin=17,gpio_in_pin=21' >> /boot/config.txt"
```


todo
====

* create a config file
* put more of the hardcoded values from code into parameters
* make code resilient against missing commands (e.g. gpio not in PATH)
* move script to run in screen instead starting from rc.local
