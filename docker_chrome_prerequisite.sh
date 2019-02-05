#!/bin/bash

# Based on: http://www.richud.com/wiki/Ubuntu_Fluxbox_GUI_with_x11vnc_and_Xvfb


apt-get update; apt-get clean

useradd apps

mkdir -p /home/apps && chown apps:apps /home/apps

# Install x11vnc.
apt-get install -y x11vnc
# Install xvfb.
apt-get install -y xvfb
# Install fluxbox.
apt-get install -y fluxbox
# Install wget.
apt-get install -y wget
# Install wmctrl.
apt-get install -y wmctrl
# Set the Chrome repo.
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# Install Chrome.
apt-get update && apt-get -y install google-chrome-stable


export VNC_SERVER_PASSWORD=password
