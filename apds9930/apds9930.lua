-- ***************************************************************************
-- APDS9930 module for ESP8266 with nodeMCU
--
-- Written by Aleksandr Aleksyshyn (https://github.com/a-sanders)
--
-- MIT license, http://opensource.org/licenses/MIT
-- ***************************************************************************
require("bit")
require("i2c")

local moduleName = ...
local M = {}
_G[moduleName] = M

require('apds9930_const')
require('apds9930_misc')

M._read_reg = read_reg
M._read_byte = read_byte
M._read_word = read_word
M._write_reg = write_reg
M._write_byte = write_byte
M._write_word = write_word
M._write_raw_byte = write_raw_byte
M.ambient_to_lux = ambient_to_lux

-- initialize i2c
function M.setup()
  if is_i2c_addr_valid(I2C_ADDR) == false then
    print("APDS9930 device not found")
    return false
  end
  
  M.enable(F.ALL, OFF)
  write_byte(R.ATIME, DEF.ATIME)
  write_byte(R.PTIME, DEF.PTIME)
  write_byte(R.WTIME, DEF.WTIME)
  write_byte(R.POFFSET, DEF.POFFSET)
  write_byte(R.CONFIG, DEF.CONFIG)
  write_byte(R.PPULSE, DEF.PPULSE) 
  write_byte(R.CONTROL, bit.bor(
    bit.lshift(DEF.PDRIVE, 6), 
	bit.lshift(DEF.PDIODE, 4),
	bit.lshift(DEF.PGAIN, 2),
	DEF.AGAIN))
  write_word(R.PILT, DEF.PILT)
  write_word(R.PIHT, DEF.PIHT)
  write_word(R.AILT, DEF.AILT)
  write_word(R.AIHT, DEF.AIHT)
  write_byte(R.PERS, DEF.PERS)
  return true
end

-- The value of the ENABLE register, which stores 
-- the enabled features of the sensor
function M.enabled_raw()
  return read_byte(R.ENABLE)
end

-- The ID of the device
function M.id()
  return read_byte(R.ID)
end

-- Get proximity data
function M.getProximityData()
  return read_word(R.PDATA)
end

-- Gets the state of a specific feature in the ENABLE register
function M.isEnabled(f)
  local v = M.enabled_raw()
  return bit.isset(v, f)
end

-- Enable/disable the state of a specific feature in the ENABLE register
function M.enable(f, enable)
  local v = M.enabled_raw()	
  if f >= 0 and f <= 6 then
    if enable then
      v = bit.set(v, f)
    else
      v = bit.clear(v, f)
	end
  elseif f == F.ALL then
    if enable then
      v = 0x7F 
    else 
      v = 0x00
    end
  end
  write_byte(R.ENABLE, v)
end 

-- LED drive strength for proximity and ALS
function M.ctrlLEDDrive(v)
  local c = read_byte(R.CONTROL)
  if v ~= nil then
    local v = bit.band(v, 3)
	v = bit.lshift(v, 6)
	c = bit.band(c, 0x3F)
	v = bit.bor(v, c)
	write_byte(R.CONTROL, v)
  else
	c = bit.band(bit.rshift(c, 6), 3)
    return c
  end
end

-- Diode used for proximity sensor
function M.ctrlProximityDiode(v)
  local c = read_byte(R.CONTROL)
  if v ~= nil then
    local v = bit.band(v, 3)
	v = bit.lshift(v, 4)
	c = bit.band(c, 0xCF)
	v = bit.bor(v, c)
	write_byte(R.CONTROL, v)
  else
	c = bit.band(bit.rshift(c, 4), 3)
    return c
  end
end

-- Receiver gain for proximity detection
function M.ctrlProximityGain(v)
  local c = read_byte(R.CONTROL)
  if v ~= nil then
    local v = bit.band(v, 3)
	v = bit.lshift(v, 2)
	c = bit.band(c, 0xF3)
	v = bit.bor(v, c)
	write_byte(R.CONTROL, v)
  else
	c = bit.band(bit.rshift(c, 2), 3)
    return c
  end
end

--  Receiver gain for ambient light sensor
function M.ctrlALSGain(v)
  local c = read_byte(R.CONTROL)
  if v ~= nil then
    local v = bit.band(v, 3)
	c = bit.band(c, 0xFC)
	v = bit.bor(v, c)
	write_byte(R.CONTROL, v)
  else
	c = bit.band(c, 3)
    return c
  end
end

local function _state(f, v)
  if v ~= nil then
    M.enable(f, v)
  end
  return M.isEnabled(f)
end

-- Turn on or off the internal oscillator and return current state
function M.statePower(v)
  return _state(F.POWER, v)
end

-- Enable or disable the ALS sensor and return current state
function M.stateALSSensor(v)
  return _state(F.AMB_LIGHT, v)
end

-- Enable or disable the proximity sensor and return current state
function M.stateProximitySensor(v)
  return _state(F.PROXIMITY, v)
end

-- Enable or disable the wait timer feature and return current state
function M.stateWaitTimer(v)
  return _state(F.WAIT, v)
end

-- Enable or disable the ALS interrupt and  return current state
function M.stateALSInterrupt(v)
  return _state(F.AMB_LIGHT_INT, v)
end

-- Enable or disable the proximity interrupt and return current state
function M.stateProximityInterrupt(v)
  return _state(F.PROXIMITY_INT, v)
end

-- Enable or disable the sleep after interrupt feature. If True,
-- the device will power down after an interrupt has been generated
function M.stateSleepAfterInterrupt(v)
  return _state(F.SLEEP_AFTER_INT, v)
end

-- If True, the device is asserting an ambient light interrupt
function M.isALSInterrupt()
  local v = read_byte(R.STATUS)
  return bit.isset(v, 4)
end

-- ALS interrupt clear
function M.clearALSInterrupt()
  write_raw_byte(CLEAR_ALS_INT)
end

-- If True, the device is asserting a proximity interrupt
function M.isProximityInterrupt()
  local v = read_byte(R.STATUS)
  return bit.isset(v, 5)
end

-- Proximity interrupt clear
function M.clearProximityInterrupt()
  write_raw_byte(CLEAR_PROX_INT)
end

-- Clear all interrupts
function M.clearAllInterrupts()
  write_raw_byte(CLEAR_ALL_INTS)
end

-- Set all the needed values to turn on the ALS and turn it on.
-- If int is True, ALS interrupts will also be enabled
-- Parameters thL and thH - thresholds
function M.enableALSSensor(int, thL, thH)
  local int = int ~= nil and int or false
  local thL = thL ~= nil and thL or DEF.AILT
  local thH = thH ~= nil and thH or DEF.AIHT
  M.ctrlALSGain(DEF.AGAIN)
  if int then
	write_word(R.AILT, thL)
	write_word(R.AIHT, thH)
  end
  M.stateALSInterrupt(int)
  M.statePower(true)
  M.stateALSSensor(true)
end

-- Set all the needed values to turn on the proximity sensor and turn it on.
-- If int is True, proximity interrupts will also be enabled
-- Parameters thL and thH - thresholds
function M.enableProximitySensor(int, thL, thH)
  local int = int ~= nil and int or false
  local thL = thL ~= nil and thL or DEF.PILT
  local thH = thH ~= nil and thH or DEF.PIHT
  M.ctrlLEDDrive(DEF.PDRIVE)
  M.ctrlProximityDiode(DEF.PDIODE)
  M.ctrlProximityGain(DEF.PGAIN)
  if int then
	write_word(R.PILT, thL)
	write_word(R.PIHT, thH)
  end
  M.stateProximityInterrupt(int)
  M.statePower(true)
  M.stateProximitySensor(true)
end

-- Get data from channel 0
function M.getCh0Data()
  return read_word(R.CH0DATA)
end

-- Get data from channel 1 
-- Proximity ADC channel (see CONTROL register, bits PDIODE)
function M.getCh1Data()
  return read_word(R.CH1DATA)
end

-- Get ALS value in lux
function M.getALSData()
  local ch0 = M.getCh0Data()
  local ch1 = M.getCh1Data()
  local gain = bit.band(read_byte(R.CONTROL), 3)
  return M.ambient_to_lux(ch0, ch1, gain)
end

-- Get proximity interrupt low and high threshold
function M.getProximityIntThreshold()
  return read_word(R.PILT), read_word(R.PIHT)
end

-- Set proximity interrupt low and high threshold
function M.setProximityIntThreshold(low, high)
  write_word(R.PILT, low)
  write_word(R.PIHT, high)
  return getProximityIntThreshold()
end

-- Get ALS interrupt low and high threshold
function M.getALSIntThreshold()
  return read_word(R.AILT), read_word(R.AIHT)
end

-- Set ALS interrupt low and high threshold
function M.setALSIntThreshold(low, high)
  write_word(R.AILT, low)
  write_word(R.AIHT, high)
  return getALSIntThreshold()
end

return M
