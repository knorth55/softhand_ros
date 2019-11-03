(ros::roseus-add-msgs "std_msgs")
(ros::roseus-add-msgs "jsk_arc2017_baxter")


(defclass softhand-interface
  :super propertied-object
  :slots (finger1-command-topic-name
          finger2-command-topic-name
          finger3-command-topic-name
          finger1-calib-action-client
          finger2-calib-action-client
          finger3-calib-action-client
  ))

(defmethod softhand-interface
  (:init (&key (calibrate nil))
    (ros::rate 10)
    (setq finger1-command-topic-name "/finger1_joint_controller/command")
    (setq finger2-command-topic-name "/finger2_joint_controller/command")
    (setq finger3-command-topic-name "/finger3_joint_controller/command")
    (ros::advertise  finger1-command-topic-name std_msgs::Float64 1)
    (ros::advertise  finger2-command-topic-name std_msgs::Float64 1)
    (ros::advertise  finger3-command-topic-name std_msgs::Float64 1)
    (setq finger1-calib-action-client
          (instance ros::simple-action-client :init
                    "/finger1_joint_controller/calib"
                    jsk_arc2017_baxter::CalibJointAction))
    (setq finger2-calib-action-client
          (instance ros::simple-action-client :init
                    "/finger2_joint_controller/calib"
                    jsk_arc2017_baxter::CalibJointAction))
    (setq finger3-calib-action-client
          (instance ros::simple-action-client :init
                    "/finger3_joint_controller/calib"
                    jsk_arc2017_baxter::CalibJointAction))
    (when calibrate (send self :calibrate))
    self)
  (:calibrate ()
    (send self :calibrate-finger1)
    (send self :calibrate-finger2)
    (send self :calibrate-finger3))
  (:calibrate-finger1 ()
    (send self :start-finger1-calib)
    (send (instance ros::Duration :init 3) :sleep)
    (while (send self :finger1-calibratingp)
      (ros::spin-once)))
  (:calibrate-finger2 ()
    (send self :start-finger2-calib)
    (send (instance ros::Duration :init 3) :sleep)
    (while (send self :finger2-calibratingp)
      (ros::spin-once)))
  (:calibrate-finger3 ()
    (send self :start-finger3-calib)
    (send (instance ros::Duration :init 3) :sleep)
    (while (send self :finger3-calibratingp)
      (ros::spin-once)))
  (:start-finger1-calib ()
    (send finger1-calib-action-client :send-goal
          (instance jsk_arc2017_baxter::CalibJointActionGoal :init)))
  (:start-finger2-calib ()
    (send finger2-calib-action-client :send-goal
          (instance jsk_arc2017_baxter::CalibJointActionGoal :init)))
  (:start-finger3-calib ()
    (send finger3-calib-action-client :send-goal
          (instance jsk_arc2017_baxter::CalibJointActionGoal :init)))
  (:finger1-calibratingp ()
    (ros::spin-once)
    (eq (send finger1-calib-action-client :get-state) ros::*simple-goal-state-active*))
  (:finger2-calibratingp ()
    (ros::spin-once)
    (eq (send finger2-calib-action-client :get-state) ros::*simple-goal-state-active*))
  (:finger3-calibratingp ()
    (ros::spin-once)
    (eq (send finger3-calib-action-client :get-state) ros::*simple-goal-state-active*))
  (:start-grasp ()
    (send self :finger-all-rotate  0.0))
  (:stop-grasp ()
    (send self :finger-all-rotate  3.0))
  (:finger-all-rotate (angle)
    (send self :finger1-rotate angle)
    (send self :finger2-rotate angle)
    (send self :finger3-rotate angle))
  (:finger1-rotate (angle)
    (let ((msg (instance std_msgs::Float64 :init :data angle)))
      (ros::publish finger1-command-topic-name msg)))
  (:finger2-rotate (angle)
    (let ((msg (instance std_msgs::Float64 :init :data angle)))
      (ros::publish finger2-command-topic-name msg)))
  (:finger3-rotate (angle)
    (let ((msg (instance std_msgs::Float64 :init :data angle)))
      (ros::publish finger3-command-topic-name msg))))

(defun softhand-init ()
  (ros::roseus "softhand_interface")
  (setq *ri* (instance softhand-interface :init)))
