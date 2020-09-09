(ros::roseus-add-msgs "std_msgs")
(ros::roseus-add-msgs "softhand_ros")


(defclass softhand-interface
  :super propertied-object
  :slots (finger1-controller-name
          finger2-controller-name
          finger3-controller-name
          finger1-command-topic-name
          finger2-command-topic-name
          finger3-command-topic-name
          finger1-calib-action-client
          finger2-calib-action-client
          finger3-calib-action-client
  ))

(defmethod softhand-interface
  (:init (&key (calibrate nil) (namespace nil))
    (ros::rate 10)
    (setq finger1-controller-name
          (format nil "~A/finger1_joint_controller" (if namespace namespace "")))
    (setq finger2-controller-name
          (format nil "~A/finger2_joint_controller" (if namespace namespace "")))
    (setq finger3-controller-name
          (format nil "~A/finger3_joint_controller" (if namespace namespace "")))
    (setq finger1-command-topic-name
          (format nil "~A/command" finger1-controller-name))
    (setq finger2-command-topic-name
          (format nil "~A/command" finger2-controller-name))
    (setq finger3-command-topic-name
          (format nil "~A/command" finger3-controller-name))
    (ros::advertise  finger1-command-topic-name std_msgs::Float64 1)
    (ros::advertise  finger2-command-topic-name std_msgs::Float64 1)
    (ros::advertise  finger3-command-topic-name std_msgs::Float64 1)
    (setq finger1-calib-action-client
          (instance ros::simple-action-client :init
                    (format nil "~A/calib" finger1-controller-name)
                    softhand_ros::CalibJointAction))
    (setq finger2-calib-action-client
          (instance ros::simple-action-client :init
                    (format nil "~A/calib" finger2-controller-name)
                    softhand_ros::CalibJointAction))
    (setq finger3-calib-action-client
          (instance ros::simple-action-client :init
                    (format nil "~A/calib" finger3-controller-name)
                    softhand_ros::CalibJointAction))
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
          (instance softhand_ros::CalibJointActionGoal :init)))
  (:start-finger2-calib ()
    (send finger2-calib-action-client :send-goal
          (instance softhand_ros::CalibJointActionGoal :init)))
  (:start-finger3-calib ()
    (send finger3-calib-action-client :send-goal
          (instance softhand_ros::CalibJointActionGoal :init)))
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
    (send self :finger-all-rotate  (* pi -2.0)))
  (:stop-grasp ()
    (send self :finger-all-rotate  pi))
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
