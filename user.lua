conf = require("conf")

function ack(conn)
	print("ack")
end

function again(conn)
	-- blink the ok led
	for i = 10, 1, -1 do
		gpio.write(conf.ack_led, gpio.HIGH)
		tmr.delay(0.03 * 1000 * 1000)
		gpio.write(conf.ack_led, gpio.LOW)
		tmr.delay(0.03 * 1000 * 1000)
	end
	conn:close()
	print(string.format("Going to sleep for %d secs...", conf.read_intvl))
	node.dsleep(conf.read_intvl * 1000 * 1000)
end

function rcv(conn)
	print("mqtt connected")
	for en_pin, topic in pairs(conf.sensors) do
		gpio.write(en_pin, gpio.HIGH)
		local val = adc.read(0)
		print("adc val was %d", val)
		gpio.write(en_pin, gpio.LOW)
		print(string.format("pin=%s, topic=%s, val=%d", en_pin, topic, val))
		mq:publish(topic, tostring(val), conf.mqtt_qos, conf.mqtt_retain, ack)
	end
	again(conn)
end

-- main
for en_pin, topic in pairs(conf.sensors) do
	gpio.mode(en_pin, gpio.OUTPUT)
	gpio.write(en_pin, gpio.LOW)
end

print(string.format("Connecting to %s:%d", conf.mqtt_broker, conf.mqtt_port))
mq = mqtt.Client("clientid", conf.mqtt_keepalive, conf.mqtt_user, conf.mqtt_pass)
mq:connect(conf.mqtt_broker, conf.mqtt_port, rcv)
