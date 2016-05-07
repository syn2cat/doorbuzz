#!/usr/bin/env python
# -*- coding: utf-8 -*-

buttonpin=24
import RPi.GPIO as GPIO
import time
import os


GPIO.setmode(GPIO.BCM)

GPIO.setup(buttonpin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
exit
while True:
  print "waiting..."
  os.system('logger shutdownbutton waiting for press...')
  try:
    GPIO.wait_for_edge(buttonpin, GPIO.FALLING)
    print('Button Pressed')
    os.system('logger shutdownbutton pressen. bye bye')
    # os.system("shutdown now -h")
  except KeyboardInterrupt:
    GPIO.cleanup()       # clean up GPIO on CTRL+C exit
GPIO.cleanup()           #
