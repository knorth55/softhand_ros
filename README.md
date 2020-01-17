# softhand_ros
[![Build Status](https://api.travis-ci.com/knorth55/softhand_ros.svg?branch=master)](https://travis-ci.com/knorth55/softhand_ros)

ROS package for SoftHand

# Installation

## Workspace build

```bash
source /opt/ros/$ROS_DISTRO/setup.bash
mkdir ~/softhand_ws/src -p
cd ~/softhand_ws/src
git clone https://github.com/knorth55/softhand_ros.git
wstool init
wstool merge softhand_ros/fc.rosinstall
wstool up
rosdep install --ignore-src --from-paths . -y -r -i
cd ~/softhand_ws
catkin build
```

## Udev installation

```bash
source ~/softhand_ws/devel/setup.bash
roscd softhand_ros
sudo cp udev/80-ft2232c.rules /etc/udev/rules.d
sudo service udev reload
sudo service udev restart
```

# How to use 

## Launch softhand

```bash
source ~/softhand_ws/devel/setup.bash
roslaunch softhand_ros softhand.launch
```

## Control softhand by euslisp

```bash
roscd softhand_ros/euslisp
roseus softhand-interface.l
# euslisp interactive mode
# (softhand-init)
# (send *ri* :start-grasp)
# (send *ri* :stop-grasp)
```
