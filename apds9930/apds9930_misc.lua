-- ***************************************************************************
-- APDS9930 module for ESP8266 with nodeMCU
-- Miscelaneous functions.
--
-- Written by Aleksandr Aleksyshyn (https://github.com/a-sanders)
--
-- MIT license, http://opensource.org/licenses/MIT
-- ***************************************************************************

require('apds9930_const')

-- Validate I2C device address
function is_i2c_addr_valid(addr)
  i2c.start(I2C_ID)
  local res = i2c.address(I2C_ID, addr, i2c.TRANSMITTER)
  i2c.stop(I2C_ID)
  return res
end

-- Read register data and return table with data
function read_reg(reg_addr, len, mode)
  local mode = mode ~= nil and mode or AUTO_INCREMENT
  local reg_addr = bit.bor(reg_addr, mode)
  local ret={}
  local c, x
  local len = len or 1
  i2c.start(I2C_ID)
  i2c.address(I2C_ID, I2C_ADDR, i2c.TRANSMITTER)
  i2c.write(I2C_ID, reg_addr)
  i2c.stop(I2C_ID)
  i2c.start(I2C_ID)
  i2c.address(I2C_ID, I2C_ADDR, i2c.RECEIVER)
  c=i2c.read(I2C_ID, len)
  for x = 1, len, 1 do
    tc=string.byte(c, x)
    table.insert(ret, tc)
  end
  i2c.stop(I2C_ID)
  return ret
end

-- Read BYTE data from register
function read_byte(reg_addr, mode)
  local d = read_reg(reg_addr, 1, mode)
  return d[1]
end

-- Read WORD data from register
function read_word(reg_addr, mode)
  local d = read_reg(reg_addr, 2, mode)
  return d[1] + bit.lshift(d[2], 8)
end

-- Write data to register. Data should be BYTE or table of bytes
function write_reg(reg_addr, data, mode)
  local mode = mode ~= nil and mode or AUTO_INCREMENT
  local reg_addr = bit.bor(reg_addr, mode)
  i2c.start(I2C_ID)
  i2c.address(I2C_ID, I2C_ADDR, i2c.TRANSMITTER)
  i2c.write(I2C_ID, reg_addr)
  local c = i2c.write(I2C_ID, data)
  i2c.stop(I2C_ID)
  return c
end

-- Write a BYTE to register
write_byte = write_reg

-- Write WORD data to register
function write_word(reg_addr, word, mode)
  local t = {}
  local a = struct.pack("<I2", word)
  local i
  for i=1,#a do
	table.insert(t, a:byte(i))
  end
  return write_reg(reg_addr, t, mode)
end

-- Write a byte to the specified device address.
-- Useful to interact with the COMMAND register directly.
function write_raw_byte(data)
  i2c.start(I2C_ID)
  i2c.address(I2C_ID, I2C_ADDR, i2c.TRANSMITTER)
  i2c.write(I2C_ID, data)
  i2c.stop(I2C_ID)
end

-- Accepts data from both channels and returns a value
-- in lux (according to the datasheet).
function ambient_to_lux(ch0, ch1, gain)
  local ALSIT = 2.73 * (256 - DEF.ATIME)
  local iac = math.max(ch0 - B * ch1, C * ch0 - D * ch1)
  local lpc = GA * DF / (ALSIT * gain)
  return iac * lpc
end
