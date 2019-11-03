(ros::roseus-add-msgs "std_msgs")


(defclass softhand-interface
  :super propertied-object
  :slots (finger1-command-topic-name
          finger2-command-topic-name
          finger3-command-topic-name))

(defmethod softhand-interface
  (:init (&key (calibrate t))
    (setq finger1-command-topic-name "/finger1_joint_controller/command")
    (setq finger2-command-topic-name "/finger2_joint_controller/command")
    (setq finger3-command-topic-name "/finger3_joint_controller/command")
    (ros::advertise  finger1-command-topic-name std_msgs::Float64 1)
    (ros::advertise  finger2-command-topic-name std_msgs::Float64 1)
    (ros::advertise  finger3-command-topic-name std_msgs::Float64 1)
    (when calibrate (send self :calibrate))
    self)
  (:calibrate
    ;; not implemented yet
    t)
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
