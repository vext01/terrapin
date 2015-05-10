conf = require("conf")

function ack(conn)
	print("ack")
end

function rcv(conn)
	print("mqtt connected")
	for en_pin, topic in pairs(conf.sensors) do
		print(string.format("pin=%s, topic=%s", en_pin, topic))
		gpio.write(en_pin, gpio.HIGH)
		local val = adc.read(0)
		print("adc val was %d", val)
		gpio.write(en_pin, gpio.LOW)
		mq:publish(topic, tostring(val), conf.mqtt_qos, conf.mqtt_retain, ack)
	end
end

-- main
for en_pin, topic in pairs(conf.sensors) do
	print(string.format("pin=%s, topic=%s", en_pin, topic))
	gpio.mode(en_pin, gpio.OUTPUT)
	gpio.write(en_pin, gpio.LOW)
end

mq = mqtt.Client("clientid", conf.mqtt_keepalive, conf.mqtt_user, conf.mqtt_pass)
mq:connect(conf.mqtt_broker, conf.mqtt_port, rcv)
