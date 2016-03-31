# Readme

This install file configures your Raspberrypi 3 Model B as a Wifi-Access Point (AP)
by sharing the incoming internet connection on `eth0` on the `wlan0` device
(internal WiFi Chip on the new Pi).

Calling the script:

```
sudo su install.sh
Parameters are:
1: SSID (default: WiFiAPi )
2: PASSPHRASE(default: Raspberrypi)
3: IP_RANGE (default: 192.168.1, produces IP of Pi with 192.168.1.1)
4: Incoming Internet connection device (default: eth0)
5: WiFi Connection Device (default: wlan0)
```






Feel free to modify it.
