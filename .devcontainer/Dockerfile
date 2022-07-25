ARG ROS_VERSION="noetic"
ARG LLVM_VERSION="14"

FROM ros:${ROS_VERSION} AS ros-ci

WORKDIR /root
COPY .devcontainer/build_script/install-llvm.sh \
  .devcontainer/build_script/install-mold.sh \
  .devcontainer/build_script/install-cmake.sh \
  .devcontainer/build_script/install-python.sh \
  ./

ARG ROS_VERSION
ARG LLVM_VERSION
ARG USE_CLANG

RUN chmod +x install-mold.sh install-llvm.sh install-cmake.sh install-python.sh
RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends git wget ccache lcov apt-transport-https && \
  ./install-cmake.sh && \
  rm -rf /usr/src/googletest && git clone https://github.com/google/googletest /usr/src/googletest

# mold require GLIBC_2.25, which is greater than that of ubuntu 16.04 (GLIBC_2.23)
RUN if [ "${ROS_VERSION}" != "kinetic" ]; then ./install-mold.sh; fi
RUN if [ "${ROS_VERSION}" = "kinetic" ]; then ./install-python.sh; else apt-get install -y --no-install-recommends python3-pip; fi
RUN if [ "${USE_CLANG}" = "1" ]; then ./install-llvm.sh ${LLVM_VERSION}; fi

RUN python3 -m pip install --upgrade pip && \
  python3 -m pip install gcovr catkin_tools

RUN mkdir -p /home/catkin_ws/src/ros_pkg_template && \
  . /opt/ros/${ROS_DISTRO}/setup.sh && \
  cd /home/catkin_ws && catkin init

RUN rm install-cmake.sh install-mold.sh

# if --build-arg USE_CLANG=1, set CC to 'clang' or set to null otherwise.
ENV CC=${USE_CLANG:+"clang"}
ENV CXX=${USE_CLANG:+"clang++"}
# if CC is null, set it to 'gcc' (or leave as is otherwise).
ENV CC=${CC:-"gcc"}
ENV CXX=${CXX:-"g++"}

# include the project
ADD . /home/catkin_ws/src/ros_pkg_template
WORKDIR /home/catkin_ws/src/ros_pkg_template
ENTRYPOINT [ "/ros_entrypoint.sh", "/bin/sh", "-c" ]

FROM ros-ci AS ros-dev

ARG LLVM_VERSION
ARG USE_IWYU=1
COPY .devcontainer/build_script/install-devtool.sh ./

RUN chmod +x install-devtool.sh
RUN ./install-devtool.sh ${LLVM_VERSION} ${USE_IWYU}

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends cppcheck

RUN python3 -m pip install --upgrade pip cmake-format
RUN apt-get autoremove -y && apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm install-llvm.sh install-devtool.sh install-python.sh