#!/bin/bash
# ROS2 aliases
alias cb="cd ~/ros2_ws && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && proj"
alias cb_simple="cd ~/ros2_ws && colcon build"
alias sw="source /opt/ros/$ROS_DISTRO/setup.bash && source ~/ros2_ws/install/setup.bash"

# Go to the lsy_franka repo
alias proj="cd ~/ros2_ws/src/lsy_franka"
alias venv="uv venv && source .venv/bin/activate && export PYTHONPATH=~/ros2_ws/src/lsy_franka/.venv/lib/python3.10/site-packages:$PYTHONPATH"

ls_cmds() {
    echo "=> Available commands"
    echo ""
    echo "|> Setup commands"
    echo "--> cb - to colcon build, can be executed from any directory."
    echo "--> cb_simple - to colcon build, can be executed from any directory."
    echo "--> sw - to source ROS2 workspace."
    echo "--> proj - to go to the lsy_franka repo."
    echo "--> venv - to activate the virtual environment."
    echo ""
    echo "|> ROS starting commands"
    echo "--> lsy - to launch Franka robot."
    echo "--> launch - to launch different nodes. Add a -s tag to see available arguments to be passed as <arg>:=<value>."
    echo "--> run - to run different nodes."
    echo ""
    echo "|> ROS control commands"
    echo "--> enable - to enable a controller."
    echo "--> disable - to disable a controller."
    echo "--> ls_ctrl - to list controllers."
}

# LSY Franka aliases
lsy() {
    namespace="default"
    robot_ip="172.16.0.2"
    fake="false"
    has_camera="false"
    rviz_config="default.rviz"
    extra_args="${@:2}"

    usage_msg() {
        echo "Usage: lsy [left|right|both] [options]"
    }

    case "$1" in
        left)
            namespace="left"
            robot_ip="172.16.1.2"
            has_camera="true"
            rviz_config="left.rviz"
            ;;
        right)
            namespace="right"
            robot_ip="172.16.0.2"
            rviz_config="default.rviz"
            ;;
        # genesis)
        #     namespace="sim"
        #     robot_ip="127.0.0.1"
        #     rviz_config="default.rviz"
        #     ;;
        both)
            case "$2" in
                fake)
                    fake="true"
                    extra_args="${@:3}"
                    ;;
            esac
            ros2 launch lsy_franka_bringup dual_franka.launch.py use_fake_hardware:=$fake $extra_args
            return
            ;;
        *)
            echo "Failed parsing first argument!"
            usage_msg
            return
            ;;
    esac

    case "$2" in
        fake)
            fake="true"
            extra_args="${@:3}"
            ;;
    esac
    ros2 launch lsy_franka_bringup franka.launch.py use_fake_hardware:=$fake robot_ip:=$robot_ip arm_id:=fr3 namespace:=$namespace has_camera:=$has_camera $extra_args

}




launch () {
    sw
    pkg=""
    launch_file=""

    case "$1" in
        cam)
            ros2 launch realsense2_camera rs_launch.py camera_name:=camera camera_namespace:=camera "${@:2}"
            pkg="realsense2_camera"
            launch_file="rs_launch.py"
            camera_name="camera"
            camera_ns_set=false

            case "$2" in
                left)
                    camera_name="left_wrist_camera"
                    camera_ns="left"
                    camera_ns_set=true
                    ;;
                right)
                    camera_name="right_wrist_camera"
                    camera_ns="right"
                    camera_ns_set=true
                    ;;
                camera)
                    camera_name="camera"
                    camera_ns="camera"
                    camera_ns_set=true
                    ;;
                *)
                    camera_name="wrist_camera"
                    camera_ns=""
                    camera_ns_set=false
                    ;;
            esac

            if [ "$camera_ns_set" = true ]; then
                ros2 launch "$pkg" "$launch_file" camera_name:="$camera_name" camera_namespace:="$camera_ns" "${@:3}"
            else
                ros2 launch "$pkg" "$launch_file" camera_name:="$camera_name" "${@:2}"
            fi
            return
            ;;
        tpcam)
            pkg="lsy_franka_bringup"
            launch_file="femto_bolt.launch.py"
            camera_name="third_person_camera"
            camera_ns_set=false
            usb_port=""

            case "$2" in
                left)
                    camera_name="left_third_person_camera"
                    camera_ns="left"
                    camera_ns_set=true
                    ;;
                right)
                    camera_name="right_third_person_camera"
                    camera_ns="right"
                    camera_ns_set=true
                    serial_number="CL8MB330047"
                    ;;
                right_down)
                    camera_name="right_down_third_person_camera"
                    camera_ns="right"
                    camera_ns_set=true
                    serial_number="CL8MB330047"
                    ;;
                right_up)
                    camera_name="right_up_third_person_camera"
                    camera_ns="right"
                    camera_ns_set=true
                    serial_number="CL8MB330050"
                    ;;
                *)
                    camera_name="third_person_camera"
                    camera_ns=""
                    camera_ns_set=false
                    ;;
            esac

            if [ "$camera_ns_set" = true ]; then
                ros2 launch "$pkg" "$launch_file" camera_name:="$camera_name" camera_ns:="$camera_ns" enable_ir:=false enable_depth:=false time_domain:=system serial_number:=$serial_number device_num:=4 attach_component_container_enable:=false"${@:3}"
            else
                ros2 launch "$pkg" "$launch_file" camera_name:="$camera_name" enable_ir:=false enable_depth:=false time_domain:=system usb_port=$usb_port "${@:2}"
            fi
            return
            ;;
        vicon)
            pkg="lsy_franka_vicon"
            launch_file="vicon.launch.py"
            case "$2" in
                left)
                    ros2 launch $pkg $launch_file franka_namespace:=\left "${@:3}"
                    return
                    ;;
                right)
                    ros2 launch $pkg $launch_file franka_namespace:=\right "${@:3}"
                    return
                    ;;
            esac
            ;;
        sync)
            pkg="lsy_franka_control_helpers"
            launch_file="sync.launch.py"
            ;;
        gripper_teleop)
            pkg="lsy_franka_control_helpers"
            launch_file="gripper_teleop.launch.py"
            ;;
        gripper)
            pkg="lsy_franka_bringup"
            launch_file="gripper.launch.py"
            case "$2" in
                left)
                    ros2 launch $pkg $launch_file robot_ip:=172.16.1.2 namespace:=/left "${@:3}"
                    return
                    ;;
                right)
                    ros2 launch $pkg $launch_file robot_ip:=172.16.0.2 namespace:=/right "${@:3}"
                    return
                    ;;
            esac
            ;;
        *)
            echo "Unknown launch name! Check if it exists."
            echo "Available launches: cam, vicon, sync, gripper, gripper_teleop."
            return
            ;;

    esac
    ros2 launch $pkg $launch_file "${@:2}"
}

