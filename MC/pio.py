import RPi.GPIO as GPIO
import requests
import time
import threading
import os
import base64
import string
import random
import datetime

"GPIO.setmode(BOARD)"

def closeLock():
	p = GPIO.PWM(12,50)        #sets pin 12 to PWM and sends 50 signals per second
	p.start(7.5)          #starts by sending a pulse at 7.5% to center the servo
	p.ChangeDutyCycle(4.5)    #sends a 4.5% pulse to turn the servo CCW
	time.sleep(2)
	p.stop()
def openLock():
        p = GPIO.PWM(12,50)        #sets pin 12 to PWM and sends 50 signals per second
        p.start(7.5)          #starts by sending a pulse at 7.5% to center the servo
        p.ChangeDutyCycle(10.5)    #sends a 4.5% pulse to turn the servo CCW
        time.sleep(2)
        p.stop()
def id_generator(size=25, chars=string.ascii_uppercase + string.ascii_lowercase + string.digits):
                return ''.join(random.choice(chars) for _ in range(size))
def checkStatus():
	open = False
	r = requests.put("http://api.codered.kirmani.io/lock/state", data = {"open": open})
	GPIO.setmode(GPIO.BOARD)
	GPIO.setup(12,GPIO.OUT)
	r = requests.get('http://api.codered.kirmani.io/lock/list')
	while True:
		if exit.is_set():
                        thread.exit()
		list = r.json()["result"]
		print list
		for id in list:
			url = "http://api.codered.kirmani.io/lock/id/"+id
			r = requests.get(url)
			if id == "OVERRIDE":
				action = r.json()["result"]["action"]
				if action == "open":
					print "WOO"
					r = requests.delete(url)
					if not open:
						openLock()
						open = True
						r = requests.put("http://api.codered.kirmani.io/lock/state", data = {"open": open})
				if action == "close":
					print "CLOSING"
					r = requests.delete(url)
					if open:
						closeLock()
						open = False
						r = requests.put("http://api.codered.kirmani.io/lock/state", data = {"open": open})
			else:
				status = r.json()["result"]["approved"]
				waiting = r.json()["result"]["waiting"]
				if waiting == False:
					if status == True:
						print "WOO"
						r = requests.delete(url)
						if not open:
							openLock()
							open = True
							r = requests.put("http://api.codered.kirmani.io/lock/state", data = {"open": open})
					if status == False:
						print "BOO"
						r = requests.delete(url)
		r = requests.get('http://api.codered.kirmani.io/lock/list')
def checkInput():
	GPIO.setmode(GPIO.BOARD)
	GPIO.setup(7, GPIO.IN)
	input = GPIO.input(7);
	while True:
		if exit.is_set():
			thread.exit()
		input = GPIO.input(7);
		while input == True:
		        input = GPIO.input(7);
		#code to activate camera		
		timestamp = time.strftime("%d-%m-%Y_%H:%M:%S")
		filename = "/home/pi/timerecord/" + timestamp + ".png"
		os.system("fswebcam -d /dev/video0 -r 680x480 --no-banner " + filename)
		encoded = base64.b64encode(open(filename, "rb").read())
		random = id_generator()
		r = requests.post("http://api.codered.kirmani.io/lock/id/" + random, data = {"image":encoded, "time": timestamp})

exit = threading.Event()
exit.clear()
status = threading.Thread(target=checkStatus)
input = threading.Thread(target=checkInput)
status.start()
input.start()
try:        
	while True:
		x=1		
except KeyboardInterrupt:
	exit.set()
	GPIO.cleanup()

 
