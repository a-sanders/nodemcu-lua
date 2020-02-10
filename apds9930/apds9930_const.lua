-- ***************************************************************************
-- APDS9930 module for ESP8266 with nodeMCU
-- Common constants.
--
-- Written by Aleksandr Aleksyshyn (https://github.com/a-sanders)
--
-- MIT license, http://opensource.org/licenses/MIT
-- ***************************************************************************

-- Default I2C ID
I2C_ID = 0

-- APDS-9930 address
I2C_ADDR = 0x39

-- APDS-9930 register addresses
R = {
  ENABLE = 0x00,
  ATIME = 0x01,
  PTIME = 0x02,
  WTIME = 0x03,
  AILTL = 0x04,
  AILTH = 0x05,
  AIHTL = 0x06,
  AIHTH = 0x07,
  PILTL = 0x08,
  PILTH = 0x09,
  PIHTL = 0x0A,
  PIHTH = 0x0B,
  PERS = 0x0C,
  CONFIG = 0x0D,
  PPULSE = 0x0E,
  CONTROL = 0x0F,
  ID = 0x12, -- read-only
  STATUS = 0x13, -- read-only
  CH0DATAL = 0x14,
  CH0DATAH = 0x15,
  CH1DATAL = 0x16,
  CH1DATAH = 0x17,
  PDATAL = 0x18,
  PDATAH = 0x19,
  POFFSET = 0x1E
}

-- word register aliases
R.AILT = R.AILTL
R.AIHT = R.AIHTL
R.PILT = R.PILTL
R.PIHT = R.PIHTL
R.CH0DATA = R.CH0DATAL
R.CH1DATA = R.CH1DATAL
R.PDATA = R.PDATAL

-- ALS coefficients
DF = 52
GA = 0.49
B = 1.862
C = 0.746
D = 1.291

-- Command register modes
REPEATED_BYTE = 0x80
AUTO_INCREMENT = 0xA0
SPECIAL_FN = 0xE0

-- On/Off definitions
OFF = false
ON = true

-- LED Drive values
LED_100MA = 0
LED_50MA = 1
LED_25MA = 2
LED_12_5MA = 3

-- Proximity Gain (PGAIN) values
PGAIN_1X = 0
PGAIN_2X = 1
PGAIN_4X = 2
PGAIN_8X = 3

-- ALS Gain (AGAIN) values
AGAIN_1X = 0
AGAIN_8X = 1
AGAIN_16X = 2
AGAIN_120X = 3

-- Interrupt clear values
CLEAR_PROX_INT = 0xE5
CLEAR_ALS_INT = 0xE6
CLEAR_ALL_INTS = 0xE7

-- Default values
DEF = {
  ATIME = 0xFF,
  WTIME = 0xFF,
  PTIME = 0xFF,
  PPULSE = 0x08,
  POFFSET = 0,       -- 0 offset
  CONFIG = 0,
  -- defaults for CONTROL register 
  PDRIVE = LED_100MA,
  PDIODE = 2, 
  PGAIN = PGAIN_8X,
  AGAIN = AGAIN_16X,
  -- proximity interrupt threshold - low and high
  PILT = 0,
  PIHT = 600,
  -- ambient light interrupt threshold - low and high
  AILT = 0xFFFF, -- Force interrupt for calibration
  AIHT = 0,
  --
  PERS = 0x22 -- 2 consecutive prox or ALS for int.
}

-- Features - acceptable parameters for methods enable/isEnabled
F = {
  POWER = 0,
  AMB_LIGHT = 1,
  PROXIMITY = 2,
  WAIT = 3,
  -- interrupt
  AMB_LIGHT_INT = 4,
  PROXIMITY_INT = 5,
  SLEEP_AFTER_INT = 6,
  --
  ALL = 7
}