buttons() {
    case "$1" in
        left)
        ros2 run franka_buttons franka_pilot_buttons --ros-args -p hostname:=172.16.1.2 -r __ns:=/left
        ;;
        right)
        ros2 run franka_buttons franka_pilot_buttons --ros-args -p hostname:=172.16.0.2 -r __ns:=/right
        ;;
    esac

}

run () {
    pkg=""
    node=""
    namespace_arg=""
    case "$1" in
        keyboard)
            pkg="lsy_franka_control_helpers"
            node="keyboard_controller"
            ;;
        io)
            pkg="lsy_franka_control_helpers"
            node="io_controller"
            ;;
        target_publisher)
            pkg="lsy_franka_control_helpers"
            node="target_publisher"
            ;;
        fake_vicon)
            pkg="lsy_franka_vicon"
            node="fake_vicon_publisher"
            namespace_arg="--ros-args -r __ns:=/vicon"
            ;;
        vicon_to_pose)
            pkg="lsy_franka_vicon"
            node="vicon_to_pose"
            namespace_arg="--ros-args -r __ns:=/vicon"
            ;;
        lsy_franka_gym)
            pkg="lsy_franka_gym"
            node="lsy_franka_gym"
            ;;
        gripper_adapter)
            pkg="lsy_franka_control_helpers"
            node="crisp_py_gripper_adapter"
            ;;
    esac

    case "$2" in
        left)
            namespace_arg="--ros-args -r __ns:=/left"
            ;;
        right)
            namespace_arg="--ros-args -r __ns:=/right"
            ;;
    esac
    sw
    ros2 run $pkg $node $namespace_arg ${@:3}
}

# Some ros2 control functions
get_controller() {
    controller=""
    case "$1" in
        jtc)
            controller="joint_trajectory_controller"
            ;;
        pin)
            controller="pin_cartesian_impedance_controller"
            ;;
        osc)
            controller="operational_space_controller"
            ;;
        tsid)
            controller="tsid_controller"
            ;;
        jointvel)
            controller="joint_velocity_controller"
            ;;
        joint)
            controller="joint_controller"
            ;;
        gravity)
            controller="gravity_compensation"
            ;;
        torquefb)
            controller="torque_feedback_controller"
            ;;
        free)
            controller="frictionless_controller"
            ;;
    esac
    echo "$controller"
}

get_controller_manager() {
    case "$1" in
        left)
            controller_manager="-c /left/controller_manager"
            ;;
        right)
            controller_manager="-c /right/controller_manager"
            ;;
    esac
    echo "$controller_manager"
}

enable() {
    controller="$(get_controller $1)"
    controller_manager="$(get_controller_manager $2)"

    echo controller: $controller
    echo controller_manager: $controller_manager

    ros2 control set_controller_state $controller active $controller_manager
}
disable() {
    controller="$(get_controller $1)"
    controller_manager="$(get_controller_manager $2)"

    ros2 control set_controller_state $controller inactive $controller_manager
}

ls_ctrl() {
    controller_manager="$(get_controller_manager $1)"
    ros2 control list_controllers $controller_manager
}

rs_config() {
    sw
    case "$1" in
        left)
            camera_name="left_wrist_camera"
            camera_ns="left"
            ;;
        right)
            camera_name="right_wrist_camera"
            camera_ns="right"
            ;;
        camera)
            camera_name="camera"
            camera_ns="camera"
            ;;
        *)
            echo "Unknown camera name! Check if it exists."
            echo "Available cameras: left, right, or camera."
            return
            ;;
    esac
    ros2 param set /${camera_ns}/${camera_name} depth_module.white_balance 3900.0
    ros2 param set /${camera_ns}/${camera_name} depth_module.enable_auto_exposure false
    ros2 param set /${camera_ns}/${camera_name} depth_module.exposure 10000
    ros2 param set /${camera_ns}/${camera_name} depth_module.gain 16

}
