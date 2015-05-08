#!/usr/bin/python
# sets color of first neo pixel
from __future__ import division
import time
import sys
from math import *

from neopixel import *

# LED strip configuration:
LED_COUNT      = 61      # Number of LED pixels.
LED_PIN        = 18      # GPIO pin connected to the pixels (must support PWM!).
LED_FREQ_HZ    = 800000  # LED signal frequency in hertz (usually 800khz)
LED_DMA        = 5       # DMA channel to use for generating signal (try 5)
LED_BRIGHTNESS = 100       # Set to 0 for darkest and 255 for brightest
LED_INVERT     = False   # True to invert the signal (when using NPN transistor level shift)

def clockcalc(value):
     return 1+((30+int(value))%60)

# Main program logic follows:
if __name__ == '__main__':
        # Create NeoPixel object with appropriate configuration.
        strip = Adafruit_NeoPixel(LED_COUNT, LED_PIN, LED_FREQ_HZ, LED_DMA, LED_INVERT, LED_BRIGHTNESS)
        # Intialize the library (must be called once before other functions).
        strip.begin()
        r=int(sys.argv[2])
        g=int(sys.argv[3])
        b=int(sys.argv[4])
	if(sys.argv[1] == "set"):
          print "Color set to: ",r,g,b
          strip.setPixelColor(0, Color(r,g,b))
          strip.show()
        if(sys.argv[1] == "morse"):
	  print "Morsing with: ",r,g,b
	  speed=10
	  morsecode=sys.argv[5]
	  for c in morsecode:
	    if c==".":
              strip.setPixelColor(0, Color(r,g,b))
	      strip.show() 
	      time.sleep(0.2)
              strip.setPixelColor(0, Color(0,0,0))
	      strip.show() 
	      time.sleep(0.2)
	    if c=="-":
              strip.setPixelColor(0, Color(r,g,b))
	      strip.show() 
	      time.sleep(0.7)
              strip.setPixelColor(0, Color(0,0,0))
	      strip.show() 
	      time.sleep(0.2)
	    if c==" ":
              strip.setPixelColor(0, Color(0,0,0))
	      strip.show() 
	      time.sleep(1)
	if(sys.argv[1] == "pulse"):
	  print "Pulsing with: ",r,g,b
	  pulsewidth=50
	  while True:
	    for i in range(pulsewidth):
	      color=Color(0,0,0)
              for j in range(0,60):
                strip.setPixelColor(clockcalc(j), color)
	      trigo=sin(i/pulsewidth*pi)
	      color=Color(int(r*trigo),int(g*trigo),int(b*trigo))
              clockpos=int(time.strftime('%I',time.localtime()))*5
              for j in range(-2,3):
                strip.setPixelColor(clockcalc(clockpos+j),Color(30,30,30))
              for j in range(0,60,5):
                strip.setPixelColor(clockcalc(j), color)
              strip.setPixelColor(clockcalc(time.strftime('%M',time.localtime())),Color(30,0,0))
              strip.setPixelColor(clockcalc(time.strftime('%S',time.localtime())),Color(0,30,0))
              strip.show()
              time.sleep(50/1000.0)
