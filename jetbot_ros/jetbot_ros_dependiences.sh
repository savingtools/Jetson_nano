#!/usr/bin/env bash

# Shell script scripts to install useful tools , such as opencv , pytorch...
# -------------------------------------------------------------------------
#Copyright © 2019 Wei-Chih Lin , kjoelovelife@gmail.com 

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
# -------------------------------------------------------------------------
# reference
# https://chtseng.wordpress.com/2019/05/01/nvida-jetson-nano-%E5%88%9D%E9%AB%94%E9%A9%97%EF%BC%9A%E5%AE%89%E8%A3%9D%E8%88%87%E6%B8%AC%E8%A9%A6/
#
# -------------------------------------------------------------------------

if [[ `id -u` -eq 0 ]] ; then
    echo "Do not run this with sudo (do not run random things with sudo!)." ;
    exit 1 ;
fi

# setup sleep time
sleep_time=3s

# get hardware-platform
hardware_platform=$(uname -i)

# judge hardware platform
if [ "${hardware_platform}" == "aarch64"  ] ; then
    # Configure power mode : 5W
    sudo nvpmodel -m1

    # Configure power mode : 10W
    #sudo nvpmodel -m0

    ## If you want to see power mode , use 
    sudo nvpmodel -q
else 
    # show information
    echo "You don't use Jeton-nano. Will not setup power mode."

fi

sleep $sleep_time

#=========step 1. install Adafruit Libraries ==================================
# pip should be installed
sudo apt-get install python-pip

# install Adafruit libraries
sudo pip2 install Adafruit-MotorHAT Adafruit-SSD1306
#==============================================================================

#=========step 2. Grant your user access to the i2c bus =======================
# pip should be installed
sudo usermod -aG i2c $USER
#==============================================================================

#=========step 3. Build jetson-inference ======================================
# git and cmake should be installed
sudo apt-get install git cmake

# get workspace
workspace="Jetson_nano/jetbot_ros"

if [ "${hardware_platform}" == "aarch64"  ] ; then

    # clone the repo and submodules
    cd ~/$workspace
    git clone https://github.com/dusty-nv/jetson-inference
    cd jetson-inference
    git submodule update --init

    # build from source
    mkdir build
    cd build
    cmake ../
    make

    # install libraries
    sudo make install

else

    # show information    
    echo "You don't use Jetson-nano. Will remove package jetbot_ros and ros_deep_learning in ~/${workspace}/catkin_ws/src "

    # delete jetbot_ros and ros_deep_learning package in file "src" , because theese package just can make with jetson family 
    sudo rm -rf ~/$workspace/catkin_ws/src/jetbot_ros
    sudo rm -rf ~/$workspace/catkin_ws/src/ros_deep_learning

fi

sleep $sleep_time

#==============================================================================

#=========step 4. Build jetson-inference ======================================
# install dependencies 
sudo apt install -y \
	python-frozendict \
	libxslt-dev \
	libxml2-dev \
	python-lxml \
	python-bs4 \
	python-tables \
    python-sklearn \
    python-rospkg \
    apt-file \
    iftop \
    atop \
    ntpdate \
    python-termcolor \
    python-sklearn \
    libatlas-base-dev \
    python-dev \
    ipython \
    python-sklearn \
    python-smbus \
    libmrpt-dev \
    mrpt-apps \
    ros-melodic-slam-gmapping \
    ros-melodic-map-server \
    ros-melodic-navigation \
    ros-melodic-vision-msgs \
    ros-melodic-image-transport \
    ros-melodic-image-publisher \
    byobu

#==============================================================================

#======  step 5. Create the name "/dev/ydlidar" for YDLIDAR  ==================
# install dependencies 
echo "Setup YDLidar X4 , and it information in ~/${workspace}/catkin_ws/src/ydlidar/README.md "
cd ~/Jetson_nano/jetbot_ros/catkin_ws/src/ydlidar/startup
sudo chmod 777 ./*
sudo sh initenv.sh
sudo udevadm control --reload-rules
sudo udevadm trigger
cd ~/$workspace
#==============================================================================

# None of this should be needed. Next time you think you need it, let me know and we figure it out. -AC
# sudo pip install --upgrade pip setuptools wheel
