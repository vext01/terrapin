conf = require("conf")

num_acks = 0

function ack(conn)
	print("ack")
	num_acks = num_acks + 1

	-- the last one?
	if num_acks == conf.num_sensors then
		again(conn, false)
	end
end

function too_long()
	print("This is taking too long, reboot!")
	again(nil, true)
end

function again(conn, fail)
	-- blink the ok led
	local led = conf.ack_led
	if fail then
		led = conf.power_led
	end

	for i = 10, 1, -1 do
		gpio.write(conf.ack_led, gpio.HIGH)
		tmr.delay(0.03 * 1000 * 1000)
		gpio.write(conf.ack_led, gpio.LOW)
		tmr.delay(0.03 * 1000 * 1000)
	end

	if conn ~= nil then
		conn:close()
	end

	print(string.format("Going to sleep for %d secs...", conf.read_intvl))
	node.dsleep(conf.read_intvl * 1000 * 1000)
end

function rcv(conn)
	print("mqtt connected")
	for en_pin, topic in pairs(conf.sensors) do
		gpio.write(en_pin, gpio.HIGH)
		local val = adc.read(0)
		gpio.write(en_pin, gpio.LOW)
		print(string.format("pin=%s, topic=%s, val=%d", en_pin, topic, val))
		conn:publish(topic, tostring(val), conf.mqtt_qos, conf.mqtt_retain, ack)
	end
end

-- main
for en_pin, topic in pairs(conf.sensors) do
	gpio.mode(en_pin, gpio.OUTPUT)
	gpio.write(en_pin, gpio.LOW)
end

-- this shouldn't take long at all
tmr.alarm(0, 10 * 1000, 0, too_long)

print(string.format("Connecting to %s:%d", conf.mqtt_broker, conf.mqtt_port))
mq = mqtt.Client("clientid", conf.mqtt_keepalive, conf.mqtt_user, conf.mqtt_pass)
mq:connect(conf.mqtt_broker, conf.mqtt_port, rcv)
