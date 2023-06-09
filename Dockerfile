FROM ros:noetic

ARG DEBIAN_FRONTEND=noninteractive

# Install some basic dependencies
RUN apt-get update && apt-get -y upgrade && apt-get -y install \
  curl ssh python3-pip git vim cmake libeigen3-dev\
  && rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo 'root:root' | chpasswd

# Permit SSH root login
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list


# Install catkin-tools
RUN apt-get update && apt-get install -y python3-catkin-tools tmux libtf2-ros-dev libsfml-dev\
  && rm -rf /var/lib/apt/lists/*

# Git requirements
# RUN apt-get install -y git-all
RUN git config --global user.name "Mattia Catellani"
RUN git config --global user.email "215802@studenti.unimore.it"
RUN git config --global color.ui true

# Create symlink for Eigen folder
RUN cd /usr/include ; ln -sf eigen3/Eigen Eigen

RUN apt update && apt install -y ros-noetic-tf2*


# Get packages for building
WORKDIR /catkin_ws
RUN mkdir src
RUN catkin config --extend /opt/ros/noetic && catkin build --no-status
RUN cd src/ ; git clone https://github.com/MatCat960/pf_coverage.git
RUN cd src/pf_coverage ; git checkout ros1-noetic ; git pull origin ros1-noetic
RUN cd src/ ; git clone https://github.com/MatCat960/particle_filter.git
RUN cd src/particle_filter ; git checkout ros1-noetic ; git pull origin ros1-noetic
RUN cd src/ ; git clone https://github.com/ARSControl/gaussian_mixture_model.git


# Build the workspace
RUN apt-get update \
  # && rosdep update \
  # && rosdep install --from-paths src -iy \
  && rm -rf /var/lib/apt/lists/*
  
# Automatically source the workspace when starting a bash session
RUN echo "source /catkin_ws/devel/setup.bash" >> /etc/bash.bashrc
RUN catkin config --extend /opt/ros/noetic && catkin build --no-status

RUN echo "--- build complete ---"


