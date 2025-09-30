#!/bin/bash
# ROS2 aliases
alias cb="cd ~/ros2_ws && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && proj"
alias sw="source /opt/ros/$ROS_DISTRO/setup.bash && source ~/ros2_ws/install/setup.bash"
alias proj="cd ~/ros2_ws/src/orbec_camera_ros2"
