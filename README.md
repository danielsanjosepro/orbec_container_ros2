# Orbec Container ROS2

A Docker-based ROS2 environment for working with Orbec cameras (Femto Bolt), providing a containerized setup for camera development and testing.

## Quick Start

### 1. Build Container

```bash
docker compose build
```

### 2. Launch Camera Node

Get the camera serial number

```bash
cyme  # or lsusb
```

Run the camera launch service

```bash
CAMERA_NAMESPACE=camera CAMERA_NAME=camera SERIAL_NUMBER=xxx docker compose up launch_camera 
```


## Development

### Using DevContainer (Recommended)

from the terminal:
```bash
# Start development container from terminal
./start_dev.sh
source ros_aliases.sh
cb  # To build 
sw  # To source the ros ws
```
or just using VS-code devcontainer extension.

