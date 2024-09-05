version: '3.8'

services:
  gammu:
    image: gammu/gammu
    container_name: gammu
    devices:
      - "/dev/ttyUSB0:/dev/ttyUSB0"
    environment:
      - GAMMU_DEVICE=/dev/ttyUSB0
      - GAMMU_CONNECTION=at115200
    volumes:
      - ./gammu-config:/etc/gammu
    restart: always


gammu-config/gammurc
[gammu]
device = /dev/ttyUSB0
connection = at115200

import gammu

sm = gammu.StateMachine()
sm.ReadConfig()
sm.Init()

message = {
    'Text': 'Hello, this is a test message!',
    'SMSC': {'Location': 1},
    'Number': '+1234567890',
}

sm.SendSMS(message)