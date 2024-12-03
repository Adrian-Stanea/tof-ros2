#!/usr/bin/env bash

ROS_DISTROS=(foxy galactic)

# Note: run the script from the parent directory
cd ..

for ROS_DISTRO in "${ROS_DISTROS[@]}"; do
    sudo docker build \
        --no-cache \
        --file ./docker/Dockerfile \
        --build-arg ROS_DISTRO=${ROS_DISTRO} \
        --tag tof-ros2:${ROS_DISTRO}-dev
done