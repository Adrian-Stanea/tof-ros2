# Use the ROS2 base image
ARG ROS_DISTRO=humble
ARG FROM_IMAGE=ros:${ROS_DISTRO}-ros-base
ARG OVERLAY_WS=/opt/ros/overlay_ws

FROM ${FROM_IMAGE}

LABEL maintainer="Bogdan Stanea, <Adrian.Stanea@analog.com>"

# Disable apt user dialogs when installing packages
ENV DEBIAN_FRONTEND=noninteractive

ARG OVERLAY_WS

# Install dependencies
WORKDIR /tmp

COPY ./apt-packages.txt /tmp/apt-packages.txt
COPY ./install_dependencies.sh /tmp/install_dependencies.sh

RUN chmod +x /tmp/install_dependencies.sh \
    && /tmp/install_dependencies.sh install_all \
    && rm /tmp/install_dependencies.sh \
    && rm /tmp/apt-packages.txt \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $OVERLAY_WS/src

# Enable apt user dialogs again
ARG DEBIAN_FRONTEND=dialog
