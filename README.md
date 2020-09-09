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
sudo cp udev/*.rules /etc/udev/rules.d
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

# Softhand hardware installation

## Set baud rate 

```bash
# set baud rate to 1000000
rosrun dynamixel_driver set_servo_config.py -b BAUD_RATE -r 1 MOTOR_ID 
```

### Set motor ID

- 1: Thumb
- 2: Index finger
- 3: Middle finger

```bash
rosrun dynamixel_driver change_id.py OLD_MOTOR_ID NEW_MOTOR_ID
```

### Disable overload error

```python
import roslib
roslib.load_manifest('dynamixel_driver')
from dynamixel_driver import dynamixel_io

dxl_io = dynamixel_io.DynamixelIO("/dev/ttyUSB0", 1000000)
dxl_io.write(MOTOR_ID, 17, (4,))
dxl_io.write(MOTOR_ID, 18, (4,))
```

### Change `product` to distinguish E151 board

We distinguish left and right hand with `product` field of FTDI chip on E151.
- Left E151's `product`: `LEFT-E151`
- Right E151's `product`: `RIGHT-E151`

In order to change them, please follow [jsk_apc doc](https://jsk-apc.readthedocs.io/en/latest/jsk_arc2017_baxter/setup_gripper_v6.html#distinguish-left-dxhub-from-right-one).

If you don't have windows, you can do it with [richardeoin/ftx-prog](https://github.com/richardeoin/ftx-prog) as follows.

```bash
git clone https://github.com/richardeoin/ftx-prog.git
cd ftx-prog/
make
# for left hand
sudo ./ftx-prog --product LEFT-E151
# for left hand
sudo ./ftx-prog --product RIGHT-E151
```
