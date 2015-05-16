conf = require("conf")
num_acks = 0

function ack(conn)
	print("ack")
	num_acks = num_acks + 1
	if num_acks == conf.num_sensors then
		again(conn, false)
	end
end

function too_long()
	print("Fail")
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
		--if pin == 1 then
		--	gpio.write(pin, gpio.HIGH)
		--else
		--	gpio.write(pin, gpio.LOW)
		--end
	end
end

function rcv(conn)
	print("mqtt connected")
	for mux_addr, topic in pairs(conf.sensors) do
		set_mux_addr(mux_addr)
		tmr.delay(10000)
		local val = adc.read(0)
		print(string.format("mux_addr=%s, topic=%s, val=%d", mux_addr, topic, val))
		conn:publish(topic, tostring(val), conf.mqtt_qos, conf.mqtt_retain, ack)
	end
end

for idx, pin in pairs(conf.mux_addr_pins) do
	print(pin)
	gpio.mode(pin, gpio.OUTPUT)
end

print("hi")
tmr.alarm(0, 10 * 1000, 0, too_long)
mq = mqtt.Client("clientid", conf.mqtt_keepalive, conf.mqtt_user, conf.mqtt_pass)
mq:connect(conf.mqtt_broker, conf.mqtt_port, rcv)
