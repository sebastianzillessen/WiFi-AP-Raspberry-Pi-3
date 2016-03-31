# Readme

This install file configures your Raspberrypi 3 Model B as a Wifi-Access Point (AP)
by sharing the incoming internet connection on `eth0` on the `wlan0` device
(internal WiFi Chip on the new Pi).

## Environment
This script was tested on 

- Raspberry-Pi 3 Model B
- No additonal HW connected
- Rasbian GBU/Linux 8 (`cat /etc/issue`) and Debian version 8.0 (`cat /etc/debian_version`)

## Running
```
git clone https://github.com/sebastianzillessen/WiFi-AP-Raspberry-Pi-3.git
cd WiFi-AP-Raspberry-Pi-3
sudo su
chmod +x install.sh
./install.sh
```

Your can specify the following parameters when calling `./install.sh`:

1. SSID (default: WiFiAPi )
2. PASSPHRASE(default: Raspberrypi)
3. IP_RANGE (default: 192.168.1, produces IP of Pi with 192.168.1.1)
4. Incoming Internet connection device (default: eth0)
5. WiFi Connection Device (default: wlan0)

These are parsed in the order. So with

```
./install.sh TestAP test123
```
You would setup your Raspberrypi with a SSID `TestAp` and a Password `test123`.







Feel free to modify it.
