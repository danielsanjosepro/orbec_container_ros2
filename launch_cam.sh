launch_camera() {
    pkg="orbec_container_ros2"
    launch_file="femto_bolt.launch.py"
    camera_name="third_person_camera"

    ros2 launch "$pkg" "$launch_file" enable_ir:=false enable_depth:=false time_domain:=system device_num:=4 attach_component_container_enable:=false "${@:1}"
    # camera_name:="$camera_name" camera_ns:="$camera_ns" serial_number:=$serial_number 
}
