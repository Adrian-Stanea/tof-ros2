#!/usr/bin/env bash

BRANCH_NAME=${BRANCH_NAME:-main}

# TODO: review the build process
#  TBD: docker image prepares the ros2_ws and the CI just does a checkout
#       - try to build the package with colcon
#       - run tests if possible
#       - investigate if another CI can create a local .deb that could be used as an artifact
# 
#  A release will publish the .deb or a Docker image wrapper using the .deb form the ros2.org index

build_from_source() {
    rm -rf ros2_ws
    mkdir -p ros2_ws/src && cd ros2_ws/src
    git clone --depth 1 --branch $BRANCH_NAME https://github.com/analogdevicesinc/tof-ros2
    cd ..

    source /opt/ros/"$ROS_DISTRO"/setup.sh

    # Install dependencies using rosdep
    rosdep update
    rosdep install --from-paths src --ignore-src -r -y

    colcon build \
        --cmake-args \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9 \
        -DCMAKE_PREFIX_PATH=/opt/glog;/opt/websockets;/opt/protobuf

    # Create .deb packages locally
    rosdep install --from-paths src -y --ignore-src

    cd src/tof-ros2
    bloom-generate rosdebian \
        --ros-distro $ROS_DISTRO

    fakeroot debian/rules binary
}
