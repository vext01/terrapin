conf = require("conf")

function ack(mux_addr)
	return function(conn)
		print("conn is ", conn)
		print(string.format("ack: %d", mux_addr))
		mux_addr = mux_addr + 1
		if mux_addr == conf.num_sensors then
			print("Success!")
			dance_led(conf.ack_led)
			again(conn, false)
		else
			take_reading(conn, mux_addr)
		end
	end
end

blink_delay = 1000 * 50
function dance_led(pin)
	for i = 0, 9, 1 do
		gpio.write(pin, gpio.LOW)
		tmr.delay(blink_delay)
		gpio.write(pin, gpio.HIGH)
		tmr.delay(blink_delay)
	end
end

function too_long()
	print("FAIL!")
	dance_led(conf.power_led)
	again(nil, true)
end

function again(conn, fail)
	if conn ~= nil then conn:close() end
	print(string.format("Going to sleep for %d secs...", conf.read_intvl))
	node.dsleep(conf.read_intvl * 1000 * 1000)
end

function set_mux_addr(mux_addr)
	for i = 0, 3, 1 do
		local val = bit.rshift(bit.band(mux_addr, math.pow(2, i)), i)
		local pin = conf.mux_addr_pins[i+1]
		print(mux_addr, pin, val)
		gpio.write(pin, val)
	end
end

function connect(conn)
	take_reading(conn, 0)
end

function take_reading(conn, mux_addr)
	print("mqtt connected")
	--for mux_addr, topic in pairs(conf.sensors) do
		topic = conf.sensors[mux_addr]
		set_mux_addr(mux_addr)
		tmr.delay(10000)
		local val = adc.read(0)
		print(string.format("mux_addr=%s, topic=%s, val=%d", mux_addr, topic, val))
		conn:publish(topic, tostring(val), conf.mqtt_qos, conf.mqtt_retain, ack(mux_addr))
	--end
end

for idx, pin in pairs(conf.mux_addr_pins) do
	gpio.mode(pin, gpio.OUTPUT)
end

print("hi")
tmr.alarm(0, 10 * 1000, 0, too_long)
mq = mqtt.Client("clientid", conf.mqtt_keepalive, conf.mqtt_user, conf.mqtt_pass)
mq:connect(conf.mqtt_broker, conf.mqtt_port, connect)
