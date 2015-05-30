conf = require("conf")
gpio.mode(conf.power_led, gpio.OUTPUT)
gpio.mode(conf.wifi_led, gpio.OUTPUT)
gpio.mode(conf.ack_led, gpio.OUTPUT)
gpio.write(conf.power_led, gpio.HIGH)
print(string.format("connecting to '%s'", conf.ssid))
wifi.setmode(wifi.STATION)
wifi.sta.config(conf.ssid, conf.pass)
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() == nil then
    else
    	tmr.stop(1)
    	print("Config done, IP is "..wifi.sta.getip())
        gpio.write(conf.wifi_led, gpio.HIGH)
	dofile("user.lua")
    end
 end)
