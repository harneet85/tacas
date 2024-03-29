import gi
import os
import signal
import time
import subprocess
import threading

#### new-messages-red.svg
# indicator-messages-new.svg
#empathy-available.svg
#empathy-busy.svg
#error.svg
# /var/lib/snapd/snap/gtk-common-themes/1506/share/icons/Yaru/scalable/status/starred-symbolic.svg

gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')
gi.require_version('Notify', '0.7')

from gi.repository import Gtk as gtk
from gi.repository import AppIndicator3 as appindicator
from gi.repository import Notify as notify

APPINDICATOR_ID = 'testindicator'

CURRPATH = os.path.dirname(os.path.realpath(__file__))
TACLOC = "./tac.sh"

class Indicator():
    def __init__(self):
        self.indicator = appindicator.Indicator.new(APPINDICATOR_ID, "tacasyellow", appindicator.IndicatorCategory.SYSTEM_SERVICES)
	self.indicator.set_icon_theme_path("/home/harneet/things/icon/")
        self.indicator.set_status(appindicator.IndicatorStatus.ACTIVE)
        self.indicator.set_menu(self.build_menu())
        notify.init(APPINDICATOR_ID)

    def build_menu(self):
        menu = gtk.Menu()

        item_starttac = gtk.MenuItem('Start TAC')
        item_starttac.connect('activate', self.startTac)

        item_killtac = gtk.MenuItem('Kill TAC')
        item_killtac.connect('activate', self.killTac)


        item_checktac = gtk.MenuItem('check TAC')
        item_checktac.connect('activate', self.threadFunc)


	item_quit = gtk.MenuItem('Quit')
        item_quit.connect('activate', self.quit)

        menu.append(item_starttac)
        menu.append(item_killtac)
        menu.append(item_checktac)
        menu.append(item_quit)
        menu.show_all()
        return menu
    
    def startTac(self, source):
	sasvpn=int(subprocess.check_output("netstat -al | grep -i sasvpn | grep -i establ|wc -l", shell=True))
	if sasvpn>0:
		global subtac
	#	os.system(TACLOC)
		subtac=subprocess.Popen([TACLOC])
		print(subtac)
		print("------------out of tac------")
	else:
		print("IBM VPN Tunnel not found . Activate IBM VPN first ")
		self.indicator.set_icon("tacasred")

    def killTac(self, source):
        try: 
		subtac.terminate()
	except:
		print("error while killing subprocess , maybe it does not exists")
        os.system("ps -ef| grep -i tac.sh | grep -v grep| awk '{print $2}'| xargs -I{} kill -9 {}")
	a=int(subprocess.check_output("ps -ef| grep -i tac.sh| egrep -v 'grep|defunct'|wc -l|tr -s '\n' ' '", shell=True))
	if a==0:
		self.indicator.set_icon("tacasred")
	print("--------printing any active tac script---------")
	print(os.system("ps -ef| grep -i tac.sh"))
        print("------------out of Kill tac------")

    def checkTac(self,source):
	while True:
		if os.path.isfile("tac.status"):
			print("inside loop ")
			stat=os.stat("./tac.status")
			mfiletime=int(stat.st_mtime/60)
			currtime=int(time.time()/60)
			difftime=currtime-mfiletime
			print("time",currtime,mfiletime,difftime)
			if difftime > 20 :
				self.indicator.set_icon("tacasred")
			else:
				self.indicator.set_icon("tacasgreen")
			print("goging to sleep")
			time.sleep(960)
			print("out of sleep")
		else:
			self.indicator.set_icon("tacasred")

    def threadFunc(self,source):
	x = threading.Thread(target=self.checkTac, args=(1,))
	x.start()

    def quit(self, source):
        gtk.main_quit()


Indicator()
signal.signal(signal.SIGINT, signal.SIG_DFL)
print("this works")
#change_green(Indicator)
gtk.main()
