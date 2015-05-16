# sudo python2.7 esptool.py --port=/dev/cuaU0 write_flash 0x0 ~/Downloads/nodemcu_integer_0.9.5_20150318.bin  -fs 32m -fm dio -ff 40m
DEV=/dev/cuaU0
user:
	sudo python2.7 ~/source/luatool/luatool/luatool.py -p ${DEV} --src user.lua --dest user.lua -r

init:
	sudo python2.7 ~/source/luatool/luatool/luatool.py -p ${DEV} --src init.lua --dest init.lua -r

conf:
	sudo python2.7 ~/source/luatool/luatool/luatool.py -p ${DEV} --src conf.lua --dest conf.lua -r

list:
	sudo python2.7 ~/source/luatool/luatool/luatool.py -p ${DEV} -l
