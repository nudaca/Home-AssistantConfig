#!/bin/bash

bt="4C:65:A8:D2:DA:A0"
sensor="sensor1"

RET=1
until [ ${RET} -eq 0 ]; do
    data=$(/usr/bin/timeout 20 /usr/bin/gatttool -b $bt --char-write-req --handle=0x10 -n 0100 --listen | grep "Notification handle" -m 2)
    RET=$?
    sleep 5
done

RET=1
until [ ${RET} -eq 0 ]; do
    battery=$(/usr/bin/gatttool -b $bt --char-read --handle=0x18 | cut -c 34-35)
    RET=$?
    sleep 5
done

temp=$(echo $data | tail -1 | cut -c 42-54 | xxd -r -p)
humid=$(echo $data | tail -1 | cut -c 64-74 | xxd -r -p)
batt=$(echo "ibase=16; $battery"  | bc)

if [[ "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]]
then
/usr/bin/mosquitto_pub -h <ip> -V mqttv311 -u <user> -P <password> -t "homeassistant/xiaomi/$sensor/temp" -m "$temp"
fi

if [[ "$humid" =~ ^[0-9]+(\.[0-9]+)?$ ]]
then
/usr/bin/mosquitto_pub -h <ip> -V mqttv311 -u <user> -P <password> -t "homeassistant/xiaomi/$sensor/humidity" -m "$humid"
fi

if [[ "$batt" =~ ^[0-9]+(\.[0-9]+)?$ ]]
then
/usr/bin/mosquitto_pub -h <ip> -V mqttv311 -u <user> -P <password> -t "homeassistant/xiaomi/$sensor/battery" -m "$batt"
fi
