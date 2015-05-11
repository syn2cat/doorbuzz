#!/usr/bin/python
# sets color of first neo pixel
from __future__ import division
import time
import sys
from math import *
import redis

from neopixel import *

# LED strip configuration:
LED_COUNT      = 61      # Number of LED pixels.
LED_PIN        = 18      # GPIO pin connected to the pixels (must support PWM!).
LED_FREQ_HZ    = 800000  # LED signal frequency in hertz (usually 800khz)
LED_DMA        = 5       # DMA channel to use for generating signal (try 5)
LED_BRIGHTNESS = 100       # Set to 0 for darkest and 255 for brightest
LED_INVERT     = False   # True to invert the signal (when using NPN transistor level shift)

def wheel(pos):
        """Generate rainbow colors across 0-255 positions."""
        if pos < 85:
                return Color(pos * 3, 255 - pos * 3, 0)
        elif pos < 170:
                pos -= 85
                return Color(255 - pos * 3, 0, pos * 3)
        else:
                pos -= 170
                return Color(0, pos * 3, 255 - pos * 3)

def clockcalc(value):
     return 1+((30+int(value))%60)

# Main program logic follows:
if __name__ == '__main__':
      # Create NeoPixel object with appropriate configuration.
      strip = Adafruit_NeoPixel(LED_COUNT, LED_PIN, LED_FREQ_HZ, LED_DMA, LED_INVERT, LED_BRIGHTNESS)
      # Intialize the library (must be called once before other functions).
      strip.begin()
      myredis=redis.StrictRedis(host='localhost', port=6379, db=0)
      while True:
        time.sleep(50/1000.0)
        try: 
          r=int(myredis.get('neored'))
        except:
          r=0
        try: 
          g=int(myredis.get('neogreen'))
        except:
          g=0
        try:
          b=int(myredis.get('neoblue'))
        except:
          b=0
        try:
          action=myredis.get('neoaction')
        except:
          action="set"
	if(action == "set"):
          print "Color set to: ",r,g,b
          for i in range(0,LED_COUNT):
            strip.setPixelColor(i, Color(r,g,b))
          strip.show()
        if(action == "morse"):
	  print "Morsing with: ",r,g,b
	  speed=10
	  for i in range(0,LED_COUNT):
            strip.setPixelColor(i, Color(0,0,0))
	  morsecode=myredis.get('neomorse')
          morsep=1
	  for c in morsecode:
	    if c==".":
              strip.setPixelColor(morsep, Color(r,g,b))
              morsep+=1
              strip.setPixelColor(morsep, Color(0,0,0))
              morsep+=1
	    if c=="-":
              strip.setPixelColor(morsep, Color(r,g,b))
              morsep+=1
              strip.setPixelColor(morsep, Color(r,g,b))
              morsep+=1
              strip.setPixelColor(morsep, Color(0,0,0))
              morsep+=1
              strip.setPixelColor(morsep, Color(0,0,0))
              morsep+=1
	    if c==" ":
              strip.setPixelColor(morsep, Color(0,0,0))
              morsep+=1
              strip.setPixelColor(morsep, Color(0,0,0))
              morsep+=1
              strip.setPixelColor(morsep, Color(0,0,0))
              morsep+=1
              strip.setPixelColor(morsep, Color(0,0,0))
              morsep+=1
	  strip.show() 
	  time.sleep(1)
	if(action == "pulse"):
	  print "Pulsing with: ",r,g,b
	  pulsewidth=50
	  while (action==myredis.get('neoaction')):
	    for i in range(pulsewidth):
              if(action!=myredis.get('neoaction')):
                break
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
                
        if(action == "flash"):
          print "Flashing with: ",r,g,b
          print myredis.get('neoaction')
          wait_ms=50
          """Rainbow movie theater light style chaser animation."""
	  while (action==myredis.get('neoaction')):
            print " Flashing with: ",r,g,b
            for j in range(256):
                print "  Flashing with: ",r,g,b
                if(action!=myredis.get('neoaction')):
                  break
                for q in range(3):
                        for i in range(0, strip.numPixels(), 3):
                                strip.setPixelColor(i+q, wheel((i+j) % 255))
                        strip.show()
                        time.sleep(wait_ms/1000.0)
                        for i in range(0, strip.numPixels(), 3):
                                strip.setPixelColor(i+q, 0)

