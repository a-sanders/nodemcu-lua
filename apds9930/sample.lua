-- initialize I2C BUS
id = 0 -- i2c.HW0
sda = 5 -- GPIO14
scl = 1 -- GPIO5
i2c.setup(id, sda, scl, i2c.FAST)

apds = require('apds9930')
apds.setup()

prox_timer = tmr:create()
prox_timer:register(500, tmr.ALARM_AUTO, function(t) 
  print(apds.getProximityData()) 
end)

amb_timer = tmr:create()
amb_timer:register(500, tmr.ALARM_AUTO, function(t) 
  print(apds.getALSData(), apds.getCh0Data(), apds.getCh1Data()) 
end)

print(string.format('id: 0x%02x', apds.id()))
print(string.format('enabled: 0x%02x', apds.enabled_raw()))
print(string.format('control: 0x%02x', apds._read_byte(R.CONTROL)))

apds.enableProximitySensor()
prox_timer:start()

apds.enableALSSensor()
amb_timer:start()
