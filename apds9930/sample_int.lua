-- initialize I2C BUS
id = 0 -- i2c.HW0
sda = 5 -- GPIO14
scl = 1 -- GPIO5
i2c.setup(id, sda, scl, i2c.FAST)

apds = require('apds9930')

apds.setup()

-- Create "sensor interrupt" trigger
gpio.mode(2, gpio.INPUT)
gpio.trig(2, "down", function(l, w)
  if apds.isProximityInterrupt() then
    print(string.format("proximity: %d", apds.getProximityData()))
  end

  if apds.isALSInterrupt() then
    print(string.format("amb.light: %d lux \t%d", apds.getALSData(), apds.getCh0Data()))
  end

  apds.clearAllInterrupts()
end)

print(string.format('id: 0x%02x', apds.id()))
print(string.format('enabled: 0x%02x', apds.enabled_raw()))
print(string.format('control: 0x%02x', apds._read_byte(R.CONTROL)))

apds.clearAllInterrupts()
apds.enableProximitySensor(true, 0, 370)
apds.enableALSSensor(true, 20, 500)
