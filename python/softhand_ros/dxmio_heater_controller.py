import math

import rospy

from dynamixel_driver.dynamixel_const import *

from dynamixel_controllers.srv import SetSpeed
from dynamixel_controllers.srv import TorqueEnable
from dynamixel_controllers.srv import SetComplianceSlope
from dynamixel_controllers.srv import SetComplianceMargin
from dynamixel_controllers.srv import SetCompliancePunch
from dynamixel_controllers.srv import SetTorqueLimit

from std_msgs.msg import Float64
from dynamixel_msgs.msg import MotorStateList
from dynamixel_msgs.msg import JointState


class DxmioHeaterController(object):
    # initialize, start, stop
    def __init__(self, dxl_io, controller_namespace, port_namespace):
        self.running = False
        self.dxl_io = dxl_io
        self.controller_namespace = controller_namespace
        self.port_namespace = port_namespace
        self.joint_name = rospy.get_param(self.controller_namespace + '/joint_name')

        # joint_state
        self.joint_state = JointState(name=self.joint_name, motor_ids=[self.motor_id])

    def initialize(self):
        raise NotImplementedError

    def start(self):
        self.running = True
        self.joint_state_pub = rospy.Publisher(self.controller_namespace + '/state', JointState, queue_size=1)
        self.command_sub = rospy.Subscriber(self.controller_namespace + '/command', Float64, self.process_command)
        self.motor_states_sub = rospy.Subscriber('motor_states/%s' % self.port_namespace, MotorStateList, self.process_motor_states)

    def stop(self):
        self.running = False
        self.joint_state_pub.unregister()
        self.motor_states_sub.unregister()
        self.command_sub.unregister()
        self.speed_service.shutdown('normal shutdown')
        self.torque_service.shutdown('normal shutdown')
        self.compliance_slope_service.shutdown('normal shutdown')

    def set_pwm_duty(self, pwm_duty):
        raise NotImplementedError

    def process_set_pwm_duty(self, req):
        self.set_pwm_duty(req.pwm_duty)
        return [] # success
